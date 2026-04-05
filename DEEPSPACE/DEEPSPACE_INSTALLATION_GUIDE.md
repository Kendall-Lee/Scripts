# DEEPSPACE Installation and Usage Guide for Blueberry Genome Comparison

## Overview
This guide will help you run DEEPSPACE to compare two blueberry genomes:
- Suziblue hap1
- V. caesariense W85-20 P0 v2

DEEPSPACE performs annotation-free synteny analysis using minimap2 and MCScanX.

## Prerequisites

### 1. MCScanX (Already installed)
✓ Location: `/cluster/home/klee/MCScanX/MCScanX_h`

If MCScanX_h is not executable, compile it:
```bash
cd /cluster/home/klee/MCScanX
make
```

### 2. minimap2 (Already available as module)
✓ Module: `cluster/minimap2/2.26`

### 3. R and Required Packages

#### Install R packages (if not already installed)
You need to install DEEPSPACE and its dependencies. On your cluster, start an interactive session:

```bash
# Request interactive session
srun --pty --mem=16G --cpus-per-task=4 --time=2:00:00 bash

# Load required modules
module load cluster/minimap2/2.26

# Start R
R
```

In R, run:
```r
# Install devtools if needed
if (!requireNamespace("devtools", quietly = TRUE))
    install.packages("devtools")

# Install BiocManager if needed
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# Install Bioconductor dependencies
BiocManager::install(c("Biostrings", "rtracklayer", "GenomicRanges", "Rsamtools"))

# Install DEEPSPACE from GitHub
devtools::install_github("jtlovell/DEEPSPACE")

# Verify installation
library(DEEPSPACE)
```

## Running DEEPSPACE

### Step 1: Copy the scripts to your cluster

Copy these two files to your cluster:
- `run_deepspace.R` → `/cluster/home/klee/run_deepspace.R`
- `submit_deepspace.sh` → `/cluster/home/klee/submit_deepspace.sh`

Make the submission script executable:
```bash
chmod +x /cluster/home/klee/submit_deepspace.sh
```

### Step 2: Submit the job

```bash
cd /cluster/home/klee
sbatch submit_deepspace.sh
```

### Step 3: Monitor the job

```bash
# Check job status
squeue -u $USER

# View output in real-time
tail -f deepspace_*.out

# View error log if needed
tail -f deepspace_*.err
```

## Expected Runtime

- **Memory**: 64 GB allocated (may use 30-50 GB)
- **CPUs**: 8 cores
- **Time**: 1-5 hours depending on genome sizes
  - minimap2 alignment: 1-5 min per alignment
  - MCScanX synteny search: ~1 min per pair

## Output Files

All results will be saved to: `/cluster/home/klee/deepspace_analysis/`

Key output files:
- `*_window__vs_*.syn.paf` - Synteny-constrained windowed hits
- `*_window__vs_*_dotplots.pdf` - Dotplot visualizations
- `*_window__vs_*_blocks.paf` - Syntenic block breakpoints
- `riparian_phasedBysuziblue.pdf` - Riparian plot showing synteny
- `custom_riparian_plot.pdf` - Custom styled riparian plot
- `session_info.txt` - R session information for reproducibility

## Understanding the Results

### Dotplots
Shows pairwise alignments between chromosomes. Points represent aligned regions:
- Diagonal lines = collinear regions (same orientation)
- Off-diagonal = rearrangements
- Inversions appear as lines with opposite slope

### Riparian Plots
River-like visualization showing synteny across genomes:
- Colored bands = syntenic regions
- Orange highlights = inversions
- Width = size of syntenic region
- Connections show homologous chromosome segments

### PAF Files
Tab-delimited text files with alignment information:
- Can be further analyzed with custom scripts
- Contains coordinates, alignment scores, and strand information

## Troubleshooting

### If MCScanX_h is not found or not executable:
```bash
cd /cluster/home/klee/MCScanX
make
chmod +x MCScanX_h
```

### If R packages fail to install:
Some packages may need system libraries. Contact your cluster admin or try:
```bash
module load gcc/9.3.0  # or appropriate compiler
```

### If memory issues occur:
Edit `submit_deepspace.sh` and increase `--mem` from 64G to 96G or 128G

### If the job fails:
1. Check the error log: `deepspace_*.err`
2. Check the output log: `deepspace_*.out`
3. Verify genome file paths in `run_deepspace.R`

## Customizing the Analysis

### Adjust for divergent genomes
If the genomes are more divergent than expected, edit `run_deepspace.R`:
```r
preset = "dist fast",  # instead of "standard"
```

### Adjust minimum chromosome length
If you want to exclude small scaffolds:
```r
minChrLen = 10e6,  # 10 Mb minimum
```

### Change resource allocation
Edit `submit_deepspace.sh` SLURM directives:
```bash
#SBATCH --cpus-per-task=16  # More CPUs
#SBATCH --mem=128G          # More memory
#SBATCH --time=48:00:00     # More time
```

## Additional Analyses

After the initial run completes, you can create custom visualizations:

```r
library(DEEPSPACE)

# Load the results
workDir <- "/cluster/home/klee/deepspace_analysis"
synFiles <- list.files(workDir, pattern = ".syn.paf$", full.names = TRUE)

# Create custom riparian plot with different colors
pdf(file.path(workDir, "custom_riparian_inverted.pdf"), width = 14, height = 10)
riparian_paf(
  pafFiles = synFiles,
  refGenome = "suziblue",
  genomeIDs = c("suziblue", "w85"),
  orderyBySynteny = FALSE,  # Order by chromosome name instead
  braidOffset = 0.1,
  braidColors = "darkgreen",
  highlightInversions = "red",
  braidAlpha = 0.9
)
dev.off()
```

## Citation

If you use DEEPSPACE for publication, cite:
- DEEPSPACE: https://github.com/jtlovell/DEEPSPACE
- minimap2: Li, H. (2018). Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics, 34:3094-3100.
- MCScanX: Wang et al. (2012). MCScanX: a toolkit for detection and evolutionary analysis of gene synteny and collinearity. Nucleic Acids Research, 40(7), e49.

## Support

For issues specific to:
- **DEEPSPACE**: https://github.com/jtlovell/DEEPSPACE/issues
- **Cluster-specific questions**: Contact your HPC administrator
- **This workflow**: Contact klee on the cluster

## Quick Reference Commands

```bash
# Submit job
sbatch submit_deepspace.sh

# Check status
squeue -u $USER

# Cancel job
scancel <job_id>

# View outputs
cd /cluster/home/klee/deepspace_analysis
ls -lh *.pdf

# Copy results to local machine
scp -r username@cluster:/cluster/home/klee/deepspace_analysis/*.pdf .
```
