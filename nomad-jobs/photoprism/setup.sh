#!/usr/bin/env bash
NOMAD_ADDR=127.0.0.1:4646
read -p "Set Phoroprism Site URL:"  siteurl
echo
read -p "Set Photoprism Admin Password:" -s adminpass
echo
read -p "Set Database Name For Photoprism:"  dbname
echo
read -p "Set Database UserName For Photoprism:" username
echo
read -p "Set Database Password for Photiprism:" -s userpass
echo

echo $siteurl
sed  -e "s#temp_userpass#$userpass#g" \
	-e "s#temp_adminpass#$adminpass#g" \
       	-e "s#temp_dbname#$dbname#g" \
	-e "s#temp_siteurl#$siteurl#g" \
	-e "s#temp_username#$username#g" ./variables_template.hcl > ./spec.nv.hcl

nomad var put @./spec.nv.hcl

nomad job plan ./photoprism-app.nomad
