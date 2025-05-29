.PHONY: lint
lint:
	ct lint --config ./ct.yaml

.PHONY: test
test:
	ct install --config ./ct.yaml --excluded-charts htp --excluded-charts observability-pipeline

.PHONY: render-templates
render-templates:
	cd tests && ./render-all-test-templates.sh

.PHONY: test-render
test-render:
	cd tests && ./render-all-test-templates.sh -b -d rendered-compare && ./compare-rendered-templates.sh 
