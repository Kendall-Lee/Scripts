#!/bin/bash
#SBATCH --job-name=SNP_density
#SBATCH -e SNP_density_%J.err
#SBATCH -o SNP_density_%J.out
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem=100G
#SBATCH --partition=normal


ml cluster/vcftools/0.1.16

# Calculate LD directly from your VCF
# More stringent filtering for reliable LD
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --max-missing 0.8 \
  --maf 0.05 \
  --geno-r2 \
  --ld-window-bp 1000000 \
  --min-r2 0.1 \
  --out SHB_LD_high_quality

# Your permissive version (for comparison)
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --max-missing 0.5 \
  --geno-r2 \
  --ld-window-bp 1000000 \
  --min-r2 0.2 \
  --out SHB_LD_permissive



# This should give you proper LD estimates

# 1. SNP density
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --SNPdensity 100000 \
  --out snp_density

# 2. Get basic statistics
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --freq \
  --out snp_freq

# 3. Missing data per individual
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --missing-indv \
  --out missing_indv

# 4. Missing data per site
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --missing-site \
  --out missing_site

# 5. Calculate allele frequency
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --freq2 \
  --out allele_freq

# 6. Site quality scores
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --site-quality \
  --out site_quality

# 7. Depth per individual
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --depth \
  --out depth_per_ind

# 8. Depth per site
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --site-mean-depth \
  --out depth_per_site

# 9. Calculate LD (on subset to avoid huge output)
# First, thin SNPs if you have too many
vcftools --gzvcf SHB_merged.snps.AF.filtered.vcf.gz \
  --thin 10000 \
  --recode \
  --recode-INFO-all \
  --out thinned_snps

# Then calculate LD
vcftools --vcf thinned_snps.recode.vcf \
  --geno-r2 \
  --ld-window-bp 1000000 \
  --min-r2 0.2 \
  --out ld_analysis
