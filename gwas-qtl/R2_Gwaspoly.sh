library(GWASpoly)
library(dplyr)

load("data_loco.tet.RData")
load("data_og.tet.RData")

###################################
# traits
###################################

############################################
############ Run GWAS Scans ################
############################################

cat("Running GWASpoly scans...\n")

N <- 665

params <- set.params(
  geno.freq = 1 - 5/N,
  fixed = NULL
)

traits <- c(
"DTFlower_yr.23","DTFlower_yr.24","DTFlower_yr.25","DTFlower_BLUE",
"DTFruit_yr.23","DTFruit_yr.24","DTFruit_yr.25","DTFruit_BLUE",
"Flow2Fruit_yr.23","Flow2Fruit_yr.24","Flow2Fruit_yr.25","Flow2Fruit_BLUES",
"FruitWeight_yr.23","FruitWeight_yr.24","FruitWeight_yr.25","FruitWeight_BLUE"
)

models <- c("additive","1-dom","2-dom")

data.loco.scan <- GWASpoly(
  data = data.loco,
  models = models,
  traits = traits,
  params = params,
  n.core = 16
)

data.og.scan <- GWASpoly(
  data = data.og,
  models = models,
  traits = traits,
  params = params,
  n.core = 16
)
###################################
# Recreate thresholds
###################################

DT.bonf.og <- set.threshold(data.og.scan, method="Bonferroni", level=0.05)
DT.bonf.loco <- set.threshold(data.loco.scan, method="Bonferroni", level=0.05)

###################################
# Extract QTL
###################################

window <- 5e6

qtl_bonf_loco <- get.QTL(
data = DT.bonf.loco,
traits = traits,
models = models,
bp.window = window
)

###################################
# Fit QTL models (FIXED)
###################################

R2_results <- list()

for(trait in traits){

qtl_trait <- qtl_bonf_loco[qtl_bonf_loco$Trait == trait,]

if(nrow(qtl_trait) > 0){

fit <- fit.QTL(
data = DT.bonf.og,   # IMPORTANT: OG model, not LOCO
trait = trait,
qtl = qtl_trait[,c("Marker","Model")],
fixed = data.frame(Effect="env",Type="factor")
)

fit$Trait <- trait
R2_results[[trait]] <- fit
}
}

R2_results <- bind_rows(R2_results)

###################################
# Save output
###################################

write.csv(R2_results,"QTL_R2_all_traits.csv",row.names=FALSE)

cat("R2 extraction complete\n")
