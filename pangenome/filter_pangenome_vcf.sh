#!/bin/bash
#SBATCH --job-name=filter_pan_vcf
#SBATCH -e filter_pan_vcf_%J.err
#SBATCH -o filter_pan_vcf_%J.out
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem=100G
#SBATCH --partition=normal

ml bcftools/1.19-gcc-13.1.0
ml htslib/1.19.1-gcc-13.1.0

INDIR="PAN_vcf"
OUTDIR="filtered_vcfs"

mkdir -p $OUTDIR

SUCCESS=0
FAILED=0

for vcf in $INDIR/*.vcf; do
    sample=$(basename $vcf .vcf)

    echo "Processing $sample..."

    # Just filter - output uncompressed VCF
    bcftools view \
        -i '(FILTER="PASS" || FILTER="lowdepth") && FORMAT/DP >= 2' \
        $vcf \
        -o $OUTDIR/${sample}.filtered.vcf

    if [ -s $OUTDIR/${sample}.filtered.vcf ]; then
        n_vars=$(grep -v "^#" $OUTDIR/${sample}.filtered.vcf | wc -l)
        echo "  ✓ $sample: $n_vars variants"
        ((SUCCESS++))
    else
        echo "  ✗ $sample FAILED (empty output)"
        rm $OUTDIR/${sample}.filtered.vcf 2>/dev/null
        ((FAILED++))
    fi
done

echo ""
echo "========================================="
echo "Filtering complete!"
echo "Successful: $SUCCESS"
echo "Failed: $FAILED"
echo "========================================="


####################################################################################################################
################### Rename the headers #############################################################################
####################################################################################################################

#!/bin/bash
#SBATCH --job-name=filter_split_vcf
#SBATCH -e filter_split_%J.err
#SBATCH -o filter_split_%J.out
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem=100G
#SBATCH --partition=normal

ml bcftools/1.19-gcc-13.1.0
ml htslib/1.19.1-gcc-13.1.0

INDIR="filtered_vcfs"
OUTDIR="filtered_split_vcfs"
TMPDIR="$OUTDIR/tmp"

mkdir -p $OUTDIR
mkdir -p $TMPDIR

SUCCESS=0

for vcf in $INDIR/*.vcf; do
    sample=$(basename $vcf .vcf)

    echo "Processing $sample..."

    # Step 1: Fix header contig names
    sed 's/SuziRef#0#//g' $vcf > $TMPDIR/${sample}.fixed_header.vcf

    # Step 2: Filter, split, keep ALTs
    bcftools view \
        -i '(FILTER="PASS" || FILTER="lowdepth") && FORMAT/DP >= 2' \
        $TMPDIR/${sample}.fixed_header.vcf | \
    bcftools norm -m -any | \
    bcftools view -i 'GT="alt"' \
        -o $OUTDIR/${sample}.vcf

    if [ -s $OUTDIR/${sample}.vcf ]; then
        n_vars=$(grep -v "^#" $OUTDIR/${sample}.vcf | wc -l)
        echo "  ✓ $sample: $n_vars variants"
        rm $TMPDIR/${sample}.fixed_header.vcf
        ((SUCCESS++))
    else
        echo "  ✗ $sample FAILED"
        rm $OUTDIR/${sample}.vcf 2>/dev/null
    fi
done

echo ""
echo "Complete! Successful: $SUCCESS"

rmdir $TMPDIR 2>/dev/null
####################################################################################################################
######### split multiallelic sites and filters out GT = 0/0 aka homozygous for the ref allele ######################
####################################################################################################################
#!/bin/bash
# split_and_filter.sh

INDIR="filtered_vcfs"
OUTDIR="split_vcfs"

mkdir -p $OUTDIR

for vcf in $INDIR/*.filtered.vcf; do
    sample=$(basename $vcf .filtered.vcf)

    echo "Processing $sample..."

    # Split multiallelic and remove sites where sample is 0/0
    bcftools norm -m -any $vcf | \
    bcftools view -i 'GT="alt"' \
      -o $OUTDIR/${sample}.split.vcf

    n_vars=$(grep -v "^#" $OUTDIR/${sample}.split.vcf | wc -l)
    echo "  ✓ $sample: $n_vars variants (after removing 0/0)"
done


##########################################################
######## quick check for biallelic vs multiallelicb#######
##########################################################

sample="B099"

echo "=== $sample Variant Statistics ==="

# Total variants
total=$(bcftools view -H ${sample}.filtered.vcf | wc -l)
echo "Total variants: $total"

# Biallelic
bi=$(bcftools view -H -m2 -M2 ${sample}.filtered.vcf | wc -l)
echo "Biallelic: $bi"

# Multiallelic
multi=$(bcftools view -H -m3 ${sample}.filtered.vcf | wc -l)
echo "Multiallelic: $multi"

# Show some multiallelic examples
echo ""
echo "Example multiallelic sites:"
bcftools view -H -m3 ${sample}.filtered.vcf | head -5 | cut -f1-5


####################################################################################################################
################### check missingness in vcf  #############################################################################
####################################################################################################################


bcftools query -f '%F_MISSING\n' SHB_merged.snps.AF.filtered.tags.vcf.gz | \
awk '{bucket=int($1*10)/10; counts[bucket]++} END {for (b in counts) print b, counts[b]}'
