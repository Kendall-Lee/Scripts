#!/bin/bash
#SBATCH --job-name=bedtools_@id
#SBATCH --partition=plant
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=350gb
#SBATCH --time=04:00:00
#SBATCH --output=stds/bedtools.@id.%j.out
#SBATCH --error=stds/bedtools.@id.%j.error

bam='/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Short_read/RedoMergedShort/@id.bam'
pre="@id"
annotation_bed='/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Plotting_files/arahy.FixedHeaders.Tifrunner.gnm2.ann1.4K0L.gene_models_main.bed'
total_sum=259622050

ml cluster/bedtools/2.28.0

# Convert GFF to BED
#gff2bed /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Plotting_files/arahy.Tifrunner.gnm2.ann1.4K0L.gene_models_main.gff3 > arahy.Tifrunner.gnm2.ann1.4K0L.gene_models_main.bed

# Find overlaps between BAM and BED
bedtools intersect -abam $bam -b $annotation_bed -bed  > ${pre}_coverage.bed

# Sort the BED file
sort -k1,1 -k2,2n ${pre}_coverage.bed > ${pre}_coverage_sorted.bed

# Merge overlapping intervals
bedtools merge -i ${pre}_coverage_sorted.bed > ${pre}_coverage_merged.bed

# Calculate the total length of merged intervals
overlap_sum=$(awk '{sum += $3 - $2} END {print sum}' ${pre}_coverage_merged.bed)

# Calculate the percentage of overlap
percentage=$(echo "scale=2; ($overlap_sum / $total_sum) * 100" | bc)

# Output the results
echo @id
echo "Total gene space: $total_sum bp"
echo "Overlap gene space: $overlap_sum bp"
echo "Percentage of gene space covered: $percentage%"



#for makig sh files for long
for i in $(ls ./*bam| sed "s:.*/::" | sed "s:.bam::g"); do cat ./bedtools_intersect.sh | sed "s:@id:$i:g"  > bedtools_intersect_"$i".sh; done


#########SHORT READ#############
#for making sh files for Short_reads
for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Short_read/Filtered/*.sorted.bam | sed "s:.*/::" |sed "s:unique_::g; s:_long.sorted.bam::g"); do cat ./bedtools_intersect.sh | sed "s:@id:$i:g"  > bedtools_intersect_"$i".sh; done



#!/bin/bash
#SBATCH --job-name=bedtools_@id
#SBATCH --partition=plant
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=350gb
#SBATCH --time=04:00:00
#SBATCH --output=stds/bedtools.@id.%j.out
#SBATCH --error=stds/bedtools.@id.%j.error

bam='/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Short_read/Filtered/Filtered_bams/unique_@id_long.sorted.bam'
pre="@id_short"
annotation_bed='/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Plotting_files/arahy.FixedHeaders.Tifrunner.gnm2.ann1.4K0L.gene_models_main.bed'
total_sum=259622050

ml cluster/bedtools/2.28.0

# Convert GFF to BED
#gff2bed /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Plotting_files/arahy.Tifrunner.gnm2.ann1.4K0L.gene_models_main.gff3 > arahy.Tifrunner.gnm2.ann1.4K0L.gene_models_main.bed

# Find overlaps between BAM and BED
bedtools intersect -abam $bam -b $annotation_bed -bed  > ${pre}_coverage.bed

# Sort the BED file
sort -k1,1 -k2,2n ${pre}_coverage.bed > ${pre}_coverage_sorted.bed

# Merge overlapping intervals
bedtools merge -i ${pre}_coverage_sorted.bed > ${pre}_coverage_merged.bed

# Calculate the total length of merged intervals
overlap_sum=$(awk '{sum += $3 - $2} END {print sum}' ${pre}_coverage_merged.bed)

# Calculate the percentage of overlap
percentage=$(echo "scale=2; ($overlap_sum / $total_sum) * 100" | bc)

# Output the results
echo @id
echo "Total gene space: $total_sum bp"
echo "Overlap gene space: $overlap_sum bp"
echo "Percentage of gene space covered: $percentage%"





######## Extracting output into a table
awk '
/^[A-Za-z0-9._-]+$/ {id=$0}  # Capture lines with IDs
/Percentage of gene space covered:/ {
  match($0, /([0-9]+(\.[0-9]+)?)%/, arr) # Extract percentage
  if (arr[1] != "") {
    gsub(/%/, "", arr[1]) # Remove the % sign
    printf "%s %s\n", id, int(arr[1]) # Print ID and integer percentage
  }
}' FilteredGene.txt > FilteredGene_Columns.txt
