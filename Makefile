VERSION ?= $(shell cat VERSION)

.PHONY: package
package: repository

.PHONY: publish
publish: publish-snapshot

.PHONY: publish-snapshot
publish-snapshot: repository
	mkdir -p repository/snapshots
	cp repository/*.tgz repository/snapshots/
	gsutil cp gs://projectriff/charts/snapshots/index.yaml repository/snapshots/
	helm repo index repository/snapshots/ --url https://projectriff.storage.googleapis.com/charts/snapshots --merge repository/snapshots/index.yaml
	gsutil cp -a public-read repository/snapshots/*.tgz gs://projectriff/charts/snapshots
	gsutil cp -a public-read repository/snapshots/index.yaml gs://projectriff/charts/snapshots/

repository: charts package.sh
	mkdir -p repository
	./package.sh projectriff-istio ${VERSION} repository
	./package.sh projectriff-riff ${VERSION} repository

.PHONY: clean
clean:
	rm -rf repository
	rm -rf charts/*/templates
