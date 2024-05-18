#!/usr/bin/env bash

cat >>/etc/rc.d/init.d/livesys <<EOF


# disable gnome-software automatically downloading updates
cat >> /usr/share/glib-2.0/schemas/org.gnome.software.gschema.override << FOE
[org.gnome.software]
download-updates=false
FOE

# don't autostart gnome-software session service
rm -f /etc/xdg/autostart/gnome-software-service.desktop

# don't run gnome-initial-setup
mkdir ~liveuser/.config
touch ~liveuser/.config/gnome-initial-setup-done

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
  sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop ""
  # need to move it to anaconda.desktop to make shell happy
  mv /usr/share/applications/liveinst.desktop /usr/share/applications/anaconda.desktop

# make the installer show up
if [ -f /usr/share/applications/liveinst.desktop ]; then
	# Show harddisk install in shell dash
	sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop ""
	# need to move it to anaconda.desktop to make shell happy
	mv /usr/share/applications/liveinst.desktop /usr/share/applications/anaconda.desktop

	cat >/usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override <<FOE
[org.gnome.shell]
favorite-apps=['firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'anaconda.desktop']
enabled-extensions=['caffeine@patapon.info', 'appindicatorsupport@rgcjonas.gmail.com', 'user-theme@gnome-shell-extensions.gcampax.github.com', 'pop-shell@system76.com', 'Vitals@CoreCoding.com', 'Bluetooth-Battery-Meter@maniacx.github.com', 'just-perfection-desktop@just-perfection', 'dash-to-dock@micxgx.gmail.com', 'blur-my-shell@aunetx' ]
FOE

	# Make the welcome screen show up
	if [ -f /usr/share/anaconda/gnome/fedora-welcome.desktop ]; then
		mkdir -p ~liveuser/.config/autostart
		cp /usr/share/anaconda/gnome/fedora-welcome.desktop /usr/share/applications/
		cp /usr/share/anaconda/gnome/fedora-welcome.desktop ~liveuser/.config/autostart/
	fi

	# Disable GNOME welcome tour so it doesn't overlap with Fedora welcome screen
	cat >>/usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override <<FOE
welcome-dialog-last-shown-version='4294967295'
FOE

	# Make the welcome screen show up
	if [ -f /usr/share/anaconda/gnome/fedora-welcome.desktop ]; then
		mkdir -p ~liveuser/.config/autostart
		cp /usr/share/anaconda/gnome/fedora-welcome.desktop /usr/share/applications/
		cp /usr/share/anaconda/gnome/fedora-welcome.desktop ~liveuser/.config/autostart/
	fi

	# Disable GNOME welcome tour so it doesn't overlap with Fedora welcome screen
	cat >>/usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override <<FOE
welcome-dialog-last-shown-version='4294967295'
FOE

	# Copy Anaconda branding in place
	if [ -d /usr/share/lorax/product/usr/share/anaconda ]; then
		cp -a /usr/share/lorax/product/* /
	fi
fi

# rebuild schema cache with any overrides we installed
glib-compile-schemas /usr/share/glib-2.0/schemas

# set up auto-login
cat > /etc/gdm/custom.conf << FOE
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=liveuser
FOE

# Turn off PackageKit-command-not-found while uninstalled
if [ -f /etc/PackageKit/CommandNotFound.conf ]; then
  sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf
fi

# make sure to set the right permissions and selinux contexts
chown -R liveuser:liveuser /home/liveuser/
restorecon -R /home/liveuser/

timedatectl set-local-rtc 1

# DNF flags
echo 'fastestmirror=1' |  tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' |  tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' |  tee -a /etc/dnf/dnf.conf

mkdir -p /btrfs_pool/_btrbk_snap

sed -i 's/compress=zstd:1/ssd,noatime,space_cache=v2,commit=120,compress=zstd:1,discard=async/' /etc/fstab
sed -i 's/daily/hourly/g' /lib/systemd/system/btrbk.timer
systemctl enable fstrim.timer


cat > /etc/btrbk/btrbk.conf <<FOE
transaction_log         /var/log/btrbk.log
lockfile                /var/lock/btrbk.lock
timestamp_format        long

snapshot_dir            _btrbk_snap
snapshot_preserve_min   3h
snapshot_preserve       6h 5d 3w 1m

volume /btrfs_pool
    snapshot_create  always
    subvolume root
    subvolume home
FOE

EOF
