#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

: "${GITHUB_TOKEN:?Environment variable GITHUB_TOKEN must be set}"
: "${GIT_USERNAME:?Environment variable GIT_USERNAME must be set}"
: "${GIT_REPOSITORY_OWNER:?Environment variable GIT_REPOSITORY_OWNER must be set}"
: "${GIT_REPOSITORY_NAME:?Environment variable GIT_REPOSITORY_NAME must be set}"

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
    exit 2
  fi

  local chart_name
  # shellcheck disable=SC2001
  chart_name=$(echo "$latest_tag" | sed "s/^v.[^\-]*-\(.*\)/\1/")

  echo "Chart Name: $chart_name"

  if [[ ! -d "$REPO_ROOT/charts/$chart_name" ]]; then
    echo "Chart $chart_name not found"
    exit 2
  fi

  rm -rf .deploy
  mkdir -p .deploy

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
  cr upload --git-repo "$GIT_REPOSITORY_NAME" --owner "$GIT_REPOSITORY_OWNER" --token "$GITHUB_TOKEN"
}

update_index() {
  git config user.name "$GIT_USERNAME"
  git remote set-url origin "https://github.com/$GIT_REPOSITORY_OWNER/$GIT_REPOSITORY_NAME.git"

  mkdir .cr-index
  cr index --git-repo "$GIT_REPOSITORY_NAME" --owner "$GIT_REPOSITORY_OWNER" --token "$GITHUB_TOKEN" --push
}

main
