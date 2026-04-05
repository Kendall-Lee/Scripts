# R script for analyzing Asparagus genomes with GENESPACE by Philip Bentz
# Run a simple OrthoFinder command from R

install.packages("BiocManager")
library(BiocManager)
devtools::install_github("jtlovell/GENESPACE", upgrade = TRUE, force = TRUE)

# load GENESPACE
library(GENESPACE)
# load dependencies
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(Biostrings))
suppressPackageStartupMessages(library(ggplot2))

BiocManager::install(
  c("BiocGenerics", "IRanges", "GenomicRanges", "GenomeInfoDb", "rtracklayer","BioStrings", force = TRUE))
install.packages('reticulate')
library(reticulate)
py_install("scipy")

#if rtracklayer issue comes up may need to do
# Install the required system libraries via conda
#conda install -c conda-forge xz zlib bzip2 curl
# Also install these development packages that R packages often need
#conda install -c conda-forge liblzma libcurl

# Try installing rtracklayer again
BiocManager::install("rtracklayer", force = TRUE)


# Install remotes if needed
install.packages("remotes")

# Install GENESPACE from GitHub
remotes::install_github("Han-Lab/GENESPACE")
args(init_genespace)

# set working directory
setwd("/cluster/lab/clevenger/KLee/Blueberry_HiFi_data")
# set as variable
wd <- "/cluster/lab/clevenger/KLee/Blueberry_HiFi_data"

# provide path to directory containing genome files (GFF3 and peptides.fasta) for all samples
genomeRepo <-"/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/GenespaceRepo"

# set path to MCScanX
path2mcscanx <- "/cluster/home/klee/MCScanX/MCScanX_h"

gpar <- init_genespace(
  wd = wd,
  path2mcscanx = path2mcscanx)


# Re-parse with unique prefixes by specifying different genomeIDs
parse_annotations(
  rawGenomeRepo = genomeRepo,
  genomeDirs = "W85",
  genomeIDs = "W85",  # This becomes the genome identifier
  gffString = "gff3",
  faString = "faa",
  genespaceWd = wd,
  troubleShoot = TRUE,
  headerEntryIndex = 1,
  overwrite = TRUE,
  headerSep = " ",
  gffIdColumn = "ID"
)

parse_annotations(
  rawGenomeRepo = genomeRepo,
  genomeDirs = "Suziblue",
  genomeIDs = "Suziblue",  # This becomes the genome identifier
  gffString = "gff3",
  faString = "faa",
  genespaceWd = wd,
  troubleShoot = TRUE,
  headerEntryIndex = 1,
  overwrite = TRUE,
  headerSep = " ",
  gffIdColumn = "ID"
)


path2orthofinder = "/cluster/home/klee/miniforge3/envs/genespace/bin/orthofinder"

# Reinitialize and run
gsParam <- init_genespace(
  wd = wd,
  path2orthofinder = path2orthofinder,
  path2mcscanx = path2mcscanx
)


gpar <- run_genespace(gsParam = gsParam, overwrite = TRUE)


# read in genome annotations for one sample
#parse_annotations(rawGenomeRepo=genomeRepo,
               #   genomeDirs="VDarrowii",
               #   genomeIDs = "VDarrowii",
               #   gffString = "gff3",
                #  faString = "faa",
               #   genespaceWd=wd,
               #   troubleShoot = TRUE,
               #   headerEntryIndex = 4,
               #   overwrite = F,
               #   headerSep=" ",
                #  gffIdColumn = "ID")

# Initialize genespace
gsParam <- init_genespace(
  wd = wd,
  path2orthofinder = "/cluster/home/klee/miniforge3/envs/genespace/bin/orthofinder",
  path2mcscanx = path2mcscanx
)

#might need ot run on cluster (not in R)
#orthofinder -f /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/tmp -t 16 -a 1 -X -o /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/orthofinder

# Run genespace
gpar <- run_genespace(gsParam = gsParam)

# Save results
save(gpar, file = file.path(wd, "results", "gsParams.rda"))

####################################################################################
# **NOTE** the genespace parameter object is returned or can be loaded
# into R via `load('/Users/pb/GENESPACE/results/gsParams.rda',verbose = TRUE)`. 
# Then you can customize your riparian plots
# by calling `plot_riparian(gsParam = gsParam, ...)`. The source
# data and ggplot2 objects are also stored in the /riparian
# directory and can also be accessed by `load(...)`.

# **NOTE** To query genespace results by position or gene, use
# `query_genespace(...)`. See specifications in ?query_genespace
# for details.

# load results
load('/Users/kendalllee/Documents/gsParams.rda',verbose = TRUE)
####################################################################################


## for a rainbow color palette
customPal <- colorRampPalette(rainbow(10))

