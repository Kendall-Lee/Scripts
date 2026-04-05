#!/bin/bash

# Paths
short_read_dir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Short_reads"
long_read_dir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/LRLP_renamed"

# Create a temporary file to store long read IDs
long_read_ids=$(mktemp)

# Extract the sample IDs from the long read filenames (before the .PB.fastq.gz suffix)
for file in "$long_read_dir"/*.PB.fastq.gz; do
    basename "$file" | sed 's/\.PB\.fastq\.gz//' >> "$long_read_ids"
done

# Loop through R1 files in the short read directory
for R1_file in "$short_read_dir"/*_R1.fq.gz; do
    # Extract the sample ID from the R1 file (remove _R1.fq.gz)
    sample_id=$(basename "$R1_file" | sed 's/_R1\.fq\.gz//')

    # Check if the sample ID exists in the long read folder
    if ! grep -q "$sample_id" "$long_read_ids"; then
        echo "No matching long read found for $R1_file and its R2 pair. Removing..."
        # Remove both R1 and R2 files if no match
        rm "$R1_file"
        rm "${short_read_dir}/${sample_id}_R2.fq.gz"
    fi
done
