#!/bin/bash
#SBATCH --job-name=pbmm2
#SBATCH -e pbsv_%J.err
#SBATCH -o pbsv_%J.out
#SBATCH --time=144:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=256G
#SBATCH --partition=plant


ml cluster/singularity/3.11.0
# id="@id"
# fqdir="/cluster/lab/clevenger/KLee/Blueberry_HiFi_data/LRLP_blueberry"
ref="/cluster/lab/clevenger/KLee/Horse/chr18.fasta"
query="/cluster/lab/clevenger/VPerez/Horse_Assembly/HA_2/Horse_Assembly_ragtag_new/ragtag.scaffold.fasta"
pre="RemiScaffoldChr18.pbmm2"
# bed=""

###run pbmm to map read to reference
singularity exec --containall --bind /cluster:/cluster docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 pbmm2 align $ref $query $pre.bam --sort -j 32 --preset HIFI --sample sample1 --rg '@RG\tID:movie1'

# #run pbsv disocover
singularity exec --containall --bind /cluster:/cluster docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 pbsv discover $pre.bam $pre.svsig.gz
#
# #run pbsv call
singularity exec --containall --bind /cluster:/cluster  docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 pbsv call $ref $pre.svsig.gz $pre.sorted.vcf



########## creating the sbatch files ########

for i in $( ls /cluster/lab/clevenger/KLee/Blueberry_HiFi_data/LRLP_blueberry/*gz | xargs -n1 basename | sed "s:\.fastq\.gz$::"
); do cat ./PBMM/pbmm2.sh | sed "s:@id:$i:g" > pbmm2."$i".sh; done
