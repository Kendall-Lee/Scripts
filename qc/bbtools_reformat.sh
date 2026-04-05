#!/bin/bash
#SBATCH --job-name=bbreformat_@id
#SBATCH --partition=plant
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=350gb
#SBATCH --time=04:00:00
#SBATCH --output=stds/bedtools.@id.%j.out
#SBATCH --error=stds/bedtools.@id.%j.error

hifi_fastq=""
out_fastq=""
samplereadstarget=""

reformat.sh in=$hifi_fastq out=$out_fastq samplereadstarget=$samplereadstarget
