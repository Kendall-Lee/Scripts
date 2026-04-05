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
PREFIX="SHB_LD"

# Convert VCF to PLINK format with half-call handling
plink --vcf $VCF \
  --double-id \
  --allow-extra-chr \
  --set-missing-var-ids @:# \
  --vcf-half-call missing \
  --make-bed \
  --out ${PREFIX}

# Step 2: Basic QC filtering (optional but recommended)
echo "Applying quality filters..."
plink --bfile ${PREFIX} \
  --maf 0.05 \
  --geno 0.1 \
  --mind 0.1 \
  --make-bed \
  --out ${PREFIX}_filtered

# Step 3: Calculate LD (r²) within windows
echo "Calculating LD..."
plink --bfile ${PREFIX}_filtered \
  --r2 \
  --ld-window-kb 1000 \
  --ld-window 99999 \
  --ld-window-r2 0.1 \
  --out ${PREFIX}_ld

# Step 4: Calculate LD for specific chromosome (if needed)
# plink --bfile ${PREFIX}_filtered \
#   --chr Chr.01 \
#   --r2 \
#   --ld-window-kb 5000 \
#   --out ${PREFIX}_ld_chr01

echo "LD calculation complete!"
echo "Output file: ${PREFIX}_ld.ld"
