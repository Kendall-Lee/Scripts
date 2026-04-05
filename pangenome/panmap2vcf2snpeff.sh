#nano file and add
##fileformat=VCFv4.2
##INFO=<ID=Meth,Number=1,Type=String,Description="Method used for variant calling">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##contig=<ID=chr01,length=100000000>
##contig=<ID=chr02,length=100000000>
##contig=<ID=chr03,length=100000000>
##contig=<ID=chr04,length=100000000>
##contig=<ID=chr05,length=100000000>
##contig=<ID=chr06,length=100000000>
##contig=<ID=chr07,length=100000000>
##contig=<ID=chr08,length=100000000>
##contig=<ID=chr09,length=100000000>
##contig=<ID=chr10,length=100000000>
##contig=<ID=chr11,length=100000000>
##contig=<ID=chr12,length=100000000>
##contig=<ID=chr13,length=100000000>
##contig=<ID=chr14,length=100000000>
##contig=<ID=chr15,length=100000000>
##contig=<ID=chr16,length=100000000>
##contig=<ID=chr17,length=100000000>
##contig=<ID=chr18,length=100000000>
##contig=<ID=chr19,length=100000000>
##contig=<ID=chr20,length=100000000>

#change chr name

cp SRLP_Smiss0.99_miss0.9_maf0.0_kmer0_dep1.panmap.vcf SRLP_Smiss0.99_miss0.9_maf0.0_kmer0_dep1.fixed.vcf

for i in $(seq -w 1 20); do
  old="chr${i}"
  new="TRv2Chr.${i}"
  sed -i "s/\b${old}\b/${new}/g" LRLP_Smiss0.99_miss0.9_maf0.0_kmer0_depfull.vcf
done

###check the file

bcftools view SRLP_Smiss0.99_miss0.9_maf0.0_kmer0_dep1.fixed.vcf -Ov -o /dev/null

#resolve any comma issues with AI
awk '
BEGIN { OFS = "\t" }
{
  if ($0 ~ /^#/ ) {
    print
  } else {
    for (i=10; i<=NF; i++) {
      if ($i ~ /,/) {
        $i = "./."
      }
    }
    print
  }
}' SRLP_Smiss0.99_miss0.9_maf0.0_kmer0_dep1.fixed.vcf > SRLP_Smiss0.99_miss0.9_maf0.0_kmer0_dep1.fixed.clean.vcf
