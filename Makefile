IP=192.168.178.100
SSH_RUN=ssh clemens@$(IP) -C

KSOPS_VERSION=4.3.1

.PHONY: all
all:

.PHONY: clean
clean:
	rm -rf tmp bin

## test

.PHONY: test
test: test/kustomize test/kustomize-ksops
	pre-commit run --all-files --verbose

KUSTOMIZE_BUILD=kustomize build --enable-helm
KUSTOMIZE_BUILD_KSOPS=KUSTOMIZE_PLUGIN_HOME=$$PWD/bin/kustomize/plugin kustomize build --enable-helm --enable-exec --enable-alpha-plugins

.PHONY: test/kustomize
test/kustomize:
	$(KUSTOMIZE_BUILD) cluster/registry/registry
	$(KUSTOMIZE_BUILD) cluster/services/calibre
	$(KUSTOMIZE_BUILD) cluster/services/home-assistant
	$(KUSTOMIZE_BUILD) cluster/services/jellyfin
	$(KUSTOMIZE_BUILD) cluster/services/prowlarr
	$(KUSTOMIZE_BUILD) cluster/services/qobuz-dl
	$(KUSTOMIZE_BUILD) cluster/services/radarr
	$(KUSTOMIZE_BUILD) cluster/services/readarr
	$(KUSTOMIZE_BUILD) cluster/services/sonarr
	$(KUSTOMIZE_BUILD) cluster/services/syncthing
	$(KUSTOMIZE_BUILD) cluster/services/transmission
	$(KUSTOMIZE_BUILD) cluster/services/zigbee2mqtt

.PHONY: test/kustomize-ksops
test/kustomize-ksops: bin/kustomize/plugin/viaduct.ai/v1/ksops/ksops
	$(KUSTOMIZE_BUILD_KSOPS) cluster/argocd/argocd
	$(KUSTOMIZE_BUILD_KSOPS) cluster/cert-manager/cert-manager
	$(KUSTOMIZE_BUILD_KSOPS) cluster/longhorn-system/longhorn
	$(KUSTOMIZE_BUILD_KSOPS) cluster/services/cloudflare-ddns
	$(KUSTOMIZE_BUILD_KSOPS) cluster/services/gitea
	$(KUSTOMIZE_BUILD_KSOPS) cluster/services/miniflux
	$(KUSTOMIZE_BUILD_KSOPS) cluster/services/recipes
	$(KUSTOMIZE_BUILD_KSOPS) cluster/services/vaultwarden

## building

.PHONY: update-flake
update-flake:
	nix flake update --commit-lock-file  --option commit-lockfile-summary "chore: update flake"

.PHONY: build
build:
	nixos-rebuild build --flake .#boltzmann --impure

.PHONY: deploy/boltzmann
deploy/boltzmann:
	kubectl scale deployments.apps -l requires-nfs=true --replicas 0
	nixos-rebuild boot --use-remote-sudo --impure --flake .#boltzmann --target-host clemens@$(IP)
	$(SSH_RUN) sudo shutdown -r 0
	sleep 5
	while ! $(SSH_RUN) exit 0 &> /dev/null; do sleep 5; done;
	$(SSH_RUN) sudo nix-collect-garbage
	kubectl scale deployments.apps -l requires-nfs=true --replicas 1

## utils

.PHONY: update-argocd-applications
update-argocd-applications:
	find ./cluster -name 'applications.yaml' -exec kubectl -n argocd apply -f {} \;

.PHONY: kubeconfig
kubeconfig:
	scp clemens@$(IP):/etc/rancher/k3s/k3s.yaml k3sconfig.yaml
	sed -ie 's/127\.0\.0\.1/$(IP)/g' k3sconfig.yaml
	KUBECONFIG=k3sconfig.yaml kubectl get pods -A
	rm -f k3sconfig.yamle

.PHONY: mount-nfs
mount-nfs:
	mkdir -p $$HOME/nfs/media
	sudo mount -t nfs $(IP):/media $$HOME/nfs/media

.PHONY: unmount-nfs
unmount-nfs:
	sudo umount  $$HOME/nfs/media

## binaries

.PHONY: bin/kustomize/plugin/viaduct.ai/v1/ksops/ksops
bin/kustomize/plugin/viaduct.ai/v1/ksops/ksops:
	mkdir -p tmp
	mkdir -p bin
	curl -L https://github.com/viaduct-ai/kustomize-sops/releases/download/v$(KSOPS_VERSION)/ksops_$(KSOPS_VERSION)_Linux_x86_64.tar.gz -o tmp/ksops.tar.gz
	tar -xzf tmp/ksops.tar.gz -C bin
	mkdir -p bin/kustomize/plugin/viaduct.ai/v1/ksops/
	cp bin/ksops bin/kustomize/plugin/viaduct.ai/v1/ksops/ksops
