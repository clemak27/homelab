FCOS_VERSION := 36.20220806.3.0

PODMAN := /usr/bin/flatpak-spawn --host podman
PODMAN_RUN_PWD := $(PODMAN) run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd
BUTANE :=  $(PODMAN_RUN_PWD) quay.io/coreos/butane:release
COREOS_INSTALLER := $(PODMAN_RUN_PWD) quay.io/coreos/coreos-installer:release

hosts/user.bu:
	$(BUTANE) --pretty --strict hosts/user.bu -o hosts/user.ign

hosts/overlays.bu:
	$(BUTANE) --pretty --strict hosts/overlays.bu -o hosts/overlays.ign

hosts/i18n.bu:
	$(BUTANE) --pretty --strict hosts/i18n.bu -o hosts/i18n.ign

ignition: hosts/user.bu hosts/overlays.bu hosts/i18n.bu

ignition/vm: ignition
	$(BUTANE) --pretty --strict --files-dir /pwd hosts/virtual/spec.bu -o hosts/virtual/spec.ign

serve: ignition
	$(PODMAN) run --interactive --rm --security-opt label=disable \
		-p 8000:8000 -v ${PWD}:/data --workdir /data -it --rm python \
		python3 -m http.server 8000

create_iso/vm: get_fcos_iso ignition/vm
	rm custom.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/vda \
		--dest-ignition /pwd/hosts/virtual/spec.ign \
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
