#!/bin/bash
#SBATCH -J OmniC_QC
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="340G"

ml cluster/pairtools
ml cluster/bwa/0.7.17
ml samtools/1.19.2-gcc-13.1.0
ref="hg38.fasta" #reference genome in fasta format
R1="OmniC_2M_R1.fastq" #omni-c fastq read 1
R2="OmniC_2M_R2.fastq" #omni-c fastq read 2

bwa mem -5SP -T0 -t16 $ref $R1 $R2| pairtools parse --min-mapq 40 --walks-policy 5unique --max-inter-align-gap 30 --nproc-in 8 --nproc-out 8 --chroms-path hg38.genome | pairtools sort --tmpdir=/home/ubuntu/ebs/temp/ --nproc 16|pairtools dedup --nproc-in 8 --nproc-out 8 --mark-dups --output-stats stats.txt|pairtools split --nproc-in 8 --nproc-out 8 --output-pairs mapped.pairs --output-sam -|samtools view -bS -@16 | samtools sort -@16 -o mapped.PT.bam;samtools index mapped.PT.bam
