#!/bin/bash
#SBATCH -e download_SRA_%j.err
#SBATCH -o download_SRA_%j.out
#SBATCH --job-name=download_SRA
#SBATCH --time=24:00:00
#SBATCH -c 8
#SBATCH --mem=64G
#SBATCH --partition=normal

ml cluster/sratoolkit/3.0.0

#!/bin/bash

# Working directory
RAW_DATA_DIR="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/RNA_seq_data"

# List of SRA accessions and sample names
declare -A SAMPLES
SAMPLES["SRR5036131"]="SRR5036131"
SAMPLES["SRR5036131"]="SRR5036131"
SAMPLES["SRR5036131"]="SRR5036131"
SAMPLES["SRR5036131"]="SRR5036131"
SAMPLES["SRR33474177"]="SRR33474177"
SAMPLES["SRR33474179"]="SRR33474179"

# Create raw data directory if it doesn't exist
mkdir -p "${RAW_DATA_DIR}"

# Function to download and compress
download_sra() {
    local sra_accession=$1
    local sample_name=$2

    echo "----------------------------------------"
    echo "Processing ${sample_name} (${sra_accession})"
    echo "----------------------------------------"

    cd "${RAW_DATA_DIR}"

    # Download SRA file (prefetch stores in cache first)
    if ! [ -f "${sra_accession}.sra" ]; then
        echo "Downloading ${sra_accession}..."
        prefetch "${sra_accession}"
    else
        echo "${sra_accession}.sra already exists, skipping download"
    fi

    # Convert to FASTQ
    if command -v fasterq-dump &> /dev/null; then
        echo "Converting ${sra_accession} to FASTQ..."
        fasterq-dump --split-files --threads 4 "${sra_accession}"
    else
        echo "fasterq-dump not found, using fastq-dump..."
        fastq-dump --split-files "${sra_accession}"
    fi

    # Gzip (no renaming needed since SRA # = sample name)
    if [ -f "${sra_accession}_1.fastq" ]; then
        gzip -v "${sra_accession}_1.fastq" "${sra_accession}_2.fastq"
        echo "Created: ${sra_accession}_1.fastq.gz, ${sra_accession}_2.fastq.gz"
    elif [ -f "${sra_accession}.fastq" ]; then
        gzip -v "${sra_accession}.fastq"
        echo "Created: ${sra_accession}.fastq.gz"
    else
        echo "ERROR: No FASTQ files found for ${sra_accession}"
        exit 1
    fi

    echo ""
}

# Loop over all samples
for sra in "${!SAMPLES[@]}"; do
    download_sra "$sra" "${SAMPLES[$sra]}"
done

echo "=========================================="
echo "All downloads complete!"
echo "Raw data located in: ${RAW_DATA_DIR}"
ls -lh "${RAW_DATA_DIR}"/*.fastq.gz
echo "=========================================="
