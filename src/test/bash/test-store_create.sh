#! /bin/sh

SCRIPTS_DIR=./src/main/bash

testStoreCreateWithDefaults(){
	/bin/bash "$SCRIPTS_DIR/store_create.sh" example ""
	
	assertTrue 'Keystore File Missing' "[ -r $PWD/example.keystore.jks ]"
	assertTrue 'Truststore File Missing' "[ -r $PWD/example.truststore.jks ]"
	assertTrue 'CSR File Missing' "[ -r $PWD/example.csr ]"
	assertTrue 'CRT File Missing' "[ -r $PWD/example-ca1-signed.crt ]"
}


. shunit2