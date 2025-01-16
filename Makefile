.PHONY: lint
lint:
	ct lint --config ./ct.yaml

.PHONY: test
test:
	ct install --config ./ct.yaml --excluded-charts htp
