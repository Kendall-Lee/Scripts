#!/usr/bin/env python3
"""
Callability and concordance analysis of 1x vs full-depth linear hapmaps.

Hapmap format: chr  pos  sample1  sample2 ...
  "-"       = missing
  1 char    = homozygous call (e.g. "A")
  2 chars   = heterozygous call (e.g. "AG", always alphabetically ordered)

Usage:
  python3 callability_concordance_hapmap.py full.hapmap 1x.hapmap -o results.tsv
"""

import argparse
import pandas as pd
import sys

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("full", help="Full-depth hapmap")
    p.add_argument("x1",  help="1x hapmap")
    p.add_argument("-o", "--output", required=True)
    return p.parse_args()

args = parse_args()

# ── read ───────────────────────────────────────────────────────────────────────
print(f"Reading {args.full} ...", flush=True)
full = pd.read_csv(args.full, sep="\t", dtype=str, na_values=["-", ""])
print(f"Reading {args.x1} ...", flush=True)
x1   = pd.read_csv(args.x1,   sep="\t", dtype=str, na_values=["-", ""])

full_samples = list(full.columns[2:])
x1_samples   = list(x1.columns[2:])
shared_samples = [s for s in full_samples if s in set(x1_samples)]
print(f"Full-depth samples : {len(full_samples)}")
print(f"1x samples         : {len(x1_samples)}")
print(f"Shared samples     : {len(shared_samples)}")

only_full = sorted(set(full_samples) - set(x1_samples))
only_x1   = sorted(set(x1_samples)  - set(full_samples))
if only_full: print(f"  Only in full: {only_full}")
if only_x1:   print(f"  Only in 1x  : {only_x1}")

# ── shared sites ───────────────────────────────────────────────────────────────
full["_key"] = full["chr"] + ":" + full["pos"]
x1["_key"]   = x1["chr"]  + ":" + x1["pos"]

shared_keys = set(full["_key"]) & set(x1["_key"])
print(f"\nFull-depth sites : {len(full):,}")
print(f"1x sites         : {len(x1):,}")
print(f"Shared sites     : {len(shared_keys):,}")

full_s = full[full["_key"].isin(shared_keys)].set_index("_key")
x1_s   = x1[x1["_key"].isin(shared_keys)].set_index("_key")
full_s = full_s.loc[sorted(shared_keys)]
x1_s   = x1_s.loc[sorted(shared_keys)]

# ── per-sample analysis ────────────────────────────────────────────────────────
records = []
for samp in shared_samples:
    sf = full_s[samp]
    s1 = x1_s[samp]

    called_full = sf.notna()
    called_1x   = s1.notna()
    co          = called_full & called_1x

    sf_co = sf[co]
    s1_co = s1[co]

    is_het_full = sf_co.str.len() == 2
    is_het_1x   = s1_co.str.len() == 2
    is_hom_full = ~is_het_full
    is_hom_1x   = ~is_het_1x

    match = sf_co == s1_co

    concordant_hom = int((is_hom_full & is_hom_1x &  match).sum())
    concordant_het = int((is_het_full & is_het_1x  &  match).sum())
    dropout        = int((is_het_full & is_hom_1x).sum())
    overcall       = int((is_hom_full & is_het_1x).sum())
    wrong_allele   = int((is_hom_full & is_hom_1x  & ~match).sum())
    het_mismatch   = int((is_het_full & is_het_1x  & ~match).sum())

    full_called = int(called_full.sum())
    x1_called   = int(called_1x.sum())
    co_called   = int(co.sum())
    concordant  = concordant_hom + concordant_het

    callability  = co_called / full_called if full_called else 0
    concordance  = concordant / co_called  if co_called  else 0
    dropout_rate = dropout    / co_called  if co_called  else 0
    wrong_pct    = wrong_allele / co_called * 100 if co_called else 0

    records.append({
        "Sample":          samp,
        "Full_called":     full_called,
        "X1_called":       x1_called,
        "Co_called":       co_called,
        "Callability":     round(callability,  4),
        "Concordance":     round(concordance,  4),
        "Concordant_hom":  concordant_hom,
        "Concordant_het":  concordant_het,
        "Dropout":         dropout,
        "Dropout_rate":    round(dropout_rate, 4),
        "Overcall":        overcall,
        "Wrong_allele":    wrong_allele,
        "Het_mismatch":    het_mismatch,
        "Callability_pct": round(callability  * 100, 4),
        "Concordance_pct": round(concordance  * 100, 4),
        "Dropout_rate_pct":round(dropout_rate * 100, 4),
        "Wrong_allele_pct":round(wrong_pct,          4),
    })

df_out = pd.DataFrame(records)
df_out.to_csv(args.output, sep="\t", index=False)
print(f"\nWrote {args.output}")

# ── pooled totals ──────────────────────────────────────────────────────────────
tot_co   = df_out["Co_called"].sum()
tot_conc = (df_out["Concordant_hom"] + df_out["Concordant_het"]).sum()
tot_drop = df_out["Dropout"].sum()
tot_wa   = df_out["Wrong_allele"].sum()
tot_oc   = df_out["Overcall"].sum()
tot_hm   = df_out["Het_mismatch"].sum()
tot_full = df_out["Full_called"].sum()

print(f"\n── Pooled results ─────────────────────────────────────────────")
print(f"  Full-depth called (shared sites): {tot_full:,}")
print(f"  Co-called                        : {tot_co:,}")
print(f"  Callability (mean)               : {df_out['Callability_pct'].mean():.1f}%")
print(f"  Concordance (pooled)             : {tot_conc/tot_co*100:.1f}%")
print(f"  Dropout rate (pooled)            : {tot_drop/tot_co*100:.1f}%")
print(f"  Wrong allele (pooled)            : {tot_wa/tot_co*100:.1f}%")
non_dropout = tot_co - tot_drop
print(f"  Allele-identity accuracy         : {(tot_conc/(non_dropout))*100:.1f}%  (excl. dropout)")
