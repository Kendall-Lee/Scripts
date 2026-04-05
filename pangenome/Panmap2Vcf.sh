#get the alleles for each site in the panmap
panmapGetAlleles LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.panmap > LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.txt

#check that the # of lines in the alleles matches the # of lines in the .panmap
#first line of this file is a header
cat LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.txt | wc -l
3272324

#first line of this file is a header
cat LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.panmap | wc -l
3272324

#as a sanity check, paste the first 4 lines of the .panmap to the alleles.txt file and check that the lens match the alleles
paste <(cat LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.panmap | cut -f1-3) LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.txt > LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.part.txt &

#once confirmed, copy only the chr and pos columns to the alleles
paste <(cat LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.panmap | cut -f1-2) LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.txt > LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.part.txt &

#copy columns 4- to the allele calls 
paste LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.part.txt <(cat LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.panmap | cut -f4-) > LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.full.txt

#convert the "alleles" column (col 3) to ref and alternate columns
awk 'BEGIN {OFS="\t"}
NR==1 {
    # Header line: print first two columns, then "REF" and "ALT", then any extra columns
    print $1, $2, "REF", "ALT", substr($0, index($0, $4))
    next
}
{
    split($3, alleles, ",")                          # Split column 3 by commas
    ref = alleles[1]                                 # First allele = REF
    alt = (length(alleles) > 1) ? alleles[2] : "."   # Default ALT to "." if none
    for (i = 3; i <= length(alleles); i++) {
        alt = alt "," alleles[i]                     # Reconstruct ALT
    }
    print $1, $2, ref, alt, substr($0, index($0, $4)) # Print modified + remaining columns
}' LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.full.txt > LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.full.ref.alt.txt


#split the fifth column that includes the pangenome samples and their allele calls into separate columns
awk 'BEGIN {OFS="\t"}
NR == 1 {
  # Process the header line
  # First 4 columns, then split sample names from field 5, then the rest (if any)
  for (i = 1; i <= 4; i++) printf "%s\t", $i
  split($5, samples, ",")
  for (i in samples) printf "%s\t", samples[i]
  for (i = 6; i <= NF; i++) printf "%s\t", $i
  print ""
  next
}
NR > 1 {
  # Process data lines
  for (i = 1; i <= 4; i++) printf "%s\t", $i
  split($5, calls, ",")
  for (i in calls) printf "%s\t", calls[i]
  for (i = 6; i <= NF; i++) printf "%s\t", $i
  print ""
}' LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.full.ref.alt.txt > LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.full.ref.alt.pansplit.txt


#convert all the pan and regular sample allele calls into that of a "vcf"-like file
awk 'BEGIN {OFS="\t"}
NR == 1 {
    # Print header as-is
    print
    next
}
{
    for (i = 1; i <= 4; i++) {
        printf "%s\t", $i           # Print first 4 columns unchanged
    }

    for (i = 5; i <= NF; i++) {
        if ($i == "-") {
            geno = "./."            # Missing call
        } else if ($i ~ /,/) {
            split($i, alleles, ",") # Heterozygous call like 1,2
            geno = alleles[1] "/" alleles[2]
        } else {
            geno = $i "/" $i        # Homozygous call, e.g. 1 → 1/1
        }
        printf "%s", geno
        if (i < NF) {
            printf "\t"
        } else {
            printf "\n"
        }
    }
}' LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.full.ref.alt.pansplit.txt > LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.full.ref.alt.pansplit.convert.txt

#add dummy values for QUAL, FILTER, INFO, FORMAT 
awk 'BEGIN {OFS="\t"}
NR == 1 {
    # Extract and print first 4 columns
    for (i = 1; i <= 4; i++) printf "%s\t", $i
    printf "QUAL\tFILTER\tINFO\tFORMAT\t"

    for (i = 5; i <= NF; i++) {
        printf "%s", $i
        if (i < NF) printf "\t"; else printf "\n"
    }
    next
}
{
    for (i = 1; i <= 4; i++) printf "%s\t", $i
    printf ".\tPASS\t.\tGT\t"

    for (i = 5; i <= NF; i++) {
        printf "%s", $i
        if (i < NF) printf "\t"; else printf "\n"
    }
}' LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.full.ref.alt.pansplit.convert.txt > LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.full.ref.alt.pansplit.convert.dummy.txt

#calculate the length of each of the contigs 
#got this info from the original .vcf of the graph


#add this synthetic header and change chr to #CHR and pos to POS

(echo "##fileformat=VCFv4.2
##source=ExampleVariantCaller
##contig=<ID=chr01,length=112420854>
##contig=<ID=chr02,length=103302290>
##contig=<ID=chr03,length=143109472>
##contig=<ID=chr04,length=128801742>
##contig=<ID=chr05,length=116542366>
##contig=<ID=chr06,length=118975115>
##contig=<ID=chr07,length=81752458>
##contig=<ID=chr08,length=51529986>
##contig=<ID=chr09,length=120499698>
##contig=<ID=chr10,length=117076737>
##contig=<ID=chr11,length=149287806>
##contig=<ID=chr12,length=120530088>
##contig=<ID=chr13,length=146301462>
##contig=<ID=chr14,length=143237272>
##contig=<ID=chr15,length=160028458>
##contig=<ID=chr16,length=151242074>
##contig=<ID=chr17,length=134191082>
##contig=<ID=chr18,length=135027066>
##contig=<ID=chr19,length=159361216>
##contig=<ID=chr20,length=145034356>
##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">" \
&& awk 'NR == 1 {$1 = "#CHROM"; $2 = "POS"} {print}' OFS="\t" LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.alleles.full.ref.alt.pansplit.convert.dummy.txt) > LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.vcf
