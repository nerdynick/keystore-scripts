#!/bin/bash

set -o nounset \
    -o errexit

HOST=$1
KEY_PASSWORD="${2-test1234}"
CA_PASSWORD="${3-test1234}"
CA_CRT_FILE="${4-casnakeoil.crt}"
CA_KEY_FILE="${5-casnakeoil.key}"
VALID_DAYS="${6-365}" 
CSR_FILE="${HOST}.csr"

#Output Files
CRT_FILE="${HOST}.crt"


#Cleanup older version
rm -rf $CRT_FILE

set -o xtrace

# Sign the host certificate with the certificate authority (CA)
if [ -f "/etc/pki/tls/openssl.cnf" ]
then
    SSL_FILE="/etc/pki/tls/openssl.cnf"
else
    SSL_FILE="/etc/ssl/openssl.cnf"
fi
openssl x509 -req \
	-CA $CA_CRT_FILE \
	-CAkey $CA_KEY_FILE \
	-in $CSR_FILE \
	-out $CRT_FILE \
	-days $VALID_DAYS \
	-CAcreateserial \
	-passin pass:$CA_PASSWORD \
	-extensions SAN