VERSION ?= $(shell cat VERSION)

.PHONY: build
build: istio-%.tgz projectriff-%.tgz

istio-%.tgz: repository istio istio.yaml
	$(shell ./prepare.sh istio)
	helm package istio --destination repository --version ${VERSION}

projectriff-%.tgz: repository projectriff projectriff.yaml
	$(shell ./prepare.sh projectriff)
	helm package projectriff --destination repository --version ${VERSION}

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
	rm -rf istio/templates/*
	rm -rf projectriff/templates/*
