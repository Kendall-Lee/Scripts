bcftools query \
  -f '%CHROM\t%POS[\t%GT]\n' \
  SHB.vcf.gz > SHB.gt.tsv
  bcftools query -l SHB.vcf.gz > samples.txt
  echo -e "CHROM\tPOS\t$(paste -sd '\t' samples.txt)" > SHB.gt.header
  cat SHB.gt.header SHB.gt.tsv > SHB.gt.with_header.tsv
  library(tidyverse)

  gt <- read_tsv("SHB.gt.with_header.tsv", show_col_types = FALSE)

  sample_cols <- colnames(gt)[-(1:2)]

  # Convert GT → presence/absence
  gt_bin <- gt %>%
    mutate(across(
      all_of(sample_cols),
      ~ ifelse(grepl("1", .), 1, 0)
    ))
    # Number of samples
    n_samples <- length(sample_cols)

    # Compute presence count per site (vectorized)
    present_matrix <- as.matrix(gt_bin[, sample_cols])

    n_present <- rowSums(present_matrix)
    gt_bin$n_present <- n_present

    core_disp_chr <- gt_bin %>%
      group_by(CHROM) %>%
      summarise(
        core_sites = sum(n_present == n_samples),
        dispensable_sites = sum(n_present < n_samples),
        frac_core = core_sites / (core_sites + dispensable_sites),
        .groups = "drop"
      )
      summary(gt_bin$n_present)
      outdir <- "pangenome_core_plots"
      dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
      window_size <- 100000

      gt_bin <- gt_bin %>%
        mutate(window = floor(POS / window_size) * window_size)
        window_core <- gt_bin %>%
          group_by(CHROM, window) %>%
          summarise(
            frac_core = mean(n_present == max(n_present)),
            .groups = "drop"
          )
          p3 <- ggplot(window_core, aes(x = window / 1e6, y = frac_core)) +
            geom_line(color = "purple") +
            facet_wrap(~ CHROM, scales = "free_x", ncol = 1) +
            labs(
              title = "Core Genome Density Across Chromosomes",
              x = "Position (Mb)",
              y = "Fraction Core (100 kb windows)"
            ) +
            theme_bw()

          ggsave(
            filename = file.path(outdir, "sliding_window_core_density.pdf"),
            plot = p3,
            width = 8,
            height = 12
          )

          ggsave(
            filename = file.path(outdir, "sliding_window_core_density.png"),
            plot = p3,
            width = 8,
            height = 12,
            dpi = 300
          )
          gt_bin$n_present   # number of samples with the site
          length(sample_cols)
          window_size <- 100000   # 100 kb
          step_size   <- 100000
          library(dplyr)

          disp_windows <- gt_bin %>%
            mutate(
              window = floor(POS / window_size) * window_size
            ) %>%
            group_by(CHROM, window) %>%
            summarise(
              dispensable_sites = sum(dispensable),
              total_sites = n(),
              disp_frac = dispensable_sites / total_sites,
              .groups = "drop"
            )
            write_tsv(disp_windows, "SHB.dispensable.sliding_100kb.tsv")
            library(ggplot2)

            p <- ggplot(disp_windows,
                        aes(x = window / 1e6, y = disp_frac)) +
              geom_line(color = "firebrick", linewidth = 0.3) +
              facet_wrap(~ CHROM, scales = "free_x") +
              labs(
                x = "Genomic position (Mb)",
                y = "Dispensable fraction",
                title = "Hypervariable regions across the blueberry pangenome"
              ) +
              theme_bw() +
              theme(
                strip.text = element_text(size = 8),
                axis.text.x = element_text(size = 6)
              )

            ggsave(
              "SHB.dispensable.sliding_100kb.png",
              p,
              width = 14,
              height = 8,
              dpi = 300
            )
            hypervar <- disp_windows %>%
              filter(disp_frac >= 0.5) %>%   # ≥50% dispensable
              mutate(
                start = window,
                end = window + window_size
              ) %>%
              select(CHROM, start, end, disp_frac)
              write_tsv(
                hypervar,
                "SHB.hypervariable_windows.bed",
                col_names = FALSE
              )



#!/bin/bash
#SBATCH --job-name=batch_coverage_detection
#SBATCH -e coverage_%J.err
#SBATCH -o coverage_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=256G
#SBATCH --partition=normal

module load bcftools/1.19-gcc-13.1.0

bcftools query \
-f '%CHROM\t%POS[\t%GT]\n' \
SHB.raw.vcf.gz \
> SHB.gt.tsv
