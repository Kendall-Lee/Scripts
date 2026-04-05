
khufu_dir="/cluster/projects/khufu/qtl_seq_II/khufu_II"
source "$khufu_dir"/utilities/load_modules.sh
source /cluster/projects/khufu/korani_projects/KhufuEnv/KhufuEnv.sh

cat Fruit_QTLvar.txt.txt | sed 1d | cut -f1-2 | awk '$1 == "Chr.04" && $2 >= 27500000 && $2 >= 32500000' > qtl.bed

sed -e "s|@phenos|FruitWTphenos.txt|g" -e "s|@hapmap|SHB_Smiss0.8_miss0.8_maf0.1.hapmap|g" -e "s|@bed|qtl.bed|g" -e "s|@out|FruitWT_Chr.04_OG|g" PVE.R > PVE_OG_run.R

Rscript PVE_run.R
