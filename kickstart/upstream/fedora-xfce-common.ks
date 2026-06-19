# Kickstart proprio do CapivaraOS Pup (nao vendorizado do fedora-kickstarts:
# o spin-kickstarts upstream para Xfce esta desatualizado/inativo desde a
# migracao para kiwi e usa mecanismos de livesys anteriores ao systemd ja
# vendorizados em fedora-live-base.ks). Os grupos/ambiente comps abaixo foram
# conferidos diretamente no comps.xml do Fedora 44 (repos fedora+updates)
# nesta maquina de build via "dnf group info xfce-desktop-environment" e
# inspecao do comps-Everything.xml.
#
# NOTA CapivaraOS: fedora-release-xfce so depende de fedora-release-common
# (nao tem arquivos proprios de wallpaper/tema) -- diferente do caso KDE
# (fedora-release-kde-desktop). Quem traz o wallpaper padrao do Fedora para
# o Xfce e o pacote "desktop-backgrounds-compat". DIFERENTE do que a Marsh
# faz com "-fedora-release-kde-desktop", NAO excluimos esse pacote aqui: ele
# e Requires obrigatorio de "xfdesktop" e de "lightdm-gtk" (confirmado em
# build real -- excluir causa "nenhum dos provedores pode ser instalado" e
# aborta o anaconda). Deixamos o desktop-backgrounds-compat instalar
# normalmente (só os wallpapers padrão do Fedora, poucos MB) e sobrescrevemos
# qual wallpaper fica ATIVO via capivaraos-branding (skel do xfconf +
# lightdm-gtk-greeter.conf), sem remover o pacote do Fedora.

%packages
# install env-group to resolve RhBug:1891500
@^xfce-desktop-environment

# Grupos opcionais do ambiente Xfce. Mantemos apenas o essencial para um
# spin leve (4GB RAM): apps padrao do Xfce (Thunar, xfce4-terminal,
# Mousepad, Ristretto, Geany, GParted, Claws Mail -- ja mais leve que
# Thunderbird), midia (Parole, Asunder, Pavucontrol) e o office minimo do
# Xfce (LibreOffice Calc + Writer, sem Impress/Draw/Base). Deixamos de fora
# @xfce-extra-plugins (plugins de painel pouco usados: sensores, clima,
# olhinhos animados etc. -- nao essenciais e VARIOS sao supérfluos para uma
# instalacao leve).
@xfce-apps
@xfce-media
@xfce-office

fedora-release-xfce
wget
system-config-printer
cups

# save some space (equivalente ao -desktop-backgrounds-basic do
# fedora-livecd-xfce.ks original, atualizado para o pacote atual)
-autofs
-acpid
-gimp-help
-aspell-*
-pidgin
-transmission
-claws-mail-plugins-archive
-claws-mail-plugins-att-remover
-claws-mail-plugins-attachwarner
-claws-mail-plugins-fetchinfo
-claws-mail-plugins-mailmbox
-claws-mail-plugins-newmail
-claws-mail-plugins-notification
-claws-mail-plugins-pgp
-claws-mail-plugins-rssyl
-claws-mail-plugins-smime
-claws-mail-plugins-spam-report
-claws-mail-plugins-tnef
-claws-mail-plugins-vcalendar

%end
