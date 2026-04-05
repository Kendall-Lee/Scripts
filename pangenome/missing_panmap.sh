#!/bin/bash
#SBATCH -J missing_data
#SBATCH --time=96:00:00
#SBATCH -c 20
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="200G"

# Input file name
input_file="LRLPPan_Smiss1_miss.75_maf0.SVs.panmap"

# Output file name
output_file="LRLPPan_Smiss1_miss.75_maf0.1.missingSVs.txt"

# Initialize the output file with a header
echo -e "chr\tpos\tlen\tMissingCount" > $output_file

# Process each line of the input file
while IFS=$'\t' read -r chr pos len rest || [[ -n "$chr" ]]; do
    # Skip lines where the "len" column contains only "1,1"
    if [[ "$len" =~ ^1(,1)*$ ]]; then
        continue
    fi

    # Count the number of '-' in the rest of the line
    missing_count=$(echo "$rest" | awk -F'-' '{print NF-1}')

    # Write the result to the output file
    echo -e "$chr\t$pos\t$len\t$missing_count" >> $output_file
done < "$input_file"

echo "Analysis complete. Missing data counts saved in $output_file."
