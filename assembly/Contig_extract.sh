#!/bin/bash

# Input and output file names
input_fasta="Suziblue.hifiasm.bp.p_utg.fa"
contig_list="contigs_above_100kb.txt"
output_fasta="filtered_contigs.fa"

# Create an empty output file
> "$output_fasta"

# Extract each contig in the list
while read -r contig; do
    samtools faidx "$input_fasta" "$contig" >> "$output_fasta"
done < "$contig_list"

echo "Filtered contigs saved to $output_fasta"
