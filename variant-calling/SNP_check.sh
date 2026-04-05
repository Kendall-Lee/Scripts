# first find most significant points in GWAs file
cat geno_phenotypes_farmcpupp_DF.txt | awk '{if ($4 < 1e-10) print $0}' | sort -k4,4
#then create bed file with ~100 bp region with SNP

#load in bedtools
ml cluster/bedtools/2.28.0
#extract surrounding region of the SNP and blast it
bedtools getfasta -fi /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Draper/DraperChrOrdered_modified.fasta -bed chr.03.bed
