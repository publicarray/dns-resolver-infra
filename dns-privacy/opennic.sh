#!/bin/bash

# Source: https://gist.github.com/netravnen/4a3a775ddb9be8d868bfd6bd2cb0cff8
# https://wiki.opennic.org/opennic/srvzone


# conf_file="/etc/unbound/opennic.conf"
conf_file="dns-privacy/opennic.conf"

opennic_root_ns="161.97.219.84 2001:470:4212:10:0:100:53:10 163.172.168.171 94.103.153.176 2a02:990:219:1:ba:1337:cafe:3 178.63.116.152 2a01:4f8:141:4281::999 209.141.36.19 188.226.146.136 2a03:b0c0:0:1010::13f:6001 198.98.51.33 144.76.103.143 2a01:4f8:192:43a5::2"

# Declare OpenNIC TLDs
opennic_tlds=""
#opennic_tlds="bbs chan cyb dyn geek gopher indy libre neo null o oss oz parody pirate" # CURRENT TOP-LEVEL DOMAINS
#opennic_tlds+=" free" # INACTIVE TOP-LEVEL DOMAINS
# opennic_tlds+=" bazar coin emc coin lib fur bit ku te ti uu" # PEERED TOP-LEVEL DOMAINS
opennic_tlds+=" opennic.glue dns.opennic.glue" # TECHNICAL ZONES

# Fetch random selection of OpenNIC servers
curl_url_opts="--data-urlencode adm=2 --data-urlencode res=3 --data-urlencode bare --data-urlencode wl=all --data-urlencode rnd=true --data-urlencode pct=99" # api params
openic_api_url="https://api.opennicproject.org/geoip/" # api url
opennic_servers="$(curl -snGL ${curl_url_opts} --data-urlencode ipv=4 ${openic_api_url})"
opennic_servers+=" $(curl -snGL ${curl_url_opts} --data-urlencode ipv=6 ${openic_api_url})"

one_opennic_root_ns=$(echo $opennic_root_ns | awk '{print $1}')

#dig . NS @$one_opennic_root_ns
opennic_tlds+=$(dig @$one_opennic_root_ns TXT tlds.opennic.glue +short | grep -v '^;' | sed s/\"//g)
echo $opennic_tlds
# dig +tcp . axfr @$one_opennic_root_ns

# Start printing the new file
ifs=$IFS
rm -f "$conf_file"
{ echo "#"
  echo "# OpenNIC zone config"
  echo "# Generated on `date '+%A, %d %b %Y at %T'`"
  echo "#"
} >> "$conf_file"

# Collect list of TLDs
for TLD in $opennic_tlds; do
  echo
  echo "auth-zone:"
  echo "    name: $TLD"
  echo "    zonefile: run/$TLD.zone"
  echo "    for-downstream: no"
  echo "    for-upstream: yes"
  echo "    primary: 127.0.0.1"
  # Collect a list of master nameservers for the zone
  for NS in $opennic_root_ns; do
    echo "    primary: $NS"  
  done
done >> "$conf_file"

# echo $conf_file
cat $conf_file
exit 0