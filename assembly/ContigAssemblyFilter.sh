#!/bin/bash

# Define the input folder containing assemblies and output folder
input_folder="Blueberry_p_utg_genomes"
output_folder="Processed_Assemblies"
mkdir -p "$output_folder"

# Minimum contig length to filter
min_length=100000

# Loop through each FASTA file in the input folder
for input_file in "$input_folder"/*.fa; do
    # Extract the base name (without path and extension)
    base_name=$(basename "$input_file" .fa)

    # Define file names for intermediate and final results
    sorted_fasta="$output_folder/${base_name}.sorted.fa"
    lengths_file="$output_folder/${base_name}.contig_lengths.txt"
    contig_list="$output_folder/${base_name}.contigs_above_${min_length}bp.txt"
    filtered_fasta="$output_folder/${base_name}.filtered_contigs.fa"

    echo "Processing $input_file..."

    # Step 1: Generate sorted contigs and their lengths
    awk '/^>/ {if (seq) {print header, length(seq); seq=""} header=$0; next} {seq=seq $0}
         END {if (seq) print header, length(seq)}' "$input_file" |
    sort -k2,2nr > "$output_folder/temp_lengths.txt"

    # Write sorted lengths to lengths file
    awk '{print substr($0, 2), $2}' "$output_folder/temp_lengths.txt" > "$lengths_file"

    # Write sorted contigs to a new FASTA file
    awk 'NR==FNR {len[$1]=$2; next}
         /^>/ {header=$0; getline seq; print header "\n" seq | "cat - >> " ENVIRON["sorted_fasta"]}' \
         sorted_fasta="$sorted_fasta" "$output_folder/temp_lengths.txt" "$input_file"

    # Clean up temporary file
    rm "$output_folder/temp_lengths.txt"

    # Step 2: Filter contigs by minimum length
    awk -v min_len="$min_length" '$2 >= min_len {print $1}' "$lengths_file" > "$contig_list"

    # Create an empty output file
    > "$filtered_fasta"

    # Extract each contig in the list
    while read -r contig; do
        samtools faidx "$input_file" "$contig" >> "$filtered_fasta"
    done < "$contig_list"

    echo "Processed files for $base_name saved in $output_folder"
done

echo "All assemblies processed. Results saved in $output_folder"
