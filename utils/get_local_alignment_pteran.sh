pteranodon=$1
t=$2
ref=$3
query=$4
out=$5
len=$6
min=$7
scafPer=$8
#################
module load cluster/bwa/0.7.17
module load cluster/R/4.1.1
mkdir -p stds
################
if [ -d $out ] ; then rm -r $out; fi
if test -z "$7" ; then  min=10; fi  #minimuim length
if test -z "$8" ; then scafPer=20; fi # percentage of matched scaffold to ref genome
################
echo "1. Pteranodon location: "$pteranodon" "
echo "2. number of threads: "$t" "
echo "3. ref genome: "$ref""
echo "4. query: "$query" "
echo "5. output folder: "$out" "
echo "6. query sequences are split into "$len" segments "
echo "7. query sequences less than "$min"MB are excluded "
echo "8. query seqeunces less than "$scafPer"% of ref matched sequence are excluded "
################
mkdir $out
################
# query splitting
chr2=$(echo $query | sed 's:[.].*::g' | sed 's:.*/::g')
mkdir "$out"/"$chr2"; csplit -s -z "$query" '/>/' '{*}' -f "$out"/"$chr2"/xx
for i in "$out"/"$chr2"/xx* ; do \
  n=$(sed 's/>// ; s/ .*// ; 1q' "$i") ; \
  mv "$i" "$out"/"$chr2"/"$n".fa ; \
done
################
cat $ref | awk 'BEGIN{id=""; len = 0}{ if($0 ~ "^>") {print id"\t"len; len=0; id=$0} else if(id != "") {len=len+length($0)} }END{print id"\t"len}' | sed '1d' | sed 's:^>::g' | sed '1ichr\tlen' > "$out"/"$chr2"/ref_len
################
for i in $(ls "$out"/"$chr2"/*.fa);do id=$(cat $i ) ; cat $i | sed '1d' | tr '\n' ' '  | sed 's: ::g' | wc -c | awk -v i=$i -v min=$min '{if($0/1e6 > min) {print i"\t"$0/1e6}}'  ; done | sort -Vrk2 > "$out"/"$chr2"/stat
################
touch "$out"/"$chr2".fa
for i in $(cat "$out"/"$chr2"/stat |cut -f 1 | sed 's:.fa$::g' | sed 's:.*/::g'); do
	cat "$out"/"$chr2"/"$i".fa  | sed '1d' | tr '\n' ' ' | sed "s: ::g"| fold -w $len | awk -v seg="$i" '{print ">"seg"&"NR"\n"$0}' >> "$out"/"$chr2".fa
done
################
bwa mem -M -t $t $ref "$out"/"$chr2".fa -o "$out"/"$chr2".sam
cat "$out"/"$chr2".sam | grep -v 'SA:Z:' |awk '{if($5==60 || $5 == "") print($0)}' | grep -v '@' | cut -f1-6 | awk -v len=$""$len"M" '{if($6 == len ) {print $0} }'  > "$out"/"$chr2".sam2
################
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
		cat "$out"/"$chr2"/"$i".sam | cut -f1-6 | grep "$chr" | cut -f 1,3,4 | sed 's:&:\t:g' | sort -rV -k 4 | awk -v len=$len 'OFS="\t"{print $1,($2*len)-len,$3,$4}' > "$out"/"$chr2"/"$i"_"$chr".txt
	done
done
################
Rscript "$pteranodon"/get_plot_based_on_local_alignment.R -in "$out"/"$chr2"
cp "$out"/"$chr2".rds ./
