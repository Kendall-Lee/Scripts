#!/bin/bash
#SBATCH --job-name=checking_adapters
#SBATCH --output=checking_adapters_%j.out
#SBATCH --error=checking_adapters_%j.err
#SBATCH --time=120:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --array=1-7  # Adjusted to match the number of files
#SBATCH --partition=plant
#SBATCH --mem=10G

ml fastp/0.23.4-gcc-13.1.0
# Define the list of input files
FILES=(
  "SRR1187676"
  "SRR1187677"
  "SRR30252211"
  "SRR30252214"
  "SRR30252215"
  "SRR30252216"
  "SRR30252217"
  "SRR30252218"
  "SRR33474177"
  "SRR33474179"
  "SRR5036131"
  )

# Select the input file based on the SLURM_ARRAY_TASK_ID
FILE=${FILES[$SLURM_ARRAY_TASK_ID-1]}
HTML_FILE="fastp_${FILE}.html"

# Run fastp for the selected file
fastp -i "${FILE}_1.fastq" -I "${FILE}_2.fastq" \
      -o checked_"${FILE}_1.fastq" -O checked_"${FILE}_2.fastq" \
      --detect_adapter_for_pe --html "${HTML_FILE}"




Then:
rename R1 1 checked_*.fastq
rename R2 2 checked_*.fastq



ml fastp/0.23.4-gcc-13.1.0

fastp -i checked_SRR33474179_1.fastq.gz -I checked_SRR33474179_2.fastq.gz -o clean_SRR33474179_1.fastq -O clean_SRR33474179_2.fastq --html fastp_SRR33474179.html
