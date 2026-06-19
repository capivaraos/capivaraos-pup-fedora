# Kickstart proprio do CapivaraOS Pup (ver nota em fedora-xfce-common.ks
# sobre por que nao vendorizamos o fedora-livecd-xfce.ks original do
# spin-kickstarts -- esta versao usa o mecanismo de livesys-scripts
# systemd atual, ja vendorizado em fedora-live-base.ks, em vez do antigo
# /etc/rc.d/init.d/livesys).

%include upstream/fedora-live-base.ks
%include upstream/fedora-xfce-common.ks

%post

# set default GTK+ theme for root (mesmo padrao do fedora-live-kde-base.ks,
# adaptado: Adwaita ja vem com o GTK, nao precisa de pacote extra)
cat > /root/.gtkrc-2.0 << EOF
include "/usr/share/themes/Adwaita/gtk-2.0/gtkrc"
include "/etc/gtk-2.0/gtkrc"
gtk-theme-name="Adwaita"
EOF
mkdir -p /root/.config/gtk-3.0
cat > /root/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name = Adwaita
EOF

# set livesys session type
sed -i 's/^livesys_session=.*/livesys_session="xfce"/' /etc/sysconfig/livesys

%end
