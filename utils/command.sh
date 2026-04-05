#!/bin/bash -euo pipefail
echo "m84238_251104_205516_s1/107876312/ccs"
bamindex fetch --chunk=42 concatemers.bam |
    /cluster/lab/clevenger/KLee/CiFi/wf-pore-c/bin/porec_digest_wrapper.py "OmniC_Bridge" --max_monomers 250 --excluded_list filtered_reads.txt                     --header concatemers.bam                     --threads 2 |
    samtools fastq --threads 1 -T '*' |
    cutadapt -j ${ubam_map_threads} \
    -a AGGTTCGTCCATCGATCGATGGACGAACCT \
    -a AGGTTCGTCCATCGATCGATGGACGAACCT \
    -a GGTTCGTCCATCGATC \
    -a GATCGATGGACGAACC \
    -o /dev/stdout - | \
    minimap2 -ay -t 13 -x map-hifi  --cap-kalloc 100m --cap-sw-mem 50m reference.fasta.mmi - |
    pore-c-py annotate - "B080" --monomers  --threads 2  --paired_end --summary

mv B080.ns.bam "B080_out.ns.bam"
samtools sort -m 1G --threads 2 -u --write-index -o "B080.cs.bam" "B080_out.ns.bam"


Step-by-step
 bamindex fetch --chunk=22 concatemers.bam
Splits or fetches a chunk (batch #22) from a large concatenated reads BAM (“concatemers.bam”)—this isolates a subset for parallel processing.
Output: reads stream.
 porec_digest_wrapper.py
Cuts each long ONT Pore‑C read into monomers (segments between restriction enzyme sites, here "OmniC_Bridge" equivalent to e.g. NlaIII/DpnII).
Removes reads listed in filtered_reads.txt if specified.
Output: virtual read fragments with segment coordinates in the SAM stream.
 samtools fastq
Converts those digested monomers into FASTQ so they can be re‑aligned to the reference.
 minimap2 ... reference.fasta.mmi -
Maps those monomers against the reference genome (the -x map-hifi preset tells minimap2 to expect PacBio/ONT high‑accuracy long reads).
Output: SAM with alignments for each monomer.
 pore-c-py annotate ... --paired_end --summary
Consumes the mapped monomers from minimap2.
Adds Pore‑C–specific annotations and pair information.
This is the step that actually creates the BAM output — B080.ns.bam.
The .ns suffix means “name‑sorted BAM” (each concatemer’s monomers grouped together).
