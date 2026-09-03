#!/usr/bin/env bash
# Reference: https://gist.github.com/dmadisetti/16006751fd6e1526fa9c2f2e1660e8e3

################################################################################################################################################################################################################################
# Question: Are these self-signed certificates azure app gateway compliant? 
#   "The CN (Common Name) for the server certificate must be different from the issuer's domain": 
#    https://learn.microsoft.com/en-us/azure/application-gateway/self-signed-certificates#:~:text=The%20CN%20(Common%20Name)%20for%20the%20server%20certificate%20must%20be%20different%20from%20the%20issuer%27s%20domain
#
# Answer: Yes, they can be setup within our non-production Azure App Gateways even though we see the corresponding ssl-handsake error on the application logs or in the browser.
#
# Question: Are self-signed certificates App-Core compliant?
# Answer: NO, 
#   Self-signed wildcard certs are NOT App-Core compliant (connection between appcore and applink-cloud would fail)
#
# Purchasing *.dapps.enterprise.com wildcard cert is avoided (300€ per year). Instead we use a signed/purchased *.deng.enterprise.com wildard cert.
################################################################################################################################################################################################################################

################################################################
# How to generate self-signed wildcard certs with this script:
#
# Main branch:
# ./05-generate-wildcard-certificate.sh eng.enterprise.com
# ./05-generate-wildcard-certificate.sh apps.enterprise.com
#
# Develop branch:
# ./05-generate-wildcard-certificate.sh deng.enterprise.com
# ./05-generate-wildcard-certificate.sh dapps.enterprise.com
################################################################

#######################################################################################################################
# Alternative: Self-Signed Certificate with Az powershell script
# https://github.com/jeffwmiles/azure-dsc-pipeline/blob/master/Create-KeyVaultSelfSignedCertificate.ps1
#######################################################################################################################

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