# TLS Certificates and Keystore Generation Scripts

A Collection of scripts/commands to quickly create a Certificate Authority (CA) and produce client/server 

> [!IMPORTANT]
> Starting with V1.0, all files contained with `/src` should be considered deprecated. These items will remain for the time being for anyone that still wishes to use them.

# Via Makefile

The makefile approach is the all-in-one approach. Everything you need is all contained in 1 script. You will need to create the CA certs prior to creating and client & server certificate. With all outputs, a Key, Cert, and P12 Keystore are created. As well as an optional Java Key Store (jks) can be created in addition, leveraging `keytool`.

## Creating a CA

**Variables**

| Variable               | Default   |
| ----------             | --------- |
| CA_FILENAME_PREFIX     | CA-Example |
| CA_EXP_DAYS            | "365" |
| CA_SUBJECT             | "/CN=ca.example.com/OU=TEST/O=MYORG/L=PaloAlto/ST=Ca/C=US" |
| CA_PASSWORD            | test123 |
| CA_TRUSTSTORE_PASSWORD | test123 |

**Make Calls**

| Call               | Desc |
| ------------------ | ---- |
| create-ca          | Create Key, Cert, and P12 for the CA |
| create-ca-jks      | Takes the output of `create-ca` and create a JKS Keystore |
| create-ca-with-jks | Shortcut to run both `create-ca` and `create-ca-jks` |

## Creating a General Purpose Cert

**Variables**

| Variable                | Default   |
| ----------              | --------- |
| CSR_FILENAME_PREFIX     | CSR-Example |
| CSR_EXP_DAYS            | "365" |
| CA_SUBJECT              | "/CN=client.example.com/OU=TEST/O=MYORG/L=PaloAlto/ST=Ca/C=US" |
| CSR_SUBJECT             | test1234 |
| CSR_TRUSTSTORE_PASSWORD | test1234 |

**Make Calls**

| Call                      | Desc |
| ------------------        | ---- |
| create-csr                | Creates a Key and associated Certificate Signing Request |
| sign-csr                  | Takes the output of `create-csr` and the already created CA to Sign the Cert and produce the Cert & P12 Keystore |
| create-csr-jks            | Takes the output of `sign-csr` and create a JKS Keystore |
| create-sign-cert          | Shortcut for `create-csr` + `sign-csr` |
| create-sign-cert-with-jks | Shortcut for `create-csr` + `sign-csr` + `create-csr-jks` |

## Creating a Client Cert

**Variables**

| Variable                    | Default   |
| ----------                  | --------- |
| CLIENT_FILENAME_PREFIX      | Client-Example |
| CLIENT_EXP_DAYS             | "365" |
| CLIENT_SUBJECT              | "/CN=client.example.com/OU=TEST/O=MYORG/L=PaloAlto/ST=Ca/C=US" |
| CLIENT_SUBJECT              | test1234 |
| CLIENT_TRUSTSTORE_PASSWORD  | test1234 |

**Make Calls**

| Call                   | Desc |
| ------------------     | ---- |
| create-client          | Create Key, CSR, Cert, and P12 for a Client |
| create-client-jks      | Takes the output of `create-client` and create a JKS Keystore |
| create-client-with-jks | Shortcut for `create-client` + `create-client-jks` |

## Creating a Server Cert

**Variables**

| Variable                    | Default   |
| ----------                  | --------- |
| SERVER_FILENAME_PREFIX      | Server-Example |
| SERVER_EXP_DAYS             | "365" |
| SERVER_SUBJECT              | "/CN=server.example.com/OU=TEST/O=MYORG/L=PaloAlto/ST=Ca/C=US" |
| SERVER_SUBJECT              | test1234 |
| SERVER_TRUSTSTORE_PASSWORD  | test1234 |

**Make Calls**

| Call                   | Desc |
| ------------------     | ---- |
| create-server          | Create Key, CSR, Cert, and P12 for a Server |
| create-server-jks      | Takes the output of `create-server` and create a JKS Keystore |
| create-server-with-jks | Shortcut for `create-server` + `create-server-jks` |

## Creating Client & Server

**Variables** 

All the Client and Server Vars listed above are used

**Make Calls**

| Call                        | Desc |
| ------------------          | ---- |
| client-server-pair          | Create Key, CSR, Cert, and P12 for both Client & Server. This is just calling the above similar commands for each |
| client-server-pair-with-jks | Like `client-server-pair` but includes JKS Keystore |
