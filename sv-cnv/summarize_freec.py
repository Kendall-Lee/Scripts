import os
import pandas as pd

data_dir = "."  # Change if needed

summary = []

for filename in os.listdir(data_dir):
    if filename.endswith(".bam_info.txt"):
        sample = filename.replace(".bam_info.txt", "")
        info_path = os.path.join(data_dir, filename)
        cnv_path = os.path.join(data_dir, f"{sample}.bam_CNVs")

        baseline_ploidy = "NA"
        cnv_count = 0
        cnv_chroms = set()

        # Parse baseline ploidy
        with open(info_path) as f:
            for line in f:
                if line.startswith("Output_Ploidy"):
                    baseline_ploidy = line.strip().split("\t")[1]
                    break

        # Parse CNVs - count only gains/losses, exclude neutral
        if os.path.exists(cnv_path):
            with open(cnv_path) as f:
                for line in f:
                    if line.startswith("chr") or line.strip() == "":
                        continue
                    parts = line.strip().split("\t")
                    if len(parts) < 5:
                        continue
                    chrom = parts[0]
                    cnv_type = parts[4].lower()
                    if cnv_type != "neutral":
                        cnv_chroms.add(chrom)
                        cnv_count += 1

        cnv_chrom_str = ",".join(sorted(cnv_chroms)) if cnv_count > 0 else "None"

        summary.append({
            "Sample": sample,
            "Baseline_Ploidy": baseline_ploidy,
            "CNV_Count": cnv_count,
            "CNV_Chromosomes": cnv_chrom_str
        })

df = pd.DataFrame(summary)
df = df.sort_values("Sample")
df.to_csv("FreeC_global_summary.csv", index=False)

print("✅ Summary saved to FreeC_global_summary.csv")
