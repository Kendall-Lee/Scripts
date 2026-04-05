#!/bin/bash
#SBATCH --job-name=Whatshap
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=200gb
#SBATCH --time=60:00:00
#SBATCH --output=whatshap.%j.out
#SBATCH --error=whatshap.%j.error
#SBATCH --partition=highmem


eval "$(conda shell.bash hook)"
conda init
conda activate whatshap-env

assembly="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/Redo_hifiasm/Bins/fasta_files/LG04_unitigs.fasta"
reads="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/B791.HiFi.fasta"
pre="LG04_mapping"


whatshap polyphase --ploidy 4 \
  -o LG4_phased.vcf \
  --reference $assembly \
  $pre.filtered_snps.vcf \
  $pre.sorted.bam
