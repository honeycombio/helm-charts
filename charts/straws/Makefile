# Description: Makefile for straws chart

.PHONY: update-dependencies
update-dependencies:
	helm dependency update ./

.PHONY: test
test:
	helm lint ./
	helm install --generate-name --dry-run --set HONEYCOMB_API_KEY=my-api-key ./

.PHONY: install
install:
	helm install straws --set HONEYCOMB_API_KEY=${HONEYCOMB_API_KEY} ./

.PHONY: uninstall
uninstall:
	helm uninstall $(shell helm list -n default | grep straws | awk '{print $$1}')
