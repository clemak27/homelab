BOLTZMANN_IP=192.168.178.100
SSH_COMMAND=ssh clemens@$(BOLTZMANN_IP) -C

update-flake:
	rm -rf result current
	nixos-rebuild build --flake .#boltzmann --impure
	mv result current
	nix flake update --commit-lock-file --option commit-lockfile-summary "chore(flake): update flake.lock"
	nixos-rebuild build --flake .#boltzmann --impure
	nvd diff current result

update-argocd-applications:
	find ./cluster -name 'applications.yaml' -exec kubectl -n argocd apply -f {} \;

deploy-homelab:
	kubectl scale -n services deployments.apps -l requires-nfs=true --replicas 0
	deploy --boot -s
	$(SSH_COMMAND) sudo shutdown -r 0
	sleep 5
	while ! $(SSH_COMMAND) exit 0 &> /dev/null; do sleep 5; done;
	$(SSH_COMMAND) sudo nix-collect-garbage
	kubectl scale -n services deployments.apps -l requires-nfs=true --replicas 1
