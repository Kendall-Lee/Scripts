#!/bin/bash

awk '
    BEGIN {
        OFS = "\t";
    }
    FNR==NR {
        # First input: conservedSmutVars.txt
        key = $1 ":" $2;
        expected[key] = $3;
        sites[key] = $1 "\t" $2 "\t" $3;
        next;
    }
    FNR==1 {
        # Header line of HapMap file
        for (i=3; i<=NF; i++) {
            samples[i] = $i;
        }
        next;
    }
    {
        lookup = $1 ":" $2;
        if (lookup in expected) {
            site = sites[lookup];
            line = site;
            for (i=3; i<=NF; i++) {
                allele = expected[lookup];
                call = $i;
                if (call == "-") {
                    line = line OFS "NA";
                } else if (index(call, allele) > 0) {
                    line = line OFS "MATCH";
                } else {
                    line = line OFS "MISMATCH";
                }
            }
            results[lookup] = line;
        }
    }
    END {
        # Print header
        header = "chr\tpos\texpected";
        for (i=3; i in samples; i++) {
            header = header OFS samples[i];
        }
        print header;

        # Print results in order they appeared in conservedSmutVars.txt
        for (k in sites) {
            if (k in results) {
                print results[k];
            } else {
                # If site not found in HapMap, fill with NA
                na_line = sites[k];
                for (i=3; i in samples; i++) {
                    na_line = na_line OFS "NOT_FOUND";
                }
                print na_line;
            }
        }
    }
' conservedSmutVars.txt LRLP_WG_redo_09.hapmap.hapmap > per_sample_allele_matches.tsv
