OUTPUT_FOLDER?=./output

#CA - Certificate Authority Configs
CA_FILENAME_PREFIX?="CA-Example"
CA_KEY_FILENAME="${OUTPUT_FOLDER}/${CA_FILENAME_PREFIX}-key.pem"
CA_CERT_FILENAME="${OUTPUT_FOLDER}/${CA_FILENAME_PREFIX}-cert.pem"
CA_P12_FILENAME="${OUTPUT_FOLDER}/${CA_FILENAME_PREFIX}.p12"
CA_EXP_DAYS?="365"
CA_SUBJECT?="/CN=ca.example.com/L=PaloAlto/ST=Ca/C=US"
CA_PASSWORD?=test123
CA_SANS?=("DNS:ca.example.com")

CA_TRUSTSTORE="${OUTPUT_FOLDER}/${CA_FILENAME_PREFIX}-trust.jks"
CA_TRUSTSTORE_PASSWORD?=test123

#CSR - Generic Certificate Signing Request Configs
CSR_FILENAME_PREFIX?="CSR-Example"
CSR_KEY_FILENAME="${OUTPUT_FOLDER}/${CSR_FILENAME_PREFIX}-key.pem"
CSR_CSR_FILENAME="${OUTPUT_FOLDER}/${CSR_FILENAME_PREFIX}-csr.pem"
CSR_CERT_FILENAME="${OUTPUT_FOLDER}/${CSR_FILENAME_PREFIX}-cert.pem"
CSR_P12_FILENAME="${OUTPUT_FOLDER}/${CSR_FILENAME_PREFIX}.p12"
CSR_EXP_DAYS?="365"
CSR_SUBJECT?="/CN=client.example.com/OU=TEST/O=MYORG/L=PaloAlto/ST=Ca/C=US"
CSR_PASSWORD?=test1234

CSR_TRUSTSTORE="${OUTPUT_FOLDER}/${CSR_FILENAME_PREFIX}-trust.jks"
CSR_TRUSTSTORE_PASSWORD?=test1234

#Client-Server Pair Configs
CLIENT_FILENAME_PREFIX?="Client-Example"
CLIENT_KEY_FILENAME="${OUTPUT_FOLDER}/${CLIENT_FILENAME_PREFIX}-key.pem"
CLIENT_CERT_FILENAME="${OUTPUT_FOLDER}/${CLIENT_FILENAME_PREFIX}-cert.pem"
CLIENT_P12_FILENAME="${OUTPUT_FOLDER}/${CLIENT_FILENAME_PREFIX}.p12"
CLIENT_EXP_DAYS?="365"
CLIENT_SUBJECT?="/CN=client.example.com/OU=TEST/O=MYORG/L=PaloAlto/ST=Ca/C=US"
CLIENT_PASSWORD?=test1234
CLIENT_SANS?=("DNS:client.example.com")

CLIENT_TRUSTSTORE="${OUTPUT_FOLDER}/${CLIENT_FILENAME_PREFIX}.jks"
CLIENT_TRUSTSTORE_PASSWORD?=test1234

SERVER_FILENAME_PREFIX?="Server-Example"
SERVER_KEY_FILENAME="${OUTPUT_FOLDER}/${SERVER_FILENAME_PREFIX}-key.pem"
SERVER_CERT_FILENAME="${OUTPUT_FOLDER}/${SERVER_FILENAME_PREFIX}-cert.pem"
SERVER_P12_FILENAME="${OUTPUT_FOLDER}/${SERVER_FILENAME_PREFIX}.p12"
SERVER_EXP_DAYS?="365"
SERVER_SUBJECT?="/CN=server.example.com/OU=TEST/O=MYORG/L=PaloAlto/ST=Ca/C=US"
SERVER_PASSWORD?=test1234
SERVER_SANS?=("DNS:server.example.com")

SERVER_TRUSTSTORE="${OUTPUT_FOLDER}/${SERVER_FILENAME_PREFIX}.jks"
SERVER_TRUSTSTORE_PASSWORD?=test1234

.PHONY: clean
clean:
	rm -Rf $(OUTPUT_FOLDER)

.PHONY: setup
setup:
	mkdir -p $(OUTPUT_FOLDER)

# 1st Creates a CA Private Key and Certificate
# 2nd Ports the CA Key and Cert into a P12 Format
.PHONY: create-ca
create-ca: setup
	openssl req -new -x509 -outform PEM \
		-addext "keyUsage=critical, digitalSignature, cRLSign, keyCertSign" \
		-addext "subjectAltName=$(CA_SANS)" \
		-keyout $(CA_KEY_FILENAME) \
		-out $(CA_CERT_FILENAME) \
		-days $(CA_EXP_DAYS) \
		-subj $(CA_SUBJECT) \
		-passin env:CA_PASSWORD \
		-passout env:CA_PASSWORD

	openssl pkcs12 \
		-export \
		-in $(CA_CERT_FILENAME) \
		-inkey $(CA_KEY_FILENAME) \
		-passin env:CA_PASSWORD \
		-passout env:CA_PASSWORD \
		-out $(CA_P12_FILENAME)

