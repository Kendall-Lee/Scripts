#!/bin/bash
#SBATCH --job-name=VCF_merge
#SBATCH -e coverage_%J.err
#SBATCH -o coverage_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=256G
#SBATCH --partition=plant


ml htslib/1.19.1-gcc-13.1.0
ml bcftools/1.19-gcc-13.1.0

# merge_vcfs.sh
# Usage: bash merge_vcfs.sh

# Compress all VCFs if not already compressed
for vcf in *.vcf; do
    echo "Compressing $vcf ..."
    bgzip -c "$vcf" > "${vcf%.vcf}.vcf.gz"
done

# Index all compressed VCFs
for vcf_gz in *.vcf.gz; do
    echo "Indexing $vcf_gz ..."
    bcftools index "$vcf_gz"
done

# Merge them
echo "Merging all VCFs..."
bcftools merge -O z -o LRLP_pan_merged.vcf.gz *.vcf.gz

# Index final merged VCF
bcftools index merged.vcf.gz

echo "Done! Output: merged.vcf.gz"
