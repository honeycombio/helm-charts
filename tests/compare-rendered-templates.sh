#!/bin/bash

RENDERED_DIR=rendered
COMPARE_DIR=rendered-compare

while getopts "b:c:" opt; do
  case $opt in
    b) RENDERED_DIR=$OPTARG;;
    d) COMPARE_DIR=$OPTARG;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

chart_dirs=($(ls -d */))

has_errors=0

for chart_dir in "${chart_dirs[@]}"; do
    echo "comparing rendered and rendered_compare for $chart_dir"

    base_dir=${chart_dir}${RENDERED_DIR}
    compare_dir=${chart_dir}${COMPARE_DIR}

    # compare the directories and return an error if they are not the same with a print out of the line differences
    result=$(diff -u ./$base_dir ./$compare_dir)
    if [ -n "$result" ]; then
        has_errors=1
    fi
done

exit $is_error
