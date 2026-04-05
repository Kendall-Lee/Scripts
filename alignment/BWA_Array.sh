#!/bin/bash
#SBATCH --job-name=bwa_array
#SBATCH -e bwa_array_%J.err
#SBATCH -o bwa_array_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --mem=96G
#SBATCH --partition=plant
#SBATCH --array=1-4

# Load necessary modules

module load cluster/bwa/0.7.17
module load samtools/1.19.2-gcc-13.1.0

# File paths
#SAMPLE_LIST=short_sample_list.txt
REF=/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanut_hypogaea2/ref.fa
READS_DIR=./
OUTDIR=./SRLP_BAMS

# Create output directory and logs if they don't exist
mkdir -p $OUTDIR missing_logs


# Get sample ID
#SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $SAMPLE_LIST)

# Define input reads
R1=sub_W.2024.SP.CA.D12.F1.26_R1.2x_SRLP.fq.gz
R2=sub_W.2024.SP.CA.D12.F1.26_R2.2x_SRLP.fq.gz

# Output files
OUT_BAM=sub_W.2024.SP.CA.D12.F1.26_0.5x.bam

# Run BWA alignment
bwa mem -t 8 $REF $R1 $R2 | samtools view -@ 4 -bS - | samtools sort -@ 4 -o $OUT_BAM -

# Index BAM
samtools index $OUT_BAM
