#!/bin/bash
#SBATCH --job-name=freebayes
#SBATCH -e logs/freebayes_%A_%a.err
#SBATCH -o logs/freebayes_%A_%a.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=120G
#SBATCH --partition=normal
#SBATCH --array=1-665%90

# Load FreeBayes
module load cluster/freebayes/1.3.1

# Get sample ID
line=$(sed -n "${SLURM_ARRAY_TASK_ID}p"  /cluster/lab/clevenger/KLee/Trinity_data/sample_list.txt)
id="$line"

# Paths
REF=="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa"
BAM="./Kendall_bams/${id}.e.bam"
OUTVCF=${id}.e.vcf

# Run FreeBayes
freebayes -f $REF -b $BAM \
  --ploidy 4 \
  --min-coverage 4 \
  --use-best-n-alleles 4 \
  --genotype-qualities \
  --dont-left-align \
  -v $OUTVCF
