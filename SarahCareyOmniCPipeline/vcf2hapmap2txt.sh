#!/bin/bash

source /cluster/projects/khufu/qtl_seq_II/khufu_II/utilities/KhufuEnvVer2.sh

# Loop through all .bam.indels.vcf.gz files
for file in *.bam.indels.vcf.gz; do
    # Extract the base filename without extensions
    base_name=$(basename "$file" .bam.indels.vcf.gz)

    # Gunzip the file
    gunzip "$file"

    # Run vcf2hapmap
    vcf2hapmap "${base_name}.bam.indels.vcf" > "${base_name}.bam.indels.hapmap"

    echo "Processed: ${base_name}.bam.indels.vcf to ${base_name}.bam.indels.hapmap"
done

# Now process all .bam.indels.hapmap files with hapmap2text
for hapmap_file in *.bam.indels.hapmap; do
    # Extract base name again
    base_name=$(basename "$hapmap_file" .bam.indels.hapmap)

    # Run hapmap2text
    hapmap2text "$hapmap_file" > "${base_name}.bam.indels.txt"

    echo "Processed: ${hapmap_file} to ${base_name}.bam.indels.txt"
done
