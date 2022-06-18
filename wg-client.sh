#!/bin/sh

# TODO make configurable
clientName="deck"
clientIP="10.6.0.5"
umask 077

mkdir -p "./wg-client-$clientName"
cd "./wg-client-$clientName" || exit

wg genkey | tee "${clientName}.key" | wg pubkey > "${clientName}.pub"
wg genpsk > "${clientName}.psk"

# TODO automate?
echo "add the keys to the server-config:"
echo "1. add to secrets.yaml"
echo "2. add to sops.nix"
echo "3. nixos-rebuild"
echo "4. add to wireguard.nix:"
echo "{"
echo "  # ${clientName}"
echo "  publicKey = builtins.readFile \"/run/secrets/wg/${clientName}/public_key\";"
echo "  presharedKeyFile = \"/run/secrets/wg/${clientName}/pre_shared_key\";"
echo "  allowedIPs = [ \"$clientIP/32\" ];"
echo "}"

echo "created client config"

echo "[Interface]" > home.conf
{
  echo "PrivateKey = $(cat "${clientName}.key")"
  echo "Address = $clientIP/24"
  echo "MTU = 1420"
  echo "DNS = 10.6.0.1"
  echo ""
  echo "[Peer]"
  echo "PublicKey = $(cat /run/secrets/wg/public_key)"
  echo "PresharedKey = $(cat "${clientName}.psk")"
  echo "Endpoint = wallstreet30.cc:51820"
  echo "AllowedIPs = 0.0.0.0/0, ::0/0"
} >> home.conf

cd ..
