#!/bin/bash

# Input and output files
input_file="Suziblue.hifiasm.bp.p_utg.fa"
sorted_fasta="Suziblue.hifiasm.bp.p_utg.length.fa"
lengths_file="Suziblue.hifiasm.bp.p_utg.contig_lengths.txt"

# Process the FASTA file
awk '/^>/ {if (seq) {print header, length(seq); seq=""} header=$0; next} {seq=seq $0}
     END {if (seq) print header, length(seq)}' "$input_file" |
sort -k2,2nr > temp_lengths.txt

# Write sorted lengths to lengths file
awk '{print substr($0, 2), $2}' temp_lengths.txt > "$lengths_file"

# Write sorted contigs to a new FASTA file
awk 'NR==FNR {len[$1]=$2; next}
     /^>/ {header=$0; getline seq; print header "\n" seq | "cat - >> " ENVIRON["sorted_fasta"]}' \
     sorted_fasta="$sorted_fasta" temp_lengths.txt "$input_file"

# Clean up temporary file
rm temp_lengths.txt

echo "Sorted FASTA file saved as $sorted_fasta"
echo "Contig lengths saved as $lengths_file"
