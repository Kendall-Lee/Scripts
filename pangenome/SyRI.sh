#!/bin/bash
#SBATCH --job-name=syri
#SBATCH -e Liftoff_%J.err
#SBATCH -o Liftoff_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=256G
#SBATCH --partition=plant

#ml cluster/samtools/1.16.1
#query
query="ragtag.scaffold.filtered.fasta"
#indexed reference
ref='TB-T2T_genomic.filtered.noMT.fna'
#prefix
pre="HorseRagtagtoRef"

#load bwa
ml cluster/minimap2/2.26
# #map
minimap2 -ax asm5 --eqx $ref $query > $pre.sam
 #samtools view -h -o $pre.sam > $pre.sorted.bam

# conda activate /cluster/home/klee/anaconda3/envs/syri_env

syri -c $pre.sam -r $ref -q $query -k -F S --prefix $pre
plotsr --sr HorseRagtagtoRefsyri.out --genome genomepaths.txt -H 5 -W 10 -o HorseRagtagtoRefsyri.pdf



plotsr --sr Chr.02.1_vs_2.2syri.out --genome genomepaths.txt -H 5 -W 5 --markers Chr02.1v02.4.C.ms3.fixed2.bed -o Chr02.1v02.4

###genomepaths.txt looks like
# ./Chr.02.4.fa	Chr.02.4
# ./Chr.02.1.fa	Chr.02.1


#marker file looks like
#chrom      start     end      genome_id  tags
# Chr.02.1	36708935	36731418	Chr.02.1	ms:3;tp:0;mc:black
# Chr.02.1	9698356	9719814	Chr.02.1	ms:3;tp:0;mc:black
# Chr.02.4	18130896	18146234	Chr.02.4	ms:3;tp:0;mc:black
# Chr.02.4	38119300	38137943	Chr.02.4	ms:3;tp:0;mc:black
# Chr.02.1	30245094	39681278	Chr.02.1	ms:3;tp:0;mc:black
# Chr.02.4	12824600	12847080	Chr.02.4	ms:3;tp:0;mc:black
# Chr.02.1	54086284	54098917	Chr.02.1	ms:3;tp:0;mc:black
# Chr.02.4	38119300	38137943	Chr.02.4	ms:3;tp:0;mc:black
# Chr.02.4	42999617	43012101	Chr.02.4	ms:3;tp:0;mc:black
# Chr.02.4	15680348	15692768	Chr.02.4	ms:3;tp:0;mc:black
