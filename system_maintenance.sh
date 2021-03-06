#!/bin/sh

backup() {
  echo "Stopping containers"
  systemctl list-unit-files | grep "docker-.*\.service\s*enabled" | awk '{print $1}' | xargs systemctl stop
  echo "Starting backup"
  cd /home/clemens || exit 1
  rsync -avz --progress -h --delete data0/archive data0_bu
  rsync -avz --progress -h --delete data0/docker data0_bu
  rsync -avz --progress -h --delete data0/retroarch data0_bu
  echo "Backup finished"
  echo "Restarting containers"
  # restart traefik first because it has a fixed ip
  systemctl restart docker-traefik
  systemctl list-unit-files | grep "docker-.*\.service\s*enabled" | awk '{print $1}' | xargs systemctl start
  # sleep in case there are some dependency issues
  sleep 60
  systemctl list-unit-files | grep "docker-.*\.service\s*enabled" | awk '{print $1}' | xargs systemctl start
  sleep 120
  echo "Finished"
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
}

upgrade() {
  cd /home/clemens/Projects/homelab || exit 1

  systemctl stop gitops-update.timer
  systemctl stop gitops-upgrade.timer

  echo "Updating flake"
  nix flake update --commit-lock-file --commit-lockfile-summary "chore(flake): Update $(date -I)"

  echo "Updating system"
  nixos-rebuild switch --flake '.?submodules=1' --impure

  echo "Pushing updated flake"
  su clemens -c "git -C /home/clemens/Projects/homelab push"

  echo "Collecting garbage"
  nix-collect-garbage

  systemctl start gitops-update.timer
  systemctl start gitops-upgrade.timer
}

reboot() {
  echo "Scheduling reboot"
  shutdown -r
}

show_help() {
  echo "Perform system maintenance tasks:"
  echo "backup: backup system"
  echo "reboot: reboot system"
  echo "upgrade: update the nix flake and reload config"
}

case "$1" in
  backup)
    backup
    ;;
  upgrade)
    upgrade
    ;;
  reboot)
    reboot
    ;;
  *)
    show_help
    ;;
esac
