# https://quay.io/repository/fedora/fedora-coreos?tab=tags
FCOS_VERSION = 42.20250526.3.0
FCOS_ISO = fedora-coreos-$(FCOS_VERSION)-live-iso.x86_64.iso

CONTAINER_RUN_PWD = podman run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd
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

# boltzmann config

hosts/boltzmann.ign: hosts/boltzmann.bu ignition
	butane --files-dir . hosts/boltzmann.bu -o hosts/boltzmann.ign
	ignition-validate hosts/boltzmann.ign

create_iso/boltzmann: $(FCOS_ISO) hosts/boltzmann.ign
	rm -f fcos.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/nvme0n1 \
		--dest-ignition /pwd/hosts/boltzmann.ign \
		-o fcos.iso fedora-coreos-$(FCOS_VERSION)-live-iso.x86_64.iso

# files

$(FCOS_ISO):
	curl -O --url https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$(FCOS_VERSION)/x86_64/$(FCOS_ISO) -C -

clean:
	fd ign --no-ignore -x rm {}
	rm -f $(FCOS_ISO) fcos.iso
