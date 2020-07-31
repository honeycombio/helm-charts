#!/bin/bash

function print_usage_and_exit() {
    echo "Failure: $1"
    echo "Usage: $0 CHART_NAME"
    echo "Example: $0 honeycomb"
    exit 1
}

CHART_NAME=$1
if [[ -z $CHART_NAME ]] ; then
    print_usage_and_exit "Chart name is required"
fi

if [[ -z $(command -v helm) ]] ; then
    echo "Failure: helm not found"
    exit 1
fi

# initialize build variables
BUILD_DIR="./_build"
INDEX_FILE=${BUILD_DIR}/index.yaml

rm -rf ${BUILD_DIR}
echo "using build directory: ${BUILD_DIR}"
mkdir ${BUILD_DIR}

# create new tgz
echo "creating new ${CHART_NAME} helm package"
if ! helm dependency build "./${CHART_NAME}" ; then
    echo "Failure: could not build chart dependencies"
fi
if ! helm package -d ${BUILD_DIR} "./${CHART_NAME}" ; then
    echo "Failure: error creating helm package"
    exit 1
fi

# download current index.yaml
echo "downloading latest index.yaml to ${INDEX_FILE}"
curl -sL https://raw.githubusercontent.com/honeycombio/helm-charts/gh-pages/index.yaml > ${INDEX_FILE}

echo "generating updated index.yaml"
helm repo index --merge "${INDEX_FILE}" ${BUILD_DIR}

echo "Complete. new index and package files can be found under ${BUILD_DIR}"
echo "Run: 'git checkout gh-pages && cp ${BUILD_DIR}/* .' and commit to update the helm chart"
