#!/bin/bash
#find significant allels
 cat genos_07_fruitWt23_phenotypes_farmcpupp_DF.txt | awk 'NR == 1 {print $0; next} {if (($4 > 0) && ($4 < 1e-05)) print $0}' | sort -gk4,4 | column -t
# currently set up just for panmap input
# need to add: hapmap input, missing data filter (if not imputed)

ml r/4.4.1-gcc-13.1.0

panmap="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/PANGENOME/LRLP_work/SHB_LR_kmer0_Smiss0.8_miss0.8_maf0.01.panmap"
phenotypes="Flow2Fruit_phenos.BLUES.txt" # a two-column tab-delimited file with sample name and phenotype
chr_pos_list="Flow2Fruit_BLUE_top_SNP.one.col.txt" # a one-column file listing chromosome and position coordinates for each marker of interest (e.g. TRv2.Chr01_9265925)

# iterate through chr_pos for each marker of interest
for chr_pos in $(cat $chr_pos_list)
do
	# get chr and pos as separate variables
	chr=$(echo $chr_pos | cut -d_ -f1)
	pos=$(echo $chr_pos | cut -d_ -f2)

	# get alleles from panmap.fa file
	allele_start=$(cat "$panmap".fa | grep -n "$chr_pos" | head -1 | cut -d: -f1)
	allele1_line=$(( allele_start + 1 ))
	allele2_line=$(( allele_start + 3 ))
	allele1=$(cat "$panmap".fa | sed -n "$allele1_line"p)
	allele2=$(cat "$panmap".fa | sed -n "$allele2_line"p)

	# make geno_pheno.txt file
	paste <(cat $panmap | awk -v c="$chr" -v p="$pos" '{if (($1 == c) && ($2 == p)) print $0}' | cut -f5- | awk -v a1="$allele1" -v a2="$allele2" '{gsub("1",a1); gsub("2",a2); gsub ("1,2",a1"/"a2)}1' | tr "," "/" | tr "\t" "\n") <(for sample in $(cat $panmap | head -1 | cut -f5- | tr "\t" "\n"); do cat $phenotypes | grep $sample | cut -f2; done) | sed "1igenotype\tphenotype" > "$chr_pos"_geno_pheno.txt
done

#put all files in one folder then you can make a pdf of allele effect
#####################
library(ggplot2)
library(data.table)

geno_dir <- "./"
out_pdf  <- "Allele_Effects.pdf"

files <- list.files(geno_dir, pattern = "_geno_pheno\\.txt$", full.names = TRUE)
res   <- data.frame(marker = character(), R2 = numeric(), PVE = numeric())

pdf(out_pdf, width = 6, height = 4)

for (f in files) {
  dat <- fread(f)
  mname <- tools::file_path_sans_ext(basename(f))

  dat$Genotype  <- factor(dat$genotype)
  dat$Phenotype <- as.numeric(dat$phenotype)

  fit <- lm(Phenotype ~ Genotype, data = dat)
  r2  <- summary(fit)$r.squared
  pve <- r2 * 100
  res <- rbind(res, data.frame(marker = mname, R2 = r2, PVE = pve))

  ## FIXED: make sure the summary table has a column named Genotype
  ns <- aggregate(Phenotype ~ Genotype, dat, length)
  colnames(ns)[2] <- "n"
  ns$label_y <- max(dat$Phenotype, na.rm = TRUE) * 1.05
  ns$label   <- paste0("n=", ns$n)

  p <- ggplot(dat, aes(x = Genotype, y = Phenotype, fill = Genotype)) +
        geom_boxplot(color = "black") +
        geom_text(
          data = ns,
          aes(x = Genotype, y = label_y, label = label),  # explicit x aesthetic
          inherit.aes = FALSE,
          size = 3
        ) +
        labs(title = mname,
             subtitle = sprintf("R² = %.3f  |  PVE = %.2f%%", r2, pve),
             x = "Genotype", y = "Phenotype") +
        theme_minimal() +
        theme(legend.position = "none")

  print(p)
}
dev.off()

write.table(
  res,
  "Marker_R2_PVE_summary.txt",
  sep = "\t", quote = FALSE, row.names = FALSE
)
