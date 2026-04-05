#!/bin/bash

# Define the directories
short_reads_dir="/cluster/projects/khufu/wiregrass/raw_data/003_20240227_Sem2/fastq/fastqs"
output_dir="matching_short"
sample_list="sample.list"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through each ID in the sample list
while read -r id; do
    # Find matching files (both R1 and R2)
    matching_files=$(find "$short_reads_dir" -type f -name "${id}_R*.fq.gz")

    # Move the matching files to the output directory
    if [[ -n "$matching_files" ]]; then
        echo "Moving files for $id..."
        mv $matching_files "$output_dir"
    else
        echo "No matching files found for $id"
    fi
done < "$sample_list"

echo "Done!"
