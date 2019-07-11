# Java Keystore Scripts
Simple Self-Signed Keystore and Truststore generation scripts

[![Build Status](https://travis-ci.org/nerdynick/keystore-scripts.svg?branch=master)](https://travis-ci.org/nerdynick/keystore-scripts)


# Root CA

## Available Variables

|Name/Desc         |  ENV Var  |CLI Arg Position|Default                                                  |
|:-----------------|:---------:|:--------------:|:--------------------------------------------------------|
|Password          |CA_PASSWORD|       1        |test1234                                                 |
|Validation in Days| CA_VALID  |       2        |365                                                      |
|Subject           |CA_SUBJECT |       4        |/CN=ca1.example.com/OU=TEST/O=MYORG/L=PaloAlto/ST=Ca/C=US|
|File Name         |CA_FILENAME|       3        |casnakeoil-ca-1                                          |

## Examples

**Generating Root CA using Default values**
```bash
$> ./ca_create.sh
```

# Keystore & Truststore 

## Available Variables

|Name/Desc              |  ENV Var  |CLI Arg Position|Default        |
|:----------------------|:---------:|:--------------:|:--------------|
|Hostname/Alias         | CN_ALIAS  |       1        |*REQUIRE*      |
|Addition SAN Attributes|  CN_SAN   |       2        |*EMPTY*        |
|Validation in Days     | CN_VALID  |       3        |365            |
|Password               |CN_PASSWORD|       4        |test1234       |
|CA Filename(s)         |CA_FILENAME|       5        |casnakeoil-ca-1|
|CA Password            |CA_PASSWORD|       6        |test123        |

## Examples

**Generating Signed Keystore and Truststore using Default values**
```bash
$> ./sotre_create.sh
```