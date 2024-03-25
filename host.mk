## host files

.PHONY: host/base
host/base:
	$(SSH_RUN) sudo rpm-ostree install --idempotent git vim make zsh distrobox nfs-utils wireguard-tools iscsi-initiator-utils
	$(SSH_RUN) sudo shutdown -r 0
	sleep 5
	while ! $(SSH_RUN) exit 0 &> /dev/null; do sleep 5; done;
	$(SSH_RUN) sudo usermod -s /usr/bin/zsh clemens
	$(SSH_RUN) curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
	$(SSH_RUN) install.sh
	$(SSH_RUN) rm install.sh
	scp $$PWD/host/zshrc clemens@$(IP):/home/clemens/.zshrc

.PHONY: host/discs
host/discs:
	scp $$PWD/host/discs/fstab clemens@$(IP):/home/clemens/fstab
	$(SSH_RUN) sudo mv /home/clemens/fstab /etc/fstab
	$(SSH_RUN) sudo chown -R root:root /etc/fstab
	$(SSH_RUN) sudo restorecon -R /etc/fstab
	$(SSH_RUN) sudo systemctl daemon-reload
	$(SSH_RUN) sudo shutdown -r 0
	sleep 5
	while ! $(SSH_RUN) exit 0 &> /dev/null; do sleep 5; done;

.PHONY: host/k3s
host/k3s: host/k3s/config host/k3s/registries host/k3s/traefik
	$(SSH_RUN) curl -sfL -o k3s.sh https://get.k3s.io
	$(SSH_RUN) chmod +x k3s.sh
	# https://github.com/k3s-io/k3s/issues/8157
	# spicy, but it works 🤷
	$(SSH_RUN) sed -ie 's/coreos/iot/g' k3s.sh
	$(SSH_RUN) sed -ie 's/rpm_target=iot/rpm_target=coreos/g' k3s.sh
	$(SSH_RUN) sed -ie 's/rpm_site_infix=iot/rpm_site_infix=coreos/g' k3s.sh
	$(SSH_RUN) sed -ie 's/iot\)/coreos\)/g' k3s.sh
	$(SSH_RUN) ./k3s.sh
	$(SSH_RUN) k3s --version
	$(SSH_RUN) rm -f k3s.sh k3s.she
	$(SSH_RUN) sudo shutdown -r 0
	sleep 5
	while ! $(SSH_RUN) exit 0 &> /dev/null; do sleep 5; done;
	sleep 15
	scp clemens@$(IP):/etc/rancher/k3s/k3s.yaml k3sconfig.yaml
	sed -ie 's/127\.0\.0\.1/$(IP)/g' k3sconfig.yaml
	KUBECONFIG=k3sconfig.yaml kubectl get pods -A
	rm -f k3sconfig.yamle

.PHONY: host/k3s/config
host/k3s/config:
	scp $$PWD/host/k3s/config.yaml clemens@$(IP):/home/clemens/config
	$(SSH_RUN) sudo mkdir -p /etc/rancher/k3s
	$(SSH_RUN) sudo mv /home/clemens/config /etc/rancher/k3s/config.yaml
	$(SSH_RUN) sudo chown -R root:root /etc/rancher

.PHONY: host/k3s/registries
host/k3s/registries:
	scp $$PWD/host/k3s/registries.yaml clemens@$(IP):/home/clemens/registries
	$(SSH_RUN) sudo mkdir -p /etc/rancher/k3s
	$(SSH_RUN) sudo mv /home/clemens/registries /etc/rancher/k3s/registries.yaml
	$(SSH_RUN) sudo chown -R root:root /etc/rancher

.PHONY: host/k3s/traefik
host/k3s/traefik:
	scp $$PWD/host/k3s/traefik-config.yaml clemens@$(IP):/home/clemens/traefik
	$(SSH_RUN) sudo mkdir -p /var/lib/rancher/k3s/server/manifests
	$(SSH_RUN) sudo mv /home/clemens/traefik /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
	$(SSH_RUN) sudo chown -R root:root /var/lib/rancher

.PHONY: host/config
host/config: host/sshd_config host/sysctl host/nfs host/iscsi

.PHONY: host/sshd_config
host/sshd_config:
	scp $$PWD/host/ssh/sshd_config clemens@$(IP):/home/clemens/01-local.conf
	scp $$PWD/host/ssh/authorized_keys clemens@$(IP):/home/clemens/.ssh/authorized_keys
	$(SSH_RUN) sudo mv /home/clemens/01-local.conf /etc/ssh/sshd_config.d/01-local.conf
	$(SSH_RUN) sudo chown root /etc/ssh/sshd_config.d/01-local.conf
	$(SSH_RUN) sudo systemctl restart sshd


