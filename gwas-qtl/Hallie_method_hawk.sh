
create loci file cat LRLPPan_Smiss1_miss0.95_maf0.01.panmap | cut -f1,2 | grep "chr01" | awk '{if ($2 >= 11603876 && $2 <= 12303500) print $0}' > TSWV_LR_selected_regions.txt

based off of QTL.bed file /cluster/projects/khufu/korani_projects/LRLPII/qtlNew.bed



#######################################################
#####run python script###########

#!/usr/bin/env python3
import sys

# ---- User inputs ----
panmap_file = "LRLPPan_Smiss1_miss0.95_maf0.01.panmap"
loci_file   = "TSWV_LR_selected_regions.txt"

# Which parent in the comma‑separated parental genotype list to use:
#C431,CB7,CC477,CC812,Florida07,GA12Y,GPNCWS17,Georganic,
# IAC322,Lariat,Marc1,NC94022,TifNV,York
# 0 = C431, 1 = CB7, etc.
PARENT_INDEX = 14  # <‑‑ change as needed

# ---- Read list of loci to keep ----
locus_set = set()
with open(loci_file, 'r') as lf:
    for line in lf:
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) >= 2:
            chrom = parts[0].replace("Chr", "chr")
            pos   = parts[1].lstrip("0")
            locus_set.add((chrom, pos))

# ---- Process the panmap file ----
with open(panmap_file, 'r') as f:
    header = f.readline().strip().split()
    # samples begin after col 4 (0‑based index 4 == 5th column)
    sample_names = header[4:]
    match_counts = {sample: 0 for sample in sample_names}
    total_counts = {sample: 0 for sample in sample_names}

    for line in f:
        parts = line.strip().split()
        if len(parts) < 5:
            continue
        chrom = parts[0].replace("Chr", "chr")
        pos   = parts[1].lstrip("0")

        # keep only selected loci
        if (chrom, pos) not in locus_set:
            continue

        pangeno_genotypes = parts[3].split(",")
        if len(pangeno_genotypes) <= PARENT_INDEX:
            continue  # not enough parent entries

        parent_call = pangeno_genotypes[PARENT_INDEX]

        for i, sample in enumerate(sample_names):
            sample_call = parts[4 + i]

            # ---- Skip missing values (corrected condition) ----
            if sample_call == "-" or parent_call == "0":
                continue

            parent_alleles = set(parent_call.split(","))
            sample_alleles = set(sample_call.split(","))

            # Count a match if they share at least one allele
            if parent_alleles & sample_alleles:
                match_counts[sample] += 1
            total_counts[sample] += 1

# ---- Output results ----
print("Sample\t%_Similarity\tMatched_Loci\tTotal_Loci")
for sample in sample_names:
    total = total_counts[sample]
    matched = match_counts[sample]
    percent = (matched / total * 100) if total > 0 else 0
    print(f"{sample}\t{percent:.2f}\t{matched}\t{total}")
