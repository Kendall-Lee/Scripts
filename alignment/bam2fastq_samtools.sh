#!/bin/bash
#SBATCH -J samtools_@id
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="190G"



ml cluster/samtools/1.16.1
CIFIBAM="/cluster/lab/clevenger/KLee/CiFi/RESULTS_noOmniC_B080/paired_end/B080.sorted.mq0.bam"
samtools fastq $CIFIBAM > B080.sorted.mq0.fastq



for i in $(ls *bam | sed "s:.bam::g");; do cat ./samtools.sh | sed "s:@id:$i:g" > samtools_"$i".sh; done
