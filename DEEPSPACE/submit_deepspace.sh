#!/bin/bash
#SBATCH --job-name=deepspace_blueberry
#SBATCH --output=deepspace_%j.out
#SBATCH --error=deepspace_%j.err
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --partition=general

# DEEPSPACE Analysis for Blueberry Genomes
# Suziblue hap1 vs V. caesariense W85

echo "=========================================="
echo "DEEPSPACE Blueberry Genome Comparison"
echo "=========================================="
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $HOSTNAME"
echo "Start time: $(date)"
echo "Working directory: $PWD"
echo ""

# Load required modules
echo "Loading modules..."
module purge
module load cluster/minimap2/2.26

# Verify minimap2 is available
echo "Checking minimap2..."
which minimap2
minimap2 --version

# Check if MCScanX exists
if [ ! -f /cluster/home/klee/MCScanX/MCScanX_h ]; then
    echo "ERROR: MCScanX_h not found at /cluster/home/klee/MCScanX/MCScanX_h"
    echo "Please verify the path or compile MCScanX if needed"
    exit 1
fi
echo "MCScanX found: /cluster/home/klee/MCScanX/MCScanX_h"

# Check if R is available
echo ""
echo "Checking R installation..."
which R
R --version | head -1

# Check if genome files exist
echo ""
echo "Verifying genome files..."
SUZIBLUE="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa"
W85="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/W85/V_caesariense_W85-20_P0_v2.fasta"

if [ ! -f "$SUZIBLUE" ]; then
    echo "ERROR: Suziblue genome not found at $SUZIBLUE"
    exit 1
fi
echo "✓ Found Suziblue: $SUZIBLUE"

if [ ! -f "$W85" ]; then
    echo "ERROR: W85 genome not found at $W85"
    exit 1
fi
echo "✓ Found W85: $W85"

# Display genome file sizes
echo ""
echo "Genome file sizes:"
ls -lh "$SUZIBLUE" | awk '{print "  Suziblue:", $5}'
ls -lh "$W85" | awk '{print "  W85:     ", $5}'

# Create output directory
OUTPUT_DIR="/cluster/home/klee/deepspace_analysis"
mkdir -p "$OUTPUT_DIR"
echo ""
echo "Output directory: $OUTPUT_DIR"

# Set number of threads
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export SLURM_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
echo "Using $SLURM_CPUS_PER_TASK CPU cores"

echo ""
echo "=========================================="
echo "Starting DEEPSPACE analysis..."
echo "=========================================="
echo ""

# Run the R script
Rscript /cluster/home/klee/run_deepspace.R

# Check exit status
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "DEEPSPACE analysis completed successfully!"
    echo "=========================================="
    echo "End time: $(date)"
    echo ""
    echo "Output files are in: $OUTPUT_DIR"
    echo ""
    echo "Key output files:"
    echo "  - *.syn.paf: Synteny-constrained windowed hits"
    echo "  - *_dotplots.pdf: Dotplot visualizations"
    echo "  - *_blocks.paf: Syntenic block breakpoints"
    echo "  - riparian_*.pdf: Riparian plots"
    echo "  - custom_riparian_plot.pdf: Custom styled plot"
    echo ""
    ls -lh "$OUTPUT_DIR"/*.pdf "$OUTPUT_DIR"/*.paf 2>/dev/null | head -20
else
    echo ""
    echo "=========================================="
    echo "ERROR: DEEPSPACE analysis failed!"
    echo "=========================================="
    echo "Check the error log: deepspace_${SLURM_JOB_ID}.err"
    exit 1
fi

echo ""
echo "Job finished at: $(date)"
