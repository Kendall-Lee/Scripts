#!/bin/bash
#SBATCH --job-name=LG@id
#SBATCH --partition=plant
#SBATCH --ntasks=1
#SBATCH --mem=240gb
#SBATCH -c 16
#SBATCH --time=400:00:00
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"


module load cluster/bwa/0.7.17
ml cluster/samtools/1.16.1

hicR1="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/B791/B791_R1.fastq.gz"
hicR2="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/B791/B791_R2.fastq.gz"

bwa index LG@id.fasta
bwa mem -5SP -T0 -t16 LG@id.fasta $hicR1 $hicR2 -o LG@id.omniC.sam

ml python/3.12.1-gcc-13.1.0

samtools faidx LG@id.fasta
cut -f1,2 LG@id.fasta.fai > LG@id.genome

#for polyploid relax the min mapq and change walks policy
#walks policy- Controls how to handle multi-mapping reads (“walks”), 4best will pick the best‐scoring alignment for each end even if it has ties or multiple placement
/cluster/home/hwright/miniconda3/bin/pairtools parse --min-mapq 20 --walks-policy 4best --max-inter-align-gap 30 --nproc-in 8 --nproc-out 8 --chroms-path LG@id.genome LG@id.omniC.sam > parsed.LG@id.omniC.pairsam

/cluster/home/hwright/miniconda3/bin/pairtools sort --nproc 16 --tmpdir=/cluster/lab/clevenger/hwright/Pine_HiFi_data/tmp/ parsed.LG@id.omniC.pairsam > sorted.parsed.LG@id.omniC.pairsam

/cluster/home/hwright/miniconda3/bin/pairtools dedup --nproc-in 8 --nproc-out 8 --mark-dups --output-stats LG@id.omniC.stats.txt --output dedup.LG@id.omniC.pairsam sorted.parsed.LG@id.omniC.pairsam

/cluster/home/hwright/miniconda3/bin/pairtools split --nproc-in 8 --nproc-out 8 --output-pairs Loblolly.50kb.mapped.hap1.pairs --output-sam unsorted.LG@id.omniC.filter.bam dedup.LG@id.omniC.pairsam

samtools sort -@16 -T /cluster/lab/clevenger/hwright/Pine_HiFi_data/tmp/hap1.temp.bam -o LG@id.omniC.PT.bam unsorted.LG@id.omniC.bam

samtools index LG@id.omniC.PT.bam



#!/usr/bin/env bash
set -euo pipefail

for fasta in LG*_unitigs.fasta; do
  # remove leading "LG" and trailing ".fasta"
  id="${fasta#LG}"       # e.g. "12_unitigs.fasta"
  id="${id%.fasta}"      # e.g. "12_unitigs"

  # generate a new script
  sed "s/@id/${id}/g" bwa_align.sh > bwa_align_"${id}".sh
  chmod +x bwa_align_"${id}".sh

  echo "Written bwa_align_${id}.sh"
done
