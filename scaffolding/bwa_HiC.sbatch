#!/bin/bash
#SBATCH --job-name=BWA_HIC
#SBATCH -e bwa_%J.err
#SBATCH -o bwa_%J.out
#SBATCH --time=72:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=40
#SBATCH --mem=320G
#SBATCH --partition=khufu

module load cluster/bwa/0.7.17
module load cluster/samtools/1.10

assembly="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B767/B767_hifi.asm.hic.hap1.p_ctg.fa"
read1="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/SuziblueHIC.R1.fastq.gz"
read2="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/SuziblueHIC.R2.fastq.gz"
pre="B767_hifi.asm.hic.hap1"
#source activate samblaster
#bwa index -a bwtsw $assembly


bwa mem -t 40 -5SP $assembly $read1 $read2 | /cluster/home/klee/samblaster-v.0.1.26/samblaster | samtools view -S -h -b -F 2316 > $pre.aligned.bam | samtools sort -n $pre.aligned.bam -o $pre.aligned.sorted.bam


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
