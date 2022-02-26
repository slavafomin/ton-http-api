#!/bin/bash

set -e

CLOUDFLARE_FILE_PATH=/etc/nginx/cloudflare

echo "#Cloudflare" > $CLOUDFLARE_FILE_PATH;


echo "geo \$realip_remote_addr \$is_cf_allowed {" >> $CLOUDFLARE_FILE_PATH;
echo "  default 0;" >> $CLOUDFLARE_FILE_PATH;
for i in ${TON_API_WHITELISTED_IPS//:/ }
do
    echo "  $i 1;" >> $CLOUDFLARE_FILE_PATH;
done
for i in `curl -sL https://www.cloudflare.com/ips-v4`; do
    echo "  $i 1;" >> $CLOUDFLARE_FILE_PATH;
done
for i in `curl -sL https://www.cloudflare.com/ips-v6`; do
    echo "  $i 1;" >> $CLOUDFLARE_FILE_PATH;
done
echo "}" >> $CLOUDFLARE_FILE_PATH;

echo "" >> $CLOUDFLARE_FILE_PATH;
echo "# - IPv4" >> $CLOUDFLARE_FILE_PATH;
for i in `curl -sL https://www.cloudflare.com/ips-v4`; do
    echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
done

echo "" >> $CLOUDFLARE_FILE_PATH;
echo "# - IPv6" >> $CLOUDFLARE_FILE_PATH;
for i in `curl -sL https://www.cloudflare.com/ips-v6`; do
    echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
done

echo "" >> $CLOUDFLARE_FILE_PATH;
echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_FILE_PATH;

# reload nginx
if [[ $1 == "--reload" ]] ; then
    nginx -s reload
fi
