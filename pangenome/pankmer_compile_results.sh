#!/bin/bash

################################################################################
# Compile Pankmer Anchor Map Results Across All Chromosomes
#
# This script compiles results from individual chromosome anchor maps
# and creates summary statistics and visualizations
################################################################################

set -e

echo "========================================================================"
echo "Compiling Pankmer Anchor Map Results"
echo "========================================================================"
echo ""

WORKDIR="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Pankmer"
ANCHORDIR="${WORKDIR}/Anchormap_PerChromosome"

cd "$WORKDIR" || exit 1

################################################################################
# Check if chromosome results exist
################################################################################

echo "=== Checking for Chromosome Results ==="
echo ""

NCHROM=0
for i in {01..12}; do
    CHR="Chr${i}"
    BDG="${ANCHORDIR}/${CHR}_anchor.bdg"

    if [ -f "$BDG" ]; then
        echo "✓ Found: $CHR"
        ((NCHROM++))
    else
        echo "✗ Missing: $CHR"
    fi
done

echo ""
echo "Found $NCHROM out of 12 chromosomes"

if [ $NCHROM -eq 0 ]; then
    echo "ERROR: No chromosome results found"
    echo "Run pankmer_anchormap_per_chromosome.sh first!"
    exit 1
fi

echo ""

################################################################################
# Compile statistics across all chromosomes
################################################################################

echo "=== Compiling Statistics ==="
echo ""

SUMMARY_ALL="${ANCHORDIR}/ALL_CHROMOSOMES_summary.txt"

cat > "$SUMMARY_ALL" << EOF
Pankmer Anchor Map Summary - All Chromosomes
=============================================
Generated: $(date)
Chromosomes analyzed: $NCHROM

Conservation Statistics Per Chromosome:
EOF

echo ""
echo "Chromosome-level statistics:"
echo "Chr       Size(Mb)  Mean      Min       Max       High%   Med%    Low%"
echo "------------------------------------------------------------------------"

for i in {01..12}; do
    CHR="Chr${i}"
    BDG="${ANCHORDIR}/${CHR}_anchor.bdg"

    if [ ! -f "$BDG" ]; then
        continue
    fi

    # Calculate statistics
    stats=$(awk '{
        sum+=$4; n++
        if($4>max) max=$4
        if(min==0 || $4<min) min=$4

        if($4 >= 0.8) high++
        else if($4 >= 0.5) medium++
        else low++
    }
    END {
        printf "%.2f %.4f %.4f %.4f %.1f %.1f %.1f", \
               sum/n, min, max, \
               high/n*100, medium/n*100, low/n*100
    }' "$BDG")

    # Get chromosome size
    ANCHOR_GENOME="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Final_assemblies/Suziblue_hap1.fa"
    if [ -f "${ANCHOR_GENOME}.fai" ]; then
        chr_size=$(grep "^${CHR}" "${ANCHOR_GENOME}.fai" | cut -f2)
        chr_mb=$(awk -v s=$chr_size 'BEGIN {printf "%.2f", s/1e6}')
    else
        chr_mb="N/A"
    fi

    # Print formatted output
    printf "%-8s %8s %9s  %s\n" "$CHR" "$chr_mb" "$stats" | tee -a "$SUMMARY_ALL"
done

echo "------------------------------------------------------------------------"

################################################################################
# Calculate genome-wide statistics
################################################################################

echo ""
echo "=== Genome-Wide Statistics ==="
echo ""

cat >> "$SUMMARY_ALL" << EOF

Genome-Wide Conservation:
EOF

# Concatenate all bedGraphs and calculate overall statistics
cat "${ANCHORDIR}"/Chr*_anchor.bdg | awk '{
    sum+=$4; n++
    if($4>max) max=$4
    if(min==0 || $4<min) min=$4

    if($4 >= 0.8) high++
    else if($4 >= 0.5) medium++
    else low++
}
END {
    printf "  Mean conservation: %.4f\n", sum/n
    printf "  Min: %.4f\n", min
    printf "  Max: %.4f\n", max
    printf "  Total windows: %d\n\n", n
    printf "Conservation Distribution:\n"
    printf "  High (≥0.8): %d windows (%.1f%%)\n", high, high/n*100
    printf "  Medium (0.5-0.8): %d windows (%.1f%%)\n", medium, medium/n*100
    printf "  Low (<0.5): %d windows (%.1f%%)\n", low, low/n*100
}' | tee -a "$SUMMARY_ALL"

