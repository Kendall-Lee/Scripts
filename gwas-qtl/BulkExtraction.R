setwd("/Users/kendalllee/Documents/Blueberry/Flow2Fruit")

library(tidyverse)

#----------------------------------------------------------
# 1. Read phenotype data
#----------------------------------------------------------
Data <- read.table(
  "Flow2Fruit_phenos.txt",
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
# 2. Read BLUEs
#----------------------------------------------------------
blues_df <- read.csv("Fruit2Flower_BLUEs.csv")
names(blues_df)
# Normalize ID + BLUE column names
if ("Name" %in% names(blues_df)) {
  blues_df <- blues_df %>% rename(DNA_ID = Name)
}
if (!"Data_BLUE" %in% names(blues_df)) {
  blues_df <- blues_df %>% rename(Data_BLUE = emmean)
}

#----------------------------------------------------------
# 3. Sequenced samples
#----------------------------------------------------------
sequenced_ids <- c(
  "B014","B043","B064","B078","B100","B110","B111","B113","B133",
  "B139","B155","B099","B171","B179","B184","B185","B187","B190",
  "B191","B192","B194","B196","B218","B220","B226","B230","B232",
  "B234","B236","B248","B2","B7","B261","B263","B264","B267",
  "B274","B276","B280","B281","B285","B293","B300","B302","B310",
  "B321","B3","B381","B382","B421","B424","B437","B445","B452",
  "B458","B553","B577","B578","B583","B597","B601","B615","B616",
  "B626","B646","B652","B653","B659","B663","B689","B694","B704",
  "B707","B708","B727","B741","B742","B744","B755","B757","B759",
  "B766","B798","B799","B800","B816","B820","B8","B828","B829",
  "B830","B837","B846","B849","B850"
)

#----------------------------------------------------------
# 4. Long format phenotypes
#----------------------------------------------------------
data_long <- Data %>%
  pivot_longer(
    cols = starts_with("yr."),
    names_to  = "Year",
    values_to = "Data"
  ) %>%
  filter(!is.na(Data)) %>%
  mutate(Sequenced = DNA_ID %in% sequenced_ids)

#----------------------------------------------------------
# 5. Top/Bottom 10 PER YEAR (sequenced only)
#----------------------------------------------------------
year_extremes <- data_long %>%
  filter(Sequenced) %>%
  group_by(Year) %>%
  arrange(Data) %>%
  mutate(rank_low  = row_number(),
         rank_high = row_number(desc(Data))) %>%
  filter(rank_low <= 10 | rank_high <= 10) %>%
  mutate(
    Source = "PerYear",
    Bulk_type = if_else(rank_low <= 10, "Low", "High"),
    phenotype_value = Data
  ) %>%
  select(DNA_ID, Year, phenotype_value, Bulk_type, Source)

#----------------------------------------------------------
# 6. Top/Bottom 10 from BLUEs (sequenced only)
#----------------------------------------------------------
blue_extremes <- blues_df %>%
  filter(DNA_ID %in% sequenced_ids) %>%
  arrange(Data_BLUE) %>%
  mutate(
    rank_low  = row_number(),
    rank_high = row_number(desc(Data_BLUE))
  ) %>%
  filter(rank_low <= 10 | rank_high <= 10) %>%
  mutate(
    Source = "BLUE",
    Year = NA,
    Bulk_type = if_else(rank_low <= 10, "Low", "High"),
    phenotype_value = Data_BLUE
  ) %>%
  select(DNA_ID, Year, phenotype_value, Bulk_type, Source)

#----------------------------------------------------------
# 7. Combine & export
#----------------------------------------------------------
final_extremes <- bind_rows(year_extremes, blue_extremes) %>%
  arrange(Source, Year, Bulk_type, phenotype_value)

write.csv(
  final_extremes,
  "Flow2Fruit_TopBottom10_Sequenced_PerYear_and_BLUE.csv",
  row.names = FALSE
)

cat("✅ File written: DaystoFruitingTopBottom10_Sequenced_PerYear_and_BLUE.csv\n")
