#!/bin/bash
#SBATCH -J pankmer_anchormap
#SBATCH --time=96:00:00
#SBATCH -c 16
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_pankmer_anchormap_%A_%a"
#SBATCH -e "stds/stderr_pankmer_anchormap_%A_%a"
#SBATCH --mem="200G"
#SBATCH --mail-user=klee@hudsonalpha.org
#SBATCH --mail-type=END,FAIL
#SBATCH --array=1-12  # For chromosomes Chr01-Chr12

################################################################################
# Pankmer Anchor Map Generation - Per Chromosome
#
# This script creates anchor maps for each chromosome of Southern Highbush
# Blueberry (SHB) using Suziblue haplotype as the reference anchor.
#
# Requires:
# - Pankmer index: SHB_Haps_Pankmer_primary_index.tar
# - Anchor genome: Suziblue_hap1.fa (bgzipped)
# - Annotations: Suziblue_hap1.gff3 (optional, for plotting)
################################################################################



echo "========================================================================"
echo "Pankmer Anchor Map - Per Chromosome Analysis"
echo "Started: $(date)"
echo "========================================================================"
echo ""

################################################################################
# Activate Pankmer Environment
################################################################################

eval "$(conda shell.bash hook)"
source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/anaconda3/envs/pankmer

################################################################################
# Configuration
################################################################################

# Working directory
WORKDIR="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Pankmer"
cd "$WORKDIR" || exit 1

# Pankmer index (all SHB haplotypes)
INDEX="${WORKDIR}/SHB_Haps_Pankmer_primary_index.tar"

# Anchor genome (reference for mapping)
ANCHOR_GENOME="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Final_assemblies/Suziblue_hap1.fa"
ANCHOR_GZ="${ANCHOR_GENOME}.gz"

# Annotation file (for plotting with genes/features)
ANNOTATION="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Final_assemblies/Liftoff/Suziblue_hap1.gffread.gff3"

# Output directory
OUTDIR="${WORKDIR}/Anchormap_PerChromosome"
mkdir -p "$OUTDIR"

# Get chromosome from SLURM array task ID
CHR_NUM=$(printf "%02d" $SLURM_ARRAY_TASK_ID)
CHR_NAME="Chr${CHR_NUM}"

echo "Configuration:"
echo "  Working directory: $WORKDIR"
echo "  Pankmer index: $INDEX"
echo "  Anchor genome: $ANCHOR_GENOME"
echo "  Annotation: $ANNOTATION"
echo "  Output directory: $OUTDIR"
echo "  Chromosome: $CHR_NAME"
echo ""

################################################################################
# Verify Input Files
################################################################################

echo "=== Verifying Input Files ==="
echo ""

if [ ! -f "$INDEX" ]; then
    echo "ERROR: Pankmer index not found: $INDEX"
    echo ""
    echo "Create it with:"
    echo "  pankmer index -g /path/to/genomes/*.fa -o $INDEX -t 16"
    exit 1
fi
echo "✓ Pankmer index: $INDEX"

if [ ! -f "$ANCHOR_GENOME" ]; then
    echo "ERROR: Anchor genome not found: $ANCHOR_GENOME"
    exit 1
fi
echo "✓ Anchor genome: $ANCHOR_GENOME"

# Check if anchor genome is bgzipped
if [ ! -f "$ANCHOR_GZ" ]; then
    echo ""
    echo "Anchor genome needs to be bgzipped for Pankmer..."
    echo "Loading samtools..."
    module load samtools/1.19.2-gcc-13.1.0
    module load htslib/1.19.1-gcc-13.1.0

    echo "Creating bgzipped version: $ANCHOR_GZ"
    bgzip -c "$ANCHOR_GENOME" > "$ANCHOR_GZ"
    echo "✓ Created: $ANCHOR_GZ"
else
    echo "✓ Bgzipped anchor: $ANCHOR_GZ"
fi

if [ -f "$ANNOTATION" ]; then
    echo "✓ Annotation file: $ANNOTATION"
    HAS_ANNOTATION=true
else
    echo "⚠️  Annotation file not found (plots will be without gene features)"
    HAS_ANNOTATION=false
fi

echo ""

################################################################################
# Index anchor genome if needed
################################################################################

echo "=== Indexing Anchor Genome ==="
echo ""

if [ ! -f "${ANCHOR_GENOME}.fai" ]; then
    echo "Indexing anchor genome..."
    samtools faidx "$ANCHOR_GENOME"
    echo "✓ Created index: ${ANCHOR_GENOME}.fai"
else
    echo "✓ Index already exists: ${ANCHOR_GENOME}.fai"
fi

# Check if chromosome exists in anchor genome
if ! grep -q "^${CHR_NAME}" "${ANCHOR_GENOME}.fai"; then
    echo "ERROR: Chromosome $CHR_NAME not found in anchor genome"
    echo ""
    echo "Available chromosomes:"
    cut -f1 "${ANCHOR_GENOME}.fai" | head -20
    exit 1
fi

echo "✓ Chromosome $CHR_NAME found in anchor genome"
echo ""

################################################################################
# Run Pankmer anchor-region for this chromosome
################################################################################

echo "=== Running Pankmer anchor-region for $CHR_NAME ==="
echo ""

