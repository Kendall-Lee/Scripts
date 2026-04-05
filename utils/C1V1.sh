# !/bin/bash

# Take user Input
echo "Enter C1, V1=50,C2=10: "
read a

# Switch Case to perform
# calculator operations
  res=`echo $a \*  50/10| bc`

echo "Result (volume H20 to add) : $res"
################################################################################
# !/bin/bash
# Read the CSV file
while IFS="," read -r col1 col2 col3
do
  # Do something with the columns
  echo `echo $col1 \*  50/10| bc`
  echo "Column 2: $col2"
  echo "Column 3: $col3"
done < sample.csv
