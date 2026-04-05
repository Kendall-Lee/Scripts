#!/bin/bash
#SBATCH -J minimap_@id
#SBATCH --time=96:00:00
#SBATCH -c 20
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="300G"

module load cluster/minimap2

fqdir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/LRLP_renamed"
id="@id"
query="$fqdir"/$id".PB.fastq.gz"
ref="/cluster/lab/clevenger/hwright/Sameer_Magic/final_asm/CC477final.fa"


minimap2 -ax asm20 $ref $query > $id.CC477.minimap.bam



# Collect primary alignment lines in the forward (0) or negative (16) direction
awk '$2 == 0 || $2 == 16' NC_XXXlp_insert_aln.sam > NC_XXXlp_insert_aln_mapped.sam

# Collect the primary alignments that reside on Chr.01
grep chr12 W.2024.SP.CA.D10.F1.22.CC477_aln.mapped.sam > W.2024.SP.CA.D10.F1.22.CC477_aln.mapped.ch12.sam


#QTL bed file interval- 1700000	2700000
#indel location from hallie -1508691
# Collect primary alignments on Chr.01 that are between 12.4 Mb and 12.6 Mb
awk '$4 >= 1508000 && $4 <= 1509000' W.2024.SP.CA.D10.F1.22.CC477_aln.mapped.ch12.sam > W.2024.SP.CA.D10.F1.22.CC477_aln.mapped.insertionregion.sam

# Collect the primary alignments around the insertion region and print map score,  position, length of read, and alignment discrepancies (2 columns)
awk '{print $2, $4, length($10), $21, $22}' NC_XXXlp_insert_aln_mapped_chr01_insertregion.sam > NC_XXXlp_insert_aln_mapped_chr01_insertregion_loclength

# The output from the previous command will generate a file like this, it will be much larger
map_Q
position
length of read
alignment stats
alignment stats
0
12400390
1023
cs:Z::1023
rl:i:0
0
12403863
1849
cs:Z::583+at:781-a:123+ta:358
rl:i:316

From here either coverage of the region can be determined if trying to find the presence of a large variant as in the case of TSWV insertion.

Or for calligng a small variant or SNP use the alignment stats that start with cs:Z:. If there is a read that differs from the reference it will be noted as a "+" meaning insertion, "-" meaning deletion, and * meaning SNP. (i.e. "+at" is "at" insertion, "-a" is an "a" deletion, "*ct" is a "c" in the reference that is a "t" in the read). Numbers in between indicate matching bases.

So if there is a specific small InDel or SNP that needs to be identified I would suggest taking out the region around the variant but far enough away where the read will be collected since the read position is based on the first read base that can be a significant distance from the variant itself.
