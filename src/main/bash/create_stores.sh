#!/bin/bash

set -o nounset \
    -o errexit

HOST=$1
KEY_PASSWORD="${2-test1234}"
STORE_PASSWORD="${3-test1234}"
CA_CRT_FILE="${4-casnakeoil.crt}"
KEY_FILE="${HOST}.key"
CRT_FILE="${HOST}.crt"

#Output files
KEYSTORE_FILE="${HOST}.keystore.jks"
KEYSTORE_FILE_P12="${HOST}.keystore.p12"
TRUSTSTORE_FILE="${HOST}.truststore.jks"
TRUSTSTORE_FILE_P12="${HOST}.truststore.p12"

#Cleanup older version
rm -f $KEYSTORE_FILE \
    $TRUSTSTORE_FILE \
    $KEYSTORE_FILE_P12 \
    $TRUSTSTORE_FILE_P12

set -o xtrace

# Create PK12 from both host files and CA crts
openssl pkcs12 \
    -export \
    -in $CRT_FILE \
    -inkey $KEY_FILE \
    -name $HOST \
    -certfile $CA_CRT_FILE \
    -passin pass:$KEY_PASSWORD \
    -passout pass:$STORE_PASSWORD \
    -out $KEYSTORE_FILE_P12
    
cp $KEYSTORE_FILE_P12 $TRUSTSTORE_FILE_P12

keytool -importkeystore \
    -srckeystore $KEYSTORE_FILE_P12 \
    -destkeystore $KEYSTORE_FILE \
    -deststoretype JKS \
    -srcstoretype PKCS12 \
    -srcstorepass $STORE_PASSWORD \
    -deststorepass $STORE_PASSWORD

keytool -importkeystore \
    -srckeystore $TRUSTSTORE_FILE_P12 \
    -destkeystore $TRUSTSTORE_FILE \
    -deststoretype JKS \
    -srcstoretype PKCS12 \
    -srcstorepass $STORE_PASSWORD \
    -deststorepass $STORE_PASSWORD