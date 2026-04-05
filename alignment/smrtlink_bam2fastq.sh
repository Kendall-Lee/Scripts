#!/bin/bash
#SBATCH -J bam2fastq
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o stdout_pbmm2
#SBATCH -e stderr_pbmm2
#SBATCH --mem="100G"

###Smrtlink tool to convert bam files to fastq.gz

ml cluster/singularity/3.11.0

bam="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791.s3.hifi_reads.bam"
out_fastq="./B791.hifi.reads.fastq.gz"

singularity exec --containall --bind /cluster:/cluster --bind /scratch:/scratch docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 bam2fastq $bam -o $out_fastq
