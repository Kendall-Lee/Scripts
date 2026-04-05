#Allele effect pipeline
cat Fruit_QTLvar.txt.txt | awk '$1 == "Chr.04" && $2 > 2e7 && $2 < 3e7 && $3 > 0.75 && $5 >.2' |  sort -t$'\t' -k4g

head -n 1 SHB_Smiss0.8_miss0.8_maf0.1.hapmap && grep "Chr.04" SHB_Smiss0.8_miss0.8_maf0.1.hapmap| grep "24923537"


chr="Chr.04"
pos="24923537"


(head -n 1 SHB_Smiss0.8_miss0.8_maf0.1.hapmap && grep $chr SHB_Smiss0.8_miss0.8_maf0.1.hapmap| grep "$pos") | awk '
{
    for (i=1; i<=NF; i++) {
        if (NR == 1) {
            header[i] = $i;  # Store header names
        } else {
            row[i] = (row[i] ? row[i] FS : "") $i;  # Concatenate column-wise
        }
    }
}
END {
    for (i=1; i<=NF; i++) {
        print header[i], row[i];  # Print each column as a row
    }
}' | tr ' ' '\t' | grep -v "-" > "$chr"_"$pos"_alleles.txt



./extract_snp_phenos.txt SHB_Smiss0.8_miss0.8_maf0.1.hapmap FruitWTphenos.txt $chr $pos

# ###########################################################
# Estimation of per‑marker variance explained (R²).
# We used a custom R script to estimate the fraction of phenotypic variance in fruit weight explained by each marker within a defined genomic region.
# The script reads the HapMap genotype file and the phenotype table, restricts the data to the specified chromosome and coordinate range, and converts genotype calls to numeric dosage codes (0, 1, 2), representing the two homozygous and heterozygous states.
# Any missing genotypes (encoded as “–”, “_”, or “N”) were treated as missing values (NA) and ignored in calculations.
# For markers with technical replicates (columns ending in “.1”, “.2”, “.3”), replicate genotypes were averaged to produce a single value per individual.
# Only markers scored in ≥ 30 individuals were evaluated.
# For each qualifying marker, we computed the squared Pearson correlation between the numeric genotype vector and the corresponding phenotypic values across individuals:
# R
# i
# 2
# ​
#  =corr
# 2
#  (G
# i
# ​
#  , P),
# where G
# i
# ​
#   is the genotype dosage and P is the phenotype.
# This statistic is equivalent to the coefficient of determination from a simple linear regression of phenotype on genotype and represents the proportion of trait variance explained by that marker.
# The resulting R² values were used to rank SNPs by their explanatory power.

#Run R2 calculation
# ============================================================
# Compute R² (percent variance explained) for SNPs/indels
# in a specified chromosome region from a HapMap file.
# Filters out sites with fewer than 7 non‑missing genotypes.
# ============================================================

# -------- User parameters ----------------------------------
hapmap_file <- "SHB_Smiss0.8_miss0.8_maf0.1.hapmap"
pheno_file  <- "D2Flowerpheno.txt"

target_chr  <- "Chr.10"     # chromosome name
start_pos   <- 5e6          # start coordinate (numeric)
end_pos     <- 15e6          # end coordinate (numeric)
min_samples <- 30            # minimum valid calls for an R² to be computed
# ------------------------------------------------------------

cat("Loading data ...\n")

# ---- 1. Read phenotype table ----
pheno <- read.table(pheno_file, header = TRUE, stringsAsFactors = FALSE)
rownames(pheno) <- pheno$ID
cat("Phenotypes loaded for", nrow(pheno), "samples\n")

# ---- 2. Read HapMap ----
suppressPackageStartupMessages(library(data.table))
hap <- fread(hapmap_file, data.table = FALSE)
colnames(hap)[1:2] <- c("chr", "pos")

# ---- 3. Filter by region ----
hap_sub <- subset(hap, chr == target_chr & pos >= start_pos & pos <= end_pos)
cat("Number of SNPs in region:", nrow(hap_sub), "\n")

# ---- 4. Identify and clean sample names ----
sample_cols <- colnames(hap_sub)[3:ncol(hap_sub)]
sample_names_clean <- sub("\\..*$", "", sample_cols)  # drop ".1", ".2", ".3"
unique_samples <- unique(sample_names_clean)

# ---- 5. Intersect with phenotype IDs ----
common_ids <- intersect(unique_samples, pheno$ID)
cat("Shared samples found:", length(common_ids), "\n")
if (length(common_ids) == 0)
  stop("No overlapping sample IDs between HapMap and phenotype table.")

