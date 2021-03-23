#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

: "${CR_TOKEN:?Environment variable CR_TOKEN must be set}"
: "${GIT_REPOSITORY_URL:?Environment variable GIT_REPO_URL must be set}"
: "${GIT_USERNAME:?Environment variable GIT_USERNAME must be set}"
: "${GIT_EMAIL:?Environment variable GIT_EMAIL must be set}"
: "${GIT_REPOSITORY_NAME:?Environment variable GIT_REPOSITORY_NAME must be set}"
: "${CHARTS_REPO:?Environment variable CHARTS_REPO must be set}"

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

main() {
  pushd "$REPO_ROOT" >/dev/null
  echo "Fetching tags..."
  git fetch --tags

  local latest_tag
  latest_tag=$(git describe --tags --abbrev=0)
  echo "Latest Tag: $latest_tag"

  if [[ ! "$latest_tag" =~ ^v[0-9].+-.* ]]; then
    echo "Latest Tag is not a 'v' Release tag"
    exit
  fi

  local chart_name
  # shellcheck disable=SC2001
  chart_name=$(echo "$latest_tag" | sed "s/^v.[^\-]*-\(.*\)/\1/")

  echo "Chart Name: $chart_name"

  if [[ ! -d "$REPO_ROOT/charts/$chart_name" ]]; then
    echo "Chart $chart_name not found"
    exit
  fi

  echo "Packaging chart $chart_name..."
  package_chart "charts/$chart_name"

  echo "Releasing charts..."
  release_charts
  sleep 5

  echo "Updating Helm repo index..."
  update_index

  popd >/dev/null

}

package_chart() {
  local chart="$1"
  cr package "$chart"
}

release_charts() {
  cr upload --git-repo "$GIT_REPOSITORY_NAME" --owner "$GIT_USERNAME"
}

update_index() {
  git config user.email "$GIT_EMAIL"
  git config user.name "$GIT_USERNAME"

  mkdir .cr-index
  cr index --charts-repo "$CHARTS_REPO" --git-repo "$GIT_REPOSITORY_NAME" --owner "$GIT_USERNAME" --push
}

main
