#!/bin/bash

HOME_DIR="$(cd "`dirname $0`/.." && pwd)"

P_PID=$$

for __file in $(ls -ltrh ${HOME_DIR}"/out/DeviceCompatibilityTable_"*".csv"|awk '{print $9}');
do

    for old_file in $(ls -ltrh ${HOME_DIR}"/out/DeviceCompatibilityTable_"*".csv.gz"|awk '{print $9}');
    do
        mv ${old_file} ${HOME_DIR}"/prc"
    done

    rm -f ${HOME_DIR}"/tmp/"${P_PID}".sort"
    sort -u -k 1 -t ";" -T ${HOME_DIR}"/tmp" ${__file} > ${HOME_DIR}"/tmp/"${P_PID}".sort"
    mv ${HOME_DIR}"/tmp/"${P_PID}".sort" ${__file}
    gzip ${__file}
done
