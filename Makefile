_top:
	$(eval image := $(shell sudo docker build -q -f docker/Dockerfile docker))
	$(eval MAKEFLAGS_FILTERED := $(shell echo $(MAKEFLAGS) | xargs -d" " -I{} echo '{}' | grep -v '\--jobserver-auth' | xargs))
	$(eval MFLAGS_FILTERED := $(shell echo $(MFLAGS) | xargs -d" " -I{} echo '{}' | grep -v '\--jobserver-auth' | xargs))
	sudo docker run --init --rm $$(if [ -t 0 ] ; then echo "-it"; fi) \
		-v $$(realpath .):/work \
		-w /work \
		-u "$$(id -u):$$(id -g)" \
		-e "MAKEFLAGS=$(MAKEFLAGS_FILTERED)" \
		-e "MFLAGS=$(MFLAGS_FILTERED)" \
		"$(image)" \
			make -f inner.mk $(MAKECMDGOALS)

$(MAKECMDGOALS): _top
	@:

.PHONY: _top
