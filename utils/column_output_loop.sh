for i in ./longsplit/*.txt; do
    # Echo the filename and the count of lines with "-" in the 4th column
    count=$(cut -f 4 "$i" | grep "-" | wc -l)
    echo -e "$i\t$count"
done
