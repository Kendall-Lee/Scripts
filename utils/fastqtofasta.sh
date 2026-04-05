#!/bin/bash

sed -n '1~4s/^@/>/p;2~4p' winter_camelina.fastq > winter_camelina.fasta
