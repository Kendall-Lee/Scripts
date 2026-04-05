#!/bin/bash
#SBATCH -J vg_giraffe
#SBATCH --time=96:00:00
#SBATCH -c 32
#SBATCH -N 2
#SBATCH -p highmem
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="300G"

ml cluster/vg/1.54.0

t="2"
id="test_24.CA.D10.F1.22"
bams="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Pan_work/Parent_graph/bams/"

vg giraffe -t $t -Z /cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/Wiregrasspan_Kendall/Wiregrasspan_Kendall.gfa.giraffe.giraffe.gbz -d /cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/Wiregrasspan_Kendall/Wiregrasspan_Kendall.gfa.giraffe.dist -m /cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/Wiregrasspan_Kendall/Wiregrasspan_Kendall.gfa.giraffe.min -f /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Pan_work/Parent_graph/bams/24.CA.D10.F1.22_masked_1.fq.gz > test_24.CA.D10.F1.22.gam

vg filter -t $t --min-mapq 60 "$bams"/"$id".gam > "$bams"/"$id".mq60.gam
vg pack -t $t -x "$gfa".giraffe.giraffe.gbz -g "$bams"/"$id".mq60.gam -D | gzip > "$bams"/"$id".mq60.pack.edge.table.gz
###
$gfa_var_genotyper -v $VCF -p "$bams"/"$id".mq60.pack.edge.table.gz -l $id --rm_inv_head --ploidy 1 --low_cov --min_tot_cov 1 > "$bams"/"$id".vcf
