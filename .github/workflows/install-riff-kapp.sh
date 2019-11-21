#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly version=$(cat VERSION)
readonly git_sha=$(git rev-parse HEAD)
readonly git_timestamp=$(TZ=UTC git show --quiet --date='format-local:%Y%m%d%H%M%S' --format="%cd")
readonly slug=${version}-${git_timestamp}-${git_sha:0:16}

source $FATS_DIR/.configure.sh

if [ ${1:-unknown} = staged ] ; then
  echo "Using staged uncharts"
  unchart_base=https://storage.googleapis.com/projectriff/charts/uncharted/snapshots/${slug}
else
  echo "Using locally built uncharts"
  unchart_base=./uncharted
fi

install_app() {
  local name=$1
  local transform=${2:-}

  if [ -z $transform ] ; then
    kapp deploy -n apps -a $name -f ${unchart_base}/${name}.yaml -y
  else
    ytt -f ${unchart_base}/${name}.yaml -f $transform --file-mark ${name}.yaml:type=yaml-plain | kapp deploy -n apps -a $name -f - -y
  fi
}

kubectl create ns apps

echo "Install Cert Manager"
install_app cert-manager

#TODO: change back to FATS after it is with cert-manager v0.11.0
# source $FATS_DIR/macros/no-resource-requests.sh
if [ $(kubectl get nodes -oname | wc -l) = "1" ]; then
  echo "Eliminate pod resource requests"
  fats_retry kubectl apply -f https://storage.googleapis.com/projectriff/no-resource-requests-webhook/no-resource-requests-webhook-20191121210956-521ae2a8c3323540.yaml
  wait_pod_selector_ready app=webhook no-resource-requests
fi
#TODO: ^^^

echo "Install riff Build"
install_app kpack
install_app riff-builders
install_app riff-build

if [ $RUNTIME = "core" ]; then
  echo "Install riff core runtime"
  install_app riff-core-runtime
fi

if [ $RUNTIME = "knative" ]; then
  echo "Install Istio"
  
  install_app istio .github/workflows/overlays/service-$(echo ${K8S_SERVICE_TYPE} | tr '[A-Z]' '[a-z]').yaml

  echo "Checking for ready ingress"
  wait_for_ingress_ready 'istio-ingressgateway' 'istio-system'

  echo "Install riff Knative runtime"
  install_app knative
  install_app riff-knative-runtime
fi
