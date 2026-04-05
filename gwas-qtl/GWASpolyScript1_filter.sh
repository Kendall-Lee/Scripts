# script1_prep.R
library(GWASpoly)
setwd("/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Combined_VCF")

genofile  <- "SHB_merged.snps.AF.filtered.mindep5.maf0.03.maxmiss0.2.dosage.CLEAN.file"
phenofile <- "SHB_all_pheno.csv"

#-------------------------------
# 1. Read data
#-------------------------------
cat("Reading GWASpoly data...\n")
data <- read.GWASpoly(
  ploidy     = 4,
  pheno.file = phenofile,
  geno.file  = genofile,
  format     = "numeric",
  n.traits   = 16,
  delim      = ","
)

cat("Initial markers:", nrow(data@map), "\n")
cat("Initial samples:", nrow(data@pheno), "\n")

#-------------------------------
# 2. Filter for stricter MAF
#-------------------------------
cat("Filtering for MAF >= 0.10...\n")

# Calculate MAF (minimum of Ref_Freq and 1-Ref_Freq)
maf <- pmin(data@map$Ref_Freq, 1 - data@map$Ref_Freq)

# Keep markers with MAF >= 0.10
maf_threshold <- 0.10
keep_markers <- which(maf >= maf_threshold)

cat("Markers passing MAF >= 0.10:", length(keep_markers), "\n")
cat("Markers removed:", nrow(data@map) - length(keep_markers), "\n")

# Subset the data
data@map <- data@map[keep_markers, ]
data@geno <- data@geno[, keep_markers]

#-------------------------------
# 3. Build kinship matrices
#-------------------------------
cat("Building LOCO kinship matrix...\n")
data.loco <- set.K(data, LOCO = TRUE, n.core = 1)
save(data.loco, file = "data_loco_maf10.RData")

cat("Building original kinship matrix...\n")
data.og <- set.K(data, LOCO = FALSE, n.core = 1)
save(data.og, file = "data_og_maf10.RData")

cat("Data preparation complete!\n")
cat("Final marker count:", nrow(data.loco@map), "\n")
