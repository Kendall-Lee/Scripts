# Create environment with all required packages
mamba create -n R_genespace
mamba activate R_genespace
# Install all required packages
conda install -c conda-forge -c bioconda \
r-viridis \
r-pak \
r-biocmanager \
r-tidyverse \
r-data.table \
r-Matrix \
r-optparse \
r-stringr \
r-scales \
r-ggplot2 \
bioconductor-iranges \
bioconductor-biostrings \
bioconductor-genomicranges \
bioconductor-rtracklayer \
orthofinder=2.5.5 \
r-igraph \
minimap2

conda activate R_genespace
# Enter R

# Install GENESPACE from GitHub
pak::pkg_install("jtlovell/GENESPACE")
.libPaths(c("/cluster/home/klee/miniforge3/envs/R_genespace/lib/R/library"))

#Install MCScanX
# # Download MCScanX
# git clone https://github.com/wyp1125/MCScanX.git
# cd MCScanX
# # Compile MCScanX
# ml cluster/java/21.0.8
# make
# # Note the full path to MCScanX for later use
# pwd

# go to R
library(GENESPACE)
library(data.table)


path2mcscanx = "/cluster/lab/clevenger/KLee/MCScanX"

# set working directory
setwd("/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/genespace_analysis3")
# set as variable
wd <- "/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/genespace_analysis3"

# provide path to directory containing genome files (GFF3 and peptides.fasta) for all samples
genomeRepo <-"/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/GenespaceRepo"


parse_annotations(
  rawGenomeRepo = genomeRepo,
  genomeDirs = "Suziblue_hap1",
  genomeIDs = "Suziblue_hap1",  # This becomes the genome identifier
  gffString = "gff3",
  faString = "fa",
  genespaceWd = wd,
  troubleShoot = TRUE,
  headerEntryIndex = 1,
  overwrite = TRUE,
  headerSep = " ",
  gffIdColumn = "ID"
)

parse_annotations(
  rawGenomeRepo = genomeRepo,
  genomeDirs = "W85_primary",
  genomeIDs = "W85_primary",  # This becomes the genome identifier
  gffString = "gff3",
  faString = "fa",
  genespaceWd = wd,
  troubleShoot = TRUE,
  headerEntryIndex = 1,
  overwrite = TRUE,
  headerSep = " ",
  gffIdColumn = "ID"
)
parse_annotations(
  rawGenomeRepo = genomeRepo,
  genomeDirs = "B080",
  genomeIDs = "B080",  # This becomes the genome identifier
  gffString = "gff3",
  faString = "fa",
  genespaceWd = wd,
  troubleShoot = TRUE,
  headerEntryIndex = 1,
  overwrite = TRUE,
  headerSep = " ",
  gffIdColumn = "ID"
)
parse_annotations(
  rawGenomeRepo = genomeRepo,
  genomeDirs = "Suziblue_denovo",
  genomeIDs = "Suziblue_denovo",  # This becomes the genome identifier
  gffString = "gff3",
  faString = "fa",
  genespaceWd = wd,
  troubleShoot = TRUE,
  headerEntryIndex = 1,
  overwrite = TRUE,
  headerSep = " ",
  gffIdColumn = "ID"
)
parse_annotations(
  rawGenomeRepo = genomeRepo,
  genomeDirs = "Draper_hap1",
  genomeIDs = "Draper_hap1",  # This becomes the genome identifier
  gffString = "gff3",
  faString = "fa",
  genespaceWd = wd,
  troubleShoot = TRUE,
  headerEntryIndex = 1,
  overwrite = TRUE,
  headerSep = " ",
  gffIdColumn = "ID"
)


# Initialize genespace
gpar <- init_genespace(
wd = wd,
path2mcscanx = path2mcscanx,
path2orthofinder =
"/cluster/home/klee/miniforge3/envs/R_genespace/bin/orthofinder",
nCores = 24,
)
# Run genespace
out <- run_genespace(gpar)
# Save results
saveRDS(out, file = file.path(wd, "genespace_results.rds"))




############################################
# CREATING VISUALIZATIONS #
############################################
library(stringr)
library(scales)
library(viridis)
library(ggplot2)
library(GENESPACE)
library(data.table)
# Load results
out <- readRDS("genespace_results.rds")

load('/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/genespace_analysis3/results/gsParams.rda',verbose = TRUE)

# Set up custom theme
ggthemes <- ggplot2::theme(
panel.background = ggplot2::element_rect(fill = "white"))
# Chromosome dictionary for clean naming
# Chromosome dictionary for clean naming
chr_dict <- c(
  "Vcev1_p0.Chr01" = "Chr.01",
  "Vcev1_p0.Chr02" = "Chr.02",
  "Vcev1_p0.Chr03" = "Chr.03",
  "Vcev1_p0.Chr04" = "Chr.04",
  "Vcev1_p0.Chr05" = "Chr.05",
  "Vcev1_p0.Chr06" = "Chr.06",
  "Vcev1_p0.Chr07" = "Chr.07",
  "Vcev1_p0.Chr08" = "Chr.08",
  "Vcev1_p0.Chr09" = "Chr.09",
  "Vcev1_p0.Chr10" = "Chr.10",
  "Vcev1_p0.Chr11" = "Chr.11",
  "Vcev1_p0.Chr12" = "Chr.12",
  # B080 (rename so they match pattern)
 "B080.Chr01" = "Chr.01",
 "B080.Chr02" = "Chr.02",
 "B080.Chr03" = "Chr.03",
 "B080.Chr04" = "Chr.04",
 "B080.Chr05" = "Chr.05",
 "B080.Chr06" = "Chr.06",
 "B080.Chr07" = "Chr.07",
 "B080.Chr08" = "Chr.08",
 "B080.Chr09" = "Chr.09",
 "B080.Chr10" = "Chr.10",
 "B080.Chr11" = "Chr.11",
 "B080.Chr12" = "Chr.12"
)

