#!/usr/bin/env Rscript
# Automated DEEPSPACE Installation Script
# This script installs all required R packages and DEEPSPACE

cat("========================================\n")
cat("DEEPSPACE Installation Script\n")
cat("========================================\n\n")

# Function to check if a package is installed
is_installed <- function(pkg) {
  suppressWarnings(require(pkg, character.only = TRUE, quietly = TRUE))
}

# Function to install a CRAN package
install_cran <- function(pkg) {
  cat("Installing", pkg, "from CRAN...\n")
  install.packages(pkg, repos = "https://cloud.r-project.org/")
}

# Function to install a Bioconductor package
install_bioc <- function(pkg) {
  cat("Installing", pkg, "from Bioconductor...\n")
  BiocManager::install(pkg, update = FALSE, ask = FALSE)
}

# Step 1: Install devtools if needed
cat("Step 1: Checking devtools...\n")
if (!is_installed("devtools")) {
  install_cran("devtools")
} else {
  cat("  ✓ devtools already installed\n")
}

# Step 2: Install BiocManager if needed
cat("\nStep 2: Checking BiocManager...\n")
if (!is_installed("BiocManager")) {
  install_cran("BiocManager")
} else {
  cat("  ✓ BiocManager already installed\n")
}

# Step 3: Install CRAN dependencies
cat("\nStep 3: Installing CRAN dependencies...\n")
cran_packages <- c("ggplot2", "dbscan", "R.utils", "data.table")

for (pkg in cran_packages) {
  if (!is_installed(pkg)) {
    install_cran(pkg)
  } else {
    cat("  ✓", pkg, "already installed\n")
  }
}

# Step 4: Install Bioconductor dependencies
cat("\nStep 4: Installing Bioconductor dependencies...\n")
bioc_packages <- c("Biostrings", "rtracklayer", "GenomicRanges", "Rsamtools")

for (pkg in bioc_packages) {
  if (!is_installed(pkg)) {
    install_bioc(pkg)
  } else {
    cat("  ✓", pkg, "already installed\n")
  }
}

# Step 5: Install DEEPSPACE from GitHub
cat("\nStep 5: Installing DEEPSPACE from GitHub...\n")
if (!is_installed("DEEPSPACE")) {
  cat("Downloading and installing DEEPSPACE...\n")
  devtools::install_github("jtlovell/DEEPSPACE", quiet = FALSE)
} else {
  cat("  ✓ DEEPSPACE already installed\n")
  cat("  Checking for updates...\n")
  devtools::install_github("jtlovell/DEEPSPACE", quiet = FALSE, force = FALSE)
}

# Step 6: Verify installation
cat("\n========================================\n")
cat("Verifying Installation\n")
cat("========================================\n\n")

all_packages <- c("devtools", "BiocManager", cran_packages, bioc_packages, "DEEPSPACE")
success <- TRUE

for (pkg in all_packages) {
  if (is_installed(pkg)) {
    cat("✓", pkg, "\n")
  } else {
    cat("✗", pkg, "- INSTALLATION FAILED\n")
    success <- FALSE
  }
}

cat("\n========================================\n")
if (success) {
  cat("SUCCESS: All packages installed!\n")
  cat("========================================\n\n")
  cat("You can now run DEEPSPACE with:\n")
  cat("  library(DEEPSPACE)\n\n")
  cat("To submit the analysis job:\n")
  cat("  sbatch /cluster/home/klee/submit_deepspace.sh\n\n")
} else {
  cat("ERROR: Some packages failed to install\n")
  cat("========================================\n\n")
  cat("Please check the error messages above and:\n")
  cat("1. Ensure you have internet connectivity\n")
  cat("2. Check that required system libraries are available\n")
  cat("3. Contact your system administrator if problems persist\n\n")
}

# Print session info for debugging
cat("R Session Information:\n")
cat("-------------------------------------\n")
print(sessionInfo())
