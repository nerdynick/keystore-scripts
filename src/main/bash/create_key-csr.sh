#!/bin/bash

set -o nounset \
    -o errexit

HOST=$1
KEY_PASSWORD="${2-test1234}"
VALID_DAYS="${3-365}" 
SUBJECT="${4-/C=US/ST=Colorado/L=Denver/O=Dis}/CN=${HOST}"


#Output Files
KEY_FILE="${HOST}.key"
CSR_FILE="${HOST}.csr"

#Cleanup older version
rm -f $KEY_FILE \
    $CSR_FILE

set -o xtrace

#Create Key
openssl genrsa \
    -passout pass:$KEY_PASSWORD \
    -out $KEY_FILE 2048

#Create CSR
openssl req \
    -new \
    -key $KEY_FILE \
    -out $CSR_FILE \
    -subj $SUBJECT