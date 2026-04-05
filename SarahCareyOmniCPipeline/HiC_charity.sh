#!/bin/bash
#SBATCH -J bwa_B080
#SBATCH --time=96:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH -p highmem
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="800G"

module load cluster/bwa/0.7.17
module load cluster/samtools/1.16.1
module load cluster/picard/2.21.6
module load cluster/python/3.11.1

FILE="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Assembly/B080_utg_filtered.fasta"
echo ${FILE}

GENO=$(echo ${FILE} | sed 's/\/cluster.*\///' | sed 's/_utg_filtered.fasta//') #note the unitigs file doesn't change whether or not you use HiC. Only the hap separation does.
echo ${GENO}

#HAP=$(echo ${FILE} | grep -o 'hap[1,2]')
#echo ${HAP}

HIC_R1="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/B080/B080_R1.fastq.gz"
HIC_R2="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/B080/B080_R2.fastq.gz"

cd /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Assembly/Charity_Method
#bwa index -a bwtsw ${FILE}

bwa mem -5SP -t 32 ${FILE} ${HIC_R1} ${HIC_R2} | samtools view -S -h -b -F 2304 -@ 32 > ${GENO}_HiC.bam #command is suggested by Phase Genomics
samtools sort -@ 32 ${GENO}_HiC.bam > ${GENO}_HiC_sorted.bam

#4, relax the q 30 (q 0) restraint since read pairs mapping to multiple places will still be important, especially for polyploids. Exclude unmapped reads.
samtools view -@ 32 -b -h -F 0x4 ${GENO}_HiC_sorted_flagged_dups_removed.bam | samtools sort -n -@ 32 - > ${GENO}_HiC_post_filtered4.bam
samtools flagstat -@ 32 ${GENO}_HiC_post_filtered4.bam > ${GENO}_HiC_post_filtered4.txt

#6, curious to see if any are above even 1...
samtools view -@ 32 -b -h -q 1 -F 0x4 ${GENO}_HiC_sorted_flagged_dups_removed.bam | samtools sort -n -@ 32 - > ${GENO}_HiC_post_filtered6.bam
samtools flagstat -@ 32 ${GENO}_HiC_post_filtered6.bam > ${GENO}_HiC_post_filtered6.txt


#don't remove the dups... I did this when I just wanted to keep them in just in case.. but later I was like, eh, there's not a reason to use them.
java -jar /cluster/software/picard-2.21.6/picard.jar MarkDuplicates \
I=${GENO}_HiC_sorted.bam \
REMOVE_DUPLICATES=true \
O=${GENO}_HiC_sorted_flagged_dups_removed.bam \
M=${GENO}_dups_metrics.txt

#quality check the reads against the assembly using a PhaseGenomics script: https://github.com/phasegenomics/hic_qc (have to install dependencies with conda first)
samtools sort -@ 32 -n ${GENO}_HiC_sorted_flagged_dups.bam > ${GENO}_HiC_name_sorted_flagged_dups.bam
conda init
conda activate hic_qc
python /cluster/home/cgoeckeritz/software/hic_qc/hic_qc.py -b ${GENO}_HiC_name_sorted_flagged_dups.bam
conda deactivate

#do remove the dups...
java -jar /cluster/software/picard-2.21.6/picard.jar MarkDuplicates \
I=${GENO}_HiC2_sorted.bam \
REMOVE_DUPLICATES=true \
O=${GENO}_HiC_sorted_flagged_dups_removed.bam \
M=${GENO}_dups_metrics_dups_removed.txt


samtools flagstat -@ 32 ${GENO}_HiC_sorted_flagged_dups.bam > ${GENO}_pre-filtered_flagstat_dups_incl.txt
samtools flagstat -@ 32 ${GENO}_HiC_sorted_flagged_dups_removed.bam > ${GENO}_pre-filtered_flagstat_dups_removed.txt

#filter for a few quality metrics... https://www.htslib.org/doc/1.11/samtools-flags.html
#note - properly paired reads may not be the way to go either since a proper pair

#1, filter for quality of 30, exclude secondary and unmapped reads, include only properly paired reads.
samtools view -@ 32 -b -h -q 30 -F 0x0100 -F 0x4 -f 0x2 ${GENO}_HiC_sorted_flagged_dups_removed.bam | samtools sort -n -@ 32 - > ${GENO}_HiC_post_filtered.bam #I filter out secondary alignments here, but... idk if that's actually needed. I think something in the HiC mapping parameters prevents multi-mappers from being penalized. I'll have to do some digging.
#I might have to be wary of the quality flag though, it looks like a lot of them have mapQs of 5 or smaller. Reads aligning to multiple places equally well are assigned a map quality of 0. I think we are going to want to hang on to those...
#samtools flagstat -@ 32 ${GENO}_HiC_post_filtered.bam > ${GENO}_HiC_post_filtered.txt

#2, relax the q 30 restraint since read pairs mapping to multiple places will still be important, especially for polyploids. Exclude secondary and unmapped reads, and include only proper pairs.
#samtools view -@ 32 -b -h -F 0x0100 -F 0x4 -f 0x2 ${GENO}_HiC_sorted_flagged_dups_removed.bam | samtools sort -n -@ 32 - > ${GENO}_HiC_post_filtered2.bam
#samtools flagstat -@ 32 ${GENO}_HiC_post_filtered2.bam > ${GENO}_HiC_post_filtered2.txt

#3, relax the q 30 restraint since read pairs mapping to multiple places will still be important, especially for polyploids. Exclude unmapped reads and include only proper pairs.
samtools view -@ 32 -b -h -F 0x4 -f 0x2 ${GENO}_HiC_sorted_flagged_dups_removed.bam | samtools sort -n -@ 32 - > ${GENO}_HiC_post_filtered3.bam
samtools flagstat -@ 32 ${GENO}_HiC_post_filtered3.bam > ${GENO}_HiC_post_filtered3.txt

#4, relax the q 30 restraint since read pairs mapping to multiple places will still be important, especially for polyploids. Exclude unmapped reads.
samtools view -@ 32 -b -h -F 0x4 ${GENO}_HiC_sorted_flagged_dups_removed.bam | samtools sort -n -@ 32 - > ${GENO}_HiC_post_filtered4.bam
samtools flagstat -@ 32 ${GENO}_HiC_post_filtered4.bam > ${GENO}_HiC_post_filtered4.txt

#5, curious to see if any are above 30... --post filtering, there were about 10% left.
samtools view -@ 32 -b -h -q 30 -F 0x4 ${GENO}_HiC_sorted_flagged_dups_removed.bam | samtools sort -n -@ 32 - > ${GENO}_HiC_post_filtered5.bam
samtools flagstat -@ 32 ${GENO}_HiC_post_filtered5.bam > ${GENO}_HiC_post_filtered5.txt

#6, curious to see if any are above even 1...
samtools view -@ 32 -b -h -q 1 -F 0x4 ${GENO}_HiC_sorted_flagged_dups_removed.bam | samtools sort -n -@ 32 - > ${GENO}_HiC_post_filtered6.bam
samtools flagstat -@ 32 ${GENO}_HiC_post_filtered6.bam > ${GENO}_HiC_post_filtered6.txt

#Decided to go with filter4 and filter6.
#sorted by name so I could mess with the -q flag in YAHS

#sbatch YAHS_ .sh
