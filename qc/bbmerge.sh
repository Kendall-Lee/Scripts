#!/bin/bash
#SBATCH --job-name=bbmerge_@id
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=100gb
#SBATCH --time=04:00:00
#SBATCH --output=stds/bbmerge.@id.%j.out
#SBATCH --error=stds/bbmerge.@id.%j.error

id="@id"
fqdir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/matching_short"
R1="$fqdir"/$id"_R1.fq.gz"
R2="$fqdir"/$id"_R2.fq.gz"

bbmerge.sh in1=$R1 in2=$R2  out=$id.merged.fastq

reformat.sh in=$id.merged.fastq out=$id.merged.fasta

for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/matching_short/*fq.gz | sed 's:_R[12].fq.gz::g' | sed 's:.*/::g'); do cat ./bbmerge.sh| sed "s:@id:$i:g" > bbmerge_"$i".sh; done
