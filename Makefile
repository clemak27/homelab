FCOS_VERSION = 36.20220820.3.0

PODMAN = /usr/bin/flatpak-spawn --host podman
PODMAN_RUN_PWD = $(PODMAN) run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd
BUTANE = $(PODMAN_RUN_PWD) quay.io/coreos/butane:release --pretty --strict
COREOS_INSTALLER = $(PODMAN_RUN_PWD) quay.io/coreos/coreos-installer:release
SOPS = $(PODMAN_RUN_PWD) --volume ${HOME}/.config/sops/age/keys.txt:/pwd/keys.txt:ro -e SOPS_AGE_KEY_FILE=/pwd/keys.txt nixery.dev/sops sops

default: ignition

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
	$(SOPS) --decrypt modules/wireguard/wg0.enc.conf > modules/wireguard/wg0.conf
	$(BUTANE) --files-dir /pwd/modules/wireguard modules/wireguard/wireguard.bu -o modules/wireguard/wireguard.ign
	rm modules/wireguard/wg0.conf

modules/init/init.ign: modules/init/init.bu modules/init/init.sh modules/init/age_key.enc
	$(SOPS) --decrypt modules/init/age_key.enc > modules/init/age_key
	$(BUTANE) --files-dir /pwd/modules/init modules/init/init.bu -o modules/init/init.ign
	rm modules/init/age_key

modules/ssh/ssh.ign: modules/ssh/ssh.bu
	$(SOPS) --decrypt modules/ssh/id_ed25519.enc > modules/ssh/id_ed25519
	$(BUTANE) --files-dir /pwd/modules/ssh modules/ssh/ssh.bu -o modules/ssh/ssh.ign
	rm modules/ssh/id_ed25519

modules/gitops/gitops.ign: modules/gitops/gitops.bu modules/gitops/gitops.sh
	$(BUTANE) --files-dir /pwd/modules/gitops modules/gitops/gitops.bu -o modules/gitops/gitops.ign

modules/nix/nix.ign: modules/nix/nix.bu modules/nix/create_nix_toolbox.sh
	$(BUTANE) --files-dir /pwd/modules/nix modules/nix/nix.bu -o modules/nix/nix.ign

ignition: modules/user.ign modules/overlays.ign modules/i18n.ign modules/autoupdates.ign modules/init/init.ign modules/wireguard/wireguard.ign modules/gitops/gitops.ign modules/ssh/ssh.ign modules/nix/nix.ign

serve: ignition
	$(PODMAN) run --interactive --rm --security-opt label=disable \
		-p 8000:8000 -v ${PWD}:/data --workdir /data -it --rm python \
		python3 -m http.server 8000

# virtual machine config

hosts/virtual.ign: hosts/virtual.bu ignition
	$(BUTANE) --files-dir /pwd hosts/virtual.bu -o hosts/virtual.ign

create_iso/virtual: fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso hosts/virtual.ign
	rm -f fcos.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/vda \
		--dest-ignition /pwd/hosts/virtual.ign \
		-o fcos.iso fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso

# nuke config

hosts/nuke.ign: hosts/nuke.bu ignition
	$(BUTANE) --files-dir /pwd hosts/nuke.bu -o hosts/nuke.ign

create_iso/nuke: fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso hosts/nuke.ign
	rm -f fcos.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/sda \
		--dest-ignition /pwd/hosts/nuke.ign \
		-o fcos.iso fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso

fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso:
	curl -O --url https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$(FCOS_VERSION)/x86_64/fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso -C -

# other
.PHONY: lint yamllint shellcheck hadolint clean test

lint: yamllint shellcheck hadolint

yamllint:
	$(PODMAN_RUN_PWD) nixery.dev/yamllint yamllint .

shellcheck:
	find . -name "*.sh" -type f | xargs $(PODMAN_RUN_PWD) nixery.dev/shellcheck shellcheck
	find . -name "*.bash" -type f | xargs $(PODMAN_RUN_PWD) nixery.dev/shellcheck shellcheck

hadolint:
	find . -name "Dockerfile" -type f | xargs $(PODMAN_RUN_PWD) nixery.dev/hadolint:latest hadolint

clean:
	find . -name "*.ign" -type f | xargs rm -f
	rm fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso
	rm fcos.iso

test:
	echo "unencrypted content" > modules/wireguard/wg0.conf
	echo "unencrypted content" > modules/init/age_key
	echo "unencrypted content" > modules/ssh/id_ed25519
	butane modules/user.bu -o modules/user.ign
	butane modules/overlays.bu -o modules/overlays.ign
	butane modules/i18n.bu -o modules/i18n.ign
	butane modules/autoupdates.bu -o modules/autoupdates.ign
	butane --files-dir modules/wireguard modules/wireguard/wireguard.bu -o modules/wireguard/wireguard.ign
	butane --files-dir modules/init modules/init/init.bu -o modules/init/init.ign
	butane --files-dir modules/ssh modules/ssh/ssh.bu -o modules/ssh/ssh.ign
	butane --files-dir modules/gitops modules/gitops/gitops.bu -o modules/gitops/gitops.ign
	butane --files-dir modules/nix modules/nix/nix.bu -o modules/nix/nix.ign
	butane --files-dir . hosts/virtual.bu -o hosts/virtual.ign
	butane --files-dir . hosts/nuke.bu -o hosts/nuke.ign
	rm modules/wireguard/wg0.conf
	rm modules/init/age_key
	rm modules/ssh/id_ed25519
