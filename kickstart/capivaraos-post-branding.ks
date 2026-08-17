# =============================================================================
# CapivaraOS Pup — pós-instalação: ajustes finos de branding
# =============================================================================
#
# A maior parte do branding (wallpapers, ícones "Sobre o Sistema", tema
# Plymouth, fundo do LightDM, /etc/os-release, /etc/issue, avatar padrão,
# wallpaper padrão do Xfce) já é instalada pelo pacote `capivaraos-branding`
# (ver ../rpm/capivaraos-branding.spec). Este post-script cobre apenas o que
# não cabe num pacote RPM: regeneração da initramfs com o tema Plymouth,
# idioma de fallback e o atalho "Instalar CapivaraOS" na área de trabalho da
# sessão live.

%post
# ── Regera a initramfs com o tema Plymouth do CapivaraOS ────────────────────
# O kernel-core gera /boot/initramfs-*.img durante a transação de pacotes do
# dnf (no scriptlet do próprio kernel), que roda ANTES do %posttrans do
# pacote capivaraos-branding (que escreve /etc/plymouth/plymouthd.conf com
# Theme=capivaraos). Sem regenerar aqui, a initramfs da ISO live continua
# com o tema padrão do Plymouth. Este %post roda depois de toda a transação
# de pacotes, garantindo que o dracut leia o plymouthd.conf já atualizado.
#
# CRÍTICO (BUG-39): usar --no-hostonly (e --no-hostonly-cmdline). O padrao do
# dracut no Fedora e hostonly="yes" (/usr/lib/dracut/dracut.conf.d/01-dist.conf).
# Como este %post roda no build (livemedia-creator --no-virt enxerga o hardware
# da MAQUINA DE BUILD), sem estes flags o initramfs sai so com os drivers do
# build -> generico o bastante pra VM, mas FALTANDO drivers de hardware real
# (ex.: i915 valleyview, SoC/PMIC e storage de netbooks Bay Trail). Resultado:
# a imagem sobe na VM mas o hardware real mostra o Plymouth e DESLIGA (o live
# nem chega no instalador). Uma imagem distribuivel PRECISA de initramfs
# generico (hostonly=no), como faz a initramfs generica do proprio Fedora.
for kver in $(ls /lib/modules); do
    dracut -f --no-hostonly --no-hostonly-cmdline "/boot/initramfs-${kver}.img" "${kver}"
done

# ── Idioma: pt_BR com fallback para en_US ───────────────────────────────────
# A diretiva "lang pt_BR.UTF-8" do kickstart já grava LANG=pt_BR.UTF-8 em
# /etc/locale.conf; adicionamos LANGUAGE para que traduções ausentes em
# pt_BR caiam para en_US em vez de en_US "puro" sem fallback.
if [ -f /etc/locale.conf ]; then
    sed -i '/^LANGUAGE=/d' /etc/locale.conf
fi
echo 'LANGUAGE=pt_BR:en_US' >> /etc/locale.conf

# ── Ícone "Instalar CapivaraOS" — APENAS na sessão live ─────────────────────
# O instalador é fornecido pelo Anaconda live via
# /usr/share/applications/liveinst.desktop (NoDisplay=true). Em sessões
# live, o script livesys-xfce (pacote livesys-scripts,
# /usr/libexec/livesys/sessions.d/livesys-xfce) copia esse liveinst.desktop
# para a área de trabalho do usuário "liveuser" (e só lá — ele NÃO roda no
# sistema já instalado), define NoDisplay=false e marca como executável.
# Aqui apenas renomeamos/reidentificamos o liveinst.desktop com o nome e o
# ícone do CapivaraOS antes disso acontecer, mantendo NoDisplay=true (o
# livesys-xfce faz o sed para NoDisplay=false ao copiá-lo para a área de
# trabalho live).
if [ -f /usr/share/applications/liveinst.desktop ]; then
    sed -i \
        -e '/^Name\[/d' \
        -e '/^GenericName\[/d' \
        -e '/^Comment\[/d' \
        -e 's/^Name=.*/Name=Instalar CapivaraOS/' \
        -e 's/^GenericName=.*/GenericName=Instalar CapivaraOS/' \
        -e 's/^Comment=.*/Comment=Instala o CapivaraOS permanentemente no computador/' \
        -e 's#^Icon=.*#Icon=/usr/share/pixmaps/capivaraos-white.png#' \
        /usr/share/applications/liveinst.desktop
    grep -q '^Name=Instalar CapivaraOS' /usr/share/applications/liveinst.desktop || \
        echo 'Name=Instalar CapivaraOS' >> /usr/share/applications/liveinst.desktop
    grep -q '^Icon=/usr/share/pixmaps/capivaraos-white.png' /usr/share/applications/liveinst.desktop || \
        echo 'Icon=/usr/share/pixmaps/capivaraos-white.png' >> /usr/share/applications/liveinst.desktop
fi

%end
