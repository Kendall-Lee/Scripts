#!/bin/bash

fasta_file="your_input.fasta"  # Replace with your FASTA file path

awk '/^>/{filename=sprintf("%s.fasta",substr($0,2));}{print > filename; close(filename);}' "$fasta_file"

# Remove empty files created by awk
find . -type f -empty -delete
