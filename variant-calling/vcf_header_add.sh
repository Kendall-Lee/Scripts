#!/bin/bash

# Define output files
SMALL_VCF="small_svs_final.vcf"
LARGE_VCF="large_svs_final.vcf"

# Common header for both VCF files
HEADER=$(cat <<EOF
##fileformat=VCFv4.2
##fileDate=$(date +%Y-%m-%d)
##source=Custom_SV_Caller
##INFO=<ID=SVTYPE,Number=1,Type=String,Description="Type of structural variant">
##INFO=<ID=END,Number=1,Type=Integer,Description="End position of the structural variant described in this record">
##INFO=<ID=SVLEN,Number=.,Type=Integer,Description="Difference in length between REF and ALT alleles">
##INFO=<ID=SVANN,Number=.,Type=String,Description="Repeat annotation of structural variant">
##ALT=<ID=INV,Description="Inversion">
##ALT=<ID=DUP,Description="Duplication">
##FILTER=<ID=PASS,Description="All filters passed">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Read depth at this position for this sample">
##contig=<ID=TRv2Chr.01,length=112420854>
##contig=<ID=TRv2Chr.02,length=103302290>
##contig=<ID=TRv2Chr.03,length=143109472>
##contig=<ID=TRv2Chr.04,length=128801742>
##contig=<ID=TRv2Chr.05,length=116542366>
##contig=<ID=TRv2Chr.06,length=118975115>
##contig=<ID=TRv2Chr.07,length=81752458>
##contig=<ID=TRv2Chr.08,length=51529986>
##contig=<ID=TRv2Chr.09,length=120499698>
##contig=<ID=TRv2Chr.10,length=117076737>
##contig=<ID=TRv2Chr.11,length=149287806>
##contig=<ID=TRv2Chr.12,length=120530088>
##contig=<ID=TRv2Chr.13,length=146301462>
##contig=<ID=TRv2Chr.14,length=143237272>
##contig=<ID=TRv2Chr.15,length=160028458>
##contig=<ID=TRv2Chr.16,length=151242074>
##contig=<ID=TRv2Chr.17,length=134191082>
##contig=<ID=TRv2Chr.18,length=135027066>
##contig=<ID=TRv2Chr.19,length=159361216>
##contig=<ID=TRv2Chr.20,length=145034356>
#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO
EOF
)

# Write header to both files
echo -e "$HEADER" > "$SMALL_VCF"
echo -e "$HEADER" > "$LARGE_VCF"

# Process small SVs (<1k)
awk '{print $1"\t"$2"\t"$3"\tN\t<SV>\t.\tPASS\tSVLEN="$4";SVTYPE=SV"}' W.2024.SP.RB.D3.F1.07.snpEff.lengths.small.txt >> "$SMALL_VCF"

# Process large SVs (>=1k)
awk '{print $1"\t"$2"\t"$3"\tN\t<SV>\t.\tPASS\tSVLEN="$4";SVTYPE=SV"}' W.2024.SP.RB.D3.F1.07.snpEff.lengths.large.txt >> "$LARGE_VCF"




####put in correct SV type
awk 'BEGIN {FS=OFS="\t"} {n=split($3, ids, ";"); sv_types=""; for (i=1; i<=n; i++) {split(ids[i], id_parts, "."); sv_types = sv_types (i > 1 ? "," : "") id_parts[2];} $4=sv_types; print $0}' small_svs.vcf > small_svs_fixed.vcf

sed 's/<SV>//g' small_svs_fixed.vcf > small_svs_final.vcf
