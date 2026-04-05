#!/bin/bash
#SBATCH -J snpEff
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_snpEff"
#SBATCH -e "stds/stderr_snpEff"
#SBATCH --mem="100G"

ml cluster/java/17.0.9
ml cluster/bcftools/1.18

vcf_dir="/cluster/home/klee/SnpEff/snpEff/vcf_files"
snpEff_jar="snpEff.jar"
genome="peanut"

output_summary="snpEff_impact_summary.tsv"
echo -e "Sample\tSVs >1kb High%\tSVs >1kb Moderate%\tSVs >1kb Low%\tSVs <1kb High%\tSVs <1kb Moderate%\tSVs <1kb Low%\tSNPs High%\tSNPs Moderate%\tSNPs Low%" > $output_summary

for vcf in "$vcf_dir"/*.vcf; do
    id=$(basename "$vcf" .vcf)

    # Extract header
    bcftools view -h "$vcf" > header.txt

    # Filter SVs < 1000bp
    bcftools view -H "$vcf" | awk -F'\t' '$8 ~ /SVLEN/ {split($8, a, ";"); for (i in a) if (a[i] ~ /SVLEN=-?[0-9]+/) {split(a[i], b, "="); if (b[2] < 1000 && b[2] > -1000) print $0}}' > sv_lt_1000.vcf

    # Filter SVs >= 1000bp
    bcftools view -H "$vcf" | awk -F'\t' '$8 ~ /SVLEN/ {split($8, a, ";"); for (i in a) if (a[i] ~ /SVLEN=-?[0-9]+/) {split(a[i], b, "="); if (b[2] >= 1000 || b[2] <= -1000) print $0}}' > sv_ge_1000.vcf

    # Add headers back
    cat header.txt sv_lt_1000.vcf > "${id}_sv_lt_1000bp.vcf"
    cat header.txt sv_ge_1000.vcf > "${id}_sv_ge_1000bp.vcf"

    # Cleanup temp files
    rm header.txt sv_lt_1000.vcf sv_ge_1000.vcf

    # Run snpEff
    java -jar "$snpEff_jar" "$genome" "$vcf" > "${id}.snpEff.vcf"

    # Count total variants per category
    sv_gt_1kb_total=$(grep -vc "^#" "${id}_sv_ge_1000bp.vcf")
    sv_lt_1kb_total=$(grep -vc "^#" "${id}_sv_lt_1000bp.vcf")
    snp_total=$(bcftools view -H "${id}.snpEff.vcf" | grep -c "TYPE=SNP")

    # Count snpEff impacts per category
    sv_gt_1kb_high=$(grep -c "HIGH" "${id}_sv_ge_1000bp.vcf")
    sv_gt_1kb_mod=$(grep -c "MODERATE" "${id}_sv_ge_1000bp.vcf")
    sv_gt_1kb_low=$(grep -c "LOW" "${id}_sv_ge_1000bp.vcf")

    sv_lt_1kb_high=$(grep -c "HIGH" "${id}_sv_lt_1000bp.vcf")
    sv_lt_1kb_mod=$(grep -c "MODERATE" "${id}_sv_lt_1000bp.vcf")
    sv_lt_1kb_low=$(grep -c "LOW" "${id}_sv_lt_1000bp.vcf")

    snp_high=$(grep -c "HIGH" "${id}.snpEff.vcf")
    snp_mod=$(grep -c "MODERATE" "${id}.snpEff.vcf")
    snp_low=$(grep -c "LOW" "${id}.snpEff.vcf")

    # Compute percentages, avoid division by zero
    sv_gt_1kb_high_p=$(awk -v h=$sv_gt_1kb_high -v t=$sv_gt_1kb_total 'BEGIN {print (t > 0 ? (h/t)*100 : 0)}')
    sv_gt_1kb_mod_p=$(awk -v m=$sv_gt_1kb_mod -v t=$sv_gt_1kb_total 'BEGIN {print (t > 0 ? (m/t)*100 : 0)}')
    sv_gt_1kb_low_p=$(awk -v l=$sv_gt_1kb_low -v t=$sv_gt_1kb_total 'BEGIN {print (t > 0 ? (l/t)*100 : 0)}')

    sv_lt_1kb_high_p=$(awk -v h=$sv_lt_1kb_high -v t=$sv_lt_1kb_total 'BEGIN {print (t > 0 ? (h/t)*100 : 0)}')
    sv_lt_1kb_mod_p=$(awk -v m=$sv_lt_1kb_mod -v t=$sv_lt_1kb_total 'BEGIN {print (t > 0 ? (m/t)*100 : 0)}')
    sv_lt_1kb_low_p=$(awk -v l=$sv_lt_1kb_low -v t=$sv_lt_1kb_total 'BEGIN {print (t > 0 ? (l/t)*100 : 0)}')

    snp_high_p=$(awk -v h=$snp_high -v t=$snp_total 'BEGIN {print (t > 0 ? (h/t)*100 : 0)}')
    snp_mod_p=$(awk -v m=$snp_mod -v t=$snp_total 'BEGIN {print (t > 0 ? (m/t)*100 : 0)}')
    snp_low_p=$(awk -v l=$snp_low -v t=$snp_total 'BEGIN {print (t > 0 ? (l/t)*100 : 0)}')

    # Append results to summary file
    echo -e "$id\t$sv_gt_1kb_high_p\t$sv_gt_1kb_mod_p\t$sv_gt_1kb_low_p\t$sv_lt_1kb_high_p\t$sv_lt_1kb_mod_p\t$sv_lt_1kb_low_p\t$snp_high_p\t$snp_mod_p\t$snp_low_p" >> $output_summary

done

echo "Processing complete. Results saved in $output_summary."
