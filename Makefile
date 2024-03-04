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
	kubectl delete -n argocd applicationsets.argoproj.io services
	nixos-rebuild --use-remote-sudo --impure --flake .#mars --target-host clemens@192.168.178.100 boot
	ssh clemens@192.168.178.100 -C sudo shutdown -r 0
	sleep 5
	while ! ssh clemens@192.168.178.100 -C exit 0 &> /dev/null; do sleep 5; done;
	ssh clemens@192.168.178.100 -C sudo nix-collect-garbage
	kubectl apply -f ./cluster/services/applications.yaml
