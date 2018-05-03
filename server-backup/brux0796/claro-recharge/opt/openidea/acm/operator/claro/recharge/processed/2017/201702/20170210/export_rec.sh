#!/bin/bash

output_file=recargas_$1.csv

for f in uplift_recargas_msisdns*.gz;
do
    md=$(stat -c %y $f)
    zgrep -v -e "^T\|H" $f | awk -F"|" -v d="${md:0:19}" '{print d";"substr($2,1,2)";"$4$5";"$3";"$7";"$9}' | grep -v SQ | grep -v ";;;;"
done > ${output_file}
gzip ${output_file}
