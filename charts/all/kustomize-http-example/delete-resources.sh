#!/bin/sh
#
# Function log
# Arguments:
#   $1 are for the options for echo
#   $2 is for the message
#   \033[0K\r - Trailing escape sequence to leave output on the same line
function log {
    if [ -z "$2" ]; then
        echo -e "\033[0K\r\033[1;36m$1\033[0m"
    else
        echo -e $1 "\033[0K\r\033[1;36m$2\033[0m"
    fi
}

if [[ -z "${KUBECONFIG}" ]]; then
    log "Please set KUBECONFIG to connecto to OpenShift"
    exit
else
    log "Using [$KUBECONFIG] to connect to OpenShift"
fi

NAMESPACE=$(oc project kustomize-http-example --short 2>&1;echo $? > /tmp/rc)
if [ $(cat /tmp/rc) -eq 0 ]; then
  log "Checking resources in namespace [ $NAMESPACE ]"
  
  if [ "$NAMESPACE" == "kustomize-http-example" ]; then
    DEPLOYMENT=$(oc get deployment -o name)
    if [ "$DEPLOYMENT." != "." ]; then
      log -n "Deleting deployment [ $DEPLOYMENT ] in $NAMESPACE ... "
      RC=$(oc delete $DEPLOYMENT > /dev/null;echo $? > /tmp/rc)
	  if [ $(cat /tmp/rc) -eq 0 ]; then
        log "Deleting deployment [ $DEPLOYMENT ] in $NAMESPACE ... ok"
      fi
    fi
  
    SERVICES=$(oc get services -o name)
  
    if [ "$SERVICES." != "." ]; then
      for service in $SERVICES
      do
        log -n "Deleting Service [ $service ] in $NAMESPACE ... "
  	  RC=$(oc delete $service > /dev/null;echo $? > /tmp/rc)
	  if [ $(cat /tmp/rc) -eq 0 ]; then
          log "Deleting Service [ $service ] in $NAMESPACE ... ok"
  	  fi
      done
    fi
   
    ROUTE=$(oc get route -o name)
    if [ "$ROUTE." != "." ]; then
      log -n "Deleting route [ $ROUTE ] in $NAMESPACE ... "
      RC=$(oc delete $ROUTE > /tmp/rc;echo $? > /tmp/rc)
	  if [ $(cat /tmp/rc) -eq 0 ]; then
        log "Deleting route [ $ROUTE ] in $NAMESPACE ... ok"
      fi
    fi
  
    RESOURCES=$(oc get all 2>&1)
    if [[ "$RESOURCES" == *"No resources found"* ]]; then
      log "All resources in namespace [ $NAMESPACE ] have been deleted"
    fi
    RC=$(oc project default > /dev/null)
    log -n "Removing [ $NAMESPACE ] namespace ... "
    NS=$(oc delete ns/$NAMESPACE;echo $? > /tmp/rc)
	if [ $(cat /tmp/rc) -eq 0 ]; then
      log "Removing [ $NAMESPACE ] namespace ... ok"
    fi
  fi
fi
