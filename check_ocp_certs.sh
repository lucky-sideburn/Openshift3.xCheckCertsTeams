#!/bin/bash

REPORT_DIR=/root
EASYMODE_PLAYBOOK=/usr/share/ansible/openshift-ansible/playbooks/openshift-checks/certificate_expiry/easy-mode.yaml
INVENTORY_FILE=/etc/ansible/hosts
EXTRA_ARGS=""
WEBHOOK_URL=""

ansible-playbook -i $INVENTORY_FILE $EASYMODE_PLAYBOOK $EXTRA_ARGS

CERTS_REPORT=$(ls -art $REPORT_DIR | grep "cert-expiry-report.*json" | tail -n 1)

echo "Checking output of easy mode playbook => ${REPORT_DIR}/${CERTS_REPORT}"

for i in $(jq '.summary.warning,.summary.expired' $REPORT_DIR/$CERTS_REPORT)
do
  if [ $i -gt 0 ] ;then
    MESSAGE=$( echo "Please check Openshift certificate, they are going to expire"  | sed 's/"/\"/g' | sed "s/'/\'/g" )
    JSON="{\"title\": \"Not took DevOps check for Openshift Certificate\", \"themeColor\": \"red\", \"text\": \"${MESSAGE}\" }"
    #curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}" -v
    echo 'curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}" -v'
  else
    MESSAGE=$( echo "This is a DeadManSwitch of openshift certificate expiration check. Certificates are not going to expire"  | sed 's/"/\"/g' | sed "s/'/\'/g" )
    JSON="{\"title\": \"Not took DevOps check for Openshift Certificate\", \"themeColor\": \"green\", \"text\": \"${MESSAGE}\" }"
    #curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}" -v
    echo 'curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}" -v'
  fi
done
