#!/bin/bash
#SBATCH --job-name=minimap_pairs
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=200gb
#SBATCH --time=60:00:00
#SBATCH --output=minimap_hifi.%j.out
#SBATCH --error=minimap_hifi.%j.error
#SBATCH --partition=highmem


ml cluster/minimap2/2.26
ml cluster/samtools/1.16.1

files=(Chr.01.1.fa Chr.01.2.fa Chr.01.3.fa Chr.01.4.fa)

for i in "${files[@]}"; do
  for j in "${files[@]}"; do
    if [[ "$i" != "$j" ]]; then
      base_i="${i%.fa}"
      base_j="${j%.fa}"
      bam="${base_i}_vs_${base_j}.sorted.bam"

      echo "Aligning $i vs $j"
      minimap2 -ax asm5 --eqx "$i" "$j" | samtools sort -@ 8 -o "$bam"
      samtools index "$bam"
    fi
  done
done


      echo "Running SyRI for $base_i vs $base_j"
      syri -c "$bam" -r "$i" -q "$j" -F B --prefix "${base_i}_vs_${base_j}"
    fi
  done
done
