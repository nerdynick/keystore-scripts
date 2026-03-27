#! /bin/bash
# This script is designed to create a CA, Server(s), and Client(s) certificates with user-provided information. 
# It uses the Makefile in the parent directory to generate the necessary keystores and certificates.
# It will not create JKS versions, only PEM and P12 versions. 
# The JKS versions can be created separately using the Makefile targets if needed.

function join_sans {
    local SAN=""
    for domain in "${@}"; do
        SAN="${SAN},DNS:${domain}"
    done
    echo "${SAN#,}"
}

make -f ../Makefile clean

read -p "Enter Subject Location Info (Space Separated: City, State ABV, Country ABV): " SUB_CITY SUB_STATE SUB_COUNTRY
SUBJECT_LOCAL="/L=${SUB_CITY}/ST=${SUB_STATE}/C=${SUB_COUNTRY}"

read -p "Enter CA Domains (Space Separated): " -a CA_DOMAINS
read -sp "Enter CA Password: " CA_PASSWORD
echo ""

export CA_PASSWORD="$CA_PASSWORD"
export CA_FILENAME_PREFIX="Cluster-CA"
export CA_SUBJECT="/CN=${CA_DOMAINS[0]}${SUBJECT_LOCAL}"
export CA_SANS=$(join_sans "${CA_DOMAINS[@]}")

echo "$CA_SANS"

make -f ../Makefile create-ca

read -sp "Enter Server Password: " SERVER_PASSWORD
export SERVER_PASSWORD="$SERVER_PASSWORD"
echo ""

while true; do
    read -p "Enter Server Domains (Space Separated, or 'done' to finish): " -a SERVER_DOMAINS
    if [[ "${SERVER_DOMAINS[0]}" == "done" ]]; then
        break
    fi

    export SERVER_FILENAME_PREFIX="${SERVER_DOMAINS[0]}"
    export SERVER_SUBJECT="/CN=${SERVER_DOMAINS[0]}${SUBJECT_LOCAL}"
    export SERVER_SANS=$(join_sans "${SERVER_DOMAINS[@]}")
    make -f ../Makefile create-server
done

read -sp "Enter Client Password: " CLIENT_PASSWORD
export CLIENT_PASSWORD="$CLIENT_PASSWORD"
echo ""

while true; do
    read -p "Enter Client Domains (Space Separated, or 'done' to finish): " -a CLIENT_DOMAINS
    if [[ "${CLIENT_DOMAINS[0]}" == "done" ]]; then
        break
    fi

    export CLIENT_FILENAME_PREFIX="${CLIENT_DOMAINS[0]}"
    export CLIENT_SUBJECT="/CN=${CLIENT_DOMAINS[0]}${SUBJECT_LOCAL}"
    export CLIENT_SANS=$(join_sans "${CLIENT_DOMAINS[@]}")
    make -f ../Makefile create-client
done