#!/bin/bash
#SBATCH --job-name=merge_SNP_ds
#SBATCH -e merge_SNP_%J.err
#SBATCH -o merge_SNP_%J.out
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=64G
#SBATCH --partition=normal

set -euo pipefail

ml bcftools/1.19-gcc-13.1.0

echo "===== Merging Individual SNP VCFs with DS ====="

# Create list of all DS VCFs
ls vcfs_bgzip/*withDS.vcf.gz > snps_list.txt

# Count files
n_files=$(wc -l < snps_list.txt)
echo "Found $n_files VCF files to merge"

if [ $n_files -ne 95 ]; then
    echo "WARNING: Expected 95 files, found $n_files"
fi

# Check all files are indexed
echo "Checking indices..."
for vcf in $(cat snps_list.txt); do
    if [ ! -f "${vcf}.tbi" ] && [ ! -f "${vcf}.csi" ]; then
        echo "Indexing $vcf..."
        bcftools index $vcf
    fi
done

echo "Merging all samples..."
bcftools merge \
   --file-list sv_ds_list.txt \
   --threads 10 \
   --merge all \
   -Oz -o LRLP_suzihap1_SVs_merged_DS.vcf.gz

bcftools index LRLP_suzihap1_SVs_merged_DS.vcf.gz

echo "Filtering for quality..."
bcftools filter \
   -i 'QUAL>=20' \
   --threads 10 \
   LRLP_suzihap1_SVs_merged_DS.vcf.gz \
   -Oz -o LRLP_suzihap1_SVs_filtered_DS.vcf.gz

bcftools index LRLP_suzihap1_SVs_filtered_DS.vcf.gz

echo "Normalizing and splitting multiallelic sites..."
bcftools norm \
   -m-both \
   --threads 10 \
   LRLP_suzihap1_SVs_filtered_DS.vcf.gz \
   -Oz -o LRLP_suzihap1_SVs_normalized_DS.vcf.gz

bcftools index LRLP_suzihap1_SVs_normalized_DS.vcf.gz

echo "Filtering for biallelic sites only..."
bcftools view \
   -m2 -M2 \
   --threads 10 \
  LRLP_suzihap1_SVs_normalized_DS.vcf.gz \
   -Oz -o LRLP_suzihap1_SVs_biallelic_DS.vcf.gz

bcftools index LRLP_suzihap1_SVs_biallelic_DS.vcf.gz

echo "===== Summary ====="
echo "Merged SNPs: $(bcftools view -H LRLP_suzihap1_SNPs_merged_DS.vcf.gz | wc -l)"
echo "After quality filter: $(bcftools view -H LRLP_suzihap1_SNPs_filtered_DS.vcf.gz | wc -l)"
echo "After normalization: $(bcftools view -H LRLP_suzihap1_SNPs_normalized_DS.vcf.gz | wc -l)"
echo "Biallelic only: $(bcftools view -H LRLP_suzihap1_SNPs_biallelic_DS.vcf.gz | wc -l)"
echo "Number of samples: $(bcftools query -l LRLP_suzihap1_SNPs_biallelic_DS.vcf.gz | wc -l)"

echo ""
echo "===== SNP Type Breakdown ====="
bcftools query -f '%INFO/SNPTYPE\n' LRLP_suzihap1_SNPs_biallelic_DS.vcf.gz | sort | uniq -c

echo ""
echo "DONE!"
echo "Final output: LRLP_suzihap1_SNPs_biallelic_DS.vcf.gz"
