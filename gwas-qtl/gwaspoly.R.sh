# analysis.R
remotes::install_github("jendelman/GWASpoly")
# Set working directory (adjust to your cluster paths!)
setwd("/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Combined_VCF_redo")

# Load required libraries
library(GWASpoly)
library(ggplot2)
library(tidyr)
library(dplyr)

#prepare genos file with merged and filtered VCF file (merged with bcftools and filtered for biallelic sites plus further optional filtering like MAF)
#VCF2dosage(VCF.file ="SHB_merged.snps.AF.filtered.vcf.gz", dosage.file = "SHB_merged.snps.redo.DP.8.maxmiss.4.minminor.25", geno.code = "GT", ploidy = 4, min.DP = 8, max.missing = 0.4, min.minor =  25)
#-------------------------------
# 1. Load + prepare data
#-------------------------------
genofile  <- "SHB_tet.DP.8.maxmiss.3.minminor.25.file"
phenofile <- "SHB_all_pheno.csv"

# Adjust n.traits to the number of columns after DNA_ID (here 16)
# But if you only want to analyse the BLUE columns, you can use 4.
data <- read.GWASpoly(
  ploidy     = 4,
  pheno.file = phenofile,
  geno.file  = genofile,
  format     = "numeric",
  n.traits   = 16,
  delim      = ","
)
#-------------------------------
# 2. Build Kinship matrices
#-------------------------------

data.loco <- set.K(data, LOCO = TRUE, n.core = 1)
save(data.loco, file = "data_loco.tet.RData")
data.original <- set.K(data, LOCO = FALSE, n.core = 1)
save(data.original, file = "data_og.tet.RData")


#-------------------------------
# 3. Set parameters & scan
#-------------------------------
# script2_gwas_trait1.R
library(GWASpoly)

load("data_loco.stringent.RData")
load("data_og.stringent.RData")

data.og <- data.original

N <- 631
params <- set.params(geno.freq = 1 - 5/N, fixed = NULL)

data.loco.scan <- GWASpoly(
  data    = data.loco,
  models  = c("additive","1-dom","2-dom"),
  traits  = c("DTFlower_BLUE"),
  params  = params,
  n.core  = 1
)

save(data.loco.scan, file = "results_loco_stringent_DTFlower_BLUE.RData")

data.og.scan <- GWASpoly(
  data    = data.og,
  models  = c("additive","1-dom","2-dom"),
  traits  = c("DTFlower_BLUE"),
  params  = params,
  n.core  = 1
)

save(data.og.scan, file = "results_og_stringent_DTFlower_BLUE.RData")




#####################################
####### Final Analysis and Viz #####
#####################################


library(GWASpoly)
library(ggplot2)

# Load all your results
load("results_loco_stringent_DTFlower_BLUE.RData")
#load("results_og_stringent_DTFlower_BLUE.RData")


#-------------------------------
# Set Thresholds - LOCO
#-------------------------------
cat("Setting thresholds for LOCO scans...\n")

# For DTFlower
data.bonf.loco.flower <- set.threshold(data.loco.scan, method="Bonferroni", level=0.05)
data.meff.loco.flower <- set.threshold(data.loco.scan, method="M.eff", level=0.05)

# Save thresholded objects
save(data.bonf.loco.flower, file="threshold_bonf_loco_stringent_DTFlower_BLUE.RData")
save(data.meff.loco.flower, file="threshold_meff_loco_stringent_DTFlower_BLUE.RData")

#-------------------------------
# Manhattan Plots
#-------------------------------
cat("Creating Manhattan plots...\n")

# Bonferroni threshold
pdf("Manhattan_Flower_Bonferroni.pdf", width=12, height=8)
manhattan.plot(
  data.bonf.loco.flower,
  traits = "DTFlower_BLUE",
  models = c("additive", "1-dom", "2-dom")
)
dev.off()

# M.eff threshold
pdf("Manhattan_Flower_Meff.pdf", width=12, height=8)
manhattan.plot(
  data.meff.loco.flower,
  traits = "DTFlower_BLUE",
  models = c("additive", "1-dom", "2-dom")
)
dev.off()

# Individual model plots
pdf("Manhattan_Flower_Additive_Bonf.pdf", width=12, height=6)
manhattan.plot(
  data.bonf.loco.flower,
  traits = "DTFlower_BLUE",
  models = "additive"
)
dev.off()

pdf("Manhattan_Flower_1dom_Bonf.pdf", width=12, height=6)
manhattan.plot(
  data.bonf.loco.flower,
  traits = "DTFlower_BLUE",
  models = "1-dom"
)
dev.off()

pdf("Manhattan_Flower_2dom_Bonf.pdf", width=12, height=6)
manhattan.plot(
  data.bonf.loco.flower,
  traits = "DTFlower_BLUE",
  models = "2-dom"
)
dev.off()

#-------------------------------
# Extract QTLs
#-------------------------------
cat("Extracting QTLs...\n")

qtl_flower_bonf <- get.QTL(
  data = data.bonf.loco.flower,
  traits = "DTFlower_BLUE",
  models = c("additive", "1-dom", "2-dom"),
  bp.window = 5e6
)

qtl_flower_meff <- get.QTL(
  data = data.meff.loco.flower,
  traits = "DTFlower_BLUE",
  models = c("additive", "1-dom", "2-dom"),
  bp.window = 5e6
)

#-------------------------------
# Save results as CSV
#-------------------------------
write.csv(qtl_flower_bonf, "QTL_Flower_Bonferroni.csv", row.names = FALSE)
write.csv(qtl_flower_meff, "QTL_Flower_Meff.csv", row.names = FALSE)

#-------------------------------
# Print summary
#-------------------------------
cat("\n=== QTLs with Bonferroni correction ===\n")
print(qtl_flower_bonf)

cat("\n=== QTLs with M.eff correction ===\n")
print(qtl_flower_meff)

cat("\nAnalysis complete! Results and plots saved.\n")
