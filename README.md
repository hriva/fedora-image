# INSTALL

## Install mock for chroot environment.
```sh
sudo dnf install mock
usermod -a -G mock "$(whoami)"

# Clone repository
git clone https://github.com/hriva/fedora-image.git
cd fedora-image
```
You can check available mock environment configs in  `/etc/mock/`

## Prepare mock environment.

```sh
mock -r fedora-40-x86_64 --init
mock -r fedora-40-x86_64 --install lorax-lmc-novirt vim-minimal pykickstart livecd-tools
sudo setenforce 0
```
This will create a new root with a builddir at `/var/lib/mock/<mock-config>/root/builddir/`. So you can move ks files here prior to beginning.

### Copy the flattened file to the chroot directory.
```sh
cp flats/alchemist-live-flat.ks /var/lib/mock/fedora-40-x86_64/root/builddir/
```

## Enter mock environment

```sh
mock -r fedora-40-x86_64 --shell --enable-network --isolation=simple
```

### From within the chroot, run:
```sh
#<mock-chroot> sh-5.2#
livemedia-creator --ks alchemist-live-flat.ks --no-virt --resultdir /var/lmc --project Fedora-Live --make-iso --volid Fedora --iso-only --iso-name Fedora-40-x86_64.iso --releasever 40 --macboot
```

After the iso is produced. Exit the mock environment and move the resulting iso to the repository directory.
```sh
cp /var/lib/mock/fedora-40-x86_64/root/var/lmc/*.iso .
sudo setenforce 1
```

### Optionally clean the mock environment.
```sh
mock -r fedora-40-x86_64 --clean
```
