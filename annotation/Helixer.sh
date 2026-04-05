#!/bin/bash
#SBATCH -J Helixer
#SBATCH --time=96:00:00
#SBATCH -c 8
#SBATCH -N 1
#SBATCH -p highmem
#SBATCH -o "stds/stdout_helixer"
#SBATCH -e "stds/stderr_helixer"
#SBATCH --mem="300G"
#SBATCH --mail-user=klee@hudsonalpha.org
#SBATCH --mail-type=END,FAIL

module load cluster/singularity/3.11.0

#singularity exec --nv --bind /cluster:/cluster docker://gglyptodon/helixer-docker:latest Helixer.py --fasta-path Suziblue_renamed_reordered.fa.mod.MAKER.masked.gz --gff-output-path Suziblue_helixer.gff3 --lineage land_plant --compression lzf


singularity exec --nv -B /cluster -B "/cluster/home/ethompson/genetree/helixer/TR/HelixerPost/target/release:/helixerpost" --env PATH="/helixerpost:$PATH" docker://gglyptodon/helixer-docker:latest Helixer.py --fasta-path Suziblue_renamed_reordered.fa.mod.MAKER.masked.gz --gff-output-path Suziblue_helixer.gff3 --lineage land_plant


#################################################################################

eval "$(conda shell.bash hook)"
source /cluster/home/klee/miniforge3/etc/profile.d/conda.sh
conda activate /cluster/home/klee/miniforge3/envs/helixer


/cluster/home/klee/Helixer/Helixer.py \
  --fasta-path Suziblue_renamed_reordered.fa.mod.MAKER.masked.gz \
  --gff-output-path Suziblue_helixer.gff3 \
  --lineage land_plant \
  --compression lzf