BDG_OUTPUT="${OUTDIR}/${CHR_NAME}_anchor.bdg"

echo "Output bedGraph: $BDG_OUTPUT"
echo ""

# Run pankmer anchor-region
# This generates a bedGraph file showing kmer conservation across the pangenome
# for each position in the anchor chromosome

pankmer anchor-region \
  -i "$INDEX" \
  -a "$ANCHOR_GZ" \
  -c "$CHR_NAME" \
  -t 16 \
  > "$BDG_OUTPUT"

if [ -f "$BDG_OUTPUT" ]; then
    echo "✓ Created bedGraph: $BDG_OUTPUT"

    # Show statistics
    nlines=$(wc -l < "$BDG_OUTPUT")
    echo "  Lines: $nlines"

    # Show first few lines
    echo ""
    echo "First 10 lines of bedGraph:"
    head -10 "$BDG_OUTPUT"
    echo ""

    # Calculate statistics
    echo "Anchor region statistics:"
    awk '{
        sum+=$4; n++
        if($4>max) max=$4
        if(min==0 || $4<min) min=$4
    }
    END {
        printf "  Mean conservation: %.2f\n", sum/n
        printf "  Min: %.2f\n", min
        printf "  Max: %.2f\n", max
    }' "$BDG_OUTPUT"
    echo ""
else
    echo "✗ ERROR: Failed to create bedGraph"
    exit 1
fi

################################################################################
# Plot anchor region with annotation
################################################################################

echo "=== Plotting Anchor Region ==="
echo ""

SVG_OUTPUT="${OUTDIR}/${CHR_NAME}_anchor_plot.svg"

if [ "$HAS_ANNOTATION" = true ]; then
    echo "Creating plot with gene annotations..."

    pankmer plot-region \
      -a "$ANCHOR_GZ" \
      -g "$ANNOTATION" \
      -b "$BDG_OUTPUT" \
      -o "$SVG_OUTPUT"

else
    echo "Creating plot without annotations..."

    pankmer plot-region \
      -a "$ANCHOR_GZ" \
      -b "$BDG_OUTPUT" \
      -o "$SVG_OUTPUT"
fi

if [ -f "$SVG_OUTPUT" ]; then
    echo "✓ Created plot: $SVG_OUTPUT"
    size=$(ls -lh "$SVG_OUTPUT" | awk '{print $5}')
    echo "  Size: $size"
    echo ""
else
    echo "⚠️  Failed to create plot (bedGraph still available)"
fi

################################################################################
# Create summary statistics per chromosome
################################################################################

echo "=== Creating Summary Statistics ==="
echo ""

SUMMARY="${OUTDIR}/${CHR_NAME}_summary.txt"

cat > "$SUMMARY" << EOF
Pankmer Anchor Map Summary - $CHR_NAME
======================================
Generated: $(date)
Chromosome: $CHR_NAME

Input Files:
  Pankmer index: $INDEX
  Anchor genome: $ANCHOR_GENOME
  Chromosome: $CHR_NAME

Output Files:
  BedGraph: $BDG_OUTPUT
  Plot: $SVG_OUTPUT

Chromosome Information:
EOF

# Get chromosome size
chr_size=$(grep "^${CHR_NAME}" "${ANCHOR_GENOME}.fai" | cut -f2)
echo "  Size: $chr_size bp ($(awk -v s=$chr_size 'BEGIN {printf "%.2f Mb", s/1e6}')" >> "$SUMMARY"

cat >> "$SUMMARY" << EOF

Conservation Statistics:
EOF

awk '{
    sum+=$4; n++
    if($4>max) max=$4
    if(min==0 || $4<min) min=$4

    # Count high/medium/low conservation bins
    if($4 >= 0.8) high++
    else if($4 >= 0.5) medium++
    else low++
}
END {
    printf "  Mean conservation: %.4f\n", sum/n
    printf "  Min: %.4f\n", min
    printf "  Max: %.4f\n", max
    printf "  Median approx: %.4f\n", (min+max)/2
    printf "\nConservation Bins:\n"
    printf "  High (≥0.8): %d windows (%.1f%%)\n", high, high/n*100
    printf "  Medium (0.5-0.8): %d windows (%.1f%%)\n", medium, medium/n*100
    printf "  Low (<0.5): %d windows (%.1f%%)\n", low, low/n*100
}' "$BDG_OUTPUT" >> "$SUMMARY"

cat "$SUMMARY"
echo ""
echo "Summary saved to: $SUMMARY"

################################################################################
# Final Summary
################################################################################

echo ""
echo "========================================================================"
echo "Chromosome $CHR_NAME Complete!"
echo "Completed: $(date)"
echo "========================================================================"
echo ""

echo "Output files:"
echo "  BedGraph: $BDG_OUTPUT"
if [ -f "$SVG_OUTPUT" ]; then
    echo "  Plot: $SVG_OUTPUT"
fi
echo "  Summary: $SUMMARY"
echo ""

echo "Next steps:"
echo "  1. Review plot: $SVG_OUTPUT"
echo "  2. Analyze bedGraph: $BDG_OUTPUT"
echo "  3. Compare conservation across all chromosomes"
echo "  4. Identify highly conserved/variable regions"
echo ""

echo "========================================================================"
