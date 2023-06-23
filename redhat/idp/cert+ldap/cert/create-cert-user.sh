#!/bin/sh
cfg="$HOME/.kube/config"
export usr=$1
export cluster=`oc config get-contexts | grep '^*' | awk '{print $3}'`
export ctx="$usr@$cluster"
current_ctx=`oc config current-context`

openssl req -new -newkey rsa:2048 -nodes -keyout $usr.key -out $usr.csr -subj "/CN=$usr"
oc create user $usr

cat <<EOF | oc apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $usr
spec:
  request: `cat $usr.csr | base64 -w 0`
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000
  usages:
  - client auth
EOF

sleep 1
oc adm certificate approve $usr
sleep 3
oc get csr $usr -o jsonpath='{.status.certificate}' | base64 -d > $usr.crt
oc config set-credentials $usr --client-certificate=$usr.crt --client-key=$usr.key --embed-certs=true
oc config set-context "$ctx" --namespace=default --cluster=$cluster --user=$usr
oc config use-context "$ctx" 
oc whoami
oc config use-context "$current_ctx" 


# extract the context recently created to share with created user owner
cat <<EOF | yq > $usr.cfg
apiVersion: v1
kind: Config
preferences: {}
current-context: $ctx
clusters: 
- 
`yq '.clusters[] | select(.name == strenv(cluster))' $cfg | sed -e 's/^/  /g'`
users:
- 
`yq '.users [] | select(.name == strenv(usr))' $cfg | sed -e 's/^/  /g'`
contexts:
-
`yq '.contexts [] | select(.name == strenv(ctx))' $cfg | sed -e 's/^/  /g'`
EOF




