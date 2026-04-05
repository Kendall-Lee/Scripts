#!/bin/bash
#SBATCH -J bcftools_merge
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%Jmerge"
#SBATCH -e "stds/stderr_%x_%Jmerge"
#SBATCH --mem="92G"

ml bcftools/1.19-gcc-13.1.0
ml htslib/1.19.1-gcc-13.1.0
# 1. Keep only biallelic variants (but ALL types)
# bcftools view -m2 -M2 PAN_DS_merged.vcf.gz -Oz -o PAN_DS_merged.bi.vcf.gz
#
# # 2. Add allele frequency + missingness
# bcftools +fill-tags PAN_DS_merged.bi.vcf.gz \
# -Oz -o PAN_DS_merged.bi.tags.vcf.gz -- -t AF,F_MISSING
#
# # 3. Filter for quality, AF, missingness
bcftools view -i 'QUAL>=20 && AF>=0.05 && AF<=0.95' \
PAN_DS_merged.bi.tags.vcf.gz -Oz -o PAN_DS_merged.bi.tags.qual.vcf.gz
#
# bcftools index -f PAN_DS_merged.bi.tags.qual.vcf.gz



DIR="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/PANGENOME/ENRICHED/filtered_split_vcfs"
OUTDIR="$DIR"       # keep results in the same directory
THREADS=8

