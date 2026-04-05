#!/bin/bash
#SBATCH --job-name=fastq_combine
#SBATCH -e fastq_combine_%J.err
#SBATCH -o fastq_combine_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=256G
#SBATCH --partition=normal

SAMPLE_LIST=/cluster/projects/khufu/qtl_seq_II/PROC/100_KLee/metadata/SHB_665samples.list
ALL_FASTQS=/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/All_fastqs
ENRICH_FASTQS=/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Enrichment_Data/Raw_data
OUTDIR=/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Combined_fastqs

mkdir -p "$OUTDIR"

while read -r SAMPLE; do
    echo "Processing $SAMPLE ..."

    # Locate FASTQs in both directories
    R1_FILES=()
    R2_FILES=()

    # All_fastqs follows:   B001_R1.fq.gz
    [ -f "$ALL_FASTQS/${SAMPLE}_R1.fq.gz" ] && R1_FILES+=("$ALL_FASTQS/${SAMPLE}_R1.fq.gz")
    [ -f "$ALL_FASTQS/${SAMPLE}_R2.fq.gz" ] && R2_FILES+=("$ALL_FASTQS/${SAMPLE}_R2.fq.gz")

    # Enrichment follows:   B001.e_R1.fq.gz
    [ -f "$ENRICH_FASTQS/${SAMPLE}.e_R1.fq.gz" ] && R1_FILES+=("$ENRICH_FASTQS/${SAMPLE}.e_R1.fq.gz")
    [ -f "$ENRICH_FASTQS/${SAMPLE}.e_R2.fq.gz" ] && R2_FILES+=("$ENRICH_FASTQS/${SAMPLE}.e_R2.fq.gz")

    # Skip if no files found
    if [ ${#R1_FILES[@]} -eq 0 ] && [ ${#R2_FILES[@]} -eq 0 ]; then
        echo "  No FASTQs found for $SAMPLE, skipping."
        continue
    fi

    # Concatenate if files exist
    if [ ${#R1_FILES[@]} -gt 0 ]; then
        echo "  Combining R1 files: ${R1_FILES[*]}"
        cat "${R1_FILES[@]}" > "$OUTDIR/${SAMPLE}_R1_combined.fq.gz"
    fi

    if [ ${#R2_FILES[@]} -gt 0 ]; then
        echo "  Combining R2 files: ${R2_FILES[*]}"
        cat "${R2_FILES[@]}" > "$OUTDIR/${SAMPLE}_R2_combined.fq.gz"
    fi
done < "$SAMPLE_LIST"
