# https://quay.io/repository/fedora/fedora-coreos?tab=tags
FCOS_VERSION = 42.20250526.3.0
FCOS_ISO = fedora-coreos-$(FCOS_VERSION)-live-iso.x86_64.iso

CONTAINER = podman
CONTAINER_RUN_PWD = $(CONTAINER) run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd
COREOS_INSTALLER = $(CONTAINER_RUN_PWD) quay.io/coreos/coreos-installer:release

default: ignition

# modules

modules/base.ign: modules/base.bu
	butane modules/base.bu -o modules/base.ign

modules/dns/dns.ign: modules/dns/dns.bu
	butane --files-dir modules/dns modules/dns/dns.bu -o modules/dns/dns.ign

modules/k3s/k3s.ign: modules/k3s/k3s.bu
	butane --files-dir modules/k3s modules/k3s/k3s.bu -o modules/k3s/k3s.ign

modules/nfs/nfs.ign: modules/nfs/nfs.bu
	butane --files-dir modules/nfs modules/nfs/nfs.bu -o modules/nfs/nfs.ign

modules/wireguard/wireguard.ign: modules/wireguard/wireguard.bu modules/wireguard/wg0.enc.conf
	sops --decrypt modules/wireguard/wg0.enc.conf > modules/wireguard/wg0.conf
	butane --files-dir modules/wireguard modules/wireguard/wireguard.bu -o modules/wireguard/wireguard.ign
	rm modules/wireguard/wg0.conf

ignition: modules/base.ign modules/dns/dns.ign modules/k3s/k3s.ign modules/nfs/nfs.ign modules/wireguard/wireguard.ign

# virtual machine config

hosts/virtual.ign: hosts/virtual.bu ignition
	butane --files-dir . hosts/virtual.bu -o hosts/virtual.ign
	ignition-validate hosts/virtual.ign

create_iso/virtual: $(FCOS_ISO) hosts/virtual.ign
	rm -f fcos.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/vda \
		--dest-ignition /pwd/hosts/virtual.ign \
		-o fcos.iso fedora-coreos-$(FCOS_VERSION)-live-iso.x86_64.iso

# nuke config

hosts/nuke.ign: hosts/nuke.bu ignition
	butane --files-dir /pwd hosts/nuke.bu -o hosts/nuke.ign
	ignition-validate hosts/nuke.ign

create_iso/nuke: $(FCOS_ISO) hosts/nuke.ign
	rm -f fcos.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/sda \
		--dest-ignition /pwd/hosts/nuke.ign \
		-o fcos.iso fedora-coreos-$(FCOS_VERSION)-live-iso.x86_64.iso

# files

$(FCOS_ISO):
	curl -O --url https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$(FCOS_VERSION)/x86_64/$(FCOS_ISO) -C -

# other

.PHONY: lint yamllint shellcheck hadolint clean test

lint: yamllint shellcheck hadolint

yamllint:
	yamllint .

shellcheck:
	find . -name "*.sh" -type f | xargs shellcheck
	find . -name "*.bash" -type f | xargs shellcheck

hadolint:
	hadolint

clean:
	find . -name "*.ign" -type f | xargs rm -f
	# rm $(FCOS_ISO)
	rm -f fcos.iso
	rm -rf bin
