#!/bin/bash
#SBATCH -J Cactus
#SBATCH --time=96:00:00
#SBATCH -c 24
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o stdout_cactus
#SBATCH -e stderr_cactus
#SBATCH --mem="200G"

module load cluster/singularity/3.11.0

singularity exec --containall --bind /cluster:/cluster docker://quay.io/comparative-genomics-toolkit/cactus:v2.5.1 cactus-pangenome /scratch/lab/clevenger/CactusJobStoreC431 /cluster/home/klee/cactus_config.txt --outDir /cluster/home/klee --reference TRv2 --outName Tifrunner2C431 --vcf --giraffe --gfa --workDir /cluster/home/klee


module load cluster/singularity/3.11.0
singularity exec --containall --bind /cluster:/cluster docker://quay.io/comparative-genomics-toolkit/cactus:v2.5.1 \
cactus-pangenome "$workDir"/JS_"$PanID" $seqfile --outDir "$workDir"/"$PanID"OUT --outName $PanID --reference $refGen --vcf --giraffe --gfa --gbz --workDir "$workDir"/
cactus-pangenome “$workDir”/JS_“$PanID” $seqfile --outDir “$workDir”/“$PanID”OUT --outName $PanID --reference $refGen --vcf --giraffe --gfa --gbz --workDir “$workDir”/
workDir & seqfile files are included the full physical path

cd P
