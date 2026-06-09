#!/usr/bin/env python3
"""
Replicate khufu 09 filtering on a panmap file produced by khufu 03.

Filters applied (in order):
  1. Smiss  -- drop samples where missingness > threshold (default 0.8)
  2. miss   -- drop sites where missingness > threshold among retained samples (default 0.8)
  3. MAF    -- drop sites where minor allele frequency < threshold (default 0.1)
              (diploid assumption: hom = 2 allele copies, het = 1 copy each allele)

Usage:
  python3 filter_panmap.py input.panmap -o output.panmap [--Smiss 0.8] [--miss 0.8] [--maf 0.1]
"""

import argparse
import pandas as pd
import numpy as np

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("input")
    p.add_argument("-o", "--output", required=True)
    p.add_argument("--Smiss", type=float, default=0.8, help="max per-sample missingness")
    p.add_argument("--miss",  type=float, default=0.8, help="max per-site missingness")
    p.add_argument("--maf",   type=float, default=0.1, help="min minor allele frequency")
    return p.parse_args()

args = parse_args()

# ── read ───────────────────────────────────────────────────────────────────────
print(f"Reading {args.input} ...", flush=True)
df = pd.read_csv(args.input, sep="\t", dtype=str, na_values=["-", ""])
meta_cols    = list(df.columns[:4])
sample_cols  = [c for c in df.columns[4:] if c and not c.startswith("Unnamed")]
print(f"  {len(df):,} sites  |  {len(sample_cols)} samples")

# ── step 1: Smiss ──────────────────────────────────────────────────────────────
miss_per_sample = df[sample_cols].isna().mean()
keep_samples = miss_per_sample[miss_per_sample <= args.Smiss].index.tolist()
dropped = sorted(set(sample_cols) - set(keep_samples))
print(f"\nSmiss ≤ {args.Smiss}:")
if dropped:
    for s in dropped:
        print(f"  dropped {s}  (missingness = {miss_per_sample[s]:.3f})")
else:
    print(f"  all {len(sample_cols)} samples retained")
print(f"  {len(keep_samples)} samples retained")

# ── step 2: site missingness ───────────────────────────────────────────────────
site_miss = df[keep_samples].isna().mean(axis=1)
keep_miss  = site_miss <= args.miss
n_drop_miss = (~keep_miss).sum()
df = df[keep_miss].copy()
print(f"\nmiss ≤ {args.miss}:  dropped {n_drop_miss:,} sites  |  {len(df):,} remaining")

# ── step 3: MAF ───────────────────────────────────────────────────────────────
# Build per-site allele counts vectorially, one sample at a time to save memory.
# Diploid assumption: hom call = 2 copies of that allele; het = 1 copy each allele.
# MAF = (total alleles - count of most common allele) / total alleles

print(f"\nMAF ≥ {args.maf}:  computing allele frequencies ...", flush=True)

# One-pass discovery of unique allele values
unique_alleles = set()
for s in keep_samples:
    for val in df[s].dropna().unique():
        for a in str(val).split(","):
            unique_alleles.add(a)
print(f"  unique allele values: {sorted(unique_alleles)}")

# Accumulate allele counts per site, one sample at a time
allele_counts = pd.DataFrame(
    0, index=df.index, columns=sorted(unique_alleles), dtype=np.int32
)

for s in keep_samples:
    parts   = df[s].str.split(",", expand=True)
    a0      = parts[0]
    a1      = parts[1] if 1 in parts.columns else pd.Series(np.nan, index=parts.index)
    is_het  = a1.notna()

    for a in unique_alleles:
        hom_a = (a0 == a) & ~is_het          # hom call → +2
        het_a = ((a0 == a) | (a1 == a)) & is_het  # het call → +1
        allele_counts[a] += (2 * hom_a.fillna(False).astype(np.int32)
                             +   het_a.fillna(False).astype(np.int32))
    del parts, a0, a1, is_het  # free memory before next sample

total  = allele_counts.sum(axis=1)
top1   = allele_counts.max(axis=1)
maf_s  = (total - top1) / total.replace(0, np.nan)
maf_s  = maf_s.fillna(0)

keep_maf   = maf_s >= args.maf
n_drop_maf = (~keep_maf).sum()
df = df[keep_maf]
print(f"  dropped {n_drop_maf:,} sites  |  {len(df):,} remaining")

# ── write output ───────────────────────────────────────────────────────────────
out_cols = meta_cols + keep_samples
df[out_cols].to_csv(args.output, sep="\t", index=False, na_rep="-")
print(f"\nWrote {len(df):,} sites × {len(keep_samples)} samples → {args.output}")
