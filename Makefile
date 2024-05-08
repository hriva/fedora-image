stable:
	ksflatten -c alchemist-layer-live.ks -o flat/alchemist-live-flat.ks; \
	livecd-creator --verbose \
	--config=flat/alchemist-live-flat.ks \
	--fslabel=alchemist-CD --releasever 40 --cache=/var/tmp/imgcreate-9ae7picx

devel:

