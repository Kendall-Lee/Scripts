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
id="m84238_241108_235612_s3.hifi_reads.bc2102.bam"
samtools fastq "$id".bam > "$id".fastq



for i in $(ls *bam | sed "s:.bam::g");; do cat ./samtools.sh | sed "s:@id:$i:g" > samtools_"$i".sh; done
