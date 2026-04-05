#!/bin/bash
#SBATCH --job-name=liftoff
#SBATCH -e Liftoff_%J.err
#SBATCH -o Liftoff_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=256G
#SBATCH --partition=normal

#go to /cluster/home/klee/liftoff
#conda activate liftoff
source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/anaconda3/envs/liftoff

# id="B080_hap1"
# #fqdir="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Final_assemblies"
# target="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/B080_hap1.fa"
# reference="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Draper/V_corymbosum_genome_Draper_v1.0-scaffolds.fasta"
# liftoff -g /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Draper/V_corymbosum_Draper_v1.0-geneModels-nameTruncated.gff $target $reference -o $id.gff


#to obtain peptide files use gffread
/cluster/home/klee/gffread/gffread /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/Liftoff/B080_hap1.gff -g /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/B080/B080_hap1.fa -o B080_hap1.gffread.gff3 --keep-genes -y B080_hap1_peptides.fasta

/cluster/home/klee/gffread/gffread \
  mikado.loci.gff3 \
  -g /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Suziblue/Final_Assembly/Suziblue_Full.fa \
  -o Suziblue.hap1.denovo.gffread.gff3 \
  --keep-genes \
  -y Suziblue.hap1.denovo.peptides.fasta

for i in $(ls /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/Final_assemblies/*.fa | sed "s:.*/::; s:.fa::g"); do cat ./liftoff.sh | sed "s:@id:$i:g" > liftoff_"$i".sh; done
