# CapivaraOS Pup — Fedora 44 (Xfce)

Spin leve do **CapivaraOS**, baseada no ambiente **Xfce** oficial do
Fedora, pensada para computadores com **ao menos 4GB de RAM**. Usa as
mesmas ferramentas oficiais do projeto Fedora que a spin KDE do
CapivaraOS Marsh (`../capivaraos-marsh-fedora/`, usada aqui como
referência de estrutura): `kickstart` + `livemedia-creator` (lorax) para a
imagem, e **Anaconda** como instalador.

## Estrutura do projeto

```
capivaraos-pup/
├── PACKAGES.md                  # Seleção de pacotes (grupos comps do Xfce, exclusões)
├── README.md                    # Este arquivo
├── build-all.sh                 # Automatiza todos os passos abaixo
├── branding/                    # Assets de identidade visual (fonte para o RPM)
│   ├── backgrounds/              # Wallpapers + CREDITOS.txt (CC BY/CC BY-SA)
│   ├── icons/                    # Logos do CapivaraOS (compartilhados com a Marsh)
│   ├── skel/.config/             # Wallpaper padrão do Xfce (xfconf)
│   └── regen-photo-wallpapers.sh # Regera os wallpapers fotográficos
├── kickstart/
│   ├── capivaraos-pup.ks         # Kickstart principal (ponto de entrada)
│   ├── capivaraos-post-branding.ks  # %post: idioma/atalho de instalação
│   ├── ks-flatten.py             # Achata os %include num único arquivo
│   └── upstream/                 # Kickstarts base do Fedora Live (vendorizados/escritos)
│       ├── fedora-repo.ks
│       ├── fedora-live-base.ks
│       ├── fedora-xfce-common.ks
│       └── fedora-live-xfce-base.ks
└── rpm/
    ├── capivaraos-branding.spec  # Pacote RPM com toda a identidade visual
    └── build-rpm.sh               # Script auxiliar para gerar o RPM
```

## Visão geral da identidade visual

Todo o branding estático (wallpapers, ícones "Sobre o Sistema", tema de
boot Plymouth, fundo da tela de login LightDM, `/etc/os-release`,
`/etc/issue`, avatar padrão, wallpaper padrão do Xfce) é empacotado num
único RPM, **`capivaraos-branding`** (ver `rpm/capivaraos-branding.spec`),
que substitui o wallpaper padrão (`desktop-backgrounds-compat`) do Fedora
Xfce.

Diferente da spin KDE (CapivaraOS Marsh, que aplica o tema WhiteSur/macOS
de terceiros), o Pup **mantém o tema Greybird/Xfwm4 padrão do Fedora
Xfce** — decisão deliberada para manter a spin leve, rápida de buildar e
sem dependência de `git clone` de temas externos durante o build. A
personalização do Pup foca em: wallpapers, tela de boot, tela de login,
ícones e identificação do sistema (`os-release`).

### Wallpapers

- 7 planos de fundo de **cor sólida com a logo do CapivaraOS no centro**
  (azul, verde, roxo, preto, e variantes com logo branca), reaproveitados da
  spin Marsh — mesma identidade visual em todas as spins do CapivaraOS.
  **Importante**: foram reconvertidos para PNG 8-bit/canal (os arquivos da
  Marsh são 16-bit/canal). O `xfdesktop` (Xfce) falha silenciosamente ao
  carregar PNG 16-bit — mantém a última imagem válida na tela sem nenhum
  erro visível — enquanto o Plasma (KDE, usado na Marsh) tolera o formato.
  Confirmado em teste real (GNOME Boxes/QXL). Se algum desses arquivos for
  resincronizado a partir da Marsh no futuro, reconverta com
  `magick arquivo.png -depth 8 arquivo.png` antes de usar nesta spin.
- 6 planos de fundo **fotográficos de capivaras com filhotes na
  natureza**, obtidos no Wikimedia Commons sob licenças livres (CC BY 2.0
  / CC BY-SA 3.0 / CC BY-SA 4.0), com a logo do CapivaraOS aplicada no
  canto inferior direito e o crédito do autor no canto inferior esquerdo.
  Ver `branding/backgrounds/CREDITOS.txt` para a lista completa de fontes,
  autores e licenças (verificadas via API do Wikimedia Commons,
  `AttributionRequired=true` para todas).

