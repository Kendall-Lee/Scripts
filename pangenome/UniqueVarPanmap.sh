#Unique vars from Panmap
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
source "$khufu_dir"/utilities/load_modules.sh
source /cluster/projects/khufu/korani_projects/KhufuEnv/KhufuEnv.sh
#first run panmapGetSNP & panmapGetSV
panmapGetSNP LRLPPan_Smiss1_miss0.95_maf0.01.panmap #no redirect needed
#panmapGetSNP is total SNP
panmapGetSV LRLPPan_Smiss1_miss0.95_maf0.01.panmap
cat SRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap | cut -f 3 | tr ',' '\t' | maxRow > SRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.maxRow

cat SRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.maxRow | sort | uniq -c > SRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.maxRow.uniq

#then run:

#!/bin/bash

# Initialize counters
count_2_to_1000=0
count_over_1000=0

# Iterate over each line of the file
while read -r occurrences variant_length; do
    # If the variant length is between 2 and 1000 inclusive, add to count_2_to_1000
    if [[ $variant_length -ge 2 && $variant_length -le 1000 ]]; then
        count_2_to_1000=$((count_2_to_1000 + occurrences))
    # If the variant length is greater than 1000, add to count_over_1000
    elif [[ $variant_length -gt 1000 ]]; then
        count_over_1000=$((count_over_1000 + occurrences))
    fi
done < "SRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.maxRow.uniq"

# Output the results
echo "Variants between 2bp and 1000bp: $count_2_to_1000"
echo "Variants over 1000bp: $count_over_1000"



# Overlapping sites
#PANMAP SNPs
awk 'NR>1 {print $1, $2, $3}' OFS='\t' SRLPPan_Smiss1_miss0.95_maf0.01.SNP.panmap > SRLPPan_Smiss1_miss0.95_maf0.01.SNP.panmap.coords
awk 'NR>1 {print $1, $2, $3}' OFS='\t' LRLPPan_Smiss1_miss0.95_maf0.01.SNP.panmap > LRLPPan_Smiss1_miss0.95_maf0.01.SNP.panmap.coords

#convert to bed
awk '{print $1, $2-1, $2+$3-1}' OFS='\t' SRLPPan_Smiss1_miss0.95_maf0.01.SNP.panmap.coords > SRLPPan_Smiss1_miss0.95_maf0.01.SNP.panmap.coords.bed
awk '{print $1, $2-1, $2+$3-1}' OFS='\t' LRLPPan_Smiss1_miss0.95_maf0.01.SNP.panmap.coords > LRLPPan_Smiss1_miss0.95_maf0.01.SNP.panmap.coords.bed


ml bedtools2/2.31.1-gcc-13.1.0
#use bedtools intersect to find overlapping sites
bedtools intersect -a SRLPPan_Smiss1_miss0.95_maf0.01.SNP.panmap.coords.bed -b LRLPPan_Smiss1_miss0.95_maf0.01.SNP.panmap.coords.bed -wa -wb > overlapping.panmap.bed

#print count by z
awk '{size=$3-$2; if(size<=1) snp++; else if(size<=1000) indel++; else sv++} END{print snp, indel, sv}' overlapping.panmap.bed




#PANMAP SVs
awk 'NR>1 {print $1, $2, $3}' OFS='\t' SRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap > SRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.coords
awk 'NR>1 {print $1, $2, $3}' OFS='\t' LRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap > LRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.coords

##split and filter to maxRow
awk '{
    n = split($3, a, ",");
    max = 0;
    for (i = 1; i <= n; i++) {
        if (a[i] > max && a[i] != "1" && a[i] != "0")
            max = a[i];
    }
    if (max > 0)
        print $1, $2, max;
}' OFS='\t' LRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.coords > LRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.maxcoords

awk '{
    n = split($3, a, ",");
    max = 0;
    for (i = 1; i <= n; i++) {
        if (a[i] > max && a[i] != "1" && a[i] != "0")
            max = a[i];
    }
    if (max > 0)
        print $1, $2, max;
}' OFS='\t' SRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.coords > SRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.maxcoords



########convert to bed
awk '{print $1, $2-1, $2+$3-1}' OFS='\t' LRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.maxcoords > LRLP_SV_KhufuPan.bed
awk '{print $1, $2-1, $2+$3-1}' OFS='\t' SRLPPan_Smiss1_miss0.95_maf0.01.SV.panmap.maxcoords > SRLP_SV_KhufuPan.bed

#size filter
#SVs over 1kb
awk '$3-$2 > 1000' SRLP_SV_KhufuPan.bed > SRLP_SV_over1kb.bed
awk '$3-$2 > 1000' LRLP_SV_KhufuPan.bed > LRLP_SV_over1kb.bed

