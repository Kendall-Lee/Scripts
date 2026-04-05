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

#fqdir="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/LRLP_renamed"
id="TRv2_control"
query="Trv2Chr1.fa"
ref="TSWV_region_compare.fa"


minimap2 -ax asm20 $ref $query > $id.TSWV_region_compare.minimap.bam



for i in $(ls /cluster/lab/clevenger/KLee/Wiregrass_LRLP/LRLP_renamed/*fastq.gz | sed "s:.PB.fastq.gz::g; s:.*/::g"); do cat ./minimap.sh| sed "s:@id:$i:g" > minimap"$i".sh; done
