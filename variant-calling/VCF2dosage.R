# analysis.R
#remotes::install_github("jendelman/GWASpoly")
# Set working directory (adjust to your cluster paths!)


# Load required libraries
library(GWASpoly)
library(ggplot2)
library(tidyr)
library(dplyr)

VCF2dosage(
  VCF.file = "LRLP_suzihap1_SVs_biallelic_DS.vcf.gz",
  dosage.file = "LRLP_suzihap1_SVs.mindep2.minminor.5.maxmiss0.8.dosage.file",
  geno.code = "DS",
  ploidy = 4,
  min.DP = 2,
  max.missing = 0.8,
  min.minor = 5
)

genofile <- "/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Enrichment_Data/SuziHap1_map/VCF/SHB_enriched.Suzi.filtered.RELAXED.dosage.file"
phenofile <- "/cluster/projects/khufu/qtl_seq_II/raw_data/100_KLee/Enrichment_Data/SuziHap1_map/Pheno_BLUEs_new.csv"

data <- read.GWASpoly(ploidy=4, pheno.file=phenofile, geno.file=genofile,
                      format="numeric", n.traits=4, delim=",")

#Build Kinship Matrix
#LOCO=TRUE → Leave-One-Chromosome-Out kinship
#Builds one kinship matrix per chromosome.
#When scanning markers on chromosome i:
#K is built using all the other chromosomes except i.
#This prevents “proximal contamination” → i.e., the association signal of
#a true QTL on chromosome i doesn’t get partially canceled by it contributing to relatedness in K.
#LOCO usually results in stronger, more accurate associations for big QTL.

data.loco <- set.K(data,LOCO=TRUE,n.core=2)

#LOCO=FALSE → Original kinship
#Builds one single kinship matrix using all SNPs genome‑wide.
#Every marker contributes to the background relatedness calculation.
#This is the “standard” K in MLM pipelines.
#Downside: if a marker is truly associated with a trait, part of its signal
#is absorbed into the kinship, making associations weaker (over‑correction).

data.original <- set.K(data,LOCO=FALSE,n.core=2)

#Number of samples
N <- 192

#set parameters
params <- set.params(
  geno.freq = 1 - 5/N,           # keep markers with ≥5 minor alleles
  fixed     = NULL               # no extra covariates
)

data.loco.scan <- GWASpoly(data=data.loco,models=c("additive","1-dom", "2-dom"),
                           traits=c("days.to.50.Fruiting_BLUE", "days.to.50.flowering_BLUE", "25FruitWt_BLUE", "days.to.50.FruitPeriod_BLUE"),params=params,n.core=2)


data.original.scan <- GWASpoly(data.original,models=c("additive","1-dom", "2-dom"),
                               traits=c("days.to.50.Fruiting_BLUE", "days.to.50.flowering_BLUE", "25FruitWt_BLUE", "days.to.50.FruitPeriod_BLUE"),params=params,n.core=2)

##qqplots
#We do QQ‑plots in GWAS to:
#1.Diagnose systematic inflation/deflation in p‑values (check model adequacy).
#2.Confirm population structure is handled (kinship, PCs).
#3.Spot true associations (SNPs that deviate upward only at the extreme tail).

pdf(file = "qqplots.pdf", width = 10)
qq.plot(data.original.scan,trait="days.to.50.Fruiting_BLUE") + ggtitle(label="Original")
qq.plot(data.loco.scan,trait="days.to.50.Fruiting_BLUE") + ggtitle(label="LOCO")

qq.plot(data.original.scan,trait="days.to.50.flowering_BLUE") + ggtitle(label="Original")
qq.plot(data.loco.scan,trait="days.to.50.flowering_BLUE") + ggtitle(label="LOCO")

qq.plot(data.original.scan,trait="days.to.50.FruitPeriod_BLUE") + ggtitle(label="Original")
qq.plot(data.loco.scan,trait="days.to.50.FruitPeriod_BLUE") + ggtitle(label="LOCO")

