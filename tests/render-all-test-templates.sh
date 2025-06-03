#!/bin/bash

set -e

BUILD_DEPENDENCIES=false
RENDERED_DIR=rendered

while getopts "bd:" opt; do
  case $opt in
    b) BUILD_DEPENDENCIES=true;;
    d) RENDERED_DIR=$OPTARG;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

chart_dirs=($(ls -d */))

for chart_dir in "${chart_dirs[@]}"; do

    if [ $BUILD_DEPENDENCIES = true ]; then
        echo "Building dependencies for ${chart_dir}"
        helm repo add honeycomb https://honeycombio.github.io/helm-charts
        helm dependency build ../charts/${chart_dir}
    fi

    rendered_dir=./${chart_dir}${RENDERED_DIR}

    # create the rendered directory if it doesn't exist
    mkdir -p ${rendered_dir}
    rm -f ${rendered_dir}/*

    echo "Rendering all templates for ${chart_dir}"

    for values_file in ./${chart_dir}/tests/*.yaml; do
        filename=$(basename "$values_file" .yaml)
        # skip the values file
        if [ "$filename" = "values" ]; then
            continue
        fi

        echo "Rendering $filename"
        helm template test ../charts/${chart_dir}/ \
            --values ${chart_dir}/base-values.yaml \
            --values "$values_file" \
            | sed '/helm.sh\/chart\:/d' | sed '/helm.sh\/hook/d' | sed '/managed-by\: Helm/d' | sed '/checksum\//d' \
            > "${rendered_dir}/rendered-${filename}.yaml"
    done

done
