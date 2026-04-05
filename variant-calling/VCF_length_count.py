import sys

# Define input and output file names
input_vcf = "output_with_contig.vcf"
output_vcf = "output_with_svlen.vcf"

# Open input and output files
with open(input_vcf, "r") as infile, open(output_vcf, "w") as outfile:
    for line in infile:
        # Write header lines as is
        if line.startswith("#"):
            outfile.write(line)
            continue

        # Process variant lines
        fields = line.strip().split("\t")

        # Extract REF (4th column, index 3) and ALT (5th column, index 4)
        ref_allele = fields[3]
        alt_allele = fields[4]

        # Handle multi-allelic cases (split ALT alleles by comma)
        alt_alleles = alt_allele.split(",")

        # Compute SVLEN for each ALT allele
        svlens = [str(len(alt)) for alt in alt_alleles]

        # Modify the INFO field (8th column, index 7)
        if fields[7] == ".":
            fields[7] = f"SVLEN={','.join(svlens)}"
        else:
            fields[7] += f";SVLEN={','.join(svlens)}"

        # Write the modified line to output file
        outfile.write("\t".join(fields) + "\n")

print(f"✅ Processing complete! The updated file is saved as '{output_vcf}'.")