qq.plot(data.original.scan,trait="25FruitWt_BLUE") + ggtitle(label="Original")
qq.plot(data.loco.scan,trait="25FruitWt_BLUE") + ggtitle(label="LOCO")
dev.off()
#how you set your genome‑wide significance threshold
#Bonferroni: α / number of SNPs → very strict, reduces false positives but increases false negatives.
#M.eff: α / effective # of independent SNPs (after accounting for LD) → less strict, balances power vs error.
data <- set.threshold(data.loco.scan,method="Bonferroni",level=0.05)
data2 <- set.threshold(data.loco.scan,method="M.eff",level=0.05)
data1 <- set.threshold(data.original.scan,method="Bonferroni",level=0.05)
data3 <- set.threshold(data.original.scan,method="M.eff",level=0.05)


pdf(file = "DTFlowermanhattan_plots.pdf")

p1 <- manhattan.plot(data, traits = "days.to.50.flowering_BLUE") +
  ggtitle("Dataset: data") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p1)

p2 <- manhattan.plot(data2, traits = "days.to.50.flowering_BLUE") +
  ggtitle("Dataset: data2") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p2)

p3 <- manhattan.plot(data1, traits = "days.to.50.flowering_BLUE") +
  ggtitle("Dataset: data1") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p3)

p4 <- manhattan.plot(data3, traits = "days.to.50.flowering_BLUE") +
  ggtitle("Dataset: data3") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p4)

dev.off()

pdf(file = "DTFruitmanhattan_plots.pdf")

p1 <- manhattan.plot(data, traits = "days.to.50.Fruiting_BLUE") +
  ggtitle("Dataset: data") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p1)

p2 <- manhattan.plot(data2, traits = "days.to.50.Fruiting_BLUE") +
  ggtitle("Dataset: data2") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p2)

p3 <- manhattan.plot(data1, traits = "days.to.50.Fruiting_BLUE") +
  ggtitle("Dataset: data1") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p3)

p4 <- manhattan.plot(data3, traits = "days.to.50.Fruiting_BLUE") +
  ggtitle("Dataset: data3") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p4)

dev.off()


### 1️⃣ For 25FruitWt_BLUE
pdf(file = "DTFruitWt_manhattan_plots.pdf")

p1 <- manhattan.plot(data, traits = "25FruitWt_BLUE") +
  ggtitle("Dataset: data — 25 Fruit Weight") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p1)

p2 <- manhattan.plot(data2, traits = "25FruitWt_BLUE") +
  ggtitle("Dataset: data2 — 25 Fruit Weight") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p2)

p3 <- manhattan.plot(data1, traits = "25FruitWt_BLUE") +
  ggtitle("Dataset: data1 — 25 Fruit Weight") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p3)

p4 <- manhattan.plot(data3, traits = "25FruitWt_BLUE") +
  ggtitle("Dataset: data3 — 25 Fruit Weight") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p4)

dev.off()


### 2️⃣ For days.to.50.FruitPeriod_BLUE
pdf(file = "DTFruitPeriod_manhattan_plots.pdf")

p1 <- manhattan.plot(data, traits = "days.to.50.FruitPeriod_BLUE") +
  ggtitle("Dataset: data — Days to 50% Fruit Period") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p1)

p2 <- manhattan.plot(data2, traits = "days.to.50.FruitPeriod_BLUE") +
  ggtitle("Dataset: data2 — Days to 50% Fruit Period") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p2)

p3 <- manhattan.plot(data1, traits = "days.to.50.FruitPeriod_BLUE") +
  ggtitle("Dataset: data1 — Days to 50% Fruit Period") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p3)

p4 <- manhattan.plot(data3, traits = "days.to.50.FruitPeriod_BLUE") +
  ggtitle("Dataset: data3 — Days to 50% Fruit Period") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
print(p4)


qtl <- get.QTL(data=data,traits="days.to.50.Fruiting_BLUE",models="2-dom",bp.window=5e6)
knitr::kable(qtl)
qtl1 <- get.QTL(data=data,traits="days.to.50.Fruiting_BLUE",models="additive",bp.window=5e6)
knitr::kable(qtl1)
qtl2 <- get.QTL(data=data,traits="days.to.50.FruitPeriod_BLUE",models="2-dom",bp.window=5e6)
knitr::kable(qtl2)
qtl3 <- get.QTL(data=data,traits="25FruitWt_BLUE",models="2-dom",bp.window=5e6)
knitr::kable(qtl3)

dev.off()
