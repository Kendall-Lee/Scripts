#!/bin/bash
ml cluster/bedtools/2.28.0
ml cluster/bcftools/1.18

bcftools view -h /cluster/lab/clevenger/hwright/Sameer_Magic/peanutpan_REFproc/peanutpan.vcf | grep '^##contig' | sed -E 's/##contig=<ID=([^,]+),length=([0-9]+).*/\1\t\2/' > chrSizes.txt
bedtools makewindows -g chrSizes.txt -w 100000 -s 10000 > windows.bed
bedtools coverage -a windows.bed -b /cluster/lab/clevenger/hwright/Sameer_Magic/peanutpan_REFproc/peanutpan.vcf -counts > coverage.txt
(echo -e "chr\tstart\tend\tvariant_count"; cat coverage.txt) > coverage_with_header.txt

#go to R to viualize
#Variant_windows.R
