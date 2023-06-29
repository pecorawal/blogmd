#!/bin/sh
dns_names="glauth.glauth.svc.cluster.local glauth.ddns.net glauth.duckdns.org glauth.mscastro.net"
subj_alt_name="subjectAltName=DNS:`echo $dns_names | sed -e 's/ /,DNS:/g'`"

openssl genrsa -out glauth.key 2048
openssl req -new -x509 -sha256 -key glauth.key -out glauth.crt -subj "/CN=glauth" -days 3650 -addext "$subj_alt_name"
yq 'with(select(.kind=="ConfigMap" and .metadata.name=="glauth"); .data."glauth.key" = load_str("glauth.key") | .data."glauth.crt" = load_str("glauth.crt"))' deployment.yaml | oc apply -f -