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

%packages --exclude-weakdeps
starship
system76-scheduler
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
clamav
clamav-update
clamd
cmake
cronie
fd-find
firewall-config
fzf
gedit
git-delta
git-lfs
glib2-devel
gnome-firmware
gnome-shell-extension-appindicator
gnome-shell-extension-caffeine
gnome-shell-extension-just-perfection
gnome-shell-extension-forge
gnome-shell-extension-pop-shell
gnome-shell-extension-user-theme
gnome-tweaks
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
setroubleshoot-server
trash-cli
vdpauinfo
w3m-img
wget
xarchiver
zlib-devel
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
-gnome-classic-session
-gnome-characters
-gnome-font-viewer
-gnome-shell-extension-launch-new-instance
-gnome-photos
-gnome-shell-extension-window-list
-braille-printer-app
-gnome-classic-session
-gnome-classic-session-xsession
%end

%post

# set livesys session type
sed -i 's/^livesys_session=.*/livesys_session="gnome"/' /etc/sysconfig/livesys

sed -i 's/compress=zstd:1/ssd,noatime,space_cache=v2,commit=120,compress=zstd:1,discard=async/' /etc/fstab
sed -i 's/daily/hourly/g' /lib/systemd/system/btrbk.timer
systemctl enable fstrim.timer
#services --enabled=btrbk


# DNF flags
echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf


%end


