stable: make-cache
	ksflatten -c alchemist-layer-live.ks -o flat/alchemist-live-flat.ks
	sudo livecd-creator --verbose \
	--config=flat/alchemist-live-flat.ks \
	--fslabel=alchemist-CD --releasever 40 --cache=/var/tmp/imgcreate-cache/

devel: make-cache

make-cache:
	mkdir -p /var/tmp/imgcreate-cache/ 2> /dev/null
