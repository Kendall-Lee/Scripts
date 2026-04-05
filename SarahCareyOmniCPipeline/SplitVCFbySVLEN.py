import sys

# Define input and output file names
input_vcf = "output_with_svlen.vcf"
snps_vcf = "snps.vcf"
small_indels_vcf = "small_indels.vcf"
large_sv_vcf = "large_sv.vcf"

# Open output files
with open(input_vcf, "r") as infile, \
     open(snps_vcf, "w") as snps_file, \
     open(small_indels_vcf, "w") as small_indels_file, \
     open(large_sv_vcf, "w") as large_sv_file:

    for line in infile:
        # Write headers to all output files
        if line.startswith("#"):
            snps_file.write(line)
            small_indels_file.write(line)
            large_sv_file.write(line)
            continue

        # Process variant lines
        fields = line.strip().split("\t")
        info_field = fields[7]

        # Extract SVLEN value
        svlen_value = None
        for entry in info_field.split(";"):
            if entry.startswith("SVLEN="):
                svlen_value = entry.split("=")[1]
                break

        if svlen_value is None:
            continue  # Skip if SVLEN is missing (shouldn't happen)

        # Handle multi-allelic sites (comma-separated SVLENs)
        svlen_values = list(map(int, svlen_value.split(",")))
        max_svlen = max(svlen_values)  # Use the longest variant

        # Write to the appropriate output file
        if max_svlen == 1:
            snps_file.write(line)
        elif 2 <= max_svlen <= 1000:
            small_indels_file.write(line)
        else:
            large_sv_file.write(line)

print(f"✅ VCF splitting complete! Output files:")
print(f"- SNPs: {snps_vcf}")
print(f"- Small Indels: {small_indels_vcf}")
print(f"- Large SVs: {large_sv_vcf}")
