#!/bin/bash

set -o nounset \
    -o errexit

PASSWORD="${1-test1234}"
VALID_DAYS="${2-365}"
FILE_NAME="${3-casnakeoil}"
SUBJECT="${4-/CN=ca1.example.com/OU=TEST/O=MYORG/L=PaloAlto/ST=Ca/C=US}"


KEY_FILE="${FILE_NAME}.key"
CRT_FILE="${FILE_NAME}.crt"
P12_FILE="${FILE_NAME}.p12"

# Cleanup files
rm -f $KEY_FILE \
    $CRT_FILE \
    $P12_FILE

set -o xtrace

# Generate CA key
openssl req -new -x509 \
    -keyout $KEY_FILE \
    -out $CRT_FILE \
    -days $VALID_DAYS \
    -subj $SUBJECT \
    -passin pass:$PASSWORD \
    -passout pass:$PASSWORD
    
# Create PK12 from both files
openssl pkcs12 \
    -export \
    -in $CRT_FILE \
    -inkey $KEY_FILE \
    -passin pass:$PASSWORD \
    -passout pass:$PASSWORD \
    -out $P12_FILE