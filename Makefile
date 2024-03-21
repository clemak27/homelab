include host.mk

IP=192.168.178.100
SSH_RUN=ssh clemens@$(IP) -C

SOPS_VERSION=3.8.1
KSOPS_VERSION=4.3.1

.PHONY: all
all:

.PHONY: clean
clean:
	rm -rf tmp bin

.PHONY: test
test:
	pre-commit run --all-files --verbose

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
	echo "don't"
	# TODO fix
	# $(SSH_RUN) sudo systemctl disable --now wg-quick@wg0
	# $(SSH_RUN) sudo systemctl disable --now dnsmasq
	# kubectl scale deployments.apps -l requires-nfs=true --replicas 0
	# sleep 15
	# $(SSH_RUN) sudo shutdown -r 0
	# sleep 5
	# while ! $(SSH_RUN) exit 0 &> /dev/null; do sleep 5; done;
	# sleep 5
	# kubectl scale deployments.apps -l requires-nfs=true --replicas 1
	# $(SSH_RUN) sudo systemctl enable --now wg-quick@wg0
	# $(SSH_RUN) sudo systemctl enable --now dnsmasq

bin/sops:
	curl -L https://github.com/getsops/sops/releases/download/v$(SOPS_VERSION)/sops-v$(SOPS_VERSION).linux.amd64 -o bin/sops
	chmod +x bin/sops

bin/ksops:
	mkdir -p tmp
	mkdir -p bin
	curl -L https://github.com/viaduct-ai/kustomize-sops/releases/download/v$(KSOPS_VERSION)/ksops_$(KSOPS_VERSION)_Linux_x86_64.tar.gz -o tmp/ksops.tar.gz
	tar -xzf tmp/ksops.tar.gz -C bin
	mkdir -p bin/kustomize/plugin/viaduct.ai/v1/ksops/
	cp bin/ksops bin/kustomize/plugin/viaduct.ai/v1/ksops/ksops
