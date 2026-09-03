#!/usr/bin/env bash
# Reference: https://gist.github.com/dmadisetti/16006751fd6e1526fa9c2f2e1660e8e3

################################################################
# How to generate wildcard certs with this script:
#
# ./generate-wildcard-certificate.sh dev.enterprise.com
# ./generate-wildcard-certificate.sh qa.enterprise.com
# ./generate-wildcard-certificate.sh uat.enterprise.com
# ./generate-wildcard-certificate.sh pre.enterprise.com
# ./generate-wildcard-certificate.sh apps.enterprise.com
################################################################

# print usage
DOMAIN=$1
if [ -z "$1" ]; then
    echo "USAGE: $0 tld"
    echo ""
    echo "This will generate a non-secure self-signed wildcard certificate for "
    echo "a given development tld."
    echo "This should only be used in a development environment."
    exit
fi

# Add wildcard
WILDCARD="*.$DOMAIN"

# Set our variables
cat <<EOF > req.cnf
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = US
ST = MD
O = home
localityName = home
commonName = $WILDCARD
organizationalUnitName = home
emailAddress = $(git config user.email)
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1   = https.$DOMAIN
DNS.2   = *.https.$DOMAIN
IP   = 127.0.0.1
EOF

# Generate our Private Key, and Certificate directly
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout "$DOMAIN.key" -config req.cnf \
  -out "$DOMAIN.crt" -sha256
rm req.cnf

echo ""
echo "Converting certificate into PFX format (required by Azure):"
openssl pkcs12 -export -inkey $DOMAIN.key -in $DOMAIN.crt -out $DOMAIN.pfx
echo "Next manual steps:"
#echo "- Use $DOMAIN.crt and $DOMAIN.key to configure Apache/nginx"
#echo "- Import $DOMAIN.crt into Chrome settings: chrome://settings/certificates > tab 'Authorities'"
echo "- Use $DOMAIN.pfx to configure Azure App Gateway and/or App Service"