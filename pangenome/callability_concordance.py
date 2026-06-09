#!/usr/bin/env python3
"""
Compute callability and concordance between 1x and full-depth panmap files.

Callability  = fraction of full-depth-called sites that also have a call at 1x
               (per sample, among shared sites)
Concordance  = fraction of co-called sites where allele calls agree,
               broken down into:
                 concordant_hom   both hom, same allele
                 concordant_het   both het, same alleles
                 dropout          full-depth het → 1x hom  (allele dropout)
                 overcall         full-depth hom → 1x het
                 wrong_allele     both hom, different alleles
                 het_mismatch     both het, different alleles
"""

import sys
import pandas as pd
import numpy as np

# ── file paths ─────────────────────────────────────────────────────────────────
PATH_1X   = "1xfounders_min1.panmap"
PATH_FULL = "full_founders_min1.panmap"

if len(sys.argv) == 3:
    PATH_1X, PATH_FULL = sys.argv[1], sys.argv[2]

# ── read files ─────────────────────────────────────────────────────────────────
print("Reading 1x file …", flush=True)
df1 = pd.read_csv(PATH_1X,   sep="\t", dtype=str, na_values=["-", ""])
print(f"  {len(df1):,} sites  |  {len(df1.columns)-4} sample columns")

print("Reading full-depth file …", flush=True)
dff = pd.read_csv(PATH_FULL, sep="\t", dtype=str, na_values=["-", ""])
print(f"  {len(dff):,} sites  |  {len(dff.columns)-4} sample columns")

# ── identify shared samples ────────────────────────────────────────────────────
samples_1x   = [c for c in df1.columns[4:]  if c and not c.startswith("Unnamed")]
samples_full = [c for c in dff.columns[4:] if c and not c.startswith("Unnamed")]
shared = sorted(set(samples_1x) & set(samples_full))
only_1x   = sorted(set(samples_1x)   - set(samples_full))
only_full = sorted(set(samples_full) - set(samples_1x))

print(f"\nShared samples ({len(shared)}):    {', '.join(shared)}")
if only_1x:
    print(f"Only in 1x   ({len(only_1x)}):    {', '.join(only_1x)}")
if only_full:
    print(f"Only in full ({len(only_full)}):    {', '.join(only_full)}")

# ── align on chr + pos ────────────────────────────────────────────────────────
df1  = df1.set_index(["chr", "pos"])
dff  = dff.set_index(["chr", "pos"])

shared_sites = df1.index.intersection(dff.index)
only_full_sites = len(dff) - len(shared_sites)
only_1x_sites   = len(df1)  - len(shared_sites)

print(f"\nSite universe")
print(f"  Shared sites:          {len(shared_sites):>12,}")
print(f"  Sites only in full:    {only_full_sites:>12,}")
print(f"  Sites only in 1x:      {only_1x_sites:>12,}")

df1s = df1.loc[shared_sites, [s for s in shared if s in df1.columns]]
dffs = dff.loc[shared_sites, [s for s in shared if s in dff.columns]]

# ── per-sample stats ──────────────────────────────────────────────────────────
def is_het(s):
    """Boolean Series: True where call is heterozygous (contains comma)."""
    return s.str.contains(",", na=False)

