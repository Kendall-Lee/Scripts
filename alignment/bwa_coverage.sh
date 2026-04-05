#!/bin/bash
#SBATCH --job-name=bwa_coverage
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=100gb
#SBATCH --time=60:00:00
#SBATCH --output=stds/minimap_hifi.%j.out
#SBATCH --error=stds/minimap_hifi.%j.error
#SBATCH --partition=plant
ml cluster/samtools/1.16.1

samtools coverage Suzi_ref.minimap2.sorted.bam -o Suzi_primary_Draper_samtools_coverage.txt
samtools coverage -m Suzi_raw_ref.sorted.bam -o Suzi_raw_Draper_samtools_coverage_hist.txt
#short read 1
read1="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/matching_short/@id_R1.fq.gz"
#short read 2
read2="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/matching_short/@id_R2.fq.gz"
#indexed reference
ref='/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanut_hypogaea2/ref.fa'
#prefix
pre="@id_short"

#load bwa
ml cluster/bwa/0.7.17
#map
bwa mem $ref $read1 $read2 > $pre.bwa_out.sam

# load samtools
ml cluster/samtools/1.16.1
samtools view -@ 32 -h $pre.bwa_out.sam | samtools sort -@ 32 -O BAM -o $pre.sorted.bam
# use samtools to index bam output and extract alignments for each separate chromosome
samtools index ${pre}.sorted.bam
# get coverage information from samtools
samtools coverage ${pre}.sorted.bam -o ${pre}_samtools_coverage.txt
## produce histograms instead of tabular output
samtools coverage -m ${pre}.sorted.bam -o ${pre}_samtools_coverage_hist.txt
## produce histograms with 100bp windows
#samtools coverage -m -w 100 ${pre}.sorted.bam -o ${pre}_samtools_coverage_hist_100bp_windows.txt


for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/matching_short | sed "s:_R[12]\.fq\.gz::g" ); do cat bwa_coverage.sh| sed "s:@id:$i:g" > bwa_coverage_"$i".sh; done


for i in $(ls ./Filtered_bams | sed "s:.bam::g"); do cat ./filt_coverage.sh| sed "s:@id:$i:g" > filt_coverage_"$i".sh; done
