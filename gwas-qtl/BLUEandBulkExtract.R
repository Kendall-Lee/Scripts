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
  "DTfruit_pheno.txt",
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

write.csv(BLUEs_df, "DTFruit_BLUEs.csv", row.names = FALSE)
cat("Model fitted and BLUEs written to DTFruit_BLUEs.csv\n")

#----------------------------------------------------------
# Step 4. Identify extreme samples
#----------------------------------------------------------

# ---- Per year extremes (raw data) ----
bottom15_per_year <- Flower_long %>%
  group_by(Year) %>%
  slice_min(X25FlowerWt, n = 15, with_ties = FALSE) %>%
  mutate(Bulk_type = "Low", Source = "PerYear") %>%
  rename(phenotype_value = X25FlowerWtDays)

top15_per_year <- Flower_long %>%
  group_by(Year) %>%
  slice_max(X25FlowerWt, n = 15, with_ties = FALSE) %>%
  mutate(Bulk_type = "High", Source = "PerYear") %>%
  rename(phenotype_value = X25FlowerWt)

per_year_extremes <- bind_rows(bottom15_per_year, top15_per_year) %>%
  ungroup() %>%
  select(Source, Year, DNA_ID, Bulk_type, phenotype_value)

# ---- BLUE extremes (across years) ----
bottom15_BLUE <- BLUEs_df %>%
  arrange(X25FlowerWt_BLUE) %>%
  slice_head(n = 15) %>%
  mutate(Bulk_type = "Low",
         Source = "BLUE",
         Year = NA,
         phenotype_value = X25FlowerWt_BLUE) %>%
  select(Source, Year, DNA_ID, Bulk_type, phenotype_value)

top15_BLUE <- BLUEs_df %>%
  arrange(desc(X25FlowerWt_BLUE)) %>%
  slice_head(n = 15) %>%
  mutate(Bulk_type = "High",
         Source = "BLUE",
         Year = NA,
         phenotype_value = X25FlowerWt_BLUE) %>%
  select(Source, Year, DNA_ID, Bulk_type, phenotype_value)

BLUE_extremes <- bind_rows(bottom15_BLUE, top15_BLUE)

#----------------------------------------------------------
# Step 5. Combine both sets and save
#----------------------------------------------------------
all_extremes <- bind_rows(per_year_extremes, BLUE_extremes) %>%
  arrange(Source, Year, Bulk_type, phenotype_value)

write.csv(all_extremes, "FlowerWeightBulks.csv", row.names = FALSE)

#----------------------------------------------------------
# Step 6. Also save the complete BLUE table (optional)
#----------------------------------------------------------
phenos_BLUE <- BLUEs_df %>%
  rename(Name = DNA_ID)
write.csv(phenos_BLUE, "25FlowerWtphenos_BLUE.csv", row.names = FALSE)

#----------------------------------------------------------
# Step 7. Console summary
#----------------------------------------------------------
cat("Model fitted and BLUEs extracted.\n")
cat("Files written:\n",
    "- 25FlowerWtphenos_BLUE.csv (all BLUEs)\n",
    "- FlowerWeightBulks.csv  (combined per-year & BLUE extremes)\n")
############################################################
