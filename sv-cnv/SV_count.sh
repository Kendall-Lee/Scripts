#!/bin/bash

# Header for the output
echo -e "File\tInversions\tInsertions\tDeletions\tTranslocation\tDuplication" > sv_counts.tsv

# Loop through each VCF file
for vcf_file in ./*.vcf; do
  # Count the number of each type of structural variation
  inversions=$(grep -c "SVTYPE=INV" "$vcf_file")
  insertions=$(grep -c "SVTYPE=INS" "$vcf_file")
  deletions=$(grep -c "SVTYPE=DEL" "$vcf_file")
  translocation=$(grep -c "SVTYPE=BND" "$vcf_file")
  duplication=$(grep -c "SVTYPE=DUP" "$vcf_file")

  # Write the counts to the output file
  echo -e "$(basename "$vcf_file")\t$inversions\t$insertions\t$deletions\t$translocation\t$duplication" >> sv_counts.tsv
done

echo "Counts of structural variations have been written to sv_counts.tsv"


############for snpEFF ######

#!/bin/bash

# Header for the output
echo -e "File\tHigh\tModerate\tLow\tModifier" > sv_impact_intergenic_removed.tsv

# Loop through each VCF file
for vcf_file in ./*.vcf; do
  # Count the number of each type of impact excluding 'intergenic_region'
  high=$(grep -v "intergenic_region" "$vcf_file" | grep -c "HIGH")
  moderate=$(grep -v "intergenic_region" "$vcf_file" | grep -c "MODERATE")
  low=$(grep -v "intergenic_region" "$vcf_file" | grep -c "LOW")
  modifier=$(grep -v "intergenic_region" "$vcf_file" | grep -c "MODIFIER")

  # Write the counts to the output file
  echo -e "$(basename "$vcf_file")\t$high\t$moderate\t$low\t$modifier" >> sv_impact_intergenic_removed.tsv
done

echo "Counts of structural variations impact have been written to sv_impact_intergenic_removed.tsv"



########## to count impact types #########

grep "ANN=" WG_merged.snpEff.vcf | grep "TRv2Chr" | grep -v "##" | awk -F 'ANN=' '{print $2}' | awk -F '|' '{if($3 ~ /HIGH/) high+=1; if($3 ~ /MODERATE/) moderate+=1; if($3 ~ /LOW/) low+=1; if($3 ~ /MODIFIER/) modifier+=1} END {print "HIGH:", high, "MODERATE:", moderate, "LOW:", low, "MODIFIER:", modifier}'




#!/bin/bash
grep "ANN=" WG_merged.snpEff.vcf | grep "TRv2Chr" | grep -v "##" | \
awk -F '\t|;' '
{
    split($8, info, ";");
    svtype="";
    for(i in info) {
        if(info[i] ~ /^SVTYPE=/) {
            split(info[i], type, "=");
            svtype = type[2];
        }
    }
    ann=$0; sub(/.*ANN=/,"",ann);
    split(ann, fields, "|");
    impact = fields[3];
    if (impact ~ /HIGH/) {
        high[svtype] += 1;
    } else if (impact ~ /MODERATE/) {
        moderate[svtype] += 1;
    } else if (impact ~ /LOW/) {
        low[svtype] += 1;
    } else if (impact ~ /MODIFIER/) {
        modifier[svtype] += 1;
    }
}
END {
    print "HIGH: INS:", high["INS"], "INV:", high["INV"], "DEL:", high["DEL"], "BND:", high["BND"], "DUP:", high["DUP"];
    print "MODERATE: INS:", moderate["INS"], "INV:", moderate["INV"], "DEL:", moderate["DEL"], "BND:", moderate["BND"], "DUP:", moderate["DUP"];
    print "LOW: INS:", low["INS"], "INV:", low["INV"], "DEL:", low["DEL"], "BND:", low["BND"], "DUP:", low["DUP"];
    print "MODIFIER: INS:", modifier["INS"], "INV:", modifier["INV"], "DEL:", modifier["DEL"], "BND:", modifier["BND"], "DUP:", modifier["DUP"];
}'