.PHONY: create-ca-jks
create-ca-jks:
	keytool -importkeystore \
		-srckeystore $(CA_P12_FILENAME)2 \
		-destkeystore $(CA_TRUSTSTORE) \
		-deststoretype JKS \
		-srcstoretype PKCS12 \
		-srcstorepass $(CA_PASSWORD) \
		-deststorepass $(CA_TRUSTSTORE_PASSWORD)

.PHONY: create-ca-with-jks
create-ca-with-jks: create-ca create-ca-jks

# Creates a generic certificate signing request
.PHONY: create-csr
create-csr: setup
	openssl req -new -outform PEM \
		-keyout $(CSR_KEY_FILENAME) \
		-out $(CSR_CSR_FILENAME) \
		-subj $(CSR_SUBJECT) \
		-passin env:CSR_PASSWORD \
		-passout env:CSR_PASSWORD

.PHONY: sign-csr
sign-csr: setup
	openssl x509 -req -outform PEM \
		-CA $(CA_CERT_FILENAME) \
		-CAkey $(CA_KEY_FILENAME) \
		-in $(CSR_CSR_FILENAME) \
		-out $(CSR_CERT_FILENAME) \
		-days $(CSR_EXP_DAYS) \
		-passin env:CA_PASSWORD

	openssl pkcs12 \
		-export \
		-in $(CSR_CERT_FILENAME) \
		-inkey $(CSR_KEY_FILENAME) \
		-out $(CSR_P12_FILENAME) \
		-passin env:CSR_PASSWORD \
		-passout env:CSR_PASSWORD

.PHONY: create-csr-jks
create-csr-jks: setup
	keytool -importkeystore \
		-srckeystore $(CSR_P12_FILENAME)2 \
		-destkeystore $(CSR_TRUSTSTORE) \
		-deststoretype JKS \
		-srcstoretype PKCS12 \
		-srcstorepass $(CSR_PASSWORD) \
		-deststorepass $(CSR_TRUSTSTORE_PASSWORD)

.PHONY: create-sign-cert
create-sign-cert: create-csr sign-csr

.PHONY: create-sign-cert-with-jks
create-sign-cert-with-jks: create-sign-cert create-csr-jks

.PHONY: create-client
create-client: setup
	openssl req -new -x509 -outform PEM \
		-addext "keyUsage=nonRepudiation, digitalSignature, keyEncipherment" \
		-addext "extendedKeyUsage=clientAuth, codeSigning, emailProtection" \
		-addext "subjectAltName=$(CLIENT_SANS)" \
		-CA $(CA_CERT_FILENAME) \
		-CAkey $(CA_KEY_FILENAME) \
		-keyout $(CLIENT_KEY_FILENAME) \
		-out $(CLIENT_CERT_FILENAME) \
		-subj $(CLIENT_SUBJECT) \
		-days $(CLIENT_EXP_DAYS) \
		-passin env:CA_PASSWORD \
		-passout env:CLIENT_PASSWORD

	openssl pkcs12 \
		-export \
		-in $(CLIENT_CERT_FILENAME) \
		-inkey $(CLIENT_KEY_FILENAME) \
		-out $(CLIENT_P12_FILENAME) \
		-passin env:CLIENT_PASSWORD \
		-passout env:CLIENT_PASSWORD

.PHONY: create-client-jks
create-client-jks: setup
	keytool -importkeystore \
		-srckeystore $(CLIENT_P12_FILENAME)2 \
		-destkeystore $(CLIENT_TRUSTSTORE) \
		-deststoretype JKS \
		-srcstoretype PKCS12 \
		-srcstorepass $(CLIENT_PASSWORD) \
		-deststorepass $(CLIENT_TRUSTSTORE_PASSWORD)

.PHONY: create-client-with-jks
create-client-with-jks: create-client create-client-jks

.PHONY: create-server
create-server: setup
	openssl req -new -outform PEM \
		-addext "keyUsage=nonRepudiation, digitalSignature, keyEncipherment" \
		-addext "extendedKeyUsage=serverAuth, clientAuth, codeSigning, emailProtection" \
		-addext "subjectAltName=$(SERVER_SANS)" \
		-CAkey $(CA_KEY_FILENAME) \
		-keyout $(SERVER_KEY_FILENAME) \
		-out $(SERVER_CERT_FILENAME) \
		-subj $(SERVER_SUBJECT) \
		-days $(SERVER_EXP_DAYS) \
		-passin env:CA_PASSWORD \
		-passout env:SERVER_PASSWORD

	openssl pkcs12 \
		-export \
		-in $(SERVER_CERT_FILENAME) \
		-inkey $(SERVER_KEY_FILENAME) \
		-out $(SERVER_P12_FILENAME) \
		-passin env:SERVER_PASSWORD \
		-passout env:SERVER_PASSWORD

.PHONY: create-server-jks
create-server-jks: setup
	keytool -importkeystore \
		-srckeystore $(SERVER_P12_FILENAME)2 \
		-destkeystore $(SERVER_TRUSTSTORE) \
		-deststoretype JKS \
		-srcstoretype PKCS12 \
		-srcstorepass $(SERVER_PASSWORD) \
		-deststorepass $(SERVER_TRUSTSTORE_PASSWORD)

.PHONY: create-server-with-jks
create-server-with-jks: create-server create-server-jks

.PHONY: client-server-pair
client-server-pair: create-client create-server

.PHONY: client-server-pair-with-jks
client-server-pair-with-jks: create-client-with-jks create-server-with-jks