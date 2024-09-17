#!/usr/bin/env bash

# https://github.com/helm/chart-releaser-action/blob/main/cr.sh
# Copyright The Helm Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

: "${GITHUB_TOKEN:?Environment variable GITHUB_TOKEN must be set}"
: "${GIT_USERNAME:?Environment variable GIT_USERNAME must be set}"
: "${GIT_REPOSITORY_OWNER:?Environment variable GIT_REPOSITORY_OWNER must be set}"
: "${GIT_REPOSITORY_NAME:?Environment variable GIT_REPOSITORY_NAME must be set}"

main() {
  local charts_dir=charts
  
  local repo_root
  repo_root=$(git rev-parse --show-toplevel)
  pushd "$repo_root" >/dev/null

  echo 'Looking up latest tag...'
  local latest_tag
  latest_tag=$(lookup_latest_tag)

  echo "Discovering changed charts since '$latest_tag'..."
  local changed_charts=()
  readarray -t changed_charts <<<"$(lookup_changed_charts "$latest_tag")"

  if [[ -n "${changed_charts[*]}" ]]; then
    add_dependencies

    rm -rf .cr-release-packages
    mkdir -p .cr-release-packages

    rm -rf .cr-index
    mkdir -p .cr-index

    for chart in "${changed_charts[@]}"; do
      if [[ -d "$chart" ]]; then
        package_chart "$chart"
      else
        echo "Nothing to do. No chart changes detected."
      fi
    done

    release_charts
    update_index
  else
    echo "Nothing to do. No chart changes detected."
  fi

  popd >/dev/null
}

lookup_latest_tag() {
  git fetch --tags >/dev/null 2>&1

  if ! git describe --tags --abbrev=0 HEAD~ 2>/dev/null; then
    git rev-list --max-parents=0 --first-parent HEAD
  fi
}

filter_charts() {
  while read -r chart; do
    [[ ! -d "$chart" ]] && continue
    local file="$chart/Chart.yaml"
    if [[ -f "$file" ]]; then
      echo "$chart"
    else
      echo "WARNING: $file is missing, assuming that '$chart' is not a Helm chart. Skipping." 1>&2
    fi
  done
}

lookup_changed_charts() {
  local commit="$1"

  local changed_files
  changed_files=$(git diff --find-renames --name-only "$commit" -- "$charts_dir")

  local depth=$(($(tr "/" "\n" <<<"$charts_dir" | sed '/^\(\.\)*$/d' | wc -l) + 1))
  local fields="1-${depth}"

  cut -d '/' -f "$fields" <<<"$changed_files" | uniq | filter_charts
}

add_dependencies() {
  echo "Adding chart dependencies"
  helm repo add honeycomb https://honeycombio.github.io/helm-charts
  helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
}

package_chart() {
  local chart="$1"
  echo "Packaging chart '$chart'..."
  cr package "$chart" --package-path .cr-release-packages
}

release_charts() {
  echo 'Releasing charts...'
  cr upload --git-repo "$GIT_REPOSITORY_NAME" --owner "$GIT_REPOSITORY_OWNER" --token "$GITHUB_TOKEN" --commit "$(git rev-parse HEAD)" --generate-release-notes
}

update_index() {
  echo 'Updating charts repo index...'
  git config user.name "$GIT_USERNAME"
  git config --global --unset url.ssh://git@github.com.insteadof
  git remote add origin-https "https://github.com/$GIT_REPOSITORY_OWNER/$GIT_REPOSITORY_NAME.git"
  git fetch --all
  cr index --git-repo "$GIT_REPOSITORY_NAME" --owner "$GIT_REPOSITORY_OWNER" --token "$GITHUB_TOKEN" --remote "origin-https" --push
}

main