# ---- 6. Collapse replicates & encode genotypes ----
geno_mat <- sapply(unique_samples, function(smpl) {
  cols <- which(sample_names_clean == smpl)
  mat <- apply(hap_sub[, sample_cols[cols], drop = FALSE], 2, function(x) {
    x <- toupper(as.character(x))
    x[x %in% c("N", "NA", "-", ".", "")] <- NA

    uniq <- unique(na.omit(x))
    if (length(uniq) > 2) {
      tbl <- sort(table(x), decreasing = TRUE)
      uniq <- names(tbl)[1:2]
      x[!x %in% uniq] <- NA
    }

    # numeric code conversion
    code <- rep(NA_real_, length(x))
    if (length(uniq) >= 1) code[x == uniq[1]] <- 0
    if (length(uniq) >= 2) code[x == uniq[2]] <- 2

    # heterozygous / mixtures
    if (length(uniq) == 2) {
      het_pattern <- paste0(uniq[1], "/", uniq[2])
      code[grepl("/", x) | (grepl(uniq[1], x) & grepl(uniq[2], x))] <- 1
      code[x == het_pattern] <- 1
    }
    code
  })
  if (is.null(dim(mat))) mat <- matrix(mat, ncol = 1)
  rowMeans(mat, na.rm = TRUE)
})

# ---- 7. Keep only phenotype samples (matched order) ----
geno_mat <- geno_mat[, colnames(geno_mat) %in% common_ids, drop = FALSE]
# reorder phenotype vector to match genotype columns exactly
pheno_vec <- pheno[match(colnames(geno_mat), pheno$ID), "blu.flower"]

cat("Genotype matrix has", ncol(geno_mat), "samples\n")
cat("Phenotype vector length:", length(pheno_vec), "\n")
stopifnot(ncol(geno_mat) == length(pheno_vec))

cat("Computing R² for", length(pheno_vec), "samples ...\n")

# ---- 8. Compute R² only for sites with >= 7 calls ----
r2vals <- apply(geno_mat, 1, function(g) {
  valid <- !is.na(g)
  n_valid <- sum(valid)
  if (n_valid < min_samples) return(NA)           # skip low coverage SNPs
  if (sd(g[valid]) == 0) return(NA)               # no variation
  cor(g[valid], pheno_vec[valid])^2               # R²
})

# record number of calls per SNP
ncalls <- apply(geno_mat, 1, function(g) sum(!is.na(g)))

hap_sub$N  <- ncalls
hap_sub$R2 <- r2vals

# ---- 9. Save output ----
top_snps <- hap_sub[order(-hap_sub$R2), c("chr", "pos", "N", "R2")]
outfile <- paste0("R2_", target_chr, "_", start_pos, "_", end_pos, ".tsv")

write.table(top_snps, file = outfile, sep = "\t",
            row.names = FALSE, quote = FALSE)

cat("Done!  Results saved to", outfile, "\n")
cat("Only markers with >=", min_samples, "genotyped samples were included.\n")
#########


"


# get top SNP

awk 'NR>1 {print $1, $2}' R2_INDEL_only_Chr.04_2e+07_3e+07.tsv | head -10 > candidate_indels.txt
####################################################################################
#change Pheno and run snp extracted

#!/bin/bash
HAPMAP="SHB_Smiss0.8_miss0.8_maf0.1.hapmap"
PHENO="FruitWTphenos.txt"
OUTDIR="Indel_summaries"
mkdir -p "$OUTDIR"

while read chr pos; do
  outbase="${OUTDIR}/${chr}_${pos}"

  echo "Processing ${chr}:${pos}"

  # 1. Extract genotype info for this SNP
  (head -n 1 "$HAPMAP" && grep -w "$chr" "$HAPMAP" | grep -w "$pos") \
    | awk '
      {
        for (i=1; i<=NF; i++) {
          if (NR == 1) {
            header[i] = $i;
          } else {
            row[i] = (row[i] ? row[i] FS : "") $i;
          }
        }
      }
      END {
        for (i=1; i<=NF; i++) {
          print header[i], row[i];
        }
      }' \
    | tr ' ' '\t' \
    | grep -v "-" > "${outbase}_alleles.txt"

  # 2. Extract genotype–phenotype table and SAVE it
  ./extract_snp_phenos.txt "$HAPMAP" "$PHENO" "$chr" "$pos" \
      > "${outbase}_geno_pheno.txt"

done < candidate_indels.txt

#Now you can individually examine each SNP in the region that is contributing to high R2
