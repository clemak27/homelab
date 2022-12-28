FCOS_VERSION = 36.20221030.3.0
SOPS_BIN_VERSION = v3.7.3
KUBECTL_VERSION = v1.25.0
ARGOCD_BIN_VERSION = v2.5.2
KUSTOMIZE_VERSION = v4.5.7
HELM_VERSION = v3.10.2
BUTANE_BIN_VERSION = v0.16.0

RUN_HOST = /usr/bin/flatpak-spawn --host
PODMAN =  $(RUN_HOST) podman
PODMAN_RUN_PWD = $(PODMAN) run --interactive --rm --security-opt label=disable --volume ${PWD}:/pwd --workdir /pwd
COREOS_INSTALLER = $(PODMAN_RUN_PWD) quay.io/coreos/coreos-installer:release
SOPS = $(PODMAN_RUN_PWD) --volume ${HOME}/.config/sops/age/keys.txt:/pwd/keys.txt:ro -e SOPS_AGE_KEY_FILE=/pwd/keys.txt nixery.dev/sops sops
LOCAL_KUBECTL = KUBECONFIG="${PWD}/kubeconfig.yaml" bin/kubectl
LOCAL_SOPS = SOPS_AGE_KEY_FILE=./key.txt bin/sops

default: ignition

# modules

modules/user.ign: modules/user.bu bin/butane
	bin/butane modules/user.bu -o modules/user.ign

modules/overlays.ign: modules/overlays.bu bin/butane
	bin/butane modules/overlays.bu -o modules/overlays.ign

modules/i18n.ign: modules/i18n.bu bin/butane
	bin/butane modules/i18n.bu -o modules/i18n.ign

modules/autoupdates.ign: modules/autoupdates.bu bin/butane
	bin/butane modules/autoupdates.bu -o modules/autoupdates.ign

modules/wireguard/wireguard.ign: modules/wireguard/wireguard.bu modules/wireguard/wg0.enc.conf bin/butane
	$(SOPS) --decrypt modules/wireguard/wg0.enc.conf > modules/wireguard/wg0.conf
	bin/butane --files-dir /pwd/modules/wireguard modules/wireguard/wireguard.bu -o modules/wireguard/wireguard.ign
	rm modules/wireguard/wg0.conf

modules/init/init.ign: modules/init/init.bu modules/init/init.sh modules/init/age_key.enc bin/butane
	$(SOPS) --decrypt modules/init/age_key.enc > modules/init/age_key
	bin/butane --files-dir /pwd/modules/init modules/init/init.bu -o modules/init/init.ign
	rm modules/init/age_key

modules/ssh/ssh.ign: modules/ssh/ssh.bu bin/butane
	$(SOPS) --decrypt modules/ssh/id_ed25519.enc > modules/ssh/id_ed25519
	bin/butane --files-dir /pwd/modules/ssh modules/ssh/ssh.bu -o modules/ssh/ssh.ign
	rm modules/ssh/id_ed25519

modules/nix/nix.ign: modules/nix/nix.bu modules/nix/create_nix_toolbox.sh bin/butane
	bin/butane --files-dir /pwd/modules/nix modules/nix/nix.bu -o modules/nix/nix.ign

modules/k3s/k3s.ign: modules/k3s/k3s.bu bin/butane
	bin/butane --files-dir /pwd/modules/k3s modules/k3s/k3s.bu -o modules/k3s/k3s.ign

modules/dns/dns.ign: modules/dns/dns.bu bin/butane
	bin/butane modules/dns.bu -o modules/dns.ign

ignition: modules/user.ign modules/overlays.ign modules/i18n.ign modules/autoupdates.ign modules/init/init.ign modules/wireguard/wireguard.ign modules/ssh/ssh.ign modules/nix/nix.ign modules/k3s/k3s.ign modules/dns/dns.ign

serve: ignition
	$(PODMAN) run --interactive --rm --security-opt label=disable \
		-p 8000:8000 -v ${PWD}:/data --workdir /data -it --rm python \
		python3 -m http.server 8000

# virtual machine config

hosts/virtual.ign: hosts/virtual.bu ignition bin/butane
	bin/butane --files-dir /pwd hosts/virtual.bu -o hosts/virtual.ign

