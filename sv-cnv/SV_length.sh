# Extract header
bcftools view -h W.2024.SP.CW.D2.F1.18.snpEff.vcf> header.txt

# Filter for SVs < 1000bp
bcftools view -H W.2024.SP.CW.D2.F1.18.snpEff.vcf | awk -F'\t' '$8 ~ /SVLEN/ {split($8, a, ";"); for (i in a) if (a[i] ~ /SVLEN=-?[0-9]+/) {split(a[i], b, "="); if (b[2] < 1000 && b[2] > -1000) print $0}}' > sv_lt_1000.vcf

# Filter for SVs >= 1000bp
bcftools view -H W.2024.SP.CW.D2.F1.18.snpEff.vcf | awk -F'\t' '$8 ~ /SVLEN/ {split($8, a, ";"); for (i in a) if (a[i] ~ /SVLEN=-?[0-9]+/) {split(a[i], b, "="); if (b[2] >= 1000 || b[2] <= -1000) print $0}}' > sv_ge_1000.vcf

# Add headers back
cat header.txt sv_lt_1000.vcf > W.2024.SP.CW.D2.F1.18_sv_less_than_1000bp.vcf
cat header.txt sv_ge_1000.vcf > W.2024.SP.CW.D2.F1.18_sv_greater_equal_1000bp.vcf

# Cleanup
rm header.txt sv_lt_1000.vcf sv_ge_1000.vcf



##############################################################
#!/bin/bash

infile="SRLP_Smiss0.99_miss0.9_maf0.0_kmer0_dep1.fixed.clean.vcf"

# Output file names
snps="SRLP_Smiss0.99_TRv2.named.snps.vcf"
indels="SRLP_Smiss0.99_TRv2.named.indels.vcf"
svs="SRLP_Smiss0.99_TRv2.named.svs.vcf"

# First, extract the header
grep '^#' "$infile" > $snps
grep '^#' "$infile" > $indels
grep '^#' "$infile" > $svs

# Now process variant lines
grep -v '^#' "$infile" | awk -v snp="$snps" -v indel="$indels" -v sv="$svs" '
{
    ref=$4
    split($5, alts, ",")
    for (i in alts) {
        alt=alts[i]
        len_diff = length(alt) > length(ref) ? length(alt) - length(ref) : length(ref) - length(alt)

        if (length(ref) == 1 && length(alt) == 1) {
            print $0 >> snp
            next
        } else if (len_diff > 0 && len_diff <= 1000) {
            print $0 >> indel
            next
        } else if (len_diff > 1000) {
            print $0 >> sv
            next
        }
    }
}
'
