###GENESPACE code by Kendall Lee Feb. 2024

#Cluster INSTALLATION
#navigate to miniconda3 folder
#download orthofinder using conda install bioconda::orthofinder
#download MCScanX zip file -> unzip -> go into the directory and type 'make'
#make sure all genome files are in one directory

# load GENESPACE
library(GENESPACE)
# load dependencies
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(Biostrings))
suppressPackageStartupMessages(library(ggplot2))

#BiocManager::install(
#  c("BiocGenerics", "IRanges", "GenomicRanges", "GenomeInfoDb", "rtracklayer",force = TRUE))


# set working directory
setwd("/cluster/home/klee/GENESPACE)
# set as variable
wd <- "/cluster/home/klee/GENESPACE"

# provide path to directory containing genome files (GFF3 and peptides.fasta) for all samples
genomeRepo <-"/cluster/home/klee/GENESPACE/Epichloe_Annotations"

# set path to MCScanX
path2mcscanx <- "/Users/pb/my-bin/MCScanX-master"