chr_dict_char <- as.character(chr_dict)
names(chr_dict_char) <- names(chr_dict)

invchr <- data.frame(
  genome = c("B080", "B080", "B080", "B080", "B080","B080","B080","B080", "Suziblue_hap1","Suziblue_hap1", "Suziblue_hap1","Suziblue_hap1","Suziblue_hap1","Suziblue_hap1","Suziblue_hap1"),
  chr = c("B080_Chr.01", "B080_Chr.04", "B080_Chr.05", "B080_Chr.06", "B080_Chr.07","B080_Chr.08", "B080_Chr.11", "B080_Chr.12", "Chr.03", "Chr.04", "Chr.06", "Chr.07", "Chr.09", "Chr.10", "Chr.11"))

gpar <- plot_riparian(
  gsParam = gsParam,
  genomeIDs = c("Suziblue_hap1","W85_primary", "B080", "Suziblue_denovo", "Draper_hap1"),
  refGenome = "W85_primary",
  chrLabFun = function(x) str_replace_all(x, chr_dict_char),
  #invertTheseChrs = invchr,
  pdfFile = "Test_plot.pdf"
)


invchr <- data.frame(
  genome = c("B080", "B080", "B080", "B080", "B080","B080","B080","B080" ),
  chr = c("B080_Chr.01", "B080_Chr.04", "B080_Chr.05", "B080_Chr.06", "B080_Chr.07"))
ripDat <- plot_riparian(
  gsParam = out,
  minChrLen2plot = 10,
  invertTheseChrs = invchr,
  refGenome = "W85",
  chrLabFontSize = 7,
  labelTheseGenomes = c("human", "mouse", "chicken"))

#############################################

  library(stringr)
  library(dplyr)

  # ---- Chromosome renaming dictionary ----
  # Create vectors of names (old -> new)
  w85_old <- paste0("Vcev1_p0.Chr", sprintf("%02d", 1:12))
  w85_new <- paste0("Chr.", sprintf("%02d", 1:12))

  b080_old <- paste0("B080_Chr.", sprintf("%02d", 1:12))
  b080_new <- paste0("Chr.", sprintf("%02d", 1:12))

  suziblue_old <- paste0("Suziblue_hap1_Chr.", sprintf("%02d", 1:12))
  suziblue_new <- paste0("Chr.", sprintf("%02d", 1:12))

  # Combine into a single named vector
  chr_dict <- c(w85_new, b080_new, suziblue_new)
  names(chr_dict) <- c(w85_old, b080_old, suziblue_old)

  # Convert to plain character vector (required by str_replace_all)
  chr_dict_char <- as.character(chr_dict)
  names(chr_dict_char) <- names(chr_dict)

  # ---- Inverted chromosomes ----
  invchr <- data.frame(
    genome = c(
      rep("B080", 7),
      rep("Suziblue_hap1", 7)
    ),
    chr = c(
      # B080 inversions
      paste0("B080_Chr.", sprintf("%02d", c(1,4,5,6,7,8,11))),
      # Suziblue inversions
      paste0("Suziblue_hap1_Chr.", sprintf("%02d", c(3,4,6,7,9,10,11)))
    )
  )

  # ---- Generate Riparian plot ----
  gpar <- plot_riparian(
    gsParam = gsParam,
    genomeIDs = c("Suziblue_hap1", "W85_primary", "B080"),
    refGenome = "W85_primary",
    # Rename chromosome labels
    chrLabFun = function(x) str_replace_all(x, chr_dict_char),
    invertTheseChrs = invchr,
    pdfFile = "Suziblue_W85_B080_chr1to12_plot.pdf"
  )

  # (Optional, only if supported)
  # gpar$genomeLabel <- c("Suziblue_hap1"="Suziblue", "W85_primary"="W85", "B080"="B080")



### if issue arises Warning message:
In subset_toChainedGenomes(genomeIDs = gids, blk = blk) :
  problem with the block coordinates, some chained combinations of genomeIDs are not in the blocks

# reload the GENESPACE parameters from the finished run
load("results/gsParams.rda")  # creates object: gsParam or out

# make sure ploidy info exists
gsParam$ploidy <- c(Suziblue_hap1 = 1,
                    W85_primary  = 1)

# then run the plot
gpar <- plot_riparian(
  gsParam   = gsParam,
  genomeIDs = c("Suziblue_hap1", "W85_primary", "B080"),
  refGenome = "W85_primary",
  chrLabFun = function(x) stringr::str_replace_all(x, chr_dict_char),
  pdfFile   = "Suziblue_W85_chr1to12_plot.pdf"
)


#!/bin/bash
#SBATCH --job-name=GENESPACE
#SBATCH --partition=normal
#SBATCH --ntasks=1
#SBATCH --mem=240gb
#SBATCH -c 16
#SBATCH --time=400:00:00
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"


source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/miniforge3/envs/R_genespace

Rscript GENESPACE.R
