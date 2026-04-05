#!/bin/bash
#SBATCH -J chromosome_binning
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p plant
#SBATCH -o stds/stdout_%x_%A_%a
#SBATCH -e stds/stderr_%x_%A_%a
#SBATCH --mem=64G

#### step by step guide for assembling with bins

PAF="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Alignment/B080SuziHap1.paf"
FASTA="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Assembly/Haps/B080_filtered_haps.fasta"
BAM="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Assembly/Haps/B080_Haps.sorted.bam"

# Step 1: For each contig & reference chromosome pair, sum aligned lengths##########
awk '{
    contig=$1; ref=$6; alnlen=$10;
    key=contig"\t"ref;
    sum[key]+=alnlen
}
END{
    for (key in sum) {
        print key"\t"sum[key]
    }
}' $PAF > contig_ref_alnlen.tsv #this file will be 3 columns like [contig_id]   [ref_chr_id]   [total_aligned_bases]

# Filter alignments
awk '$3 >= 10000' contig_ref_alnlen.tsv > contig_ref_alnlen.filtered.tsv

# Make chromosome bins
mkdir -p contig_lists
for CHR in $(cut -f2 contig_ref_alnlen.filtered.tsv | sort -u); do
    awk -v c="$CHR" '$2==c {print $1}' contig_ref_alnlen.filtered.tsv | sort -u > contig_lists/${CHR}.txt
done

######3. Make a list of contigs for Chr.01 #############
ml cluster/seqkit/2.10.0

mkdir -p chr_bins
for LIST in contig_lists/*.txt; do
    CHR=$(basename $LIST .txt)
    seqkit grep -f $LIST $FASTA > chr_bins/${CHR}.fa
done






#5.Filter HiC BAM for these contigs#########################
ml samtools/1.19.2-gcc-13.1.0
ml cluster/java/17.0.9

mkdir -p hic_bin_filtered
for LIST in contig_lists/*.txt; do
    CHR=$(basename $LIST .txt)
    samtools view -b $BAM $(cat $LIST) > hic_bin_filtered/${CHR}.bam
    samtools sort -o hic_bins/${CHR}.sorted.bam hic_bin_filtered/${CHR}.bam
    samtools index hic_bins/${CHR}.sorted.bam
done

#or map omni C reads ot just the bindbwa index ${REFCHR}.fa
ml cluster/bwa/0.7.17
ml samtools/1.19.2-gcc-13.1.0
ml cluster/java/17.0.9

hicR1="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/B080/B080_R1.fastq.gz"
hicR2="/cluster/lab/clevenger/KLee/Blueberry_HiC_files/B080/B080_R2.fastq.gz"

mkdir -p hic_bins
for FASTA in chr_bins/*.fa; do
    CHR=$(basename $FASTA .fa)
    bwa index $FASTA
    bwa mem -5SP -t 16 $FASTA $hicR1 $hicR2 | samtools view -b -o hic_bins/${CHR}.bam -
    samtools sort -o hic_bins/${CHR}.sorted.bam hic_bins/${CHR}.bam
    samtools index hic_bins/${CHR}.sorted.bam
done


#6. Run YAHS
#!/bin/bash
#SBATCH --job-name=YAHS_B080.sh
#SBATCH -e YAHSF4_B080_utg%J.err
#SBATCH -o YAHSF4_B080_utg%J.out
#SBATCH --time=200:00:00
#SBATCH --nodes=1-1
#SBATCH --ntasks=100
#SBATCH --mem=500Gb
#SBATCH --partition=highmem
ml cluster/java/17.0.9
ml samtools/1.19.2-gcc-13.1.0
samtools index /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Binning/chr_bins/Chr.01.fa
/cluster/home/klee/yahs/yahs /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Binning/chr_bins/Chr.01.fa /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Binning/hic_bins/Chr.01.sorted.bam -o chr01.yahs.bin
# #
/cluster/home/klee/yahs/juicer pre -a -o chr01.yahs.bin_JBAT chr01.yahs.bin_utg.bin chr01.yahs.bin_scaffolds_final.agp Chr.01.fa.fai > Chr.01.yahs.bin_JBAT.log 2>&1

### have to check the *.log file for the size to use for assembly before running this line

java -Xmx300G  -jar /cluster/lab/harkess/bin/yahs-1.1/juicer_tools.1.9.9_jcuda.0.8.jar pre ${REFCHR}.yahs.bin_JBAT.txt B${REFCHR}.yahs.bin_JBAT.hic <(echo "assembly xxx")
