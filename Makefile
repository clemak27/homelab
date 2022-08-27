PODMAN := /usr/bin/flatpak-spawn --host podman
FCOS_VERSION := 36.20220806.3.0

ignition: test.bu
	$(PODMAN) run --interactive --rm --security-opt label=disable \
		--volume ${PWD}:/pwd --workdir /pwd quay.io/coreos/butane:release \
		--pretty --strict test.bu > test.ign

serve: ignition
	$(PODMAN) run --interactive --rm --security-opt label=disable \
		-p 8000:8000 -v ${PWD}:/data --workdir /data -it --rm python \
		python3 -m http.server 8000

create_iso/vm: get_fcos_iso ignition
	rm custom.iso
	$(PODMAN) run --interactive --rm --security-opt label=disable \
		--volume ${PWD}:/pwd --workdir /pwd quay.io/coreos/coreos-installer:release \
		iso customize \
		--dest-device /dev/vda \
		--dest-ignition test.ign \
		-o custom.iso fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso


.PHONY: get_fcos_iso
get_fcos_iso:
	curl -O --url https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$(FCOS_VERSION)/x86_64/fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso -C -

.PHONY: clean
clean:
	rm test.ign
	rm fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso
	rm custom.iso

default: ignition
