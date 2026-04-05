#!/bin/bash
#SBATCH --job-name=BWAmem2
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=50gb
#SBATCH --time=10:00:00

#SBATCH --mail-type=END,FAIL

module load cluster/bwa/0.7.17
module load samtools/1.19.2-gcc-13.1.0

# File paths
#SAMPLE_LIST=short_sample_list.txt
REF="/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanut_hypogaea2/ref.fa"
READS_DIR=./
OUTDIR=./SRLP_BAMS
# Define input reads
R1="sub_W.2024.SP.CA.D12.F1.26_R1.1x_SRLP.fq.gz"
R2="sub_W.2024.SP.CA.D12.F1.26_R2.1x_SRLP.fq.gz"
# Output files
OUT_BAM="sub_W.2024.SP.CA.D12.F1.26.1x.bam"

# Run BWA alignment
bwa mem -t 8 $REF $R1 $R2 | samtools view -@ 4 -bS - | samtools sort -@ 4 -o $OUT_BAM -

# Index BAM
samtools index $OUT_BAM

# 4. Convert to BED
bedtools bamtobed -i $pre.filtered.bam > $pre.filtered.bed
