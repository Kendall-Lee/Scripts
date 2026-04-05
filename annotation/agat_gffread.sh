#!/bin/bash
#SBATCH --job-name=agat
#SBATCH --partition=batch
#SBATCH --ntasks=4
#SBATCH --mem=55G
#SBATCH --time=04:00:00
#SBATCH --output=agat.out
#SBATCH --error=agat.err

# script by PBentz 30 NOV 2023

# put this script in directory with GTF file from TSEBRA results

## name variables:
# path to gtf file (ie, TSEBRA results)
gtf='/path/to/tsebra.gtf'
# path to genome assembly fasta file (does not need to be masked)
ref='/path/to/genome.fasta'

## load agat
ml AGAT/1.1.0
# convert gtf to gff3 using AGAT
agat_convert_sp_gxf2gxf.pl -g $gtf -o agat.gff3

# load gffread
ml gffread/0.12.7-GCCcore-11.2.0
## filter the gff3 file converted by AGAT using gffread --> discard any mRNAs with CDS having in-frame stop codons, check and adjust the starting CDS phase if the original phase leads to a translation with an in-frame stop codon, single-exon transcripts are also checked on the opposite strand, automatic adjustment of the CDS stop coordinate if premature or downstream, cluster the input transcripts into loci, discarding "redundant" transcripts (those with the same exact introns and fully contained or equal boundaries), also discard as redundant the shorter, fully contained transcripts (intron chains matching a part of the container), and ensure genes have exon annotations, discard any mRNAs that either lack initial START codon or the terminal STOP codon, or have an in-frame stop codon (i.e. only print mRNAs with a complete CDS), and discard genes with CDS < 300 nt
# this script also output peptides and nucleotides (coding sequence only) fasta files for all gene predictions
gffread agat.gff3 \
-g $ref \
-o agat.gffread.gff3 \
--keep-genes \
-O -V -H -B -P --adj-stop \
-M -d gff_duplication_info -K \
--force-exons --gene2exon --t-adopt \
-x splicedCDS.fasta -y peptides.fasta \
-W -S --sort-alpha -l 300 -J

# get stats for preliminary gff3 file converted by AGAT
agat_sp_statistics.pl --gff agat.gff3 -o agat.gff3.stats.out

# get stats for final gff3 file filtered by gffread
agat_sp_statistics.pl --gff agat.gffread.gff3 -o agat.gffread.gff3.stats.out
