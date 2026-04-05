#!/bin/bash
#SBATCH -J qtlvar_test
#SBATCH --time=96:00:00
#SBATCH -c 4
#SBATCH -N 1
#SBATCH -p khufu
#SBATCH -o "stds/stdout_qtlvar_test%x_%J"
#SBATCH -e "stds/stderr_qtlvar_test_%x_%J"
#SBATCH --mem="200G"
##################

# cat /cluster/home/zmyers/khufu_runscripts/qtlvartemplate.sh | sed "s:@proj::g; s:@ptype::g" > qtlvar_@ptype.sh

khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
"$khufu_dir"/11_QTLvarIB.sh \
-t 4 \
-o qtlvar_test \
-Hlist high.list \
-Llist low.list \
-bams /cluster/home/klee/raw_data/bams \
-n 5 \
-bulkN 20
