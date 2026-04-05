#!/bin/bash
#SBATCH -J Enrichment_QC
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%JQC"
#SBATCH -e "stds/stderr_%x_%JQC"
#SBATCH --mem="92G"
BED="/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Enrichment_Data/AllProbesSuzi.filtered.bed"
PRE="All_suzi_hap1"
BAM_DIR="/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Enrichment_Data/SuziHap1_map"
echo -e "Sample\tMeanDepth\tPercentCovered" > $PRE.summary.tsv

for bam in $BAM_DIR/*.e.bam; do
    sample=$(basename "$bam" .e.bam)

    # Depth at every base in BED, including zero-coverage
    mean=$(samtools depth -a -b "$BED" "$bam" \
             | awk '{sum+=$3; n+=1} END {if (n>0) print sum/n; else print 0}')

    # Percent of bases with coverage >0
    covered=$(samtools depth -a -b "$BED" "$bam" \
                | awk '{if($3>0) c+=1; n+=1} END {if (n>0) print (c/n)*100; else print 0}')

    echo -e "${sample}\t${mean}\t${covered}" >> $PRE.summary.tsv
done
