#checking hawkhap using CC477, smut as reference

#This cuts out only the smut region per the updated bed file. It then looks at only the parent CC477, removes het calls and counts the A C T G calls
cat Parent_Hapmap.hapmap | awk '{if (NR == 1 || ($1 == "TRv2Chr.12" && $2 >= "1733320" && $2 <= 2649406)){print $0}}' | cut -f2,7 | grep -v "-" | awk '{if (length($2) == 1){print $0} }' > X1.txt
#do this with one line of sample hapmap and compare (can remove sort uniq part if want to go line by line)
cat Unimputed_Merge.hapmap | awk '{if (NR == 1 || ($1 == "TRv2Chr.12" && $2 >= "1733320" && $2 <= 2649406)){print $0}}' | cut -f2,7 | grep -v "-" | awk '{if (length($2) == 1){print $0} }' > X2.txt