ripDat <- plot_riparian(
  gsParam = gsParam, 
  refGenome = "W85_primary", 
  forceRecalcBlocks = FALSE)

# make custom riparian plot with the above theme, color palette, and inverted chromosomes
ripDat <- plot_riparian(
  gsParam = gsParam, 
  refGenome = "W85",
  genomeIDs = c("W85", "Suziblue"), 
  forceRecalcBlocks = FALSE,
  gapProp = 0.025, # controls the gap size between chromosomes in the largest genome
  scaleBraidGap = 1.75, # adds a gap proportional to the height of the chromosome polygons
  scaleGapSize = .5, # controls how large the gaps are for smaller genomes
  howSquare = 1, # make the chromosome polygons less rounded and more like a rectangle so the bounds are clearer
  chrLabFontSize = 5, # font size for Chr labels
  #  labelTheseGenomes = c("Asparagus_horridus_hap1","Asparagus_horridus_hap2"), # only label these Chr
  #  palette = black_customPal, # uncomment for black color palette custom
  palette = customPal, # uncomment for rainbow color palette custom
  #  palette = white_customPal, # uncomment for white background theme
  #  chrFill = "white", # uncomment for white background theme
  #  addThemes = white_ggthemes, # uncomment for white background theme
  braidAlpha = .65, # adjust transparency of braids
)


# output plot to pdf
pdf(file="test_riparian.pdf", width = 8)
ripDat
dev.off()




####################### TO PLOT ONLY REGION OF INTEREST #########################################
####################### TO PLOT ONLY REGION OF INTEREST #########################################
####################### TO PLOT ONLY REGION OF INTEREST #########################################



## call region of interest
roi <- data.frame(genome = c("Cranberry", "Bilberry", "VDarrowii"), 
                  chr = c("cm040175.1", "cm029270.1", "cm037151.1"), color = c("orange"))

ripDat_roi <- plot_riparian(
  gsParam = out, 
  backgroundColor = NULL,
  highlightBed = roi,
  refGenome = "VDarrowii")

ripDat
## plot just region of interest
ripDat_roi <- plot_riparian(
  gsParam = gsParam, 
  highlightBed = roi, 
  backgroundColor = NULL, # this must be included to only plot ROI
  refGenome = "VDarrowii",
  genomeIDs = c("Cranberry", 
                "Bilberry", "Blueberry"),
  palette = customPal, # color palette
  braidAlpha = .65,   
  scaleBraidGap = 1.75, # adds a gap proportional to the height of the chromosome polygons
  scaleGapSize = .5, # controls how large the gaps are for smaller genomes
  howSquare = 1, # make the chromosome polygons less rounded and more like a rectangle so the bounds are clearer
  chrLabFontSize = 15, # font size for Chr labels
)


# output plot to pdf
pdf(file="Y_inversion.pdf", width = 10)
ripDat_roi
dev.off()




############################################################################################
############################################################################################
############################################################################################
############################################################################################


##### SDR ######




# create data frame for Y-SDR and X-specific region
SDR <- data.frame(
  genome = c("Asparagus_horridus_hap1", "Asparagus_horridus_hap2"),
  chr = c("Chr02", "Chr02"),
  start = c(68935917, 68799476),
  end = c(78464106, 70909589))

# pull syntenic hits against a reference for a specific region
qreturn <- query_hits(gsParam = gsParam, bed = SDR, synOnly = TRUE)

# make dot plot of the hits
sdr_dot <- subset(qreturn[["Asparagus_horridus_hap2, Chr02: 68799476-70909589"]], genome2 == "Asparagus_horridus_hap1")
gghits(sdr_dot, useOrder = F)

# output plot to pdf
pdf(file="SDR_syntenic_dotplot.pdf", width = 10)
gghits(sdr_dot, useOrder = F)
dev.off()

oi <- data.frame(genome = c("Mcerifera_hap1", "Mcerifera_hap2"), chr = c("chr08", "chr08"), color = c("orange"))

ggthemes <- ggplot2::theme(
  panel.background = ggplot2::element_rect(fill = "white"))

ripDat <- plot_riparian(
  gsParam = out, 
  highlightBed = roi, 
  backgroundColor = NULL,
  addThemes = ggthemes,
  chrFill = c("grey"), 
  useOrder = FALSE,
  genomeIDs = c("Mcerifera_hap1", "Mcerifera_hap2"),
  refGenome = "Mcerifera_hap1")

?plot_riparian()

############################################################################################
############################################################################################
############################################################################################
############################################################################################



# make data frame of ROI for just the SDR
SDR2 <- data.frame(
  genome = c("Asparagus_horridus_hap1"),
  chr = c("Chr02"),
  start = c(68935917),
  end = c(78464106))

