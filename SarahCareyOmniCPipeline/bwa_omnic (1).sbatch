#!/bin/bash
#SBATCH --job-name=BWA_OMNIC.B791_hap2
#SBATCH -e BWA_OMNIC.B791_hap2_%J.err
#SBATCH -o BWA_OMNIC.B791_hap2_%J.out
#SBATCH --time=72:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=20
#SBATCH --mem=100G
#SBATCH --partition=plant

module load cluster/bwa/0.7.17
module load cluster/samtools/1.10


hifi="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/Redo_hifiasm/B791_hap2_filtered.fasta" #this should be unitigs from hifiasm
hicR1="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/B791/B791_R1.fastq.gz"
hicR2="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/B791/B791_R2.fastq.gz"
pre="B791_Hap2_l0_filter_2308"

bwa index B791_hap2_filtered.fasta

bwa mem -t 20 -5SP $hifi $hicR1 $hicR2  | /cluster/home/klee/samblaster-v.0.1.26/samblaster | samtools view -S -h -b -F 2308 > $pre.bam


bwa mem -t 20 -5SP Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY.50000.fa ../../Illumina/OmniC/KDUN_OmniC_NA_NA_TTCCAAGG_Humulus_lupulus_var_lupuloides_OmniC_-Humulus_lupulus_var_lupuloides_OmniC__I1273_L1_R1.fastq.gz ../../Illumina/OmniC/KDUN_OmniC_NA_NA_TTCCAAGG_Humulus_lupulus_var_lupuloides_OmniC_-Humulus_lupulus_var_lupuloides_OmniC__I1273_L1_R2.fastq.gz | samblaster | samtools view -S -h -b -F 2316 > Humulus_lupuloides_MN-1421.default.hic.hap2.p_ctg.racon_minusY_OmniC.bam
