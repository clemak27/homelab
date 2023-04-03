FCOS_VERSION = 36.20221030.3.0

CONTAINER = docker
CONTAINER_RUN_PWD = $(CONTAINER) run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd
COREOS_INSTALLER = $(CONTAINER_RUN_PWD) quay.io/coreos/coreos-installer:release
SOPS = SOPS_AGE_KEY_FILE=./key.txt sops

default: ignition

# modules

modules/user.ign: modules/user.bu
	butane modules/user.bu -o modules/user.ign

modules/overlays.ign: modules/overlays.bu butane
	butane modules/overlays.bu -o modules/overlays.ign

modules/i18n.ign: modules/i18n.bu
	butane modules/i18n.bu -o modules/i18n.ign

modules/autoupdates.ign: modules/autoupdates.bu
	butane modules/autoupdates.bu -o modules/autoupdates.ign

modules/wireguard/wireguard.ign: modules/wireguard/wireguard.bu modules/wireguard/wg0.enc.conf
	$(SOPS) --decrypt modules/wireguard/wg0.enc.conf > modules/wireguard/wg0.conf
	butane --files-dir /pwd/modules/wireguard modules/wireguard/wireguard.bu -o modules/wireguard/wireguard.ign
	rm modules/wireguard/wg0.conf

modules/init/init.ign: modules/init/init.bu modules/init/init.sh modules/init/age_key.enc
	$(SOPS) --decrypt modules/init/age_key.enc > modules/init/age_key
	butane --files-dir /pwd/modules/init modules/init/init.bu -o modules/init/init.ign
	rm modules/init/age_key

modules/ssh/ssh.ign: modules/ssh/ssh.bu
	$(SOPS) --decrypt modules/ssh/id_ed25519.enc > modules/ssh/id_ed25519
	butane --files-dir /pwd/modules/ssh modules/ssh/ssh.bu -o modules/ssh/ssh.ign
	rm modules/ssh/id_ed25519

modules/nix/nix.ign: modules/nix/nix.bu modules/nix/create_nix_toolbox.sh
	butane --files-dir /pwd/modules/nix modules/nix/nix.bu -o modules/nix/nix.ign

modules/k3s/k3s.ign: modules/k3s/k3s.bu
	butane --files-dir /pwd/modules/k3s modules/k3s/k3s.bu -o modules/k3s/k3s.ign

modules/dns/dns.ign: modules/dns/dns.bu
	butane modules/dns.bu -o modules/dns.ign

ignition: modules/user.ign modules/overlays.ign modules/i18n.ign modules/autoupdates.ign modules/init/init.ign modules/wireguard/wireguard.ign modules/ssh/ssh.ign modules/nix/nix.ign modules/k3s/k3s.ign modules/dns/dns.ign

serve: ignition
	docker run --interactive --rm --security-opt label=disable \
		-p 8000:8000 -v ${PWD}:/data --workdir /data -it --rm python \
		python3 -m http.server 8000

# virtual machine config

hosts/virtual.ign: hosts/virtual.bu ignition
	butane --files-dir /pwd hosts/virtual.bu -o hosts/virtual.ign

create_iso/virtual: fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso hosts/virtual.ign
	rm -f fcos.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/vda \
		--dest-ignition /pwd/hosts/virtual.ign \
		-o fcos.iso fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso

# nuke config

hosts/nuke.ign: hosts/nuke.bu ignition
	butane --files-dir /pwd hosts/nuke.bu -o hosts/nuke.ign

create_iso/nuke: fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso hosts/nuke.ign
	rm -f fcos.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/sda \
		--dest-ignition /pwd/hosts/nuke.ign \
		-o fcos.iso fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso

# files

fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso:
	curl -O --url https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$(FCOS_VERSION)/x86_64/fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso -C -

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

test: bin/butane
	echo "unencrypted content" > modules/wireguard/wg0.conf
	echo "unencrypted content" > modules/init/age_key
	echo "unencrypted content" > modules/ssh/id_ed25519
	bin/butane modules/user.bu -o modules/user.ign
	bin/butane modules/overlays.bu -o modules/overlays.ign
	bin/butane modules/i18n.bu -o modules/i18n.ign
	bin/butane modules/autoupdates.bu -o modules/autoupdates.ign
	bin/butane modules/dns/dns.bu -o modules/dns/dns.ign
	bin/butane --files-dir modules/wireguard modules/wireguard/wireguard.bu -o modules/wireguard/wireguard.ign
	bin/butane --files-dir modules/init modules/init/init.bu -o modules/init/init.ign
	bin/butane --files-dir modules/ssh modules/ssh/ssh.bu -o modules/ssh/ssh.ign
	bin/butane --files-dir modules/nix modules/nix/nix.bu -o modules/nix/nix.ign
	bin/butane --files-dir modules/k3s modules/k3s/k3s.bu -o modules/k3s/k3s.ign
	bin/butane --files-dir . hosts/virtual.bu -o hosts/virtual.ign
	bin/butane --files-dir . hosts/nuke.bu -o hosts/nuke.ign
	rm modules/wireguard/wg0.conf
	rm modules/init/age_key
	rm modules/ssh/id_ed25519

bin/butane:
	mkdir -p bin
	curl -L --url https://github.com/coreos/butane/releases/download/v0.16.0/butane-x86_64-unknown-linux-gnu -o bin/butane  -C -
	chmod +x bin/butane

clean:
	find . -name "*.ign" -type f | xargs rm -f
	rm fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso
	rm fcos.iso
	rm -rf bin
	rm -f key.txt

key.txt:
	$(SOPS) --decrypt modules/init/age_key.enc > key.txt

# k3s

k3s/init_argocd: key.txt
	kubectl create namespace argocd && \
	kubectl -n argocd create secret generic helm-secrets-private-keys --from-file=key.txt && \
	helm install -n argocd argocd cluster/argocd/application && \
	sleep 75 && \
	kubectl delete -n argocd secrets argocd-initial-admin-secret

k3s/create_argocd_applications:
	find ./cluster -name 'applications.yaml' -exec kubectl -n argocd apply -f {} \;

k3s/create_cert_issuer: key.txt
	$(SOPS) --decrypt cluster/cert-manager/issuer/issuer.yaml > cluster/cert-manager/issuer/issuer_unenc.yaml && \
	kubectl apply -n cert-manager -f cluster/cert-manager/issuer/issuer_unenc.yaml && \
	rm -f cluster/cert-manager/issuer/issuer_unenc.yaml
