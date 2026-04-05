awk 'NR>1 {printf "%s\t%d\t%d\n",$1,$2,$2}' file1.panmap > f1.bed
awk 'NR>1 {printf "%s\t%d\t%d\n",$1,$2,$2}' file2.panmap > f2.bed

ml cluster/bedtools/2.28.0

bedtools intersect -a f1.bed -b f2.bed -wa | sort -u > overlap_sites.bed
