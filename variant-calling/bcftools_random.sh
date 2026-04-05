#!/bin/bash
#SBATCH -J bcftools
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%Jmerge"
#SBATCH -e "stds/stderr_%x_%Jmerge"
#SBATCH --mem="92G"

ml bcftools/1.19-gcc-13.1.0
ml htslib/1.19.1-gcc-13.1.0
#output the comparable genotype matrices for both datasets.
# extract shared variant sites
bcftools view -R common_sites/sites.txt -Oz -o suzi_WGS_common.vcf.gz Suzi_WGS_vcf/suzi_WGS_merged.vcf.gz
bcftools view -R common_sites/sites.txt -Oz -o suzi_enrich_common.vcf.gz Suzi_e_vcf/suzi_enrich_merged.vcf.gz


# make filelists
ls Suzi_WGS_vcf/*.vcf.gz > skim.list
ls Suzi_e_vcf/*.vcf.gz > enrich.list

# merge variant positions
bcftools merge -l skim.list -Oz -o all_skim.vcf.gz
bcftools index all_skim.vcf.gz

bcftools merge -l enrich.list -Oz -o all_enrich.vcf.gz
bcftools index all_enrich.vcf.gz


bcftools isec \
  -p common_sites \
  -n=2 \
  Suzi_WGS_vcf/suzi_WGS_merged.vcf.gz \
  Suzi_e_vcf/Suzi_SHB_e_merged.vcf.gz

  # This will make a folder common_sites/ containing:
  # 0000.vcf → sites unique to WGS
  # 0001.vcf → sites unique to Enrichment
  # 0002.vcf → all (union)
  # 0003.vcf → intersection (present in both; same position + alleles)

#output the comparable genotype matrices for both datasets.
bcftools view -R common_sites/0003.vcf -Oz -o suzi_WGS_common.vcf.gz   Suzi_WGS_vcf/suzi_WGS_merged.vcf.gz
bcftools view -R common_sites/0003.vcf -Oz -o suzi_enrich_common.vcf.gz   Suzi_e_vcf/suzi_enrich_merged.vcf.gz
bcftools index suzi_WGS_common.vcf.gz
bcftools index suzi_enrich_common.vcf.gz
