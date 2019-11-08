![](https://github.com/projectriff/charts/workflows/CI/badge.svg)

# projectriff Helm charts

Helm charts to install Istio and riff.

## Install

### Prerequisites

- a running kubernetes cluster (1.14+)
- kubectl (1.14+)
- helm (3.0+)

### Steps

1. Install Istio (optional, required for the Knative runtime)

   Append:

   - `--set gateways.istio-ingressgateway.type=NodePort` for clusters that do not support LoadBalancer services, like Minikube.
   - `--devel` for the latest snapshot.
   
   ```sh
   kubectl create namespace istio-system
   helm install istio projectriff/istio --namespace istio-system --wait
   ```

   For more configuration options see the [Istio documentation](https://archive.istio.io/v1.1/docs/reference/config/installation-options/).

1. Install riff

   Append:

   - `--set tags.core-runtime=true` to enable the Core runtime
   - `--set tags.knative-runtime=true` to enable the Knative runtime
   - `--set tags.streaming-runtime=true` to enable the Streaming runtime
   - `--set cert-manager.enabled=false` if cert-manager is already installed
   - `--set knative.enabled=false` if Knative serving is already installed
   - `--devel` for the latest snapshot.

   ```sh
   kubectl create namespace riff-system
   helm install riff projectriff/riff --namespace riff-system
   ```

1. Enjoy.

### Uninstall

```
# remove any riff resources
kubectl delete riff --all-namespaces --all

# remove any Knative resources (if Knative runtime is enabled)
kubectl delete knative --all-namespaces --all

# remove riff
helm delete riff --namespace riff-system
kubectl delete customresourcedefinitions.apiextensions.k8s.io -l app.kubernetes.io/managed-by=Tiller,app.kubernetes.io/instance=riff

# remove istio (if installed)
helm delete istio --namespace istio-system
kubectl delete namespace istio-system
kubectl get customresourcedefinitions.apiextensions.k8s.io -oname | grep istio.io | xargs -L1 kubectl delete
```

## Creating charts

### Prerequisites

- internet access
- helm (3.0+)
- ytt (0.14.0)
- yq
- k8s-tag-resolver
- gcloud (for publishing)

### Steps

Optionally, update the chart templates to the latest component builds.

```sh
make templates
```

Package charts locally. Charts will be placed in the `repository` directory.

```sh
make package
```
