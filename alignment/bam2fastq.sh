#!/bin/bash
#SBATCH -J bam2fastq
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o stdout_pbsv
#SBATCH -e stderr_pbsv
#SBATCH --mem="200G"

ml cluster/singularity/3.11.0

singularity exec --containall --bind /cluster:/cluster docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 bam2fastq -o suziblue_3 ./m84238_241006_141059_s2.hifi_reads.bam
