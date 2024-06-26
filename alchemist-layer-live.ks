# Maintained by the Fedora Workstation WG:
# http://fedoraproject.org/wiki/Workstation
# mailto:desktop@lists.fedoraproject.org
%include fedora-live-base.ks
%include fedora-workstation-common.ks
# Disable this for now as packagekit is causing compose failures
# by leaving a gpg-agent around holding /dev/null open.
#
#include snippets/packagekit-cached-metadata.ks

part / --size 10240 --fstype ext4

services --enabled="NetworkManager,ModemManager,akmods"

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
gnome-shell-extension-caffeine
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
ffmpeg
gstreamer1-plugin-libav
gstreamer1-plugins-bad-free-extras
gstreamer1-plugins-bad-freeworld
gstreamer1-plugins-ugly
gstreamer1-vaapi
rpmfusion-nonfree-release-tainted
%end

%post

# set livesys session type
sed -i 's/^livesys_session=.*/livesys_session="gnome"/' /etc/sysconfig/livesys
%end
