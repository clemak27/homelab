#!/bin/sh

mkdir -p ~/Projects
cd Projects || exit 1
git clone https://github.com/clemak27/homelab.git
cd homelab || exit 1
toolbox create nix
toolbox run -c nix ~/Projects/homelab/init_nix_toolbox.sh
