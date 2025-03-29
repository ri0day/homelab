#!/usr/bin/env bash
NOMAD_ADDR=127.0.0.1:4646
read -p "Cloudflare Dns Api Token:" -s cfdnstoken
echo
sed -e "s/temp_cfdnstoken/$cfdnstoken/g" ./variables_template.hcl > ./spec.nv.hcl

nomad var put @./spec.nv.hcl

nomad job plan ./traefik.nomad
