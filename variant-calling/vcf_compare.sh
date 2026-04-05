#!/bin/bash
#SBATCH -J vcf_compare
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o stdout_vcf_compare
#SBATCH -e stderr_vcf_compare
#SBATCH --mem="90G"


ml cluster/htslib/1.9
ml cluster/vcftools/0.1.16

bgzip file
tabix -p vcf file
vcf-compare vcf_1 vcf_2 > comparison_stats
