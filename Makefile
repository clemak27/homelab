include host.mk

IP=192.168.178.100
SSH_RUN=ssh clemens@$(IP) -C

SOPS_VERSION=3.8.1
KSOPS_VERSION=4.3.1
KUSTOMIZE_VERSION=5.3.0

.PHONY: all
all:

.PHONY: clean
clean:
	rm -rf tmp bin

.PHONY: test
test: test/kustomize test/kustomize-ksops

KUSTOMIZE_BUILD=bin/bin/kustomize build --enable-helm
KUSTOMIZE_BUILD_KSOPS=KUSTOMIZE_PLUGIN_HOME=$$PWD/bin/kustomize/plugin bin/bin/kustomize build --enable-helm --enable-exec --enable-alpha-plugins

.PHONY: test/kustomize
test/kustomize: bin/bin/kustomize
	$(KUSTOMIZE_BUILD) cluster/registry/registry
	$(KUSTOMIZE_BUILD) cluster/services/calibre
	$(KUSTOMIZE_BUILD) cluster/services/home-assistant
	$(KUSTOMIZE_BUILD) cluster/services/jackett
	$(KUSTOMIZE_BUILD) cluster/services/jellyfin
	$(KUSTOMIZE_BUILD) cluster/services/qobuz-dl
	$(KUSTOMIZE_BUILD) cluster/services/radarr
	$(KUSTOMIZE_BUILD) cluster/services/readarr
	$(KUSTOMIZE_BUILD) cluster/services/sonarr
	$(KUSTOMIZE_BUILD) cluster/services/syncthing
	$(KUSTOMIZE_BUILD) cluster/services/transmission
	$(KUSTOMIZE_BUILD) cluster/services/zigbee2mqtt

.PHONY: test/kustomize-ksops
test/kustomize-ksops: bin/ksops bin/bin/kustomize
	$(KUSTOMIZE_BUILD_KSOPS) cluster/argocd/argocd
	$(KUSTOMIZE_BUILD_KSOPS) cluster/cert-manager/cert-manager
	$(KUSTOMIZE_BUILD_KSOPS) cluster/longhorn-system/longhorn
	$(KUSTOMIZE_BUILD_KSOPS) cluster/services/cloudflare-ddns
	$(KUSTOMIZE_BUILD_KSOPS) cluster/services/gitea
	$(KUSTOMIZE_BUILD_KSOPS) cluster/services/miniflux
	$(KUSTOMIZE_BUILD_KSOPS) cluster/services/recipes
	$(KUSTOMIZE_BUILD_KSOPS) cluster/services/vaultwarden

.PHONY: update-argocd-applications
update-argocd-applications:
	find ./cluster -name 'applications.yaml' -exec kubectl -n argocd apply -f {} \;

.PHONY: mount_nfs
mount_nfs:
	mkdir -p $$HOME/nfs/media
	sudo mount -t nfs $(IP):/media $$HOME/nfs/media

.PHONY: unmount_nfs
unmount_nfs:
	sudo umount  $$HOME/nfs/media

.PHONY: upgrade
upgrade:
	$(SSH_RUN) sudo rpm-ostree upgrade

.PHONY: reboot
reboot:
	kubectl scale deployments.apps -l requires-nfs=true --replicas 0
	sleep 15
	$(SSH_RUN) sudo systemctl reboot
	sleep 5
	while ! $(SSH_RUN) exit 0 &> /dev/null; do sleep 5; done;
	sleep 5
	kubectl scale deployments.apps -l requires-nfs=true --replicas 1

bin/bin/kustomize:
	mkdir -p tmp
	mkdir -p bin/bin
	curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v$(KUSTOMIZE_VERSION)/kustomize_v$(KUSTOMIZE_VERSION)_linux_amd64.tar.gz -o tmp/kustomize.tar.gz
	tar -xzf tmp/kustomize.tar.gz -C bin/bin

bin/sops:
	mkdir -p bin
	curl -L https://github.com/getsops/sops/releases/download/v$(SOPS_VERSION)/sops-v$(SOPS_VERSION).linux.amd64 -o bin/sops
	chmod +x bin/sops

bin/ksops:
	mkdir -p tmp
	mkdir -p bin
	curl -L https://github.com/viaduct-ai/kustomize-sops/releases/download/v$(KSOPS_VERSION)/ksops_$(KSOPS_VERSION)_Linux_x86_64.tar.gz -o tmp/ksops.tar.gz
	tar -xzf tmp/ksops.tar.gz -C bin
	mkdir -p bin/kustomize/plugin/viaduct.ai/v1/ksops/
	cp bin/ksops bin/kustomize/plugin/viaduct.ai/v1/ksops/ksops
