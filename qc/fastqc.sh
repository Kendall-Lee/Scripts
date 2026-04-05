#!/bin/bash
#SBATCH -J FastQC_@file
#SBATCH --time=96:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="384G"

ml cluster/multiqc/1.17
ml fastqc/0.12.1-gcc-13.1.0
ml cluster/java/17.0.9
mkdir -p Kendall_fastqc
fastqc -o Kendall_fastqc /cluster/lab/clevenger/KLee/Trinity_data/Kendall_Data/*.fq.gz


multiqc /cluster/lab/clevenger/KLee/Trinity_data/Kendall_fastqc -o /cluster/lab/clevenger/KLee/Trinity_data/Kendall_multiqc





ml fastqc/0.12.1-gcc-13.1.0
ml cluster/java/17.0.9
mkdir -p Kendall_fastqc
fastqc -o Kendall_fastqc /cluster/lab/clevenger/KLee/Trinity_data/Kendall_Data/*.fq.gz
