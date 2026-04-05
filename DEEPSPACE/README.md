# DEEPSPACE Analysis for Blueberry Genomes

Complete workflow for comparing Suziblue hap1 and V. caesariense W85-20 genomes using DEEPSPACE on your HPC cluster.

## Quick Start

```bash
# 1. Copy all files to your cluster
cd /cluster/home/klee

# 2. Make scripts executable
chmod +x verify_setup.sh submit_deepspace.sh

# 3. Verify setup
./verify_setup.sh

# 4. If needed, install DEEPSPACE
Rscript install_deepspace.R

# 5. Submit the job
sbatch submit_deepspace.sh
```

## Files Included

### Main Scripts
1. **submit_deepspace.sh** - SLURM submission script for the cluster
2. **run_deepspace.R** - Main R script that runs DEEPSPACE analysis
3. **verify_setup.sh** - Checks if everything is ready to run
4. **install_deepspace.R** - Installs DEEPSPACE and all dependencies

### Documentation
5. **DEEPSPACE_INSTALLATION_GUIDE.md** - Comprehensive setup instructions
6. **README.md** - This file

## What You Need

### Already Available ✓
- MCScanX: `/cluster/home/klee/MCScanX/MCScanX`
- minimap2: `cluster/minimap2/2.26` (as module)
- Genome 1: `/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa`
- Genome 2: `/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/W85/V_caesariense_W85-20_P0_v2.fasta`

### Needs Installation
- DEEPSPACE R package (run `install_deepspace.R`)

## Step-by-Step Instructions

### 1. Setup and Verification

First, verify that everything is ready:

```bash
cd /cluster/home/klee
./verify_setup.sh
```

This will check:
- MCScanX installation
- minimap2 module availability
- R installation
- R packages
- Genome file accessibility
- Script files

### 2. Install DEEPSPACE (if needed)

If the verification script shows DEEPSPACE is not installed:

```bash
# Option A: Run the installation script
Rscript install_deepspace.R

# Option B: Manual installation in R
R
```

In R:
```r
# Install dependencies
if (!requireNamespace("devtools", quietly = TRUE))
    install.packages("devtools")

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install(c("Biostrings", "rtracklayer", "GenomicRanges", "Rsamtools"))

# Install DEEPSPACE
devtools::install_github("jtlovell/DEEPSPACE")

# Verify
library(DEEPSPACE)
```

### 3. Submit the Job

Once verification passes:

```bash
sbatch submit_deepspace.sh
```

### 4. Monitor Progress

```bash
# Check job status
squeue -u $USER

# View output log (updates in real-time)
tail -f deepspace_*.out

# View error log (if any issues)
tail -f deepspace_*.err
```

## Expected Runtime

- **Total time**: 2-6 hours
- **Memory usage**: 30-50 GB (64 GB allocated)
- **CPU usage**: 8 cores
- **Disk space needed**: ~5-10 GB for outputs

### Time breakdown:
- minimap2 alignment: 1-5 minutes per comparison
- MCScanX synteny search: ~1 minute per pair
- Plotting and finalization: 5-10 minutes

## Output Files

All results saved to: `/cluster/home/klee/deepspace_analysis/`

### Key Outputs:

**Synteny Files (.paf)**
- `suziblue_window__vs_w85.syn.paf` - Synteny-constrained alignments
- `suziblue_window__vs_w85_blocks.paf` - Syntenic block coordinates

**Visualizations (.pdf)**
- `suziblue_window__vs_w85_dotplots.pdf` - Genome-wide dotplot
- `riparian_phasedBysuziblue.pdf` - Main riparian plot
- `custom_riparian_plot.pdf` - Custom styled version

**Metadata**
- `session_info.txt` - R session info for reproducibility

## Understanding the Results

### Dotplots
Shows chromosome-level alignments between genomes:
- **Diagonal lines** = Collinear regions (same orientation)
- **Off-diagonal points** = Chromosomal rearrangements
- **Inverted slopes** = Inversions
- **Scattered points** = Translocations or local duplications

### Riparian Plots
River-like flow showing synteny:
- **Colored bands** = Syntenic chromosome segments
- **Width** = Size/significance of syntenic region
- **Connections** = Homologous relationships
- **Orange highlights** = Inverted sequences
- **Gaps** = Non-syntenic regions

### PAF Files
Tab-delimited alignment data containing:
- Query and target coordinates
- Alignment length and quality
- Strand orientation
- Mapping quality scores

Can be parsed with custom scripts or awk/grep for specific analyses.

## Troubleshooting

### Common Issues

**1. "MCScanX_h not found"**
```bash
cd /cluster/home/klee/MCScanX
make
chmod +x MCScanX_h
```

