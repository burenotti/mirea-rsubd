#!/bin/bash

WORKSPACE_FOLDER="$1"
for report_file_path in "$WORKSPACE_FOLDER"/*.typ; do
    echo "Processing File: $report_file_path"

    report_name=$(basename "$report_file_path" ".typ")
    echo "$report_name"
    typst compile \
        --font-path "$WORKSPACE_FOLDER/template" \
        -f pdf \
        --ppi 100 \
        --root "$WORKSPACE_FOLDER" \
        "$report_file_path" "$WORKSPACE_FOLDER/output/$report_name.pdf"
done