SDR2$color <- c("cyan")

# make rip plot just highlighting ROI (ie, hap1 SDR)
ripDat <- plot_riparian(
  gsParam = gsParam, 
  refGenome = "Asparagus_horridus_hap1",
  genomeIDs = c("Asparagus_setaceus", 
                "Asparagus_horridus_hap2", 
                "Asparagus_horridus_hap1", 
                "Asparagus_officinalis"), 
  forceRecalcBlocks = FALSE,
  gapProp = 0.025, # controls the gap size between chromosomes in the largest genome
  scaleBraidGap = 1.75, # adds a gap proportional to the height of the chromosome polygons
  scaleGapSize = .5, # controls how large the gaps are for smaller genomes
  howSquare = 1, # make the chromosome polygons less rounded and more like a rectangle so the bounds are clearer
  invertTheseChrs = invchr,
  chrLabFontSize = 10, # font size for Chr labels
  #  palette = black_customPal, # uncomment for black color palette custom
  palette = customPal, # uncomment for rainbow color palette custom
  #  palette = white_customPal, # uncomment for white background theme
  #  chrFill = "lightgrey", # uncomment for white background theme
  #  addThemes = white_ggthemes, # uncomment for white background theme
  braidAlpha = .65, # adjust transparency of braids
  useRegions = FALSE, 
  highlightBed = SDR2,
  labelTheseGenomes = c("Asparagus_horridus_hap1","Asparagus_horridus_hap2"), # only label these Chr
  
)

# output plot to pdf
pdf(file="rip_plot_SDR_highlight.pdf", width = 10)
ripDat
dev.off()


############################################################################################
############################################################################################
############################################################################################
############################################################################################

# make data frame of ROI for just the SDR of Aoff
aoff_SDR <- data.frame(
  genome = c("Asparagus_officinalis"),
  chr = c("AsparagusV1_01"),
  start = c(3411433),
  end = c(4258465))

aoff_SDR$color <- c("green")

# make rip plot just highlighting ROI (ie, hap1 SDR)
ripDat <- plot_riparian(
  gsParam = gsParam, 
  refGenome = "Asparagus_horridus_hap1",
  genomeIDs = c("Asparagus_setaceus", 
                "Asparagus_horridus_hap2", 
                "Asparagus_horridus_hap1", 
                "Asparagus_officinalis"), 
  forceRecalcBlocks = FALSE,
  gapProp = 0.025, # controls the gap size between chromosomes in the largest genome
  scaleBraidGap = 1.75, # adds a gap proportional to the height of the chromosome polygons
  scaleGapSize = .5, # controls how large the gaps are for smaller genomes
  howSquare = 1, # make the chromosome polygons less rounded and more like a rectangle so the bounds are clearer
  invertTheseChrs = invchr,
  chrLabFontSize = 10, # font size for Chr labels
  braidAlpha = .65, # adjust transparency of braids
  useRegions = FALSE, 
  highlightBed = aoff_SDR,
  labelTheseGenomes = c("Asparagus_horridus_hap1","Asparagus_horridus_hap2"), # only label these Chr
  
)


# output plot to pdf
pdf(file="rip_plot_Aoff_SDR_highlight.pdf", width = 10)
ripDat
dev.off()



############################################################################################
############################################################################################
############################################################################################
############################################################################################



## plot A horridus SDR across all Asparagus genomes


# make data frame of ROI for just the SDR
roi <- data.frame(
  genome = c("Asparagus_horridus_hap1"),
  chr = c("Chr02"),
  start = c(68935917),
  end = c(78464106))

roibed <- roi[,c("genome", "chr")]
roibed$start <- c("68935917")
roibed$end <- c("78464106")
roibed$color <- c("cyan")


## plot just region of interest
ripDat_roi <- plot_riparian(
  gsParam = gsParam, 
  highlightBed = roi, 
  backgroundColor = NULL, # this must be included to only plot ROI chromosome
  refGenome = "Asparagus_horridus_hap1",
  genomeIDs = c("Asparagus_horridus_hap1", 
                "Asparagus_horridus_hap2",
                "Asparagus_officinalis", 
                "Asparagus_setaceus"),
  palette = customPal, # color palette
  braidAlpha = .65,   
  scaleBraidGap = 1.75, # adds a gap proportional to the height of the chromosome polygons
  scaleGapSize = .5, # controls how large the gaps are for smaller genomes
  howSquare = 1, # make the chromosome polygons less rounded and more like a rectangle so the bounds are clearer
  chrLabFontSize = 15, # font size for Chr labels
)




# output plot to pdf
pdf(file="Y_inversion_all_Asparagus.pdf", width = 10)
ripDat_roi
dev.off()
