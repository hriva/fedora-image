# INSTALL
## Install deps
```sh
sudo dnf install pykickstart
```
```sh
git clone

ksflatten -c alchemist-live-workstation.ks -o alchemist-live-flat.ks
mkdir /var/tmp/cache
sudo livecd-creator --verbose \\
--config=alchemist-live-flat.ks \\
--fslabel=alchemist-LiveCD --releasever 40 --cache=/var/tmp/cache
```
