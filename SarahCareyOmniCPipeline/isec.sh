#!/bin/bash
#SBATCH -J bcftools_isec
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_isec"
#SBATCH -e "stds/stderr_isec"
#SBATCH --mem="200G"
#SBATCH --mail-user=klee@hudsonalpha.org
#SBATCH --mail-type=END,FAIL

bcftools isec -p common_sites -n=2 /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Linear_work/ReDoOctober/bams/LR.merged.vcf.gz /cluster/lab/clevenger/KLee/Wiregrass_LRLP/short_linear_2/bams/SR.merged.vcf.gz
