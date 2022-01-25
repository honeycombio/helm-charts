# Creating a new individual chart release

This repository supports multiple Helm charts, and has a specific release process dependent on Helm [chart-releaser](https://github.com/helm/chart-releaser).
Chart releases must be done against the last commit to main only.
When needing to release multiple charts, you must do the merge to main and release process, one chart at a time.

## Chart release process

Note: Updates to `appVersion` ought to be done in a separate PR.
Consider it like a dependency update; we don't mix those into release prep PRs.

1. Update `version` in the `Chart.yaml` file for the specific chart being released
2. Update `CHANGELOG.md` for the specific chart with the changes since the last release
3. Commit changes, push, and open a release preparation pull request for review
4. Once the pull request is merged, fetch the updated `main` branch
5. Add a tag to the `main` branch with the new version in the following format: `v1.2.3-CHART_NAME`, where CHART_NAME is the name of the chart being released (for example v1.3.1-refinery, v1.1.1-honeycomb, etc.)
6. Push the new version tag up to the project repository to kick off the CI workflow, which will package the chart into a new release and update the `index.yaml` file in the `gh-pages` branch with an additional entry pointing to the new chart release.
7. Update the Release with proper release notes (copied from CHANGELOG)

The Honeycomb Helm chart repository is contained and served from within the `gh-pages` branch.
You can view the repository's [index](https://honeycombio.github.io/helm-charts/index.yaml) definition.
