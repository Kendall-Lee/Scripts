#!/bin/bash
#SBATCH -J @code_spartan
#SBATCH --time=96:00:00
#SBATCH -c 20
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_spartan_%x_%J"
#SBATCH -e "stds/stderr_spartan_%x_%J"
#SBATCH --mem="200G"

# cat /cluster/home/zmyers/khufu_runscripts/spartantemplate.sh | sed "s:@proj::g; s:@code::g" > spartan.sh

khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"

### SpartanV
"$khufu_dir"/utilities/spartanV.sh \
--hap /cluster/lab/clevenger/KLee/Wiregrass_LRLP/Short_linear/Wiregrass_short_linear_09.hapmap\
--sim 0.9 \
--fill true

### SpartanIII
#"$khufu_dir"/spartan/run_spartan.sh \
#-hap /cluster/projects/khufu/qtl_seq_II/PROC/@proj/hapmaps/@proj.hapmap \
#-bams /cluster/projects/khufu/qtl_seq_II/PROC/@proj/bams \
#-t 20 \
#-pos 5 \
#-het 0.6 \
#-K 8 nGen 100 \
#-Eval TRUE \
#-Imp TRUE
