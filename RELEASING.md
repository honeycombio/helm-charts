# Creating a new individual chart release

This repository supports multiple Helm charts, and has a specific release process dependent on Helm [chart-releaser](https://github.com/helm/chart-releaser).
Chart releases must be done against the last commit to main only.

## Chart release process

A release is created automatically for any commit on main that modifies a chart. If the same commit modifies separate charts, each chart will be released individually.

When modifying a chart you must increment the chart's version, following [semvar](https://semver.org/).
For example, if you make a change to the Refinery chart that fixes a bug you should bump the patch value of the version the the chart's `Chart.yaml` file.
