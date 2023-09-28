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
	nix flake update
	git add flake.lock
	git commit -m 'chore: update flake'
	git push

.PHONY: deploy/ares
deploy/ares:
	sudo nixos-rebuild --impure --flake .#ares --target-host clemens@192.168.178.100 boot
	kubectl cordon ares
	ssh clemens@192.168.178.100 -C sudo shutdown -r 0
	sleep 5
	while ! ssh clemens@192.168.178.100 -C exit 0; do sleep 2; done;
	ssh clemens@192.168.178.100 -C sudo nix-collect-garbage
	kubectl uncordon ares

.PHONY: deploy/deimos
deploy/deimos:
	sudo nixos-rebuild --impure --flake .#deimos --target-host clemens@192.168.178.101 boot
	kubectl drain deimos --ignore-daemonsets --delete-emptydir-data
	ssh clemens@192.168.178.101 -C sudo shutdown -r 0
	sleep 5
	while ! ssh clemens@192.168.178.101 -C exit 0 &> /dev/null; do sleep 2; done;
	ssh clemens@192.168.178.101 -C sudo nix-collect-garbage
	kubectl uncordon deimos

.PHONY: deploy/phobos
deploy/phobos:
	sudo nixos-rebuild --impure --flake .#phobos --target-host clemens@192.168.178.102 boot
	kubectl drain phobos --ignore-daemonsets --delete-emptydir-data
	ssh clemens@192.168.178.102 -C sudo shutdown -r 0
	sleep 5
	while ! ssh clemens@192.168.178.102 -C exit 0; do sleep 2; done;
	ssh clemens@192.168.178.102 -C sudo nix-collect-garbage
	sleep 5
	kubectl uncordon phobos
