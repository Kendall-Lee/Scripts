#!/bin/bash
#SBATCH -J pbsv
#SBATCH --time=96:00:00
#SBATCH -c 12
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o stdout_pbsv
#SBATCH -e stderr_pbsv
#SBATCH --mem="200G"


ml cluster/singularity/3.11.0

id="@id"
fqdir="/cluster/lab/clevenger/KLee/LongPlex_Analysis/fastqs/"
ref="/cluster/lab/clevenger/KLee/PacBio_project/ref.fa"
query="$fqdir"/$id".fastq.gz"
pre=$id".pbmm"
bed="/cluster/home/klee/TRF/build/ref.TRF.bed"

###run pbmm to map read to reference
#singularity exec --containall --bind /cluster:/cluster  docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 pbmm2 align $ref $query /cluster/lab/clevenger/KLee/Wiregrass_LRLP/SV_files/$pre.bam --sort -j 32 --preset HIFI --sample sample1 --rg '@RG\tID:movie1'

#singularity exec --containall --bind /cluster:/cluster docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 pbsv discover --tandem-repeats $bed /cluster/lab/clevenger/KLee/LongPlex_Analysis/pbsv/@id.pbmm.bam @id.svsig.gz


singularity exec --containall --bind /cluster:/cluster  docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 pbsv call $ref /cluster/lab/clevenger/KLee/LongPlex_Analysis/pbsv/@id.svsig.gz /cluster/lab/clevenger/KLee/LongPlex_Analysis/pbsv/@id.pbmm.sorted.vcf --ccs


######PRepping Sbatch
for i in $(ls /cluster/lab/clevenger/KLee/LongPlex_Analysis/pbsv/*bam | sed "s:.pbmm.bam::g; s:.*/::g"); do cat pbsv_call.sh | sed "s:@id:$i:g" > pb_discover_"$i".sh; done

################## test run July 2024######################
#!/bin/bash
#SBATCH -J pbmm2_24.CA.D10.F1.22
#SBATCH --time=96:00:00
#SBATCH -c 32
#SBATCH -N 2
#SBATCH -p highmem
#SBATCH -o stdout_pbmm2
#SBATCH -e stderr_pbmm2
#SBATCH --mem="400G"


ml cluster/singularity/3.11.0

query="/cluster/lab/clevenger/KLee/Wiregrass_LRLP/Raw_fastqs/24.CA.D10.F1.22.PB.fastq.gz"
ref="/cluster/lab/clevenger/KLee/PacBio_project/ref.fa"
bed="/cluster/home/klee/TRF/build/ref.TRF.bed"

###run pbmm to map read to reference
#singularity exec --containall --bind /cluster:/cluster docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 pbmm2 align $ref $query ./24.CA.D10.F1.22.PB.pbmm.bam --sort --preset CCS --sample sample1 --r$

#run pbsv disocover
singularity exec --containall --bind /cluster:/cluster docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 pbsv discover --tandem-repeats $bed /cluster/lab/clevenger/KLee/Wiregrass_LRLP/SV_files/WG_pop/24.CA.D10.F1.22.PB.pbmm.bam /cluster/lab/clevenger/KLee/Wiregrass_LRLP/SV_files/WG_pop/24.CA.D10.F1.22.TRF.PB.svsig.gz

#run pbsv call
singularity exec --containall --bind /cluster:/cluster  docker://harbor.apps.haib.org/bioinformatics/smrtlink:1.0.0 pbsv call $ref /cluster/lab/clevenger/KLee/Wiregrass_LRLP/SV_files/WG_pop/24.CA.D10.F1.22.TRF.PB.svsig.gz 24.CA.D10.F1.22.TRF.PB.pbmm.sorted.vcf