# # Reheader, compress, and index each VCF
# for f in "$DIR"/*.combo.vcf; do
#     sample=$(basename "$f".combo.vcf)
#     tmpfile="$OUTDIR/${sample}.name"
#     echo "$sample" > "$tmpfile"
#
#     # Write renamed VCF (compressed with bgzip directly)
#     bcftools reheader -s "$tmpfile" "$f" \
#       | bgzip -c > "$OUTDIR/${sample}.renamed.vcf.gz"
#
#     # Index
#     bcftools index "$OUTDIR/${sample}.renamed.vcf.gz"
#
#     rm "$tmpfile"
# done
#
# # Make a list of renamed files
ls "$OUTDIR"/*.filtered.vcf.split.vcf.withDS.vcf.gz > "$OUTDIR/vcfs.list"
#
# Merge all renamed vcfs
bcftools merge -l $OUTDIR/vcfs.list -Oz -o $OUTDIR/PAN_DS_merged.vcf.gz --threads $THREADS
# #
# # # Index merged VCF
 bcftools index $OUTDIR/PAN_DS_merged.vcf.gz


# Keep only biallelic SNPs
bcftools view -m2 -M2 -v snps $OUTDIR/merged.vcf.gz -Oz -o $OUTDIR/Suzi_e_merged.snps.vcf.gz
bcftools +fill-tags $OUTDIR/Suzi_e_merged.snps.vcf.gz -Oz -o $OUTDIR/Suzi_e_merged.AF.vcf.gz -- -t AF
bcftools view -i 'QUAL>=30 && AF>=0.05 && AF<=0.95' $OUTDIR/Suzi_e_merged.AF.vcf.gz -Oz -o $OUTDIR/Suzi_e_merged.AF.filtered.vcf.gz
bcftools index -f $OUTDIR/Suzi_e_merged.AF.filtered.vcf.gz

########## if you want to do it based off of a list #############



#!/bin/bash
#SBATCH -J bcftools_merge
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%Jmerge"
#SBATCH -e "stds/stderr_%x_%Jmerge"
#SBATCH --mem="92G"

ml bcftools/1.19-gcc-13.1.0
ml htslib/1.19.1-gcc-13.1.0

DIR="/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Combined_VCF"
OUTDIR="$DIR"
THREADS=8
#MISSING_LIST="/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Enrichment_Data/SuziHap1_map/missing.list"  # 🔹 path to your list of missing samples

# # Convert missing.list into a bash array
# mapfile -t MISSING_SAMPLES < "$MISSING_LIST"
#
# # Function to check if sample is in missing.list
# in_missing_list() {
#     local sample=$1
#     for s in "${MISSING_SAMPLES[@]}"; do
#         if [[ "$s" == "$sample" ]]; then
#             return 0
#         fi
#     done
#     return 1
# }
#
# # 🔹 Only process samples in missing.list
# for f in "$DIR"/*.e.vcf; do
#     sample=$(basename "$f" .e.vcf)
#     if ! in_missing_list "$sample"; then
#         echo "Skipping $sample (not in missing.list)"
#         continue
#     fi
#
#     echo "Processing $sample"
#     tmpfile="$OUTDIR/${sample}.name"
#     echo "$sample" > "$tmpfile"
#
#     bcftools reheader -s "$tmpfile" "$f" | bgzip -c > "$OUTDIR/${sample}.renamed.vcf.gz"
#     bcftools index "$OUTDIR/${sample}.renamed.vcf.gz"
#     rm "$tmpfile"
# done
#
# # 🔹 Make a list of only the renamed VCFs that exist (filtered set)
# ls "$OUTDIR"/*.renamed.vcf.gz > "$OUTDIR/renamed_vcfs.list"
#
# # Merge and filter
# bcftools merge -l "$OUTDIR/renamed_vcfs.list" -Oz -o "$OUTDIR/merged.vcf.gz" --threads "$THREADS"
# bcftools index "$OUTDIR/merged.vcf.gz"

#filters merged file to keep only biallelic snps
bcftools view -m2 -M2 -v snps "$OUTDIR/merged.vcf.gz" -Oz -o "$OUTDIR/SHB_merged.snps.vcf.gz"
#adds allele frequency
bcftools +fill-tags "$OUTDIR/SHB_merged.snps.vcf.gz" -Oz -o "$OUTDIR/SHB_merged.snps.AF.vcf.gz" -- -t AF
#filters for quality and allele frequency between 5% and 95%
bcftools view -i 'QUAL>=30 && AF>=0.05 && AF<=0.95' "$OUTDIR/SHB_merged.snps.AF.vcf.gz" -Oz -o "$OUTDIR/SHB_merged.snps.AF.filtered.vcf.gz"
bcftools index -f "$OUTDIR/SHB_merged.snps.AF.filtered.vcf.gz"


#!/bin/bash
#SBATCH -J bcftools_filter
#SBATCH --time=24:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p normal
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="192G"

ml bcftools/1.19-gcc-13.1.0
ml htslib/1.19.1-gcc-13.1.0


DIR="/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Combined_VCF"
OUTDIR="$DIR"
THREADS=8

# Step 1: Extract SNPs only
bcftools view -v snps "$OUTDIR/merged.vcf.gz" \
  -Oz -o "$OUTDIR/SHB_merged.snps.vcf.gz" \
  --threads "$THREADS"

# Step 2: Add AF and other tags (AC, AN, F_MISSING)
bcftools +fill-tags "$OUTDIR/SHB_merged.snps.vcf.gz" \
  -Oz -o "$OUTDIR/SHB_merged.snps.tagged.vcf.gz" \
  -- -t AF,AC,AN,F_MISSING

# Step 3: Apply all filters at once
# - QUAL >= 30
# - AF between 0.05 and 0.95
# - Max 40% missing (F_MISSING < 0.4)
# - Minor allele count >= 25
# - Biallelic sites only
bcftools view \
  -i 'QUAL>=30 && AF>=0.05 && AF<=0.95 && F_MISSING<0.4 && (AC>=25 && AC<=(AN-25)) && N_ALT==1' \
  "$OUTDIR/SHB_merged.snps.tagged.vcf.gz" \
  -Oz -o "$OUTDIR/SHB_merged.snps.filtered.vcf.gz" \
  --threads "$THREADS"

# Index
bcftools index -f "$OUTDIR/SHB_merged.snps.filtered.vcf.gz"

# Quick stats
echo "Variants after filtering:"
bcftools view -H "$OUTDIR/SHB_merged.snps.filtered.vcf.gz" | wc -l
#######
