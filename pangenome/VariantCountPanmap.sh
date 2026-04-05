
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