Para regenerar os wallpapers fotográficos a partir das fotos originais:

```bash
cd branding
./regen-photo-wallpapers.sh
```

## Pré-requisitos (máquina de build, Fedora 44 x86_64)

```bash
sudo dnf install -y lorax rpm-build ImageMagick git createrepo_c
```

- `lorax` fornece o `livemedia-creator`.
- `rpm-build` + `ImageMagick` são necessários para gerar o RPM
  `capivaraos-branding`.
- `createrepo_c` é usado para o repositório local do RPM.
- O build precisa de acesso à rede (pacotes do Fedora).
- `livemedia-creator --no-virt` precisa rodar como root (usa
  `dnf --installroot` e monta `/dev`, `/proc` etc. no diretório de
  instalação).

## Build rápido

```bash
./build-all.sh
```

Isso gera o RPM de branding, monta o repositório local em
`/var/tmp/capivaraos-pup-repo` e constrói a ISO com `livemedia-creator`,
deixando o resultado em `/var/tmp/capivaraos-pup-result/`.

## Build passo a passo

### Passo 1 — Construir o RPM `capivaraos-branding`

```bash
cd rpm
./build-rpm.sh
```

Gera `~/rpmbuild/RPMS/noarch/capivaraos-branding-1.1.1-1.*.noarch.rpm`.

### Passo 2 — Disponibilizar o RPM como repositório local

```bash
mkdir -p /var/tmp/capivaraos-pup-repo
cp ~/rpmbuild/RPMS/noarch/capivaraos-branding-*.rpm /var/tmp/capivaraos-pup-repo/
createrepo_c /var/tmp/capivaraos-pup-repo
```

(`kickstart/capivaraos-pup.ks` já referencia esse caminho via
`repo --name=capivaraos-local --baseurl=file:///var/tmp/capivaraos-pup-repo`.)

### Passo 3 — Gerar a ISO com `livemedia-creator`

```bash
cd kickstart
python3 ks-flatten.py capivaraos-pup.ks > /var/tmp/capivaraos-pup-flat.ks

sudo livemedia-creator --ks=/var/tmp/capivaraos-pup-flat.ks \
    --no-virt --resultdir=/var/tmp/capivaraos-pup-result \
    --project="CapivaraOS Pup" --make-iso --iso-only \
    --iso-name=CapivaraOS-Pup-1.1.1-x86_64.iso \
    --volid="CapivaraOS Pup 1.1.1" --variant="CapivaraOS Pup" \
    --releasever=44
```

A ISO final fica em
`/var/tmp/capivaraos-pup-result/CapivaraOS-Pup-1.1.1-x86_64.iso`.

## Testando a ISO

```bash
qemu-system-x86_64 -m 4096 -enable-kvm \
    -cdrom /var/tmp/capivaraos-pup-result/CapivaraOS-Pup-1.1.1-x86_64.iso
```

(`-m 4096` simula o requisito mínimo de 4GB RAM da spin.)

## Limitações conhecidas

- **RPM Fusion não está habilitado** (mesma postura do CapivaraOS Marsh):
  o VLC incluso roda com suporte de codecs reduzido.
- **Tema padrão do Xfce (Greybird)**: ao contrário da Marsh, o Pup não
  replica o layout/tema macOS-WhiteSur — ver `PACKAGES.md` e a seção
  "Visão geral da identidade visual" para o racional.

## Ver também

- `../capivaraos-marsh-fedora/` — spin KDE Plasma do CapivaraOS (tema
  WhiteSur/macOS), referência de estrutura usada para este projeto.
- `PACKAGES.md` — racional completo da seleção de pacotes desta spin.

## Comunidade

- Encontrou um bug ou tem uma sugestão? Abra uma [issue](../../issues/new/choose).
- Dúvidas gerais ou ideias em aberto? Use as [Discussions](../../discussions).
- Vulnerabilidade de segurança? Veja [`SECURITY.md`](SECURITY.md) — não abra issue pública.
- Quer contribuir com código? Veja [`CONTRIBUTING.md`](CONTRIBUTING.md).
- Este projeto segue o [Código de Conduta](CODE_OF_CONDUCT.md) do CapivaraOS.
- Licenciado sob [GPLv3](LICENSE).
