# Maintained by the Fedora Workstation WG:
# http://fedoraproject.org/wiki/Workstation
# mailto:desktop@lists.fedoraproject.org
# Disable this for now as packagekit is causing compose failures
# by leaving a gpg-agent around holding /dev/null open.
#
#include snippets/packagekit-cached-metadata.ks

part / --size 10240 --fstype ext4

# Include the appropriate repo definitions
repo --name=rpmfusion-free --mirrorlist=https://mirrors.rpmfusion.org/metalink?repo=free-fedora-$releasever&arch=$basearch --install
repo --name=rpmfusion-nonfree --mirrorlist=https://mirrors.rpmfusion.org/metalink?repo=nonfree-fedora-$releasever&arch=$basearch --install
repo --name=starship --baseurl=https://download.copr.fedorainfracloud.org/results/atim/starship/fedora-$releasever-$basearch/ --install
repo --name=system76-scheduler --baseurl=https://download.copr.fedorainfracloud.org/results/kylegospo/system76-scheduler/fedora-$releasever-$basearch/ --install
repo --name=asus-linux --baseurl=https://download.copr.fedorainfracloud.org/results/lukenukem/asus-linux/fedora-$releasever-$basearch/ --install
repo --name=Brave-browser --baseurl=https://brave-browser-rpm-release.s3.brave.com/$basearch --install

%packages --exclude-weakdeps
brave-browser
asusctl
asusctl-rog-gui
starship
system76-scheduler
supergfxctl
gnome-initial-setup
alacritty
adw-gtk3-theme
alacritty
autoconf
bash-doc
bat
btrbk
bzip2-devel
chkrootkit
dconf-editor
dnf-plugin-versionlock
dnf-utils
duf
eza
gnome-tweaks
git-crypt
git-gui
cmake
cronie
fd-find
firewall-config
fzf
gedit
git-delta
git-lfs
gnome-firmware
gnome-shell-extension-appindicator
gnome-shell-extension-blur-my-shell
gnome-shell-extension-caffeine
gnome-shell-extension-dash-to-dock
gnome-shell-extension-just-perfection
gnome-shell-extension-forge
gnome-shell-extension-pop-shell
gnome-shell-extension-pop-shell-shortcut-overrides
gnome-shell-extension-user-theme
gnome-extensions-app
gnome-tweaks
gparted
gstreamer1-plugin-libav
gstreamer1-vaapi
gstreamer1-vaapi
htop
jq
libffi-devel
libva
libva-utils
make
ncdu
neovim
nvidia-vaapi-driver
nvtop
onedrive
openssl-devel
pdfgrep
powertop
profile-sync-daemon
ranger
ripgrep
rkhunter
sassc
seahorse
trash-cli
vdpauinfo
w3m-img
wget
xarchiver
zoxide
zsh
akmod-nvidia
xorg-x11-drv-nvidia-cuda
xorg-x11-drv-nvidia-cuda-libs
vdpauinfo
libva-utils
vulkan
#ffmpeg
gstreamer1-plugin-libav
#gstreamer1-plugins-bad-free-extras
#gstreamer1-plugins-bad-freeworld
gstreamer1-plugins-ugly
gstreamer1-vaapi
rpmfusion-nonfree-release-tainted
-vim-enhanced
-gnome-tour
%end


bootloader --append="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau"

%post --logfile=/root/ks-post.log --erroronfail
systemctl disable akmods

cat >> /usr/libexec/livesys/sessions.d/livesys-custom    << EOF
#!/bin/sh
#
# live-gnome: gnome-specific setup for livesys
# SPDX-License-Identifier: GPL-3.0-or-later
#

cmdline="$(cat /proc/cmdline)"

# disable gnome-software automatically downloading updates
cat >> /usr/share/glib-2.0/schemas/org.gnome.software.gschema.override << FOE
[org.gnome.software]
allow-updates=false
download-updates=false
FOE

# don't autostart gnome-software session service
rm -f /etc/xdg/autostart/org.gnome.Software.desktop

# disable the gnome-software shell search provider
cat >> /usr/share/gnome-shell/search-providers/org.gnome.Software-search-provider.ini << FOE
DefaultDisabled=true
FOE

if [ ! -d /var/lib/gnome-initial-setup ]; then
  # don't run gnome-initial-setup
  mkdir ~liveuser/.config
  : > ~liveuser/.config/gnome-initial-setup-done
fi

# suppress anaconda spokes redundant with gnome-initial-setup
cat >> /etc/sysconfig/anaconda << FOE
[NetworkSpoke]
visited=1

[PasswordSpoke]
visited=1

[UserSpoke]
visited=1
FOE

# make the installer show up
if [ -f /usr/share/applications/liveinst.desktop ]; then
  # Show harddisk install in shell dash
  sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop
  # need to move it to anaconda.desktop to make shell happy
  mv /usr/share/applications/liveinst.desktop /usr/share/applications/anaconda.desktop

  cat >> /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override << FOE
[org.gnome.shell]
favorite-apps=['brave-browser.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Software.desktop', 'org.gnome.Nautilus.desktop', 'anaconda.desktop']

# Set theme to adw-gtk3-dark
[org.gnome.desktop.interface]
gtk-theme='adw-gtk3-dark'

FOE

  if [ ! -d /var/lib/gnome-initial-setup ]; then
    # Make the welcome screen show up
    # The name was changed in March 2023 in Fedora 39, we can stop
    # caring about the old name (fedora-welcome.desktop) when F38 is
    # EOL
    for deskname in org.fedoraproject.welcome-screen.desktop fedora-welcome.desktop; do
      if [ -f /usr/share/anaconda/gnome/${deskname} ]; then
        mkdir -p ~liveuser/.config/autostart
        cp /usr/share/anaconda/gnome/${deskname} /usr/share/applications/
        cp /usr/share/anaconda/gnome/${deskname} ~liveuser/.config/autostart/
      fi
    done

    # Disable GNOME welcome tour so it doesn't overlap with Fedora welcome screen
    cat >> /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override <<- "    FOE"
	welcome-dialog-last-shown-version='4294967295'
    FOE
  fi

  # Copy Anaconda branding in place
  if [ -d /usr/share/lorax/product/usr/share/anaconda ]; then
    cp -a /usr/share/lorax/product/* /
  fi
fi

# rebuild schema cache with any overrides we installed
glib-compile-schemas /usr/share/glib-2.0/schemas

# set up auto-login if it's a non-persistent boot
if [ "${cmdline##* rd.live.overlay[= ]}" != "$cmdline"  -o ! -d /var/lib/gnome-initial-setup ]; then
  cat > /etc/gdm/custom.conf <<- "  FOE"
	[daemon]
	AutomaticLoginEnable=True
	AutomaticLogin=liveuser
  FOE
fi

# Turn off PackageKit-command-not-found while uninstalled
if [ -f /etc/PackageKit/CommandNotFound.conf ]; then
  sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf
fi

# Don't require authentication for starting the installer
cat > /usr/share/polkit-1/rules.d/20-livesys-gnome.rules << FOE
polkit.addRule(function(action, subject) {
    if (!subject.local)
        return undefined;
    if (subject.user !== 'liveuser')
        return undefined;
    if (action.id.indexOf('org.fedoraproject.pkexec.liveinst') !== 0)
        return undefined;
    return 'yes';
});
FOE
chmod 755 /usr/libexec/livesys/sessions.d/livesys-custom

%end

%include fedora-live-base.ks
%include fedora-workstation-common.ks
