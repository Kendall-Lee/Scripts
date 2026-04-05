#!/usr/bin/env python3
import sys
import gzip

ploidy = 4

infile = sys.argv[1]
outfile = sys.argv[2]

with gzip.open(infile, 'rt') as fin, open(outfile, 'w') as fout:

    for line in fin:
        if line.startswith("##"):
            fout.write(line)

        elif line.startswith("#CHROM"):
            fout.write('##FORMAT=<ID=DS,Number=1,Type=Float,Description="AD-derived dosage (4*ALT/DP)">\n')
            fout.write(line)

        else:
            fields = line.rstrip().split("\t")

            format_fields = fields[8].split(":")

            if "DP" not in format_fields or "AD" not in format_fields:
                fout.write(line)
                continue

            dp_index = format_fields.index("DP")
            ad_index = format_fields.index("AD")

            fields[8] = fields[8] + ":DS"

            new_samples = []

            for sample in fields[9:]:
                vals = sample.split(":")

                if vals[dp_index] == "." or vals[ad_index] == ".":
                    new_samples.append(sample + ":.")
                    continue

                dp = float(vals[dp_index])
                ad_vals = vals[ad_index].split(",")

                if dp > 0 and len(ad_vals) >= 2:
                    alt = float(ad_vals[1])
                    ds = round(ploidy * alt / dp, 4)
                else:
                    ds = "."

                new_samples.append(sample + ":" + str(ds))

            fields[9:] = new_samples
            fout.write("\t".join(fields) + "\n")
