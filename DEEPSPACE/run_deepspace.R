#!/usr/bin/env Rscript
# DEEPSPACE analysis for Suziblue hap1 vs W85 blueberry genomes
# Author: Created for KLee
# Date: December 2025

# Load required libraries
library(DEEPSPACE)

# Set up paths
workDir <- "/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/DEEPSPACE/deepspace_analysis"
dir.create(workDir, showWarnings = FALSE, recursive = TRUE)

# Define genome paths
fastaFiles <- c(
  suziblue = "/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa",
  w85 = "/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/W85/V_caesariense_W85-20_P0_v2.fasta"
)

# Define genome IDs
genomeIDs <- c("suziblue", "w85")

# Verify files exist
for(i in genomeIDs) {
  if(!file.exists(fastaFiles[i])) {
    stop(paste0("File not found: ", fastaFiles[i]))
  }
  cat(paste0("Found: ", fastaFiles[i], "\n"))
}

# Get file sizes for reference
for(i in genomeIDs) {
  size <- file.info(fastaFiles[i])$size / 1e9
  cat(paste0(i, " genome size: ", round(size, 2), " GB\n"))
}

# Run DEEPSPACE clean_windows
# These are blueberry genomes which are moderately related
# Using default settings initially, can adjust if needed
cat("\n=== Starting DEEPSPACE analysis ===\n")
cat("Working directory:", workDir, "\n")
cat("Reference genome: suziblue\n")
cat("Query genome: w85\n\n")

results <- clean_windows(
  faFiles = fastaFiles,
  genomeIDs = genomeIDs,
  wd = workDir,
  preset = "dist fast",
  stripChrname = "",     # not NULL
  minChrLen = 1e6,
  nCores = 8,
  MCScanX_hCall = "/cluster/home/klee/MCScanX/MCScanX",
  minimap2call = "minimap2"
)

test <- clean_windows(
  faFiles = fastaFiles,
  genomeIDs = c("gorilla", "human", "mouse"),
  wd = workHere,
  
  preset = "dist fast",
  
  stripChrname = ".*chromosome |,.*",
  minChrLen = 20e6, 
  
  nCores = 8,
  MCScanX_hCall = "/path/to/MCScanX/MCScanX_h",
  minimap2call = "/path/to/minimap2")

cat("\n=== DEEPSPACE analysis complete ===\n")
cat("Results saved to:", workDir, "\n")

# List output files
cat("\nOutput files:\n")
output_files <- list.files(workDir, pattern = "\\.(paf|pdf)$", full.names = TRUE)
for(f in output_files) {
  cat(" -", basename(f), "\n")
}

# Create custom riparian plot with specific styling
cat("\n=== Creating custom riparian plot ===\n")
pdf(file.path(workDir, "custom_riparian_plot.pdf"), width = 12, height = 8)
riparian_paf(
  pafFiles = results$mapFilePaths$synFile,
  refGenome = results$refGenome,
  genomeIDs = results$genomeIDs,
  orderyBySynteny = TRUE,
  braidOffset = 0.075,
  braidColors = c("dodgerblue3", "forestgreen", "firebrick3"),
  highlightInversions = "darkorange",
  braidAlpha = 0.8
)
dev.off()

cat("\n=== Analysis Summary ===\n")
cat("Working directory:", workDir, "\n")
cat("Synteny files: ", paste(basename(results$mapFilePaths$synFile), collapse = ", "), "\n")
cat("Dotplots saved as PDF\n")
cat("Riparian plots saved as PDF\n")

# Save session info
sink(file.path(workDir, "session_info.txt"))
cat("DEEPSPACE Analysis Session Info\n")
cat("================================\n\n")
sessionInfo()
sink()

cat("\nSession info saved to:", file.path(workDir, "session_info.txt"), "\n")
cat("\n=== All done! ===\n")
