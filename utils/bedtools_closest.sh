ml bedtools2/2.31.1-gcc-13.1.0
ml cluster/seqkit/2.10.0
#nano your txt file and copy and paste in the files, no header
#convert your chromosome position .txt file
awk 'BEGIN{OFS="\t"} {print $1, $2-1, $2}' HIGH_CONFIDENCE_QTL_MARKERS.bed > chr_05_region.clean.txt.bed
#sort
sort -k1,1 -k2,2n HIGH_CONFIDENCE_QTL_MARKERS.bed > HIGH_CONFIDENCE_QTL_MARKERS.sorted.bed
#sort -k1,1 -k2,2n genes.bed > genes.sorted.bed

bedtools closest -a  test.bed -b /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/braker/genes.bed -d >  test.txt

#liftoff genes
bedtools closest -a chr_05_region.clean.txt.sorted.bed -b /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Liftoff/Suziblue_genes_hap1_nohap.sorted.bed -d > Liftoff_chr_05_region.clean.txt.closest.txt

### includes only those found inside a gene (d=0)
awk -F'\t' '$21<=50 {print $20}' STRUCTURAL_VARIANTS_ONLY.closest.txt | sort -u > STRUCTURAL_VARIANTS_ONLY.bed.closest.candidate_genes.txt

awk '{print "^"$1"\\.t"}' HIGH_CONFIDENCE_QTL_MARKERS.closest.candidate_genes.txt > HIGH_CONFIDENCE_QTL_MARKERS.closest.candidate_genes.regex.txt


# Annotate high-confidence QTL regions with nearest genes
bedtools closest -a HIGH_CONFIDENCE_REGIONS.bed \
  -b your_genome_annotation.gff3 \
  -d > QTL_REGIONS_NEAREST_GENES.txt

# Annotate specific SV/high-delta markers
bedtools closest -a QTLSEQ_TOP30_PEAK_MARKERS.bed \
  -b your_genome_annotation.gff3 \
  -d > TOP_MARKERS_NEAREST_GENES.txt

# Check if variants fall WITHIN genes (not just near)
bedtools intersect -a HIGH_CONFIDENCE_QTL_MARKERS.bed \
  -b your_genome_annotation.gff3 \
  -wa -wb > QTL_IN_GENES.txt

#### includes all SNPs
awk '$8<=50000 {print $7}' chr_05_region.clean.txt.closest.txt | sort -u > chr_05_region.clean.txt_candidate_genes.txt

awk '{print "^"$1"\\.t"}' chr_05_region.clean.txt_candidate_genes.txt > chr_05_region.clean.txtcandidate_genes_regex.txt



seqkit grep -n -r -f STRUCTURAL_VARIANTS_ONLY.bed.closest.candidate_genes.txt \
/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/braker/braker.codingseq \
> STRUCTURAL_VARIANTS_ONLY.bed_candidate_genes_cds.fa

grep -c ">" DTFlower_candidate_genes_cds.fa


seqkit translate STRUCTURAL_VARIANTS_ONLY.bed_candidate_genes_cds.fa > STRUCTURAL_VARIANTS_ONLY_candidate_protein.fa
