#!/bin/bash
#SBATCH --job-name=Geno_compare_RE
#SBATCH -e geno_RE_%J.err
#SBATCH -o geno_RE_%J.out
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=128G
#SBATCH --partition=plant

ml bcftools/1.19-gcc-13.1.0

echo "Analyzing RE enrichment data vs WGS..."

# Index the RE VCF if needed
if [ ! -f ./Suzi_e_vcf/Suzi_e_RE_merged.AF.filtered.vcf.gz.tbi ]; then
    echo "Indexing RE VCF..."
    bcftools index -t ./Suzi_e_vcf/Suzi_e_RE_merged.AF.filtered.vcf.gz
fi

# Get samples from RE enrichment
echo "Extracting RE sample list..."
bcftools query -l ./Suzi_e_vcf/Suzi_e_RE_merged.AF.filtered.vcf.gz > re_samples.txt

echo "Total RE samples: $(wc -l < re_samples.txt)"

# Find which RE samples are in WGS
echo "Finding overlap with WGS..."
bcftools query -l ./Suzi_WGS_vcf/suzi_WGS_merged.vcf.gz > wgs_samples_full.txt
grep -Fxf re_samples.txt wgs_samples_full.txt > re_wgs_overlap.txt

echo "RE samples also in WGS: $(wc -l < re_wgs_overlap.txt)"
echo ""
echo "Overlapping samples:"
cat re_wgs_overlap.txt

# Check which plate samples are in this overlap
echo ""
echo "=== Plate 1 (B335-B436) samples in overlap ==="
seq 335 436 | sed 's/^/B/' | grep -Fxf - re_wgs_overlap.txt | sort

echo ""
echo "=== Plate 2 (B437-B547) samples in overlap ==="
seq 437 547 | sed 's/^/B/' | grep -Fxf - re_wgs_overlap.txt | sort

# Now create intersection of positions
echo ""
echo "Finding intersecting variant positions between WGS and RE..."
bcftools isec -p isec_re \
  ./Suzi_WGS_vcf/suzi_WGS_merged.vcf.gz \
  ./Suzi_e_vcf/Suzi_e_RE_merged.AF.filtered.vcf.gz

echo ""
echo "Intersection complete. Files in isec_re/:"
ls -lh isec_re/

echo ""
echo "Next step: Run concordance analysis on these overlapping samples"



########### then run concordance ########################################
#!/bin/bash
#SBATCH --job-name=Concordance_RE
#SBATCH -e concord_RE_%J.err
#SBATCH -o concord_RE_%J.out
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=128G
#SBATCH --partition=plant

ml bcftools/1.19-gcc-13.1.0

echo "Compressing and indexing RE intersection files..."

# Compress isec output if needed
if [ ! -f isec_re/0000.vcf.gz ]; then
    bgzip -c isec_re/0000.vcf > isec_re/0000.vcf.gz
    bcftools index -t isec_re/0000.vcf.gz
fi

if [ ! -f isec_re/0001.vcf.gz ]; then
    bgzip -c isec_re/0001.vcf > isec_re/0001.vcf.gz
    bcftools index -t isec_re/0001.vcf.gz
fi

if [ ! -f isec_re/0002.vcf.gz ]; then
    bgzip -c isec_re/0002.vcf > isec_re/0002.vcf.gz
    bcftools index -t isec_re/0002.vcf.gz
fi

if [ ! -f isec_re/0003.vcf.gz ]; then
    bgzip -c isec_re/0003.vcf > isec_re/0003.vcf.gz
    bcftools index -t isec_re/0003.vcf.gz
fi

echo "Calculating concordance for RE samples..."

# Calculate concordance for each sample
echo "Sample,Total_WGS_Called,Total_RE_Called,Called_Both,Concordant,Discordant,Concordance_Rate" > re_concordance.csv

while read sample; do
    echo "Processing $sample..."

    # Extract genotypes for this sample from both VCFs at shared positions
    # WGS: file 0002.vcf.gz (WGS at shared positions)
    # RE: file 0003.vcf.gz (RE at shared positions)

    bcftools query -s $sample -f '%CHROM\t%POS[\t%GT]\n' isec_re/0002.vcf.gz | \
      awk '$3 != "./." && $3 != ".|."' > wgs_${sample}_re.txt

    bcftools query -s $sample -f '%CHROM\t%POS[\t%GT]\n' isec_re/0003.vcf.gz | \
      awk '$3 != "./." && $3 != ".|."' > re_${sample}_re.txt

    wgs_called=$(wc -l < wgs_${sample}_re.txt)
    re_called=$(wc -l < re_${sample}_re.txt)

    # Join and compare
    awk 'NR==FNR {wgs[$1":"$2]=$3; next}
         {
            key=$1":"$2
            if (key in wgs) {
                total++
                wgs_gt = wgs[key]
                re_gt = $3

                # Normalize genotypes
                gsub(/\|/, "/", wgs_gt)
                gsub(/\|/, "/", re_gt)

                if ((wgs_gt == "0/1" || wgs_gt == "1/0") && (re_gt == "0/1" || re_gt == "1/0")) {
                    concordant++
                } else if (wgs_gt == re_gt) {
                    concordant++
                } else {
                    discordant++
                }
            }
         }
         END {
            if (total > 0) {
                conc_rate = concordant / total
                print total, concordant, discordant, conc_rate
            } else {
                print 0, 0, 0, 0
            }
         }' wgs_${sample}_re.txt re_${sample}_re.txt > result_${sample}_re.txt

    read total_both concordant discordant conc_rate < result_${sample}_re.txt

    echo "$sample,$wgs_called,$re_called,$total_both,$concordant,$discordant,$conc_rate" >> re_concordance.csv

    rm wgs_${sample}_re.txt re_${sample}_re.txt result_${sample}_re.txt

done < re_wgs_overlap.txt

echo "Done! Results in re_concordance.csv"

# Summary
awk -F',' 'NR>1 {
    total++
    if ($7 >= 0.95) excellent++
    else if ($7 >= 0.90) good++
    else if ($7 >= 0.80) questionable++
    else if ($7 > 0) poor++
    else no_data++

    if ($4 >= 1000) good_cov++
}
END {
    print "\n=== Summary ==="
    print "Total samples:", total
    print "Samples with ≥1000 shared sites:", good_cov
    print ""
    print "Concordance:"
    print "  Excellent (≥95%):", excellent
    print "  Good (90-95%):", good
    print "  Questionable (80-90%):", questionable
    print "  Poor (<80%):", poor
    print "  No data:", no_data
}' re_concordance.csv

# Focus on plate samples
echo ""
echo "=== Plate 1 & 2 Sample Concordance ===" > plate_concordance.txt
awk -F',' 'NR==1 {print; next}
     {
        sample = $1
        num = substr(sample, 2) + 0
        if (num >= 335 && num <= 547) print
     }' re_concordance.csv | sort -t',' -k7,7nr >> plate_concordance.txt

echo "Plate sample concordance saved to plate_concordance.txt"
cat plate_concordance.txt
