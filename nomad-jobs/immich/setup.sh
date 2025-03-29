#!/usr/bin/env bash
NOMAD_ADDR=127.0.0.1:4646
setupredis(){
read -p "Input Redis authtoken:" -s authtoken
echo
sed  -e "s/temp_auth_token/$authtoken/g"  ./redis_vars_template.hcl > ./redis_spec.nv.hcl

nomad var put -force @./redis_spec.nv.hcl
nomad job plan ./redis.nomad
}

setuppg(){
read -p "Input PG password:" -s pg_passwd
sed -e "s/temp_pg_passwd/$pg_passwd/g" ./pg_vars_template.hcl >./pg_spec.nv.hcl
nomad var put -force @./pg_spec.nv.hcl
nomad job plan ./pg.nomad
}
setupimmich(){

read -p "Input DB password:" -s pg_passwd
echo
read -p "Input REDIS password:" -s redis_authtoken
sed -e "s/temp_db_password/$pg_passwd/g" -e "s/temp_redis_password/$redis_authtoken/g" ./immich_vars_template.hcl >./immich_spec.nv.hcl
nomad var put -force @./immich_spec.nv.hcl
nomad job plan ./immich-server.nomad
}
eval $1
