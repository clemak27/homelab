PODMAN := /usr/bin/flatpak-spawn --host podman

.PHONY: igition
igition:
	$(PODMAN) run --interactive --rm --security-opt label=disable \
       --volume ${PWD}:/pwd --workdir /pwd quay.io/coreos/butane:release \
       --pretty --strict test.bu > test.ign

.PHONY: serve
serve:
	$(PODMAN) run --interactive --rm --security-opt label=disable \
		-p 8000:8000 -v ${PWD}:/data --workdir /data -it --rm python \
		python3 -m http.server 8000

default: igition
