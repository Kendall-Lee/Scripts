#SeqFileA
TRref	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanut_hypogaea2/ref.fa
Bailey	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/Bailey/Bailey.fa
C431	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/C431/C431.fa
C99R	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/C99R/C99R.fa
CC41	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/CC41/CC41.fa
TR	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanut_hypogaea2/ref.fa

#SeqFileB
TRref	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanut_hypogaea2/ref.fa
CC477	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/CC477/CC477.fa
CC812	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/CC812/CC812.fa
Florida07	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/Florida07/Florida07.fa
GA12Y	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/GA12Y/GA12Y.fa

#SeqFileC
TRref	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanut_hypogaea2/ref.fa
Georganic	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/Georganic/Georganic.fa
GPNCWS17	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/GP.NC.WS.17/GP.NC.WS.17.fa
IAC322	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/IAC322/IAC322.fa
ICG1471	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/ICG1471/ICG1471.fa
Lariat	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/Lariat/Lariat.fa
Marc1	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/Marc1/Marc1.fa

#SeqFileD
TRref	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanut_hypogaea2/ref.fa
NC94022	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/NC94022/NC94022.fa
NMValA	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/NMValA/NMValA.fa
TifNV	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/TifNV/TifNV.fa
Wildseq	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/Wildseq/Wildseq.fa
York	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/MGCParent_Progenitor_Scaffold/York/York.fa
CarTRsynth	/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/CarTR_synthetic/CarTRsynth.fa

#!/bin/bash
#SBATCH -J PanRef
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_%x_%J"
#SBATCH -e "stds/stderr_%x_%J"
#SBATCH --mem="384G"
###############
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
seqfile="/cluster/projects/khufu/qtl_seq_II/ref_genomes/peanutPAN_refs/SeqFile_Kendall.txt"
t=12
refGen="TRref"
PanID="Wiregrasspan_Kendall"
###
mkdir -p stds;  "$khufu_dir"/khufuPAN/ref.sh -PanID $PanID -seqfile $seqfile -refGen $refGen -t $t
"$khufu_dir"/khufuPAN/gfa.sh -gfa ""$PanID"OUT/"$PanID".gfa" -t "$t"