echo ""

################################################################################
# Create combined bedGraph
################################################################################

echo "=== Creating Combined BedGraph ==="
echo ""

COMBINED_BDG="${ANCHORDIR}/ALL_CHROMOSOMES_anchor.bdg"

# Concatenate all chromosome bedGraphs
cat "${ANCHORDIR}"/Chr*_anchor.bdg > "$COMBINED_BDG"

echo "✓ Created: $COMBINED_BDG"
nlines=$(wc -l < "$COMBINED_BDG")
echo "  Total lines: $nlines"
echo ""

################################################################################
# Create conservation distribution plot data
################################################################################

echo "=== Creating Conservation Distribution Data ==="
echo ""

DIST_CSV="${ANCHORDIR}/conservation_distribution.csv"

# Create histogram data
cat "${ANCHORDIR}"/Chr*_anchor.bdg | awk '
BEGIN {
    print "chromosome,conservation,count"
}
{
    chr = $1
    cons = $4
    # Bin conservation values
    bin = int(cons * 20) / 20  # Bins of 0.05
    data[chr][bin]++
}
END {
    for (chr in data) {
        for (bin in data[chr]) {
            print chr "," bin "," data[chr][bin]
        }
    }
}' > "$DIST_CSV"

echo "✓ Created: $DIST_CSV"
echo "  Use this for plotting in R or Python"
echo ""

################################################################################
# Create sliding window summary
################################################################################

echo "=== Creating Sliding Window Summary ==="
echo ""

WINDOW_CSV="${ANCHORDIR}/sliding_window_summary.csv"

# Calculate average conservation in 100kb windows
cat "${ANCHORDIR}"/Chr*_anchor.bdg | awk '
BEGIN {
    print "chromosome,start,end,mean_conservation,n_sites"
    window_size = 100000  # 100kb windows
}
{
    chr = $1
    pos = int($2 / window_size)
    win_start = pos * window_size
    win_end = win_start + window_size

    key = chr "_" win_start
    sum[key] += $4
    count[key]++
    chr_map[key] = chr
    start_map[key] = win_start
    end_map[key] = win_end
}
END {
    for (key in sum) {
        mean = sum[key] / count[key]
        print chr_map[key] "," start_map[key] "," end_map[key] "," mean "," count[key]
    }
}' > "$WINDOW_CSV"

echo "✓ Created: $WINDOW_CSV"
echo "  Use this for genome-wide plots"
echo ""

################################################################################
# Identify highly conserved and variable regions
################################################################################

echo "=== Identifying Conserved and Variable Regions ==="
echo ""

CONSERVED="${ANCHORDIR}/highly_conserved_regions.bed"
VARIABLE="${ANCHORDIR}/highly_variable_regions.bed"

# Extract highly conserved regions (conservation ≥ 0.9)
cat "${ANCHORDIR}"/Chr*_anchor.bdg | awk '$4 >= 0.9' > "$CONSERVED"

# Extract highly variable regions (conservation ≤ 0.3)
cat "${ANCHORDIR}"/Chr*_anchor.bdg | awk '$4 <= 0.3' > "$VARIABLE"

nconserved=$(wc -l < "$CONSERVED")
nvariable=$(wc -l < "$VARIABLE")

echo "✓ Highly conserved regions (≥0.9): $nconserved"
echo "  File: $CONSERVED"
echo ""
echo "✓ Highly variable regions (≤0.3): $nvariable"
echo "  File: $VARIABLE"
echo ""

################################################################################
# Create R plotting script
################################################################################

