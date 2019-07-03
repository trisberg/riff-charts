# projectriff Helm charts

Helm charts to insall istio and riff.

## Install

### Prerequisites

- a running kubernets cluster (1.11+)
- kubectl (1.11+)
- helm (2.14+)

### Steps

1. Initialize Helm

   ```sh
   kubectl create serviceaccount tiller -n kube-system
   kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount kube-system:tiller
   helm init --service-account tiller
   ```

1. Load the projectriff charts

   ```sh
   helm repo add projectriff-snapshots https://projectriff.storage.googleapis.com/charts/snapshots
   helm repo update
   ```

1. Install istio

   Append `--set ServiceType=NodePort` for clusters that do not support LoadBalancer services, like Minikube.

   ```sh
   helm install projectriff-snapshots/projectriff-istio -n istio --devel
   ```

1. Install riff

   ```sh
   helm install projectriff-snapshots/projectriff-riff -n riff --devel
   ```

1. Enjoy.

## Building charts

### Prerequisites

- internet access
- helm (2.14+)
- ytt (0.14.0)
- gcloud (for publishing)

### Steps

Build charts locally. Charts will be placed in the `repository` directory.

```sh
make build
```

Publish charts

```sh
make publish
```
