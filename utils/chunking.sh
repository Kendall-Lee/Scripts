#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <genome_sequence_file>"
    exit 1
fi

# Input genome sequence file
genome_file="/cluster/home/klee/PacBio_project/subsample_work/ICGV91707_subsample.fastq"

# Check if the file exists
if [ ! -f "$genome_file" ]; then
    echo "Error: File not found: $genome_file"
    exit 1
fi

# Output directory for chunks
output_dir="genome_chunks"
mkdir -p "$output_dir"

# Counter for chunk filenames
counter=1

# Process the genome sequence in chunks
while IFS= read -r -n 1000 chunk; do
    if [ -n "$chunk" ]; then
        # Write the chunk to a file
        echo "$chunk" > "$output_dir/chunk_$counter.fasta"
        ((counter++))
    fi
done < "$genome_file"

echo "Genome sequence has been broken into non-overlapping 1000 base pair chunks in $output_dir"



################ Zack's code ######written for a fasta file
#!/bin/bash

# declare path to reference file
ref="/cluster/home/klee/PacBio_project/subsample_work/ICGV91707_subsample.fasta"

# get list of line numbers for each chromosome in reference genome
chr_lines=($(cat -n  $ref | grep ">" | awk '{print $1}'))

# add the end line number to chr_lines
file_len=($(cat $ref | wc -l))
chr_lines+=($file_len)

# get list of chromosome names in reference genome
chr_names=($(cat $ref | grep ">" | awk '{print $1}'))

# set segment size
seg=1000

# declare cumulative nucleotide count
nt_ct_cml=0

# loop through list of chromosome names
for c in ${!chr_names[@]}; do

	# define range of lines in the reference genome containing sequence for a given chromosome
	chr_start=${chr_lines[$c]}
	chr_end=${chr_lines[$(( c + 1 ))]}

	# calculate the nucleotide count for a given chromosome
	nt_ct=($(cat $ref | tail -n +$chr_start | head -n $((chr_end - chr_start + 1)) | grep -v ">" | tr -d '[:space:]' | wc -c))

	# round the nucleotide count based on the segment size
	nt_ct_round=($(((nt_ct - (nt_ct % seg)) / seg)))

	# set the starting variables for nucleotide counts for a given chromosome
	seg_ct=0
	nt_start=0
	nt_end=($((nt_start + seg)))

	# generate segment start and stop values for a given chromosome
	while [ $seg_ct -le $nt_ct_round ]
	do
		echo -e "${chr_names[$c]}\t$nt_start\t$nt_end"
		((seg_ct++))
		((nt_start+=seg))
		((nt_end+=seg))
	done

	# increase the cumulative nucleotide count to include nucleotides from a given chromosome
	# ((nt_ct_cml+=nt_ct))

	# reset the nucleotide count for the next chromosome
	((nt_ct_cml=0))
done


###from pteranodon
for i in $(cat "$out"/"$chr2"/stat |cut -f 1 | sed 's:.fa$::g' | sed 's:.*/::g'); do
	cat "$out"/"$chr2".sam2 | grep -E  ""$i"&[0-9]" > "$out"/"$chr2"/"$i".sam
	cat "$out"/"$chr2"/"$i".sam | grep -E  ""$i"&[0-9]" | cut -f1-6| cut -f 3|sort |uniq -c | sed -E "s:^ +::g" | sed 's: :\t:g' | sort -Vr > "$out"/"$chr2"/"$i".stat
	sum=$(cat  "$out"/"$chr2"/"$i".stat | cut -f 1 |awk 'BEGIN {sum = 0} { sum += $i } END { print sum }')
	#chr=$(cat "$out"/"$chr2"/"$i".stat | head -1| cut -f 2)
	scaf_len=$(cat "$out"/"$chr2"/stat | grep -w $i | cut -f 2)
	#chrs=$(cat "$out"/"$chr2"/"$i".stat | awk -v sum=$sum '{if($1/sum*100  > 20) {print $2}}')
	chrs=$(cat "$out"/"$chr2"/"$i".stat | awk -v scaf_len=$scaf_len -v len=$len -v scafPer=$scafPer '{ if( ($1*len)/(scaf_len*1e6)*100 >= scafPer) print $2 }')
	for chr in $chrs
	do
