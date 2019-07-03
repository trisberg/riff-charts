VERSION ?= $(shell cat VERSION)

.PHONY: build
build: charts/projectriff-istio-%.tgz charts/projectriff-riff-%.tgz

charts/projectriff-istio-%.tgz: repository charts/projectriff-istio charts/projectriff-istio.yaml
	$(shell ./prepare.sh projectriff-istio)
	helm package ./charts/projectriff-istio --destination repository --version ${VERSION}

charts/projectriff-riff-%.tgz: repository charts/projectriff-riff charts/projectriff-riff.yaml
	$(shell ./prepare.sh projectriff-riff)
	helm package ./charts/projectriff-riff --destination repository --version ${VERSION}

.PHONY: publish
publish: publish-snapshot

.PHONY: publish-snapshot
publish-snapshot: build
	mkdir -p repository/snapshots
	cp repository/*.tgz repository/snapshots/
	gsutil cp gs://projectriff/charts/snapshots/index.yaml repository/snapshots/
	helm repo index repository/snapshots/ --url https://projectriff.storage.googleapis.com/charts/snapshots --merge repository/snapshots/index.yaml
	gsutil cp -a public-read repository/snapshots/*.tgz gs://projectriff/charts/snapshots
	gsutil cp -a public-read repository/snapshots/index.yaml gs://projectriff/charts/snapshots/

repository:
	mkdir repository

.PHONY: clean
clean:
	rm -rf repository
	rm -rf charts/*/templates/*
