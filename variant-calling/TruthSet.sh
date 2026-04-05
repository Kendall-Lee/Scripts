# ##for parent change for correct parent
# cat LRLPPan.vcf9 | cut -d, -f 1 | awk '{if ($2!="") print $0}'
# cat LRLPPan.vcf9 | cut -f 1-2 | tr ',' '\t' | cut -f 1,4 | awk '{if ($2!="") print $0}' > LRLPPan.CC477.vcf9
#
# #change column name to reflect source file
# # sed -i 's:TifNV:TifNV_vcf9:g' LRLPPan.TifNV.vcf9
# #
# # ##for downsampled query
# # cat TifNV_HIFI.vcf | grep -v "#" | tr ':' '\t' | cut -f 1,2,4,5,18,19 | awk '{if ($5>0) print $1"_"$2"\t"$3","$4"\t"$6}' | awk '{n=split($2,X,","); split($3,Z,",") ; W=$1";" ; for(i=1; i<=n; i++){if(Z[i]>0)W=W","X[i]} ; print W} ' | sed "s:;,:\t:g" | awk '{if(NF==2) print $0}' >
# #
# #
# # ##RN choosing alt for 0/1 or
# # cat TifNV_HIFI.vcf | grep -v "#" | tr ':' '\t' | cut -f 1,2,4,5,10,18 | awk '{split($5, GT, ":"); split($6, DP, ":"); if (DP[1] > 0 && GT[1] != "0/0") print $1"_"$2"\t"$4","$5"\t"$5}' | awk '{n=split($2,X,","); split($3,Z,",") ; W=$1";" ; for(i=1; i<=n; i++){if(Z[i]>0)W=W","X[i]} ; print W} ' | sed "s:;,:\t:g" | awk '{if(NF==2) print $0}'
# # #add column header to query files
# # sed -i '1i chr-post\tTifNV_allele' TifNV.extracted.vcf
# #
# #
# # #then merge and assign Match/mismatch grep "TRv2Chr.19" | grep "112528709"
# # # (sort TifNV.extracted.vcf -k1,1) > TifNV.extracted.sorted.vcf
# # # (sort LRLPPan.TifNV.vcf9 -k1,1) > LRLPPan.TifNV.sorted.vcf9
# # # join -t $'\t' -j1 TifNV.extracted.sorted.vcf LRLPPan.TifNV.sorted.vcf9 > TifNV.compare.txt
# # #awk '{split($3, alt_alleles, ","); for (i in alt_alleles) if ($2 == alt_alleles[i]) {print $1, $2, "SAME"; next} print $1, $2, $3, "DIFFERENT"}' merge_TifNV.correct.vcf > TifNV_comparison_results.new.tsv
# #
# # #new for het
# awk '{split($3, alt_alleles, ","); for (i in alt_alleles) if ($2 == alt_alleles[i] || index(alt_alleles[i], $2) > 0 || index($2, alt_alleles[i]) > 0) {print $1, $2, "SAME"; next} print $1, $2, $3, "DIFFERENT"}' merge_TifNV.correct.vcf > TifNV_comparison_results.new.tsv
# #
# # remove all lines with alleles >4 bp
# awk 'length($2) <= 4' TifNV_Final_compare.txt
# # wc -l LRLPPan.TifNV.vcf9
# # wc -l TifNV.extracted.sorted.vcf
# # cat TifNV_comparison_results.tsv | wc -l
# # cat TifNV_comparison_results.tsv | grep "SAME" | wc -l
# cat TifNV_comparison_results.tsv | grep "DIFFERENT" | wc -l
#
# ########## vcf5 method ######
#
cat sub_Georganic_HIFI.vcf5 | sed 1d | sed "1i1;1" | tr ';' '\t' | paste peanutpan.vcf9 - | awk '{if($7>0) print $0}' | cut -f 3,6 | tr ',' '\t' | cut -f 10,20 | sed 1d | grep -v -w 0 | awk '{if($1==$2) X+=1 }END{print X,NR,X/NR*100}' #> gives three numbers 1.Match # 2.Overlap # of sites 3.Match %

cat sub_Baileyfinal150bpkmer.vcf5 | grep -v "0" | wc -l #to get total downsample sites

cat peanutpan.vcf9 | cut -f 3 | tr ',' '\t' | cut -f 10 | grep -v "0" | wc -l #to get total parent sites

