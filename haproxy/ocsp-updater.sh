#!/bin/sh

set -x
set -e

# https://www.haproxy.com/blog/haproxy-1-9-has-arrived/
# https://icicimov.github.io/blog/server/HAProxy-OCSP-stapling/

# Certificates path and names
DIR="/opt/ssl"
CERT="fullchain-key.pem"
CERT_RSA="fullchain-key.pem.rsa"
CERT_ECC="fullchain-key.pem.ecdsa"
RUNTIME_API=/run/haproxy/admin.sock

create_ocsp () {
    CERT=$1

    # Get the issuer URI, download it's certificate and convert into PEM format
    ISSUER_URI=$(openssl x509 -in ${DIR}/${CERT} -text -noout | grep 'CA Issuers' | cut -d: -f2,3)
    ISSUER_NAME=letsencrypt
    if [ -z "$ISSUER_URI" ]; then
        exit 1
    fi

    wget -q -O- "$ISSUER_URI" | openssl x509 -inform DER -outform PEM -out ${DIR}/${ISSUER_NAME}.pem

    # Get the OCSP URL from the certificate
    ocsp_url=$(openssl x509 -noout -ocsp_uri -in ${DIR}/${CERT})

    # Extract the hostname from the OCSP URL
    ocsp_host=$(echo "$ocsp_url" | cut -d/ -f3)

    # Create/update the ocsp response file and update HAProxy
    openssl ocsp -noverify -no_nonce -issuer ${DIR}/${ISSUER_NAME}.pem -cert ${DIR}/${CERT} -url "$ocsp_url" -header Host="$ocsp_host" -respout ${DIR}/${CERT}.ocsp
    [ $? -eq 0 ] && [ "$(pidof haproxy)" ] && [ -s ${DIR}/${CERT}.ocsp ] && echo "set ssl ocsp-response $(base64 -w 0 ${DIR}/${CERT}.ocsp)" | socat $RUNTIME_API stdio
}

create_ocsp $CERT
create_ocsp $CERT_RSA
create_ocsp $CERT_ECC

sleep 259200 # 3 days
exit 0
