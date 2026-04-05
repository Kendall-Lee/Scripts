#!/bin/bash
#SBATCH --job-name=BWA_OMNIC_
#SBATCH -e bwa_%J.err
#SBATCH -o bwa_%J.out
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --mem=320G
#SBATCH --partition=plant


hifi="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/B791_1errOmniCploidy.asm.hic.p_ctg.fa"
hicR1="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/KSQ0544/KSQ0544_S2_L001_R1_001.fastq.gz"
hicR2="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/KSQ0544/KSQ0544_S2_L001_R2_001.fastq.gz"
pre="B791_Primary"
#filtered_hifi="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/ReRun-Hifiasm/"$pre".filtered.fa"

module load samtools/1.19.2-gcc-13.1.0
module load cluster/java/17.0.9
module load cluster/bwa/0.7.17

# #first prep unitig file but removing the smallest contigs that will make it noisy
# samtools faidx $hifi
# awk '$2 >= 50000' B791_1errOmniCploidy.asm.hic.p_ctg.fa.fai | cut -f1 > B791_long_contigs.txt
# samtools faidx $hifi $(cat B791_long_contigs.txt) >$pre.filtered.fa
# # # # # # # # #

bwa index $pre.filtered.fa
bwa mem -t 32 -5SP $pre.filtered.fa $hicR1 $hicR2 | /cluster/home/klee/samblaster-v.0.1.26/samblaster | samtools view -S -h -b -F 1804 > $pre.bam
samtools sort $pre.bam > $pre.sorted.bam


# #troubleshoot pipeline
# bwa index $hifi
bwa mem -t 32 -5SP "$hifi" "$hicR1" "$hicR2" > "$pre.sam" 2> bwa_mem.log

/cluster/home/klee/samblaster-v.0.1.26/samblaster --verbose \
  < "$pre.sam" 2> samblaster.log > "$pre.marked.sam"

samtools view -@ 32 -Sb -F 2316 "$pre.marked.sam" > "$pre.bam" 2> samtools.log

#bwa mem -t 40 -5SP palmetto.asm.hic.hap2.p_ctg.fa KWQD_OmniC_NA_NA_TGAGCTAG_Sabal_palmetto_OmniC-Sabal_palmetto_OmniC_I1367_L2_R1.fastq.gz KWQD_OmniC_NA_NA_TGAGCTAG_Sabal_palmetto_OmniC-Sabal_palmetto_OmniC_I1367_L2_R2.fastq.gz | samblaster | samtools view -S -h -b -F 2316 > palmetto.asm.hic.hap2.bam
#installation
Download the file:
wget https://github.com/GregoryFaust/samblaster/releases/download/v.0.1.26/samblaster-v.0.1.26.tar.gz
Unzip the file:
tar -xzvf samblaster-v.0.1.26.tar.gz
Navigate to the extracted directory:
cd samblaster-v.0.1.26
Compile the software:
make
Test the executable:
./samblaster --version