**2. "Module minimap2 not found"**
```bash
module avail minimap  # Find available versions
module load cluster/minimap2/2.26
```

**3. "DEEPSPACE not installed"**
```bash
Rscript install_deepspace.R
```

**4. "Out of memory error"**
Edit `submit_deepspace.sh`:
```bash
#SBATCH --mem=96G  # Increase from 64G
```

**5. "Job timeout"**
Edit `submit_deepspace.sh`:
```bash
#SBATCH --time=48:00:00  # Increase from 24:00:00
```

### Getting Help

1. **Check logs**: `deepspace_*.out` and `deepspace_*.err`
2. **Verify setup**: `./verify_setup.sh`
3. **Check genome files**: Ensure they exist and are readable
4. **Test minimap2**: `minimap2 --version`
5. **Test R**: `R --version`

## Customization

### Adjust for Genome Divergence

If genomes are more divergent than expected, edit `run_deepspace.R`:

```r
# Change from "standard" to "dist fast"
preset = "dist fast",
```

### Filter Small Scaffolds

To exclude small scaffolds/contigs:

```r
# Increase minimum chromosome length
minChrLen = 10e6,  # 10 Mb instead of 5 Mb
```

### Modify Resource Allocation

Edit `submit_deepspace.sh`:

```bash
#SBATCH --cpus-per-task=16   # More CPUs (faster minimap2)
#SBATCH --mem=128G           # More memory
#SBATCH --time=48:00:00      # More time
```

### Custom Visualizations

After main analysis completes, create custom plots:

```r
library(DEEPSPACE)
workDir <- "/cluster/home/klee/deepspace_analysis"

# Load synteny files
synFiles <- list.files(workDir, pattern = ".syn.paf$", full.names = TRUE)

# Create custom riparian plot
pdf(file.path(workDir, "my_custom_plot.pdf"), width = 16, height = 10)
riparian_paf(
  pafFiles = synFiles,
  refGenome = "suziblue",
  genomeIDs = c("suziblue", "w85"),
  orderyBySynteny = TRUE,
  braidOffset = 0.1,
  braidColors = c("steelblue", "forestgreen", "coral"),
  highlightInversions = "darkred",
  braidAlpha = 0.85
)
dev.off()
```

## Advanced Usage

### Running Multiple Comparisons

To compare additional genomes, edit `run_deepspace.R`:

```r
fastaFiles <- c(
  suziblue = "/path/to/suziblue.fa",
  w85 = "/path/to/w85.fasta",
  genome3 = "/path/to/genome3.fa"
)

genomeIDs <- c("suziblue", "w85", "genome3")
```

### Extracting Specific Syntenic Regions

Use awk to parse PAF files:

```bash
# Extract alignments on chromosome 1
awk '$6 == "Chr01"' deepspace_analysis/*.syn.paf

# Extract high-quality alignments (MAPQ > 30)
awk '$12 > 30' deepspace_analysis/*.syn.paf

# Get inversions only
awk '$5 == "-"' deepspace_analysis/*.syn.paf
```

## Citation

If you use this workflow in your research, please cite:

**DEEPSPACE**
- Repository: https://github.com/jtlovell/DEEPSPACE
- Related tool (GENESPACE): Lovell et al. (2022) eLife

**minimap2**
- Li, H. (2018). Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics, 34:3094-3100.

**MCScanX**
- Wang et al. (2012). MCScanX: a toolkit for detection and evolutionary analysis of gene synteny and collinearity. Nucleic Acids Research, 40(7), e49.

## Contact

- **Cluster issues**: Contact your HPC administrator
- **DEEPSPACE issues**: https://github.com/jtlovell/DEEPSPACE/issues
- **Workflow questions**: klee

## Quick Reference

```bash
# Submit job
sbatch submit_deepspace.sh

# Check status
squeue -u $USER

# Cancel job
scancel <job_id>

# View results
cd /cluster/home/klee/deepspace_analysis
ls -lh *.pdf *.paf

# Download results
scp -r username@cluster:/cluster/home/klee/deepspace_analysis/*.pdf .
```

## File Locations Reference

```
/cluster/home/klee/
├── MCScanX/MCScanX_h                    # MCScanX executable
├── run_deepspace.R                       # Main analysis script
├── submit_deepspace.sh                   # SLURM submission script
├── verify_setup.sh                       # Setup verification
├── install_deepspace.R                   # Installation script
└── deepspace_analysis/                   # Output directory
    ├── *.syn.paf                         # Synteny files
    ├── *.pdf                             # Visualizations
    └── session_info.txt                  # Session info

/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/
├── Suziblue/Final_Assembly/
│   └── Suziblue_hap1.fa                 # Genome 1
└── W85/
    └── V_caesariense_W85-20_P0_v2.fasta # Genome 2
```
