include host.mk

.PHONY: all
all:

.PHONY: clean
clean:

.PHONY: test
test:
	pre-commit run --all-files --verbose

.PHONY: update-argocd-applications
update-argocd-applications:
	find ./cluster -name 'applications.yaml' -exec kubectl -n argocd apply -f {} \;

.PHONY: update-flake
update-flake:
	nix flake update --commit-lock-file  --option commit-lockfile-summary "chore: update flake"

.PHONY: mount_nfs
mount_nfs:
	mkdir -p $$HOME/nfs/media
	sudo mount -t nfs 192.168.178.100:/media $$HOME/nfs/media

.PHONY: unmount_nfs
unmount_nfs:
	sudo umount  $$HOME/nfs/media

.PHONY: build
build:
	nixos-rebuild --impure --flake .#mars build

.PHONY: deploy/mars
deploy/mars:
	kubectl scale deployments.apps -l requires-nfs=true --replicas 0
	sleep 15
	ssh clemens@192.168.178.100 -C sudo shutdown -r 0
	sleep 5
	while ! ssh clemens@192.168.178.100 -C exit 0 &> /dev/null; do sleep 5; done;
	sleep 5
	kubectl scale deployments.apps -l requires-nfs=true --replicas 1
	ssh clemens@192.168.178.100 -C sudo systemctl restart dnsmasq

bin/sops:
	curl -L https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 -o bin/sops
	chmod +x bin/sops

bin/ksops:
	mkdir -p tmp
	mkdir -p bin
	curl -L https://github.com/viaduct-ai/kustomize-sops/releases/download/v4.3.1/ksops_4.3.1_Linux_x86_64.tar.gz -o tmp/ksops.tar.gz
	tar -xzf tmp/ksops.tar.gz -C bin
	mkdir -p bin/kustomize/plugin/viaduct.ai/v1/ksops/
	cp bin/ksops bin/kustomize/plugin/viaduct.ai/v1/ksops/ksops
