lang es_US.UTF-8
keyboard us
timezone America/Guatemala
selinux --enforcing
firewall --enabled --service=mdns
xconfig --startxonboot
zerombr
clearpart --all
part / --size 10240 --fstype ext4
services --enabled=NetworkManager,ModemManager --disabled=sshd
network --bootproto=dhcp --device=link --activate
rootpw --lock --iscrypted locked
shutdown

repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
#repo --name=updates-testing --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-testing-f$releasever&arch=$basearch
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=rpmfusion-free --mirrorlist=https://mirrors.rpmfusion.org/metalink?repo=free-fedora-$releasever&arch=$basearch
repo --name=rpmfusion-nonfree --mirrorlist=https://mirrors.rpmfusion.org/metalink?repo=nonfree-fedora-$releasever&arch=$basearch

%packages --excludeWeakdeps
# Explicitly specified here:
# <notting> walters: because otherwise dependency loops cause yum issues.
kernel
kernel-modules
kernel-modules-extra

# The point of a live image is to install
anaconda
anaconda-install-env-deps
anaconda-live
@anaconda-tools
-fcoe-utils
-device-mapper-multipath
-sdubby
aajohan-comfortaa-fonts
dracut-live
glibc-all-langpacks
livesys-scripts
-@dial-up
-@input-methods
-@standard
@^workstation-product-environment

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
# Exclude unwanted packages from @anaconda-tools group
-gfs2-utils
-reiserfs-utils
%end

%post
# Enable livesys services
systemctl enable livesys.service
systemctl enable livesys-late.service

# enable tmpfs for /tmp
systemctl enable tmp.mount

# make it so that we don't do writing to the overlay for things which
# are just tmpdirs/caches
# note https://bugzilla.redhat.com/show_bug.cgi?id=1135475
cat >> /etc/fstab << EOF
vartmp   /var/tmp    tmpfs   defaults   0  0
EOF

# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
echo "Packages within this LiveCD"
rpm -qa --qf '%{size}\t%{name}-%{version}-%{release}.%{arch}\n' |sort -rn
# Note that running rpm recreates the rpm db files which aren't needed or wanted
rm -f /var/lib/rpm/__db*

# go ahead and pre-make the man -k cache (#455968)
/usr/bin/mandb

# make sure there aren't core files lying around
rm -f /core*

# remove random seed, the newly installed instance should make it's own
rm -f /var/lib/systemd/random-seed

# convince readahead not to collect
# FIXME: for systemd

echo 'File created by kickstart. See systemd-update-done.service(8).' \
    | tee /etc/.updated >/var/.updated

# Drop the rescue kernel and initramfs, we don't need them on the live media itself.
# See bug 1317709
rm -f /boot/*-rescue*

# Disable network service here, as doing it in the services line
# fails due to RHBZ #1369794
systemctl disable network

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id

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

