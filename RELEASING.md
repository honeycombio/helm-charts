# Creating a new individual chart release

This repository supports multiple Helm charts, and has a specific release process dependent on Helm [chart-releaser](https://github.com/helm/chart-releaser).
Chart releases must be done against the last commit to main only. 
When needing to release multiple charts, you must do the merge to main and release process, one chart at a time.

## Chart release process

1. Ensure the last commit merged to main is for the specific Helm chart about to release.
2. Create a new Release with proper release notes. Add a tag to the release in the following format: `v1.2.3-CHART_NAME`, where CHART_NAME is the name of the chart being released (ie: honeycomb, refinery, etc.)
3. The CI workflow will package the chart into a new release, and update the `index.yaml` file in the `gh-pages` branch with an additional entry pointing to the new chart release.

The Honeycomb Helm Chart repository is contained and served from within the `gh-pages` branch. 
You can view the repository's [index](https://honeycombio.github.io/helm-charts/index.yaml) definition. 
