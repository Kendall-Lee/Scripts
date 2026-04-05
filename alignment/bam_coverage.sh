#!/bin/bash
#SBATCH --job-name=filt_cov_@id
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=60gb
#SBATCH --time=60:00:00
#SBATCH --output=stds/filt_cov.%j.out
#SBATCH --error=stds/filt_cov.%j.error
#SBATCH --partition=plant

#bam files
bam="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Short_read/RedoMergedShort/Filtered/Filtered_bams/@id.bam"

#prefix
pre="@id_short"
# load samtools
ml cluster/samtools/1.16.1

samtools sort $bam -@ 32 -O BAM -o $pre.sorted.bam
# use samtools to index bam output and extract alignments for each separate chromosome
samtools index ${pre}.sorted.bam
# get coverage information from samtools
samtools coverage ${pre}.sorted.bam -o ${pre}_samtools_coverage.txt
## produce histograms instead of tabular output
samtools coverage -m ${pre}.sorted.bam -o ${pre}_samtools_coverage_hist.txt
## produce histograms with 100bp windows
#samtools coverage -m -w 100 ${pre}.sorted.bam -o ${pre}_samtools_coverage_hist_100bp_windows.txt


for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Coverage/Short_read/RedoMergedShort/Filtered/Filtered_bams| sed "s:.bam::g"); do cat ./filt_cov.sh| sed "s:@id:$i:g" > filt_coverage_"$i".sh; done
