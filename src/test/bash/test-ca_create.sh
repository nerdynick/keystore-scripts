#! /bin/sh

SCRIPTS_DIR=./src/main/bash

testCACreateWithDefaults(){
	/bin/sh "$SCRIPTS_DIR/ca_create.sh"
	
	assertTrue 'Key File Missing' "[ -r $PWD/casnakeoil-ca-1.key ]"
	assertTrue 'CRT File Missing' "[ -r $PWD/casnakeoil-ca-1.crt ]"
	assertTrue 'Invalid CA Key' "openssl rsa -in casnakeoil-ca-1.key -check -noout -passin pass:test1234"
}


. shunit2