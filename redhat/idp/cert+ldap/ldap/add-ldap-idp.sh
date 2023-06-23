#!/bin/sh
type="private"
ldap_host="glauth.glauth.svc.cluster.local"
bind_dn="cn=redhat,ou=csa,dc=latam,dc=redhat"
bind_pwd="redhat" # change the passwd according to the bindDN used
crt_file=glauth.crt
ldap_searchbase="dc=latam,dc=redhat"
ldap_filter="cn"
ldap_url="ldaps://$ldap_host/$ldap_searchbase?$ldap_filter"
secret_name="glauth-bind-passwd"
config_map_name="glauth-cert-$type"
export patch_file="/tmp/ldap-idp-$type.yaml"
export idp_name="ldap-$type"

oc delete secret $secret_name -n openshift-config --ignore-not-found
oc delete configmap $config_map_name -n openshift-config --ignore-not-found
oc create secret generic $secret_name --from-literal=bindPassword="$bind_pwd" -n openshift-config 
oc create configmap $config_map_name --from-file=ca.crt=$crt_file -n openshift-config

cat <<EOF > $patch_file
- ldap:
    attributes:
      email:
        - mail
      id:
        - dn
      name:
        - cn
      preferredUsername:
        - uid
    bindDN: $bind_dn
    bindPassword:
      name: $secret_name
    ca:
      name: $config_map_name
    insecure: false
    url: $ldap_url
  mappingMethod: claim
  name: $idp_name
  type: LDAP
EOF

echo -n "removing $idp_name... "
oc get oauth cluster -o yaml | yq 'del(.spec.identityProviders[] | select(.name == strenv(idp_name)))' | oc apply -f -
echo -n "adding $idp_name... "
oc get oauth cluster -o yaml | yq '.spec.identityProviders += load(strenv(patch_file))' | oc apply -f -
rm $patch_file