create_iso/virtual: fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso hosts/virtual.ign
	rm -f fcos.iso
	$(COREOS_INSTALLER) iso customize \
		--dest-device /dev/vda \
		--dest-ignition /pwd/hosts/virtual.ign \
		-o fcos.iso fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso

# nuke config

hosts/nuke.ign: hosts/nuke.bu ignition bin/butane
	bin/butane --files-dir /pwd hosts/nuke.bu -o hosts/nuke.ign

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
	$(PODMAN_RUN_PWD) nixery.dev/yamllint yamllint .

shellcheck:
	find . -name "*.sh" -type f | xargs $(PODMAN_RUN_PWD) nixery.dev/shellcheck shellcheck
	find . -name "*.bash" -type f | xargs $(PODMAN_RUN_PWD) nixery.dev/shellcheck shellcheck

hadolint:
	find . -name "Dockerfile" -type f | xargs $(PODMAN_RUN_PWD) nixery.dev/hadolint:latest hadolint

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

clean:
	find . -name "*.ign" -type f | xargs rm -f
	rm fedora-coreos-$(FCOS_VERSION)-live.x86_64.iso
	rm fcos.iso
	rm -rf bin
	rm -f key.txt

key.txt:
	$(SOPS) --decrypt modules/init/age_key.enc > key.txt

# k3s

k3s/init_argocd: bin/kubectl bin/helm key.txt
	bin/kubectl create namespace services && \
  bin/kubectl create namespace cert-manager && \
	bin/kubectl create namespace argocd && \
	kubectl -n argocd create secret generic helm-secrets-private-keys --from-file=key.txt && \
	bin/helm install -n argocd argocd cluster/argocd && \
	sleep 75 && \
	bin/kubectl apply -n argocd -f cluster/argocd/applications.yaml && \
	bin/kubectl delete -n argocd secrets argocd-initial-admin-secret

k3s/create_cert_issuer: bin/kubectl bin/sops key.txt
	$(LOCAL_SOPS) --decrypt cluster/cert-manager/issuer/issuer.yaml > cluster/cert-manager/issuer/issuer_unenc.yaml && \
	bin/kubectl apply -n cert-manager -f cluster/cert-manager/issuer/issuer_unenc.yaml && \
	rm -f cluster/cert-manager/issuer/issuer_unenc.yaml

k3s/init_longhorn: bin/kubectl bin/helm key.txt
	bin/kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml

# bin

bin/butane:
	mkdir -p bin
	curl -L --url https://github.com/coreos/butane/releases/download/$(BUTANE_BIN_VERSION)/butane-x86_64-unknown-linux-gnu -o bin/butane  -C -
	chmod +x bin/butane

bin/sops:
	mkdir -p bin
	curl -L --url https://github.com/mozilla/sops/releases/download/$(SOPS_BIN_VERSION)/sops-$(SOPS_BIN_VERSION).linux -o bin/sops  -C -
	chmod +x bin/sops

bin/kubectl:
	mkdir -p bin
	curl -L --url https://dl.k8s.io/release/$(KUBECTL_VERSION)/bin/linux/amd64/kubectl -o bin/kubectl -C -
	chmod +x bin/kubectl

bin/argocd:
	mkdir -p bin
	curl -L --url https://github.com/argoproj/argo-cd/releases/download/$(ARGOCD_BIN_VERSION)/argocd-linux-amd64 -o bin/argocd -C -
	chmod +x bin/argocd

bin/kustomize:
	mkdir -p bin
	curl -L --url https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/$(KUSTOMIZE_VERSION)/kustomize_$(KUSTOMIZE_VERSION)_linux_amd64.tar.gz -o bin/kustomize.tar.gz -C -
	tar -xvf bin/kustomize.tar.gz -C bin
	rm -f bin/kustomize.tar.gz
	chmod +x bin/kustomize

bin/helm:
	mkdir -p bin
	curl -L --url https://get.helm.sh/helm-$(HELM_VERSION)-linux-amd64.tar.gz -o bin/helm.tar.gz -C -
	tar -zxvf bin/helm.tar.gz -C bin
	mv bin/linux-amd64/helm bin/helm
	rm -rf bin/linux-amd64
	chmod +x bin/helm
