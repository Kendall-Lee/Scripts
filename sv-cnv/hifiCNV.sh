#!/bin/bash
#SBATCH -J hificnv
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o stdout_hificnv
#SBATCH -e stderr_hificnv
#SBATCH --mem="200G"

/cluster/home/klee/hificnv-v0.1.7-x86_64-unknown-linux-gnu/hific --bam /cluster/home/klee/CB7_project/Mapping_files/CB7.mapped.IAC322.sorted.bam --ref /cluster/home/klee/Peanut_seqs/IAC322.fa --threads 12 --output-prefix CB7 --cov-regex "."
