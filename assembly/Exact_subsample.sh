#!/bin/bash

# Ensure correct usage
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <samplesheet.txt> <genome_size> <output_dir>"
    exit 1
fi

SAMPLESHEET=$1
GENOME_SIZE=$2
OUTPUT_DIR=$3

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Read sample sheet line by line, skipping header
tail -n +2 "$SAMPLESHEET" | while IFS=$'\t' read -r SAMPLE_ID HIFI_READS SHORT_READ_R1 SHORT_READ_R2 HIFI_DEPTH SHORT_DEPTH; do
    echo "Processing sample $SAMPLE_ID..."

    # Remove spaces & hidden characters from depth values
    HIFI_DEPTH=$(echo "$HIFI_DEPTH" | tr -d '[:space:]')
    SHORT_DEPTH=$(echo "$SHORT_DEPTH" | tr -d '[:space:]')

    # Check if depth values are numeric
    if ! [[ "$HIFI_DEPTH" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! [[ "$SHORT_DEPTH" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "Error: Depth values for $SAMPLE_ID are not numeric: HIFI=$HIFI_DEPTH, SHORT=$SHORT_DEPTH"
        continue
    fi

    # Determine the lower depth
    MIN_DEPTH=$(echo "$HIFI_DEPTH $SHORT_DEPTH" | awk '{print ($1 < $2) ? $1 : $2}')

    if (( $(echo "$HIFI_DEPTH == $SHORT_DEPTH" | bc -l) )); then
        echo "Depths are equal; no subsampling needed for $SAMPLE_ID."
        continue
    fi

    echo "Subsampling to $MIN_DEPTH X depth..."

    if (( $(echo "$HIFI_DEPTH > $SHORT_DEPTH" | bc -l) )); then
        # Subsample HiFi reads
        OUTPUT_HIFI="$OUTPUT_DIR/${SAMPLE_ID}_HIFI_subsampled.fastq.gz"
        rasusa reads -g "$GENOME_SIZE" -c "$MIN_DEPTH" -o "$OUTPUT_HIFI" "$HIFI_READS"
        echo "HiFi reads subsampled to $MIN_DEPTH X for $SAMPLE_ID."
    else
        # Subsample short reads (paired-end)
        OUTPUT_R1="$OUTPUT_DIR/${SAMPLE_ID}_R1_subsampled.fq.gz"
        OUTPUT_R2="$OUTPUT_DIR/${SAMPLE_ID}_R2_subsampled.fq.gz"
        rasusa reads -g "$GENOME_SIZE" -c "$MIN_DEPTH" -o "$OUTPUT_R1" -o "$OUTPUT_R2" "$SHORT_READ_R1" "$SHORT_READ_R2"
        echo "Short reads subsampled to $MIN_DEPTH X for $SAMPLE_ID."
    fi

    echo "Done processing $SAMPLE_ID."
done

echo "All samples processed."



###################################################

#!/bin/bash
#SBATCH --job-name=exact match
#SBATCH -e yahs_%J.err
#SBATCH -o yahs_%J.out
#SBATCH --time=48:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=25
#SBATCH --mem=150G
#SBATCH --partition=plant

#save the above script, chmod 777 it, then run:

conda activate rasusa_env

bash norm.sh samplesheet.txt 2.5g ./output/
