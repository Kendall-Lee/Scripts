#!/bin/bash
#SBATCH --job-name=bcftoools_call
#SBATCH -e Liftoff_%J.err
#SBATCH -o Liftoff_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=256G
#SBATCH --partition=plant


ml bcftools/1.19-gcc-13.1.0

#bcftools merge -m all -O z -o merged.vcf.gz $(cat vcf_list.txt | sed 's/$/.gz/')

bcftools mpileup -Oz -q 20 -f chr18.fasta RemiRagtagchr18.sorted.bam > RemiRagtagchr18.mpileup.vcf.gz
bcftools call -c -Oz RemiRagtagchr18.mpileup.vcf.gz > HorseRagtagtoChr18.call.vcf.gz