echo "=== Creating R Plotting Script ==="
echo ""

RSCRIPT="${ANCHORDIR}/plot_anchormap_results.R"

cat > "$RSCRIPT" << 'EOF'
#!/usr/bin/env Rscript

# Plot Pankmer Anchor Map Results
library(ggplot2)
library(tidyverse)

setwd("/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Pankmer/Anchormap_PerChromosome")

################################################################################
# 1. Conservation distribution
################################################################################

dist <- read.csv("conservation_distribution.csv")

p1 <- ggplot(dist, aes(x = conservation, y = count, fill = chromosome)) +
  geom_bar(stat = "identity") +
  facet_wrap(~chromosome, ncol = 3) +
  labs(title = "Conservation Distribution per Chromosome",
       x = "Kmer Conservation",
       y = "Count") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("conservation_distribution_per_chr.pdf", p1, width = 12, height = 10)

# Overall distribution
p2 <- ggplot(dist, aes(x = conservation, y = count)) +
  geom_histogram(stat = "identity", bins = 20, fill = "steelblue") +
  labs(title = "Genome-Wide Conservation Distribution",
       x = "Kmer Conservation",
       y = "Count") +
  theme_minimal()

ggsave("conservation_distribution_genome.pdf", p2, width = 10, height = 6)

################################################################################
# 2. Sliding window plot
################################################################################

windows <- read.csv("sliding_window_summary.csv")

# Order chromosomes
windows$chromosome <- factor(windows$chromosome,
                             levels = paste0("Chr", sprintf("%02d", 1:12)))

p3 <- ggplot(windows, aes(x = start/1e6, y = mean_conservation)) +
  geom_line(color = "darkblue") +
  facet_wrap(~chromosome, ncol = 2, scales = "free_x") +
  labs(title = "Conservation Along Chromosomes (100kb windows)",
       x = "Position (Mb)",
       y = "Mean Conservation") +
  theme_minimal() +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red", alpha = 0.5)

ggsave("conservation_sliding_window.pdf", p3, width = 14, height = 16)

################################################################################
# 3. Summary statistics per chromosome
################################################################################

chr_stats <- windows %>%
  group_by(chromosome) %>%
  summarize(
    mean_cons = mean(mean_conservation),
    sd_cons = sd(mean_conservation),
    min_cons = min(mean_conservation),
    max_cons = max(mean_conservation)
  )

p4 <- ggplot(chr_stats, aes(x = chromosome, y = mean_cons)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_errorbar(aes(ymin = mean_cons - sd_cons, ymax = mean_cons + sd_cons),
                width = 0.2) +
  labs(title = "Mean Conservation per Chromosome",
       x = "Chromosome",
       y = "Mean Conservation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("mean_conservation_per_chr.pdf", p4, width = 10, height = 6)

cat("Plots saved:\n")
cat("  conservation_distribution_per_chr.pdf\n")
cat("  conservation_distribution_genome.pdf\n")
cat("  conservation_sliding_window.pdf\n")
cat("  mean_conservation_per_chr.pdf\n")
EOF

echo "✓ Created R script: $RSCRIPT"
echo ""

################################################################################
# Final Summary
################################################################################

echo "========================================================================"
echo "Compilation Complete!"
echo "========================================================================"
echo ""

echo "Output files created:"
echo "  Summary: $SUMMARY_ALL"
echo "  Combined bedGraph: $COMBINED_BDG"
echo "  Conservation distribution: $DIST_CSV"
echo "  Sliding windows: $WINDOW_CSV"
echo "  Conserved regions: $CONSERVED ($nconserved sites)"
echo "  Variable regions: $VARIABLE ($nvariable sites)"
echo "  R plotting script: $RSCRIPT"
echo ""

echo "Next steps:"
echo "  1. Review summary: cat $SUMMARY_ALL"
echo "  2. Run R script: Rscript $RSCRIPT"
echo "  3. Examine conserved regions for potential functional importance"
echo "  4. Examine variable regions for diversity/breeding targets"
echo ""

echo "========================================================================"
