#!/bin/bash

echo "File to process must follow this layout: NTC|TECNOLOGIA|FL_DUAL_SIM|SEGMENTO"

DIR=/opt/openidea/acm/operator/claro/report/customer_update/ext

if [ ! $# -eq 2 ]
then
    echo "Usage $0 <DIR> <FILENAME> "
    exit 1
fi

DIR=$1
FILENAME=$2

rm -f ${DIR}/aparelhos_base_pre.*.csv ${DIR}/aparelhos_base_pre.*.csv.gz

cat ${DIR}/${FILENAME} |sed '1d'| awk -v dir=${DIR} '{ntc=$1;seg=$4;if (seg=="FEATURE PHONE"){tec=1} else if(seg=="SMARTPHONE"||seg=="TABLET"){tec=2} else if(seg=="WEBPHONE"){tec=3} else {tec=0}; if($3=="S"){tec=tec+4}; if (tec>0) {print $1";"tec > dir"/aparelhos_base_pre."ntc%8".csv"}}' FS="|"

for (( i=0;i<8;i++ ))
do
    sort -T ${DIR}/. -t ";" ${DIR}/aparelhos_base_pre.${i}.csv > ${DIR}/aparelhos_base_pre.${i}.sort
    mv ${DIR}/aparelhos_base_pre.${i}.sort ${DIR}/aparelhos_base_pre.${i}.csv
    gzip ${DIR}/aparelhos_base_pre.${i}.csv
done
