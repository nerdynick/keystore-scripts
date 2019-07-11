#!/bin/bash

set -o nounset \
    -o errexit \
    -o verbose
#    -o xtrace

PASSWORD="test1234"
SUBJECT='/CN=ca1.example.com/OU=TEST/O=MYORG/L=PaloAlto/ST=Ca/C=US'
FILE_NAME="casnakeoil-ca-1"
VALID_DAYS=365

KEY_FILE="${FILE_NAME}.key"
CRT_FILE="${FILE_NAME}.crt"

# Cleanup files
rm -f $KEY_FILE $CRT_FILE

# Generate CA key
openssl req -new -x509 \
	-keyout $KEY_FILE \
	-out $CRT_FILE \
	-days $VALID_DAYS \
	-subj $SUBJECT \
	-passin pass:$PASSWORD \
	-passout pass:$PASSWORD