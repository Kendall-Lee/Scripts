#!/bin/bash

# Input FASTA file
input_fasta="Draper_chr.fasta"
output_fasta="new.fasta"

# Loop through Chr.1 to Chr.48
for i in $(seq 1 48); do
    chrom="Chr.$i"
    samtools faidx "$input_fasta" "$chrom" >> "$output_fasta"
done

echo "New FASTA file with sorted chromosomes saved to $output_fasta"
