#!/bin/bash
#SBATCH -J bcftools_filter_steps
#SBATCH --time=24:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p normal
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="192G"

ml bcftools/1.19-gcc-13.1.0
ml htslib/1.19.1-gcc-13.1.0

DIR="/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Combined_VCF_redo"
OUTDIR="$DIR"
THREADS=8


bcftools view \
  -v snps \
  -i 'QUAL>=30' \
  merged.vcf.gz \
  -Oz -o step1.snps.qual30.vcf.gz \
  --threads 8

bcftools index step1.snps.qual30.vcf.gz

bcftools view -H step1.snps.qual30.vcf.gz | wc -l > step1.out.lines
