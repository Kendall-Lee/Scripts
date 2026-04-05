#!/bin/bash
#SBATCH --job-name=plink
#SBATCH -e plink_%J.err
#SBATCH -o plink_%J.out
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem=100G
#SBATCH --partition=normal

ml cluster/plink/1.90

VCF="SHB_merged.snps.AF.filtered.vcf.gz"
PREFIX="SHB_structure"


# Convert VCF to PLINK format and run PCA
plink2 --vcf $VCF \
       --double-id \
       --allow-extra-chr \
       --set-missing-var-ids @:# \
       --make-bed \
       --out $PREFIX

# Run PCA (default 10 PCs)
plink2 --bfile $PREFIX \
       --pca 20 \
       --out $PREFIX.pca

# Output: your_data_pca.eigenvec and your_data_pca.eigenval