# Select 2 ≤ length ≤ 1000 bp (Indels)
awk '$3-$2 >= 2 && $3-$2 <= 1000' SRLP_SV_KhufuPan.bed > SRLP_Indel_KhufuPan.bed
awk '$3-$2 >= 2 && $3-$2 <= 1000' LRLP_SV_KhufuPan.bed > LRLP_Indel_KhufuPan.bed
#intersect command
# only report each A interval once if it overlaps any B interval
bedtools intersect \
    -a SRLP_SV_KhufuPan.bed \
    -b LRLP_SV_KhufuPan.bed \
    -u \
    > SV_overlaps_unique.bed



####### Linear Overlap
awk 'NR>1 {print $1, $2 }' OFS='\t' LRLP_maf0.01_miss95_Smiss1_09.filthet_falsehapmap > LRLP_maf0.01_miss95_Smiss1_09.hapmap.coords
awk 'NR>1 {print $1, $2 }' OFS='\t' Wiregrass_short_linear_09.hapmap > Wiregrass_short_linear_09.hapmap.coords

awk '{print $1, $2-1, $2}' OFS='\t' LRLP_maf0.01_miss95_Smiss1_09.hapmap.coords > LRLP_maf0.01_miss95_Smiss1_09.hapmap.coords.bed
awk '{print $1, $2-1, $2}' OFS='\t' Wiregrass_short_linear_09.hapmap.coords > SRLP_WG_redo_09.bed

bedtools intersect -a SRLP_WG_redo_09.bed -b /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Linear_work/ReDoOctober/LRLP_WG_redo_09.bed -u > WG_vs_SRLP_SNP_overlap.bed
wc -l WG_vs_SRLP_SNP_overlap.bed

#if renaming chromosomes is needed
awk '{sub(/^TRv2Chr\./,"chr"); print}' LRLP_maf0.01_miss95_Smiss1_09.hapmap.coords.bed \
  > LRLP_maf0.01_miss95_Smiss1_09.hapmap.coords_renamed.bed

#### indels
awk 'NR>1 {print $1, $2 }' OFS='\t' SR.merged.filtered.01maf.75miss.hapmap > SR.merged.filtered.01maf.75miss.hapmap.coords
awk 'NR>1 {print $1, $2 }' OFS='\t' LR.merged.DP.filtered.01maf.75miss.hapmap > LR.merged.DP.filtered.01maf.75miss.hapmap.coords


awk '{print $1, $2-1, $2}' OFS='\t' LR.merged.DP.filtered.01maf.75miss.hapmap.coords > LR.merged.DP.filtered.01maf.75miss.hapmap.coords.bed
awk '{print $1, $2-1, $2}' OFS='\t' SR.merged.filtered.01maf.75miss.hapmap.coords > SR.merged.filtered.01maf.75miss.hapmap.coords.bed



bedtools intersect -a SR.merged.filtered.01maf.75miss.hapmap.coords.bed -b /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Linear_work/ReDoOctober/bams/LR.merged.DP.filtered.01maf.75miss.hapmap.coords.bed -u > WG_vs_SRLP_indel_overlap.bed
wc -l WG_vs_SRLP_indel_overlap.bed

bedtools intersect -a /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Linear_work/ReDoOctober/bams/LR.merged.DP.filtered.01maf.75miss.hapmap.coords.bed -b SR.merged.filtered.01maf.75miss.hapmap.coords.bed -u > WG_vs_SRLP_indel_overlap.bedLRLP
wc -l WG_vs_SRLP_indel_overlap.bedLRLP


###make sure beds are separated by tabs not spaces #######
for f in *.bed; do
  sed -i 's/\r$//' "$f"                  # remove stray Windows ^M if any
  awk '{$1=$1}1' OFS='\t' "$f" > tmp && mv tmp "$f"
done
######################################## All way comparison
# ── SNPs
bedtools intersect -a LRLP_linear_SNP.bed \
                   -b LRLP_Pan_SNP.bed \
                   -u > LRLP_SNPs_overlap.bed

# ── Indels
bedtools intersect -a LRLP_linear_indels.bed \
                   -b LRLP_Indel_KhufuPan.bed \
                   -u > LRLP_Indels_overlap.bed



                   # ── SNPs
bedtools intersect -a SRLP_linear_SNP.bed \
                   -b SRLP_Pan_SNP.bed \
                   -u > SRLP_SNPs_overlap.bed

# ── Indels
bedtools intersect -a SRLP_linear_indels.bed \
                   -b SRLP_Indel_KhufuPan.bed \
                   -u > SRLP_Indels_overlap.bed
