############################################################
# Flower_BLUE_cluster.R
#  - Reads tab‑delimited phenotype file
#  - Reshapes to long format
#  - Fits mixed model (BLUEs)
#  - Collects high & low samples per year AND from BLUEs
#  - Exports one combined summary file
############################################################

library(dplyr)
library(tidyr)
library(lme4)
library(emmeans)

#----------------------------------------------------------
# Step 1. Read tab-separated data
#----------------------------------------------------------
Data <- read.table(
  "FruitWt_pheno.txt",
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE
)

# Handle possible variants in the first column name
if ("DNA.ID" %in% names(Data)) {
  Data <- Data %>% rename(DNA_ID = DNA.ID)
} else if ("DNA ID" %in% names(Data)) {
  Data <- Data %>% rename(DNA_ID = `DNA ID`)
}


#----------------------------------------------------------
# Step 2. Wide → long
#----------------------------------------------------------
data_long <- Data %>%
  pivot_longer(
    cols = starts_with("yr."),
    names_to  = "Year",
    values_to = "Data"
  ) %>%
  mutate(
    DNA_ID = factor(DNA_ID),
    Year   = factor(Year)
  )

#----------------------------------------------------------
# Step 3. Mixed model for BLUEs
#----------------------------------------------------------
model <- lmer(
  Data ~ DNA_ID + (1|Year),
  data = data_long,
  na.action = na.omit
)

BLUEs_df <- as.data.frame(emmeans(model, ~ DNA_ID)) %>%
  rename(Data_BLUE = emmean)

write.csv(BLUEs_df, "Fruit2Flower_BLUEs.csv", row.names = FALSE)
cat("Model fitted and BLUEs written to Fruit2Flower_BLUEs.csv\n")
