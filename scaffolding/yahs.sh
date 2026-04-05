#!/bin/bash
#SBATCH --job-name=Suzi_YAHS
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=200G
#SBATCH --partition=khufu

#
# #
# hifi="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/B791_1errOmniCploidy.asm.hic.p_ctg.fa"
# hicR1="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/KSQ0544/KSQ0544_S2_L001_R1_001.fastq.gz"
# hicR2="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/KSQ0544/KSQ0544_S2_L001_R2_001.fastq.gz"
# pre="B791_Primary"
#
module load cluster/samtools/1.10
module load cluster/java/21.0.8
# module load cluster/bwa/0.7.17
#
# # # #first prep unitig file but removing the smallest contigs that will make it noisy
# # samtools faidx $hifi
# # awk '$2 >= 50000' B080_redo.asm.hic.hap1.p_ctg.fa.fai | cut -f1 > B080_hap1_long_contigs.txt
# # samtools faidx B080_redo.asm.hic.hap1.p_ctg.fa $(cat B080_hap1_long_contigs.txt) > B080_hap1_filtered.fa
# # # # # # # # #
# # # #
# # # # # #1 map with bwa
# #bwa index $filtered_hifi
# #bwa to map omnic to contig assembly, -5SP prevents alternative alignments from being reported & (-P) means you won’t get single-end alignments if one read of a pair fails to map.
#
# # # # samtools view -@ 32 -b -q 1 -h -F 2308 B791_hap1_filtered.sorted.bam > B791_hap1_filtered_Q1_2308.sorted.bam #| samtools sort -n -@ 32 - > B791_utg_filtered.sorted_filtered4.bam
# # # # samtools flagstat -@ 32  B791_hap1_filtered_Q1_2308.sorted.bam > B791_hap1_filtered_Q1_2308.sorted.txt
# # # # # # # # # # ##########################################
# # # # # # # # # #2 run yahs/juicer
# # # # # # #
# samtools faidx $hifi
#/cluster/home/klee/yahs/yahs --read-length 1800 B080_filtered_haps.fasta B080_pairs_fixed_take4_header_sorted.pa5
/cluster/home/klee/yahs/juicer pre \
    -a \
    -o yahs.out_JBAT \
    yahs.out.bin \
    yahs.out_scaffolds_final.agp \
    B080_filtered_haps.fasta.fai


java -Xmx300G  -jar /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre yahs.out_JBAT.txt B080_attempt3_yahs.out_JBAT.hic <(echo "assembly 2115512217")
# # # # # # # #
/cluster/home/klee/yahs/juicer pre -a -o yahs.out_JBAT yahs.out.bin yahs.out_scaffolds_final.fa B080_filtered_haps.fasta.fai > B080_CiFi_JBAT.log 2>&1
java -Xmx300G  -jar /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre \
     -a yahs.out.bin \
     yahs.out_scaffolds_final.fa \
     B080_filtered_haps.fasta \
     B080_yahs.out_JBAT.hic

/cluster/home/klee/yahs/yahs  --jb -o B791_Primary /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791/B791_1errOmniCploidy.asm.hic.p_ctg.fa B791_Primary.sorted.bam
/cluster/home/klee/yahs/juicer pre -a -o B791_Primary_JBAT B791_Primary.bin B791_Primary_scaffolds_final.fa $hifi.fai > B791_Primary_JBAT.log 2>&1
# # #
# # # ### have to check the *.log file for the size to use for assembly before running this line
#
 java -Xmx300G  -jar /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre B080_Hap1.sorted_JBAT.txt B080_Hap1.sorted_JBAT.hic <(echo "assembly 1410341478")

#Restrction enzymes for Phase HiC
#Dpnll GATC
#Ddel CTNAG
#Msel TTAA
#Hinfl GANTCs

###########################B080#######################
#!/bin/bash
#SBATCH --job-name=YAHS_B080.sh
#SBATCH -e YAHSF4_B080_utg%J.err
#SBATCH -o YAHSF4_B080_utg%J.out
#SBATCH --time=200:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=100
#SBATCH --mem=500Gb
#SBATCH --partition=plant

# hifi="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Primary_hifiasm/B080_RE.hifiasm.hic.p_utg.fa" #this should be unitigs from hifiasm
# hicR1="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/B080/B080_R1.fastq.gz"
# hicR2="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/B080/B080_R2.fastq.gz"
#hifi="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Assembly/Haps/B080_hap2_filtered.fasta"
module load samtools/1.19.2-gcc-13.1.0
module load cluster/java/17.0.9

#first prep unitig file but removing the smallest contigs that will make it noisy
#samtools faidx $hifi
# awk '$2 >= 50000' $hifi.fai | cut -f1 > B080_long_contigs.txt
# samtools faidx $hifi $(cat B080_long_contigs.txt) > B080_RE.filtered.hifiasm.hic.p_utg.fa

# # #1 map with bwa
# bwa index $filtered_hifi
# # # # #
#bwa mem -t 40 -5SP $filtered_hifi $hicR1 $hicR2 > B080_filtered_utg.bam
#
# samtools view -@ 32 -b -h -F 0x4 B080_filtered_utg.bam|  samtools sort -n -@ 32 - > B080_filtered4_utg.sort.bam
# samtools flagstat -@ 32 B080_filtered4_utg.sort.bam > B080_filtered4_utg.sort.txt
# # # ##########################################
#samtools faidx $hifi
# # # # ##########################################
# # # # #2 run yahs/juicer
# # # #
/cluster/home/klee/yahs/yahs /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/B080_noOmniC.asm.bp.p_ctg.fa ./RESULTS/paired_end/B080.sorted.mq20.bam -o B080.CiFi.mq20
# #
/cluster/home/klee/yahs/juicer pre -a -o B080.CiFi.mq20_JBAT B080.CiFi.mq20.bin B080.CiFi.mq20_scaffolds_final.agp /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/B080_noOmniC.asm.bp.p_ctg.fa.fai > B080.CiFi.mq20_JBAT.log 2>&1

## have to check the *.log file for the size to use for assembly before running this line

java -Xmx300G  -jar /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre B080.CiFi.mq20_JBAT.txt B080.CiFi.mq20_JBAT.hic <(echo "assembly 1497975525")
