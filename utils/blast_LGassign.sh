#!/bin/bash
#SBATCH -J blast_@id
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_blast_@id"
#SBATCH -e "stds/stderr_blast_@id"
#SBATCH --mem="200G"

ml samtools/1.19.2-gcc-13.1.0
ml cluster/blast/2.9.0

# id="@id"
# fqdir="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B791"
#
# #samtools fasta "$fqdir"/"$id".bam > $id.fasta

#query="$id".fasta

#makeblastdb -in B791_redo.asm.hic.p_utg.fa -dbtype nucl

blastn -query Blueberry_Markers.clean.fasta -db B791_redo.asm.hic.p_utg.fa  -outfmt 6 -evalue 1e-10 -out blast_hits.tsv

# the above command gives a table like :
#marker_id  unitig_id  %identity  aln_length  mismatches  gap_opens  q_start  q_end  s_start  s_end  evalue  bit_score

###### relate blast table to linkage group #
# Create a lookup file: marker name → linkage group
awk -F"\t" 'NR>1 && $1 != "" {print $2"\t"$7}' Blueberry_Markers.tsv > marker_to_LG.tsv
# $2 = Marker Name, $7 = Linkage Group

# Join with BLAST output (assuming query is marker name)
awk 'FNR==NR {lg[$1]=$2; next} {print $0 "\t" lg[$1]}' marker_to_LG.tsv blast_results.tsv > blast_with_LG.tsv

#keeps the highest scoring based on bit score per unitigsawk '{
awk '{
  if (!($2 in best) || $12 > best[$2]) {
    best[$2] = $12;
    line[$2] = $0;
  }
}
END {
  for (s in line) print line[s];
}' blast_output.tsv > best_per_unitig.tsv



 #append LG to the filtered sets
 awk 'FNR==NR {lg[$1]=$2; next} {print $0, lg[$1]}' marker_to_LG.tsv best_per_unitig.tsv > best_hits_with_LG.tsv

#sort by LG
sort -k13 best_hits_with_LG.tsv > best_hits_with_LG.sorted.tsv

#extract only IDs
awk '{print $2"\t"$13}' best_hits_with_LG.sorted.tsv > unitig_to_LG.tsv

#extract per LG
awk '$2=="LG09"{print $1}' unitig_to_LG.tsv > LG09_unitigs.txt

#make fasta file for each linkage group set
/cluster/home/klee/seqtk/seqtk subseq B791_redo.asm.hic.p_utg.fa LG12_unitigs.txt > LG12_unitigs.fasta





##############
for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/SV_files/BAM_files/*pbmm_TRv2Chr01.bam | sed 's:.*/::g'| sed 's:.bam::g'); do cat ./blast.sh | sed "s:@id:$i:g" > blast_"$i".sh; done
