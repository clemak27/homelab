IP=192.168.178.100
SSH_RUN=ssh clemens@$(IP) -C

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