results = []
for sample in shared:
    s1 = df1s[sample]
    sf = dffs[sample]

    co = sf.notna() & s1.notna()

    full_called = int(sf.notna().sum())
    x1_called   = int(s1.notna().sum())
    co_called   = int(co.sum())

    # zygosity masks (within co-called sites only)
    sf_het = co & is_het(sf)
    sf_hom = co & ~is_het(sf)
    s1_het = co & is_het(s1)
    s1_hom = co & ~is_het(s1)

    match = co & (sf == s1)

    concordant_hom  = int((sf_hom & s1_hom &  match).sum())
    concordant_het  = int((sf_het & s1_het &  match).sum())
    dropout         = int((sf_het & s1_hom        ).sum())  # het → hom
    overcall        = int((sf_hom & s1_het        ).sum())  # hom → het
    wrong_allele    = int((sf_hom & s1_hom & ~match).sum())
    het_mismatch    = int((sf_het & s1_het & ~match).sum())

    concordant  = concordant_hom + concordant_het
    callability = co_called / full_called if full_called > 0 else float("nan")
    concordance = concordant / co_called  if co_called  > 0 else float("nan")
    dropout_rate = dropout   / co_called  if co_called  > 0 else float("nan")

    results.append(dict(
        Sample          = sample,
        Full_called     = full_called,
        X1_called       = x1_called,
        Co_called       = co_called,
        Callability     = callability,
        Concordance     = concordance,
        Concordant_hom  = concordant_hom,
        Concordant_het  = concordant_het,
        Dropout         = dropout,
        Dropout_rate    = dropout_rate,
        Overcall        = overcall,
        Wrong_allele    = wrong_allele,
        Het_mismatch    = het_mismatch,
    ))

res = pd.DataFrame(results)

# ── overall (pooled) ──────────────────────────────────────────────────────────
total_full = res["Full_called"].sum()
total_co   = res["Co_called"].sum()
totals = {c: res[c].sum() for c in
          ["Co_called", "Concordant_hom", "Concordant_het",
           "Dropout", "Overcall", "Wrong_allele", "Het_mismatch"]}
overall_concordance = (totals["Concordant_hom"] + totals["Concordant_het"]) / total_co
overall_callability = total_co / total_full
overall_dropout     = totals["Dropout"] / total_co

# ── summary table ─────────────────────────────────────────────────────────────
W = 110
print("\n" + "─" * W)
print(f"{'Sample':<20} {'Full_called':>12} {'1x_called':>10} {'Co_called':>10} "
      f"{'Callability':>12} {'Concordance':>12} {'Dropout%':>10}")
print("─" * W)
for r in results:
    print(f"{r['Sample']:<20} {r['Full_called']:>12,} {r['X1_called']:>10,} "
          f"{r['Co_called']:>10,} {r['Callability']:>11.2%} "
          f"{r['Concordance']:>11.2%} {r['Dropout_rate']:>9.2%}")
print("─" * W)
print(f"{'OVERALL (pooled)':<20} {total_full:>12,} {'':>10} {total_co:>10,} "
      f"{overall_callability:>11.2%} {overall_concordance:>11.2%} {overall_dropout:>9.2%}")
print("─" * W)

# ── discordance breakdown table ───────────────────────────────────────────────
print(f"\n{'─' * W}")
print("Discordance breakdown  (counts per co-called site category)")
print(f"{'Sample':<20} {'Conc_hom':>10} {'Conc_het':>10} {'Dropout':>10} "
      f"{'Overcall':>10} {'Wrong_al':>10} {'Het_mis':>10}")
print("─" * W)
for r in results:
    print(f"{r['Sample']:<20} {r['Concordant_hom']:>10,} {r['Concordant_het']:>10,} "
          f"{r['Dropout']:>10,} {r['Overcall']:>10,} "
          f"{r['Wrong_allele']:>10,} {r['Het_mismatch']:>10,}")
print("─" * W)
print(f"{'OVERALL':<20} "
      f"{totals['Concordant_hom']:>10,} {totals['Concordant_het']:>10,} "
      f"{totals['Dropout']:>10,} {totals['Overcall']:>10,} "
      f"{totals['Wrong_allele']:>10,} {totals['Het_mismatch']:>10,}")
print("─" * W)

# ── save TSV ──────────────────────────────────────────────────────────────────
out_tsv = "callability_concordance_results.tsv"
for col in ["Callability", "Concordance", "Dropout_rate"]:
    res[col + "_pct"] = (res[col] * 100).round(2)
res.to_csv(out_tsv, sep="\t", index=False, float_format="%.4f")
print(f"\nResults saved to: {out_tsv}")
