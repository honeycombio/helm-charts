.PHONY: lint
lint:
	ct lint --config ./ct.yaml

.PHONY: test
test:
	ct install --config ./ct.yaml --excluded-charts htp --excluded-charts htp-builder --excluded-charts htp-builder

.PHONY: render-templates
render-templates:
	cd tests && ./render-all-test-templates.sh

.PHONY: test-render
test-render:
	cd tests && ./render-all-test-templates.sh -b -d rendered-compare && ./compare-rendered-templates.sh 

.PHONY: render-base-templates
render-base-templates:
	cd tests && ./render-all-test-templates.sh -b -d rendered
