#!/bin/bash

CURRENT_DATE=$(date +%Y%m%d) #YYYYMMDD
ONE_MONTH_DATE=$(date +%Y%m%d -d "$CURRENT_DATE -1 month")
TWO_MONTH_DATE=$(date +%Y%m%d -d "$CURRENT_DATE -2 month")
THREE_MONTH_DATE=$(date +%Y%m%d -d "$CURRENT_DATE -3 month")

FILES_DIR=/opt/openidea/acm/operator/claro/report/recharge_aggregation/out
AUX_DIR=/opt/openidea/acm/operator/claro/report/recharge_avarage/src

max_days=6

echo "reading current files..."
for (( i=1; i <= $max_days; ++i ))
do
    for f in `ls $FILES_DIR/uplift_recargas_msisdns_$(date +%Y%m%d -d "$CURRENT_DATE -$i day")*`;
	do zcat $f | sed '1d;$d' >> $AUX_DIR/current_file_$CURRENT_DATE.txt;
	done
done
	gzip $AUX_DIR/current_file_$CURRENT_DATE.txt
echo "current file created"

echo "reading j1 files..."
for (( i=1; i <= $max_days; ++i ))
do
	for f in `ls $FILES_DIR/uplift_recargas_msisdns_$(date +%Y%m%d -d "$ONE_MONTH_DATE -$i day")*`;
        do zcat $f | sed '1d;$d' >> $AUX_DIR/j1_file_$CURRENT_DATE.txt;
        done
done
	 gzip $AUX_DIR/j1_file_$CURRENT_DATE.txt
echo "j1 file created"

echo "reading j2 files..."
for (( i=1; i <= $max_days; ++i ))
do
	for f in `ls $FILES_DIR/uplift_recargas_msisdns_$(date +%Y%m%d -d "$TWO_MONTH_DATE -$i day")*`;
        do zcat $f | sed '1d;$d' >> $AUX_DIR/j2_file_$CURRENT_DATE.txt;
        done
done
	 gzip $AUX_DIR/j2_file_$CURRENT_DATE.txt
echo "j2 file created..."

echo "reading j3 files..."
for (( i=1; i <= $max_days; ++i ))
do
	for f in `ls $FILES_DIR/uplift_recargas_msisdns_$(date +%Y%m%d -d "$THREE_MONTH_DATE -$i day")*`;
        do zcat $f | sed '1d;$d' >> $AUX_DIR/j3_file_$CURRENT_DATE.txt;
        done
done
	 gzip $AUX_DIR/j3_file_$CURRENT_DATE.txt
echo "j3 file created"