.PHONY: host/sysctl
host/sysctl:
	scp $$PWD/host/sysctl/fsnotify clemens@$(IP):/home/clemens/fsnotify
	scp $$PWD/host/sysctl/ipv4 clemens@$(IP):/home/clemens/ipv4
	$(SSH_RUN) sudo mv /home/clemens/fsnotify /etc/sysctl.d/01-local.conf
	$(SSH_RUN) sudo mv /home/clemens/ipv4 /etc/sysctl.d/90-ipv4-ip-forward.conf
	$(SSH_RUN) sudo chown -R root:root /etc/sysctl.d
	$(SSH_RUN) sudo restorecon -R /etc/sysctl.d

.PHONY: host/nfs
host/nfs:
	scp $$PWD/host/discs/exports clemens@$(IP):/home/clemens/exports
	$(SSH_RUN) sudo mv /home/clemens/exports /etc/exports
	$(SSH_RUN) sudo chown -R root:root /etc/exports
	$(SSH_RUN) sudo systemctl enable --now nfs-server
	$(SSH_RUN) sudo exportfs -a
	$(SSH_RUN) sudo systemctl restart nfs-server

.PHONY: host/iscsi
host/iscsi:
	$(SSH_RUN) sudo mkdir -p /etc/iscsi
	$(SSH_RUN) sudo 'echo "InitiatorName=$$(/sbin/iscsi-iname)" \> /etc/iscsi/initiatorname.iscsi'
	$(SSH_RUN) sudo systemctl enable --now iscsid

.PHONY: host/access
host/access: host/firewalld host/wireguard host/dnsmasq host/systemd-resolved

.PHONY: host/firewalld
host/firewalld:
	# not ideal, but it works and I did the same in NixOS 🤷
	$(SSH_RUN) sudo systemctl disable firewalld
	$(SSH_RUN) sudo systemctl stop firewalld

.PHONY: host/wireguard
host/wireguard:
	scp $$PWD/wg0.conf clemens@$(IP):/home/clemens/wg
	$(SSH_RUN) sudo mkdir -p /etc/wireguard
	$(SSH_RUN) sudo mv /home/clemens/wg /etc/wireguard/wg0.conf
	$(SSH_RUN) sudo chown -R root:root /etc/wireguard
	$(SSH_RUN) sudo restorecon -R /etc/wireguard
	$(SSH_RUN) sudo systemctl enable --now wg-quick@wg0
	$(SSH_RUN) sudo systemctl restart wg-quick@wg0

.PHONY: host/dnsmasq
host/dnsmasq:
	scp $$PWD/host/dns/dnsmasq clemens@$(IP):/home/clemens/dnsm
	$(SSH_RUN) sudo mv /home/clemens/dnsm /etc/dnsmasq.d/01-homelab.conf
	$(SSH_RUN) sudo chown root:root /etc/dnsmasq.d/01-homelab.conf
	$(SSH_RUN) sudo restorecon -R /etc/dnsmasq.d
	scp $$PWD/host/dns/homelab_hosts clemens@$(IP):/home/clemens/hlh
	$(SSH_RUN) sudo mkdir -p /etc/hosts.d
	$(SSH_RUN) sudo mv /home/clemens/hlh /etc/hosts.d/01-homelab
	$(SSH_RUN) sudo chown -R root:root /etc/hosts.d
	$(SSH_RUN) sudo restorecon -R /etc/hosts.d
	$(SSH_RUN) sudo systemctl enable --now dnsmasq
	$(SSH_RUN) sudo systemctl restart dnsmasq

.PHONY: host/systemd-resolved
host/systemd-resolved:
	scp $$PWD/host/dns/resolved clemens@$(IP):/home/clemens/resolved
	$(SSH_RUN) sudo mkdir -p /etc/systemd/resolved.conf.d
	$(SSH_RUN) sudo mv /home/clemens/resolved /etc/systemd/resolved.conf.d/dnsmasq.conf
	$(SSH_RUN) sudo chown -R root:root /etc/systemd/resolved.conf.d/
	$(SSH_RUN) sudo restorecon -R /etc/systemd/resolved.conf.d/
	$(SSH_RUN) sudo systemctl restart systemd-resolved
