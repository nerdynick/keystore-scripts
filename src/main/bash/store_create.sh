#!/bin/bash

set -o nounset \
    -o errexit \
    -o verbose

HOST=$1
EXTRA=""
PASSWORD="test1234"
CA_CRT_FILE="casnakeoil-ca-1.crt"
CA_KEY_FILE="casnakeoil-ca-1.key"
VALID_DAYS=365

if [ ! -z "$2" ]
then
  EXTRA=",$2"
fi

echo "------------------------------- $HOST -------------------------------"
echo "------------------------------- $EXTRA -------------------------------"

KEYSTORE_FILE="${HOST}.keystore.jks"
TRUSTSTORE_FILE="${HOST}.truststore.jks"
CSR_FILE="${HOST}.csr"
CRT_FILE="${HOST}-ca1-signed.crt"

#Cleanup older version 
rm -rf $KEYSTORE_FILE
rm -rf $TRUSTSTORE_FILE
rm -rf $CSR_FILE
rm -rf $CRT_FILE

# Create host keystore
keytool -genkey -noprompt \
	-alias $HOST \
	-dname "CN=${HOST}" \
	-ext "san=DNS:$HOST$EXTRA"\
	-keystore $KEYSTORE_FILE \
	-keyalg RSA \
	-storepass $PASSWORD \
	-keypass $PASSWORD

# Create the certificate signing request (CSR)
keytool -storetype jks \
	-keystore $KEYSTORE_FILE \
	-alias $HOST \
	-certreq \
	-file $CSR_FILE \
	-storepass $PASSWORD \
	-keypass $PASSWORD \
	-ext "san=DNS:$HOST$EXTRA"

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
	-passin pass:$PASSWORD \
	-extfile <(cat $SSL_FILE <(printf "[SAN]\nsubjectAltName=DNS:$HOST$EXTRA")) \
	-extensions SAN


# Sign and import the CA cert into the keystore
keytool -noprompt -keystore $KEYSTORE_FILE -alias CARoot -import -file $CA_CRT_FILE -storepass $PASSWORD -keypass $PASSWORD

# Sign and import the host certificate into the keystore
keytool -noprompt -keystore $KEYSTORE_FILE -alias ${HOST} -import -file $CRT_FILE -storepass $PASSWORD -keypass $PASSWORD

# Create truststore and import the CA cert
keytool -storetype  jks  -noprompt -keystore $TRUSTSTORE_FILE -alias CARoot -import -file $CA_CRT_FILE -storepass $PASSWORD -keypass $PASSWORD