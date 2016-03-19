#!/bin/bash

: ${LDAP_URI:?"Missing variable LDAP_URI"}
: ${PROXY_URI:?"Missing variable PROXY_URI"}
: ${SERVERNAME:?"Missing variable SERVERNAME"}

: ${BASIC_AUTH_STRING:="LDAP authentication"}
: ${REQUIRE_COND:="Require valid-user"}
: ${LISTEN_PORT:=80}
: ${LOGLEVEL:=warn}
: ${ENABLE_WEBSOCKET:=yes}

if [[ -v HTTPS_CERT_PEM ]]; then
  if [[ -v HTTPS_KEY_PEM ]]; then
    echo "Missing bariable HTTPS_KEY_PEM"
    exit 1
  fi
  echo -e "$HTTPS_CERT_PEM" > /usr/local/apache2/conf/proxy_ldap.cert.pem
  echo -e "$HTTPS_KEY_PEM" > /usr/local/apache2/conf/proxy_ldap.key.pem
  [[ -v DHPARAM_PEM ]] && {
    echo "$DHPARAM_PEM" >> /usr/local/apache2/conf/proxy_ldap.cert.pem;
  }
fi


[[ -v LDAPS_CACERT_PEM ]] && {
  echo "$LDAPS_CACERT_PEM" > /ldap_cacert.pem
}


eval "cat >> /usr/local/apache2/conf/proxy_ldap.conf << EOF
$(cat /proxy_ldap.conf.template)
EOF"

[[ -v DISPLAY_CONFIG ]] && {
  cat /usr/local/apache2/conf/proxy_ldap.conf
}

# base image CMD
httpd-foreground
