#!/bin/bash
# =============================================================================
# Regera os wallpapers de fotos de capivaras COM FILHOTES
# (capivaraos-desktop-foto-*.png) — CapivaraOS Pup
# =============================================================================
#
# As fotos originais NÃO ficam no repositório (apenas as versões finais com
# logo/crédito embutidos). Este script baixa de novo as fotos do Wikimedia
# Commons (CC BY/CC BY-SA), recorta para 1920x1080, sobrepõe a logo branca do
# CapivaraOS no canto inferior direito e um crédito de autoria PEQUENO no
# canto inferior esquerdo, posicionado ACIMA da altura do painel inferior do
# Xfce (para não ficar escondido por ele).
#
# A atribuição (exigida pelas licenças CC) é mantida, só ficou pequena e
# discreta. Ver backgrounds/CREDITOS.txt para a lista de fontes e licenças.
#
# Requer: curl, ImageMagick (convert/magick), python3. Precisa de acesso à
# rede. Uso: ./regen-photo-wallpapers.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BG="${SCRIPT_DIR}/backgrounds"
UA="CapivaraOS-build/1.0 (https://capivaraos.org)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

CONVERT=convert
command -v convert >/dev/null 2>&1 || CONVERT=magick

# ── Logo branca para o canto inferior direito ───────────────────────────────
"$CONVERT" "${BG}/CapivaraOS_Logo.png" -fill white -colorize 100% \
    -resize 220x "${TMP}/logo-branca.png"

# Faz o download de uma imagem do Wikimedia Commons pelo nome do arquivo.
baixar() {
    local nome="$1" destino="$2"
    local url
    url="$(python3 -c "import urllib.parse,sys; print('https://commons.wikimedia.org/wiki/Special:FilePath/'+urllib.parse.quote(sys.argv[1]))" "$nome")"
    echo "  baixando: $nome"
    curl -fsSL -A "$UA" -o "$destino" "$url"
}

# Gera um wallpaper final a partir da foto original.
#   $1 = arquivo original   $2 = saída (.png)   $3 = crédito (texto)
#
# ZONA SEGURA — por que a logo e o crédito ficam a 250px das laterais, e não
# nos 40/24px que seriam o natural para um canto.
#
# O wallpaper é 16:9 (1920x1080). Numa tela 4:3 exibida em "Ampliado"/zoom, o
# xfdesktop escala pela altura e corta a largura que sobra: 1920 - (1080*4/3)
# = 480px, ou seja 240px de CADA lado. Tudo que estiver a menos de 240px da
# borda lateral simplesmente não existe nessa tela.
#
# Com os 40/24px antigos, logo e crédito caíam inteiros dentro da faixa
# cortada — confirmado em VM 4:3 em 2026-07-21, onde o crédito aparecia como
# "...ann — CC BY-SA 4.0". Isso é mais que estética: as fotos são CC BY-SA e
# a licença EXIGE atribuição, então um crédito cortado é um problema de
# licenciamento, não de layout.
#
# 250px dá 10px de folga sobre os 240 necessários. O estilo padrão da spin é
# "Esticado" (não corta nada), mas o usuário pode trocar pelo seletor a
# qualquer momento — a zona segura protege independente do estilo escolhido.
gerar() {
    local orig="$1" saida="$2" credito="$3"
    "$CONVERT" "$orig" \
        -resize 1920x1080^ -gravity center -extent 1920x1080 \
        "${TMP}/logo-branca.png" -gravity southeast -geometry +250+45 -composite \
        -gravity southwest -font Liberation-Sans -pointsize 22 \
        -undercolor '#00000066' -fill white \
        -annotate +250+104 "  ${credito}  " \
        "$saida"
    echo "  gerado: $(basename "$saida")"
}

# nome no Wikimedia | saída | crédito
declare -a FOTOS=(
"Capivaras e seus filhotes.jpg|capivaraos-desktop-foto-familia.png|Foto: Alexandra Palitoz — CC BY-SA 4.0"
"Filhotes de capivara.jpg|capivaraos-desktop-foto-filhotes.png|Foto: Valquiria A. Ferreira — CC BY-SA 4.0"
"Nossa Brasília - Capivara e filhote (33859267416).jpg|capivaraos-desktop-foto-brasilia.png|Foto: Renato Araújo/Agência Brasília — CC BY 2.0"
"Capivaras no Rio Sorocaba.JPG|capivaraos-desktop-foto-sorocaba.png|Foto: P.H. Messias — CC BY-SA 3.0"
"La carpinchada.JPG|capivaraos-desktop-foto-carpinchada.png|Foto: Miguel A. Germann — CC BY-SA 4.0"
"O Amamento do filhote de Capivara.JPG|capivaraos-desktop-foto-amamentacao.png|Foto: Julie Ribeiro da Silva — CC BY-SA 3.0"
)

for entrada in "${FOTOS[@]}"; do
    IFS='|' read -r nome saida credito <<< "$entrada"
    echo "== ${saida} =="
    baixar "$nome" "${TMP}/orig.jpg"
    gerar "${TMP}/orig.jpg" "${BG}/${saida}" "$credito"
done

echo
echo "Concluído. 6 wallpapers regenerados em ${BG}/"
