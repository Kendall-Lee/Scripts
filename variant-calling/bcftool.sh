#!/bin/bash
#SBATCH --job-name=bcftools
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=600gb
#SBATCH --time=60:00:00
#SBATCH --output=bcftools.%j.out
#SBATCH --error=bcftools.%j.error
#SBATCH --partition=highmem

ml cluster/bcftools/1.18
ref="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Draper/DraperChrOrdered.fasta"
bam="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/minimap_work/Suzi_raw_ref.sorted.bam"

bcftools mpileup -f $ref $bam | bcftools call -mv -Oz -o SuziDraper.vcf

bcftools view variants.vcf | grep "FAD2"
