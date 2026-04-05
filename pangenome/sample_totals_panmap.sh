#!/bin/bash
#SBATCH -J varcounttest
#SBATCH --time=96:00:00
#SBATCH -c 20
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="200G"

#for the use of counting SNPs, SVs, and Indels in panmap files

# Input file name
input_file="test.pan"

# Output file name
output_file="test.pan.variants.txt"

# Extract the header row to get sample names
header=$(head -n 1 "$input_file")

# Get the sample column names (from column 5 onwards)
sample_columns=$(echo "$header" | cut -f5-)

# Initialize the output file with a header
echo -e "Sample\tCount_- \tCount_1\tCount_2_1000\tCount_over_1000" > $output_file

# Loop through each sample column to calculate totals
for i in $(seq 5 $(echo "$header" | awk '{print NF}')); do
    # Extract sample name
    sample_name=$(echo "$header" | cut -f$i)

    # Initialize counts
    count_dash=0
    count_1=0
    count_2_1000=0
    count_over_1000=0

    # Loop through the rows and process each one
    while read -r line || [[ -n "$line" ]]; do
        # Skip the header row
        if [[ "$line" == "$header" ]]; then
            continue
        fi

        # Extract the 'len' value (3rd column) and the sample data
        len=$(echo "$line" | cut -f3)
        sample_value=$(echo "$line" | cut -f$i)

        # Split the len into its components (separated by commas)
        IFS=',' read -r -a len_values <<< "$len"
        IFS=',' read -r -a sample_values <<< "$sample_value"

        # Variables for keeping track of how many positions we have left to process for each len value
        position_counter=0
        for j in "${!len_values[@]}"; do
            variant_len="${len_values[$j]}"
            sample_val="${sample_values[$j]}"

            # Increment the count for each position based on the length
            for ((k=0; k<variant_len; k++)); do
                position_counter=$((position_counter + 1))

                # Handle sample values and increment counts
                if [[ "$sample_val" == "-" ]]; then
                    count_dash=$((count_dash + 1))
                elif [[ "$sample_val" == "1" ]]; then
                    count_1=$((count_1 + 1))
                elif [[ "$sample_val" =~ ^[2-9]$ ]] || [[ "$sample_val" =~ ^[1-9][0-9]$ ]] || [[ "$sample_val" =~ ^[1-9][0-9][0-9]$ ]] || [[ "$sample_val" == "1000" ]]; then
                    count_2_1000=$((count_2_1000 + 1))
                elif [[ "$sample_val" -gt 1000 ]]; then
                    count_over_1000=$((count_over_1000 + 1))
                fi
            done
        done
    done < "$input_file"

    # Write the totals to the output file for this sample
    echo -e "$sample_name\t$count_dash\t$count_1\t$count_2_1000\t$count_over_1000" >> $output_file
done

echo "Analysis complete. Totals saved in $output_file."





########python version ######################################################################################
#!/usr/bin/env python3

import sys

input_file = "SRLPPan_Smiss1_miss0.95_maf0.01.panmap"
output_file = "SRLPPan_Smiss1_miss0.95_maf0.01.panmap.variants.txt"

def categorize(length):
    if length == 1:
        return "one"
    elif 2 <= length <= 1000:
        return "2_1000"
    elif length > 1000:
        return "over_1000"
    else:
        return None

with open(input_file, "r") as infile, open(output_file, "w") as outfile:
    header = infile.readline().strip().split('\t')
    sample_names = header[4:]  # Skip first four columns
    sample_count = len(sample_names)

    # Initialize count dict per sample
    counts = {
        sample: {"dash": 0, "one": 0, "2_1000": 0, "over_1000": 0}
        for sample in sample_names
    }

    for line_num, line in enumerate(infile, start=2):
        parts = line.strip().split('\t')

        if len(parts) < 4 + sample_count:
            print(f"[WARNING] Line {line_num}: Expected {sample_count} samples, got {len(parts)-4}. Skipping.", file=sys.stderr)
            continue

        # Parse len field
        try:
            variant_lengths = list(map(int, parts[2].split(',')))
            num_variants = len(variant_lengths)
        except Exception:
            print(f"[ERROR] Line {line_num}: Couldn't parse len field: {parts[2]}. Skipping.", file=sys.stderr)
            continue

        sample_values = parts[4:]

        for i, val in enumerate(sample_values):
            sample = sample_names[i]
            val = val.strip()

            if val == "-":
                counts[sample]["dash"] += 1
                continue

            # Now correctly handle "1,2", "2,3", etc.
            try:
                indices = [int(v.strip()) for v in val.split(',')]
            except ValueError:
                print(f"[WARNING] Line {line_num}, sample '{sample}': invalid mixed value '{val}'. Skipping.", file=sys.stderr)
                continue

            for idx in indices:
                if not (1 <= idx <= num_variants):
                    print(f"[WARNING] Line {line_num}, sample '{sample}': index {idx} out of range [1-{num_variants}]. Skipping.", file=sys.stderr)
                    continue

                length = variant_lengths[idx - 1]  # Convert from 1-based to 0-based

                cat = categorize(length)
                if cat:
                    counts[sample][cat] += 1

    # Output header
    outfile.write("Sample\tCount_-\tCount_1\tCount_2_1000\tCount_over_1000\n")
    for sample in sample_names:
        c = counts[sample]
        outfile.write(f"{sample}\t{c['dash']}\t{c['one']}\t{c['2_1000']}\t{c['over_1000']}\n")

print(f"✅ Analysis complete. Multi-allelic sites handled. Output: {output_file}")



##############################
#!/bin/bash
#SBATCH -J varcountSRLP
#SBATCH --time=1:00:00
#SBATCH -c 2
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="4G"

ml python/3.11.1-gcc-13.1.0  # Or your environment setup
python3 VariantCount.py
