#!/bin/bash

uninstall_chart() {
  local name=$1
  local namespace=$2

  helm delete $name --namespace $namespace
  kubectl delete customresourcedefinitions.apiextensions.k8s.io -l app.kubernetes.io/managed-by=Tiller,app.kubernetes.io/instance=$name
  kubectl delete namespace $namespace 
}

source $FATS_DIR/macros/cleanup-user-resources.sh

if [ $RUNTIME = "knative" ]; then
  echo "Uninstall Istio"
  uninstall_chart istio istio-system
  # extra cleanup for Istio
  kubectl get customresourcedefinitions.apiextensions.k8s.io -oname | grep istio.io | xargs -L1 kubectl delete
  kubectl delete namespace istio-system
fi

echo "Uninstall riff"
uninstall_chart riff riff-system

echo "Uninstall Cert Manager"
uninstall_chart cert-manager cert-manager-helm
kubectl delete namespace cert-manager
