#! /bin/sh

SCRIPTS_DIR=../../main/bash

testCACreate(){
	/bin/sh "$SCRIPTS_DIR/ca_create.sh"
	assertTrue 'Key File missing' "[ -r casnakeoil-ca-1.key' ]"
	assertTrue 'CRT File Missing' "[ -r casnakeoil-ca-1.crt' ]"
}