stable: cache-dir
	ksflatten -c alchemist-layer-live.ks -o flat/alchemist-live-flat.ks
	sudo livecd-creator --verbose \
	--config=flat/alchemist-live-flat.ks \
	--plugins \
	--fslabel=alchemist-CD --releasever 40 --cache=/var/tmp/imgcreate-cache/

media: cache-dir
	ksflatten -c alchemist-layer-live.ks -o flat/alchemist-live-flat.ks
	sudo livemedia-creator --ks flat/alchemist-live-flat.ks \
	--disk-image base.iso \
	--resultdir /var/tmp/live-media \
	--project Fedora --make-iso --volid alchemist --iso-only \
	--releasever 40 --macboot

devel: cache-dir

cache-dir:
	mkdir -p /var/tmp/imgcreate-cache/ 2> /dev/null
