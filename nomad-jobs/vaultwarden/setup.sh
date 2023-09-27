#!/usr/bin/env bash
NOMAD_ADDR=127.0.0.1:4646
read -p "VaultWarden Admin Token:" -s admintoken
echo

sed  -e "s/temp_admintoken/$admintoken/" ./variables_template.hcl > ./spec.nv.hcl
nomad var put @./spec.nv.hcl

nomad job plan ./vaultwarden.nomad
