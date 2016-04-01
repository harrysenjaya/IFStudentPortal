#!/bin/bash

export PW=`cat password`

# Create a server certificate, tied to localhost:9000
keytool -genkeypair -v \
  -alias IFStudentPortal \
  -dname "CN=localhost:9000, OU=IFStudentPortal, O=Universitas Katolik Parahyangan, L=Bandung, ST=Jawa Barat, C=ID" \
  -keystore IFStudentPortal.jks \
  -keypass:env PW \
  -storepass:env PW \
  -keyalg EC \
  -keysize 256 \
  -validity 385

# Create a certificate signing request for localhost:9000
keytool -certreq -v \
  -alias IFStudentPortal \
  -keypass:env PW \
  -storepass:env PW \
  -keystore IFStudentPortal.jks \
  -file IFStudentPortal.csr

# Tell IFStudentPortal-CA to sign the localhost:9000 certificate. 
# Technically, digitalSignature for DHE or ECDHE, keyEncipherment for RSA 
keytool -gencert -v \
  -alias IFStudentPortal-CA \
  -keypass:env PW \
  -storepass:env PW \
  -keystore IFStudentPortal-CA.jks \
  -infile IFStudentPortal.csr \
  -outfile IFStudentPortal.crt \
  -ext KeyUsage:critical="digitalSignature,keyEncipherment" \
  -ext EKU="serverAuth" \
  -ext SAN="DNS:localhost" \
  -rfc

# Tell IFStudentPortal.jks it can trust exampleca as a signer.
keytool -import -v \
  -alias IFStudentPortal-CA \
  -file IFStudentPortal-CA.crt \
  -keystore IFStudentPortal.jks \
  -storetype JKS \
  -storepass:env PW << EOF
yes
EOF

# Import the signed certificate back into IFStudentPortal.jks 
keytool -import -v \
  -alias IFStudentPortal \
  -file IFStudentPortal.crt \
  -keystore IFStudentPortal.jks \
  -storetype JKS \
  -storepass:env PW

# List out the contents of IFStudentPortal.jks just to confirm it.  
# If you are using Play as a TLS termination point, this is the key store you should use.
keytool -list -v \
  -keystore IFStudentPortal.jks \
  -storepass:env PW