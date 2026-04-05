#!/bin/bash

# Define the old and new gfa paths
old_gfa="gfa=\"/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Pan_work/new_gfa/LRLPPan_REFproc/LRLPPan.gfa\""
new_gfa="gfa=\"/cluster/lab/clevenger/hwright/Sameer_Magic/peanutpan_REFproc/peanutpan.gfa\""

# Loop through each .sh file in the current directory
for script in *.sh; do
    # Use sed to replace the old gfa path with the new one
    sed -i "s|$old_gfa|$new_gfa|" "$script"
    echo "Updated $script"
done




#!/bin/bash
#Define old and new paths
old_path="bam_new_test"
new_path="bams"
#Escape for full line replacement including variable assignment
old_line="bams="$old_path"" new_line="bams="$new_path""
#Loop through .sh files
for script in *.sh; do sed -i "s|$old_line|$new_line|" "$script"; echo "Updated $script"; done
