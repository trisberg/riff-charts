FROM ubuntu:bionic
ENV HELM_VERSION=v2.14.2
RUN apt-get update && apt-get install -y curl \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
  && mv ./kubectl /usr/local/bin \
  && chmod 755 /usr/local/bin/kubectl \
  && curl -LO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && tar -xvzf helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && mv linux-amd64/helm /usr/local/bin \
  && rm -rf linux-amd64 \
  && rm helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && apt-get remove -y --auto-remove curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY Dockerfile app /cnab/
COPY charts /charts/

CMD ["/cnab/app/run"]
