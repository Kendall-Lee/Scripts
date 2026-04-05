#!/bin/bash

# Read the list of sample names from samples.list
sample_list="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/LRLP_renamed/samples.list"

# Define the directory containing your output BAM files
bam_dir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Linear_work/new_names/bams"

# Loop through each sample name in the sample list
while IFS= read -r sample; do
    # Check if the BAM file corresponding to the sample exists in the BAM directory
    if ! ls "${bam_dir}/unique_${sample}.bam.csi" > /dev/null 2>&1; then
        # If the BAM file does not exist, print the missing sample name
        echo "Missing sample: ${sample}"
    fi
done < "$sample_list"