#
# echo "$(paste peanutpan.vcf9 <(sed 1d ./bams_newPangraph/York_HIFI.vcf5) | awk '{if($2 != "-") count+=1} END{print count}') / $(sed 1d ./bams_newPangraph/York_HIFI.vcf5 | wc -l) * 100" | bc -l
#
# ###### vcf2 #############
# #3/10/25
# #this code removes DP=0 and all GT because GT is unreliable
# awk '!/^#/ {if ($4 != "0") print $1,$2,$3,$4,$5,$6,$7,$8,$9}'  CC477_HIFI.vcf2 | awk '{ $3=""; print $0 }' | grep -v "DP=0" >  CC477_HIFI.filtered.vcf
# #replace all blanks with tabs
# sed 's/[[:space:]]/'$'\t''/g'  CC477_HIFI.filtered.vcf >  CC477_HIFI_filtered_02.vcf2
#
# #for 2 alleles
# cat  CC477_HIFI_filtered_02.vcf2 | tr ',' '\t' | awk '{if (NF==6) print $0}' >  CC477_HIFI_filtered_02_2allele.vcf2
# cat  CC477_HIFI_filtered_02_2allele.vcf2 | awk -v OFS="\t" '{if (($5==0)) print $1,$3; else if (($6==0)) print $1,$2; else print $1,$2","$3}' >  CC477_HIFI_filtered_02_2allele.FINAL.vcf2
#
# #for 3 alleles
# cat  CC477_HIFI_filtered_02.vcf2| tr ',' '\t' | awk '{if (NF==8) print $0}' >  CC477_HIFI_filtered_02_3allele.vcf2
# awk -v OFS="\t" '{correct_alleles=""; for(i=6; i<=8; i++) if($i!=0) correct_alleles = (correct_alleles == "" ? $(i-4) : correct_alleles","$(i-4)); print $1, correct_alleles;}'  CC477_HIFI_filtered_02_3allele.vcf2 >  CC477_HIFI_filtered_02_3allele.FINAL.vcf2
#
#
# ### for 4 alleles
# cat  CC477_HIFI_filtered_02.vcf2| tr ',' '\t' | awk '{if (NF==10) print $0}' >  CC477_HIFI_filtered_02_4allele.vcf2
# awk -v OFS="\t" '{correct_alleles=""; for(i=7; i<=10; i++) if($i!=0) correct_alleles = (correct_alleles == "" ? $(i-5) : correct_alleles","$(i-5)); print $1, correct_alleles;}'  CC477_HIFI_filtered_02_4allele.vcf2 >  CC477_HIFI_filtered_4allele.FINAL.vcf2
#
#
# # for 5 alleles
# cat  CC477_HIFI_filtered_02.vcf2| tr ',' '\t' | awk '{if (NF==12) print $0}' >  CC477_HIFI_filtered_02_5allele.vcf2
# awk -v OFS="\t" '{correct_alleles=""; for(i=8; i<=12; i++) if($i!=0) correct_alleles = (correct_alleles == "" ? $(i-6) : correct_alleles","$(i-6)); print $1, correct_alleles;}'  CC477_HIFI_filtered_02_5allele.vcf2 >  CC477_HIFI_filtered_5allele.FINAL.vcf2
#
# ## for 6 alleles
# cat  CC477_HIFI_filtered_02.vcf2| tr ',' '\t' | awk '{if (NF==14) print $0}' >  CC477_HIFI_filtered_02_6allele.vcf2
# awk -v OFS="\t" '{correct_alleles=""; for(i=9; i<=14; i++) if($i!=0) correct_alleles=(correct_alleles==""?$(i-7):correct_alleles","$(i-7)); print $1, correct_alleles;}'  CC477_HIFI_filtered_02_6allele.vcf2 >  CC477_HIFI_filtered_02_6allele.FINAL.vcf2
#
# #merge all the files back together
# cat  CC477_HIFI_filtered_02_6allele.FINAL.vcf2  CC477_HIFI_filtered_5allele.FINAL.vcf2   CC477_HIFI_filtered_4allele.FINAL.vcf2  CC477_HIFI_filtered_02_3allele.FINAL.vcf2  CC477_HIFI_filtered_02_2allele.FINAL.vcf2 | sort -Vk1,1 >  CC477.FINAL.vcf2
#
#
# merge LRLPPan.CC477.vcf9 CC477.FINAL.vcf2 | grep -v "NA" >  CC477_compare.txt
#
# #judge each line as same or different taking into account heterozygosity
# awk '{split($3, alt_alleles, ","); for (i in alt_alleles) if ($2 == alt_alleles[i] || index(alt_alleles[i], $2) > 0 || index($2, alt_alleles[i]) > 0) {print $1, $2, "SAME"; next} print $1, $2, $3, "DIFFERENT"}'  CC477_compare.txt >  CC477_compare.result.txt
# #remove lines with alleles with more than 4 bp
# awk 'length($2) <= 4'  CC477_compare.result.txt >  CC477_compare.result.filtered.txt
# wc -l CC477_compare.result.filtered.txt
# cat  CC477_compare.result.filtered.txt| grep "SAME" | wc -l
# cat  CC477_compare.result.filtered.txt | grep "DIFFERENT" | wc -l
#
#
# rm *allele*
