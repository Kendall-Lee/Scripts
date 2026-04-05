#!/bin/bash
# DEEPSPACE Setup Verification Script
# Run this before submitting the main job to verify everything is ready

echo "========================================"
echo "DEEPSPACE Setup Verification"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Check 1: MCScanX
echo -n "Checking MCScanX... "
if [ -f "/cluster/home/klee/MCScanX/MCScanX_h" ]; then
    if [ -x "/cluster/home/klee/MCScanX/MCScanX_h" ]; then
        echo -e "${GREEN}✓ Found and executable${NC}"
    else
        echo -e "${YELLOW}⚠ Found but not executable${NC}"
        echo "  Run: chmod +x /cluster/home/klee/MCScanX/MCScanX_h"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗ Not found${NC}"
    echo "  Expected location: /cluster/home/klee/MCScanX/MCScanX_h"
    echo "  To compile: cd /cluster/home/klee/MCScanX && make"
    ERRORS=$((ERRORS + 1))
fi

# Check 2: minimap2 module
echo -n "Checking minimap2 module... "
module purge
if module load cluster/minimap2/2.26 2>/dev/null; then
    echo -e "${GREEN}✓ Module loads successfully${NC}"
    minimap2 --version 2>/dev/null | head -1 | sed 's/^/  Version: /'
else
    echo -e "${RED}✗ Module not available${NC}"
    echo "  Try: module avail minimap"
    ERRORS=$((ERRORS + 1))
fi

# Check 3: R installation
echo -n "Checking R... "
if command -v R &> /dev/null; then
    R_VERSION=$(R --version | head -1)
    echo -e "${GREEN}✓ Found${NC}"
    echo "  $R_VERSION"
else
    echo -e "${RED}✗ Not found${NC}"
    echo "  R is required for DEEPSPACE"
    ERRORS=$((ERRORS + 1))
fi

# Check 4: R packages (if R is available)
if command -v R &> /dev/null; then
    echo -n "Checking R packages... "
    
    R_CHECK=$(R --slave --vanilla << 'EOF'
packages <- c("devtools", "ggplot2", "dbscan", "R.utils", "data.table",
              "Biostrings", "rtracklayer", "GenomicRanges", "Rsamtools")
installed <- sapply(packages, function(pkg) {
    suppressWarnings(require(pkg, character.only = TRUE, quietly = TRUE))
})
if (all(installed)) {
    cat("ALL_INSTALLED\n")
} else {
    cat("MISSING:", paste(packages[!installed], collapse = ", "), "\n")
}
EOF
)
    
    if [[ $R_CHECK == *"ALL_INSTALLED"* ]]; then
        echo -e "${GREEN}✓ All required packages installed${NC}"
    else
        echo -e "${YELLOW}⚠ Some packages missing${NC}"
        echo "  $R_CHECK"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    # Check DEEPSPACE specifically
    echo -n "Checking DEEPSPACE package... "
    DEEPSPACE_CHECK=$(R --slave --vanilla << 'EOF'
if (suppressWarnings(require("DEEPSPACE", quietly = TRUE))) {
    cat("INSTALLED\n")
} else {
    cat("NOT_INSTALLED\n")
}
EOF
)
    
    if [[ $DEEPSPACE_CHECK == *"INSTALLED"* ]]; then
        echo -e "${GREEN}✓ DEEPSPACE is installed${NC}"
    else
        echo -e "${RED}✗ DEEPSPACE not installed${NC}"
        echo "  To install, run R and execute:"
        echo "    devtools::install_github('jtlovell/DEEPSPACE')"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Check 5: Genome files
echo ""
echo "Checking genome files..."

SUZIBLUE="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_hap1.fa"
W85="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/W85/V_caesariense_W85-20_P0_v2.fasta"

echo -n "  Suziblue hap1... "
if [ -f "$SUZIBLUE" ]; then
    SIZE=$(ls -lh "$SUZIBLUE" | awk '{print $5}')
    echo -e "${GREEN}✓ Found ($SIZE)${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    echo "    Expected: $SUZIBLUE"
    ERRORS=$((ERRORS + 1))
fi

echo -n "  W85 genome... "
if [ -f "$W85" ]; then
    SIZE=$(ls -lh "$W85" | awk '{print $5}')
    echo -e "${GREEN}✓ Found ($SIZE)${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
    echo "    Expected: $W85"
    ERRORS=$((ERRORS + 1))
fi

# Check 6: Required scripts
echo ""
echo "Checking analysis scripts..."

echo -n "  run_deepspace.R... "
if [ -f "/cluster/home/klee/run_deepspace.R" ]; then
    echo -e "${GREEN}✓ Found${NC}"
else
    echo -e "${YELLOW}⚠ Not found${NC}"
    echo "    Copy run_deepspace.R to /cluster/home/klee/"
    WARNINGS=$((WARNINGS + 1))
fi

echo -n "  submit_deepspace.sh... "
if [ -f "/cluster/home/klee/submit_deepspace.sh" ]; then
    if [ -x "/cluster/home/klee/submit_deepspace.sh" ]; then
        echo -e "${GREEN}✓ Found and executable${NC}"
    else
        echo -e "${YELLOW}⚠ Found but not executable${NC}"
        echo "    Run: chmod +x /cluster/home/klee/submit_deepspace.sh"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠ Not found${NC}"
    echo "    Copy submit_deepspace.sh to /cluster/home/klee/"
    WARNINGS=$((WARNINGS + 1))
fi

# Check 7: Output directory
echo ""
echo -n "Checking output directory... "
OUTPUT_DIR="/cluster/home/klee/deepspace_analysis"
if [ -d "$OUTPUT_DIR" ]; then
    echo -e "${GREEN}✓ Exists${NC}"
    echo "  Location: $OUTPUT_DIR"
else
    echo -e "${YELLOW}⚠ Does not exist (will be created)${NC}"
    echo "  Will be created at: $OUTPUT_DIR"
fi

# Check 8: Disk space
echo ""
echo -n "Checking available disk space... "
AVAIL_SPACE=$(df -h /cluster/home/klee | tail -1 | awk '{print $4}')
echo "Available: $AVAIL_SPACE"

# Summary
echo ""
echo "========================================"
echo "Summary"
echo "========================================"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Ready to run DEEPSPACE${NC}"
    echo ""
    echo "To submit the job, run:"
    echo "  sbatch /cluster/home/klee/submit_deepspace.sh"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ ${WARNINGS} warning(s) found${NC}"
    echo "You may proceed, but review the warnings above."
    echo ""
    echo "To submit the job, run:"
    echo "  sbatch /cluster/home/klee/submit_deepspace.sh"
else
    echo -e "${RED}✗ ${ERRORS} error(s) and ${WARNINGS} warning(s) found${NC}"
    echo "Please fix the errors above before proceeding."
    echo ""
    echo "Common fixes:"
    echo "1. Install DEEPSPACE in R:"
    echo "   R -e \"devtools::install_github('jtlovell/DEEPSPACE')\""
    echo ""
    echo "2. Compile MCScanX:"
    echo "   cd /cluster/home/klee/MCScanX && make"
    echo ""
    echo "3. Copy the analysis scripts to /cluster/home/klee/"
fi

echo ""
exit $ERRORS
