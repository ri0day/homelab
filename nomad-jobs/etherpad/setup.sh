#!/usr/bin/env bash
NOMAD_ADDR=127.0.0.1:4646
read -p "set Etherpad Admin passwword:" -s adminpass
echo
read -p "DB username" -s db_user
echo
read -p "DB password" -s db_pass

sed  -e "s/temp_adminpassword/$adminpass/"  -e "s/temp_dbuser/$db_user/"  -e "s/temp_dbpass/$db_pass/" ./variables_template.hcl > ./spec.nv.hcl
nomad var put @./spec.nv.hcl

nomad job plan ./etherpad.nomad
