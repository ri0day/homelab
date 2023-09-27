#!/usr/bin/env bash
NOMAD_ADDR=127.0.0.1:4646
read -p "Input Mysql User Password:" -s userpass
echo
read -p "Input Mysql Root Password:" -s rootpass
echo

sed  -e "s/temp_userpass/$userpass/g" -e "s/temp_rootpass/$rootpass/g" ./variables_template.hcl > ./spec.nv.hcl
nomad var put @./spec.nv.hcl

nomad job plan ./mariadb.nomad

