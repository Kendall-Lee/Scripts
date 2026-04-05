#!/bin/bash

# Iterate over all bam.bounderies.fa2 files in the current directory
for fa2_file in *.bam.bounderies.fa2; do
    # Extract the Sample ID from the filename
    sample_id=$(echo "$fa2_file" | sed 's/unique_\(.*\).bam.bounderies.fa2/\1/')

    # Count the number of lines in the bam.bounderies.fa2 file and divide by 2
    fa2_lines=$(wc -l < "$fa2_file")
    fa2_half=$((fa2_lines / 2))

    # Find the corresponding bam.bounderies.fa.sam_filtered.list file
    sam_filtered_list="${fa2_file%.bam.bounderies.fa2}.bam.bounderies.fa.sam_filtered.list"

    # Count the number of lines in the bam.bounderies.fa.sam_filtered.list file
    if [ -f "$sam_filtered_list" ]; then
        sam_filtered_lines=$(wc -l < "$sam_filtered_list")
    else
        sam_filtered_lines=0
    fi

    # Print the results in 3 columns: Sample ID, half of fa2 line count, sam_filtered.list line count
    echo -e "${sample_id}\t${fa2_half}\t${sam_filtered_lines}"
done




module load cluster/graphaligner
