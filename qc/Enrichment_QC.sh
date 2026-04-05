#!/bin/bash
#SBATCH --job-name=Enrichment_QC
#SBATCH -e Enrichment_QC_%J.err
#SBATCH -o Enrichment_QC_%J.out
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --mem=320G
#SBATCH --partition=plant


ml samtools/1.19.2-gcc-13.1.0

#step 1. evaluate average depth per probe region for each sample in list file
mkdir -p Draper_e_Filter_ProbeCoverage

for BAM in Draper_map/*.bam; do
    # Strip directory + extension to get sample name
    SAMPLE=$(basename "$BAM" .e.bam)
    OUT="Draper_e_Filter_ProbeCoverage/${SAMPLE}.probe_cov.txt"

    echo "Processing $SAMPLE"

    samtools bedcov AllProbesDraper.filtered.bed "$BAM" \
    | awk -v s="$SAMPLE" '{len=$3-$2; avg=$7/len; print $1,$2,$3,$4,s,$7,len,avg}' OFS="\t" > "$OUT"
done

#!/bin/bash
echo -e "Sample\tTotal_Mappings\tTotal_Mappings_Covered\tAverage_Depth" > FilterALL_Summary.tsv

for f in Draper_e_Filter_ProbeCoverage/*.probe_cov.txt; do
    sample=$(head -1 $f | cut -f5)
    total_mappings=$(wc -l < $f)
    total_cov=$(awk '$6>0' $f | wc -l)
    avg_depth=$(awk '{sum+=$8}END{print sum/NR}' $f)
    echo -e "$sample\t$total_mappings\t$total_cov\t$avg_depth" >> Draper_e_FilterALL_Summary.tsv
done



############
#Samtools Depths
#!/bin/bash

BEDFILE="TranscriptProbesSuziHap1.bed"
OUTDIR="TranscriptProbesSuziHap1_depth_summary"
mkdir -p $OUTDIR

for BAM in /cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Enrichment_Data/SuziHap1_map/*.bam
do
    # Get just the basename without path and extension
    SAMPLE=$(basename "$BAM" .bam)

    echo "Processing $SAMPLE ..."

    # Count of bases in BED regions
    samtools depth -b $BEDFILE $BAM \
        | wc -l \
        | awk '{print $1}' \
        > $OUTDIR/${SAMPLE}.bind_count.depth

    # Mean depth across BED regions
    samtools depth -b $BEDFILE $BAM \
        | awk '{sum+=$3} END { if (NR>0) print sum/NR; else print 0}' \
        > $OUTDIR/${SAMPLE}.bind_mean.depth
done
