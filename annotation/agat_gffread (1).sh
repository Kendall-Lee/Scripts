#!/bin/bash
#SBATCH --job-name=agat_gffread
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=55G
#SBATCH --time=04:00:00
#SBATCH --output=agat_gffread.%j.out
#SBATCH --error=agat_gffread.%j.err
############################################################
## activate agat env
eval "$(conda shell.bash hook)"
conda init
conda activate agat_env
############################################################

############################################################
## name variables:
# path to gffread executable
gffread="/cluster/home/klee/gffread/gffread"
############################################################
# path to reference fasta genome
ref="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_Full.fa"
# file prefix for in and out
pre="Suziblue_tiberius"
############################################################
############################################################
gzip -d ${ref}.gz
# convert helixer gff to proper gff3 using AGAT
agat_convert_sp_gxf2gxf.pl -g Suziblue_full_tiberius.gff -o Suziblue_full_tiberius.gff3
############################################################
############################################################
## use gffread to filter the gff3 file converted by AGAT using gffread --> discard any mRNAs with CDS having in-frame stop codons, check and adjust the starting CDS phase if the original phase leads to a translation with an in-frame stop codon, single-exon transcripts are also checked on the opposite strand, automatic adjustment of the CDS stop coordinate if premature or downstream, cluster the input transcripts into loci, discarding "redundant" transcripts (those with the same exact introns and fully contained or equal boundaries), also discard as redundant the shorter, fully contained transcripts (intron chains matching a part of the container), and ensure genes have exon annotations, discard any mRNAs that either lack initial START codon or the terminal STOP codon, or have an in-frame stop codon (i.e. only print mRNAs with a complete CDS), and discard genes with CDS < 300 nt
${gffread} Suziblue_full_tiberius.gff3 -g ${ref} -o ${pre}.ISOFORMS.gff3 --keep-genes -O -V -H -B -P --adj-stop -M -K --force-exons --gene2exon --t-adopt -l 300 -J
############################################################
############################################################
# keep longest isoform for each gene - these are your PRIMARY protein coding sequences and peptides
agat_sp_keep_longest_isoform.pl -gff ${pre}.ISOFORMS.gff3 -o ${pre}.PRIMARY.gff3

#  rerun gffread to output peptides and protein coding sequence fasta files for all PRIMARY genes and bed formatted annotations file
${gffread} ${pre}.PRIMARY.gff3 -g ${ref} -o ${pre}.PRIMARY.bed -x ${pre}.PRIMARY.CDS.fa -y ${pre}.PRIMARY.peptides.fa --bed --keep-genes -W -S
#  rerun gffread to output peptides and protein coding sequence fasta files for all genes+ISOFORMS and bed formatted annotations file
${gffread} ${pre}.ISOFORMS.gff3 -g ${ref} -o ${pre}.ISOFORMS.bed -x ${pre}.ISOFORMS.CDS.fa -y ${pre}.ISOFORMS.peptides.fa --bed --keep-genes -W -S

# print stats for primary genes and isoforms
agat_sp_statistics.pl --gff ${pre}.PRIMARY.gff3 -o ${pre}.PRIMARY.gff3.stats.out
agat_sp_statistics.pl --gff ${pre}.ISOFORMS.gff3 -o ${pre}.ISOFORMS.gff3.stats.out
# print stats for prefiltered annotations for comparison
agat_sp_statistics.pl --gff agat.gff3 -o prefiltered.gff.stats.out
