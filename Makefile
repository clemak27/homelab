FCOS_VERSION := 36.20220806.3.0

PODMAN := /usr/bin/flatpak-spawn --host podman
PODMAN_RUN_PWD := $(PODMAN) run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd
BUTANE := $(PODMAN_RUN_PWD) quay.io/coreos/butane:release
COREOS_INSTALLER := $(PODMAN_RUN_PWD) quay.io/coreos/coreos-installer:release
SOPS_CMD := $(PODMAN_RUN_PWD) -e SOPS_AGE_KEY_FILE=/pwd/keys.txt nixery.dev/sops sops

hosts/user.bu:
	$(BUTANE) --pretty --strict hosts/user.bu -o hosts/user.ign

hosts/overlays.bu:
	$(BUTANE) --pretty --strict hosts/overlays.bu -o hosts/overlays.ign

hosts/i18n.bu:
	$(BUTANE) --pretty --strict hosts/i18n.bu -o hosts/i18n.ign

hosts/autoupdates.bu:
	$(BUTANE) --pretty --strict hosts/autoupdates.bu -o hosts/autoupdates.ign

hosts/wireguard.bu:
	$(SOPS_CMD) --decrypt hosts/wg0.enc.conf > hosts/wg0.conf
	$(BUTANE) --pretty --strict --files-dir /pwd/hosts hosts/wireguard.bu -o hosts/wireguard.ign
	rm hosts/wg0.conf

ignition: hosts/user.bu hosts/overlays.bu hosts/i18n.bu hosts/autoupdates.bu hosts/wireguard.bu

serve: ignition
	$(PODMAN) run --interactive --rm --security-opt label=disable \
		-p 8000:8000 -v ${PWD}:/data --workdir /data -it --rm python \
		python3 -m http.server 8000

ignition/vm: ignition
	$(BUTANE) --pretty --strict --files-dir /pwd hosts/virtual/spec.bu -o hosts/virtual/spec.ign

create_iso/vm: get_fcos_iso ignition/vm
	rm -f custom.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/vda \
		--dest-ignition /pwd/hosts/virtual/spec.ign \
		-o custom.iso fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso

.PHONY: get_fcos_iso
get_fcos_iso:
	curl -O --url https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$(FCOS_VERSION)/x86_64/fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso -C -

.PHONY: clean
clean:
	find . -name "*.ign" -type f | xargs rm -f
	rm fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso
	rm custom.iso

default: ignition
