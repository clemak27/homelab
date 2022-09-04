FCOS_VERSION := 36.20220806.3.0

PODMAN := /usr/bin/flatpak-spawn --host podman
PODMAN_RUN_PWD := $(PODMAN) run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd
BUTANE := $(PODMAN_RUN_PWD) quay.io/coreos/butane:release --pretty --strict
COREOS_INSTALLER := $(PODMAN_RUN_PWD) quay.io/coreos/coreos-installer:release
SOPS_CMD := $(PODMAN_RUN_PWD) --volume ${HOME}/.config/sops/age/keys.txt:/pwd/keys.txt:ro -e SOPS_AGE_KEY_FILE=/pwd/keys.txt nixery.dev/sops sops

# modules

modules/user.ign: modules/user.bu
	$(BUTANE) modules/user.bu -o modules/user.ign

modules/overlays.ign: modules/overlays.bu
	$(BUTANE) modules/overlays.bu -o modules/overlays.ign

modules/i18n.ign: modules/i18n.bu
	$(BUTANE) modules/i18n.bu -o modules/i18n.ign

modules/autoupdates.ign: modules/autoupdates.bu
	$(BUTANE) modules/autoupdates.bu -o modules/autoupdates.ign

modules/wireguard/wireguard.ign: modules/wireguard/wireguard.bu modules/wireguard/wg0.enc.conf
	$(SOPS_CMD) --decrypt modules/wireguard/wg0.enc.conf > modules/wireguard/wg0.conf
	$(BUTANE) --files-dir /pwd/modules/wireguard modules/wireguard/wireguard.bu -o modules/wireguard/wireguard.ign
	rm modules/wireguard/wg0.conf

modules/init/init.ign: modules/init/init.bu modules/init/init.sh modules/init/age_key.enc
	$(SOPS_CMD) --decrypt modules/init/age_key.enc > modules/init/age_key
	$(BUTANE) --files-dir /pwd/modules/init modules/init/init.bu -o modules/init/init.ign
	rm modules/init/age_key

ignition: modules/user.ign modules/overlays.ign modules/i18n.ign modules/autoupdates.ign modules/init/init.ign modules/wireguard/wireguard.ign

serve: ignition
	$(PODMAN) run --interactive --rm --security-opt label=disable \
		-p 8000:8000 -v ${PWD}:/data --workdir /data -it --rm python \
		python3 -m http.server 8000

# virtual machine config

ignition/vm: ignition
	$(BUTANE) --files-dir /pwd hosts/virtual.bu -o hosts/virtual.ign

create_iso/vm: get_fcos_iso ignition/vm
	rm -f custom.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/vda \
		--dest-ignition /pwd/hosts/virtual.ign \
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
