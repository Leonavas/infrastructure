#!/bin/bash

DIR=/opt/openidea/acm/operator/claro/report/movement_extraction

mkdir -p ${DIR}"/out/Base_Campanhas_201612"

mv ${DIR}"/out/Base_Campanhas_201612"*".txt.gz" ${DIR}"/out/Base_Campanhas_201612/"

P_PID=$$

TMP_DIR=${DIR}/tmp/${P_PID}

mkdir -p ${TMP_DIR}

function wait_p() {
    while true; do
        __nr_files=$(ls -l ${TMP_DIR}/*.txt|wc -l)
        if [ ${__nr_files} -eq 10 ]; then
            break
        else
            sleep 15
        fi
    done
}

function lote1 () {    
    touch ${TMP_DIR}/lote1_start.txt
    ${DIR}/bin/extract-data.sh "02 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "03 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "14 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "18 Dec 2016 UTC"    
    touch ${TMP_DIR}/lote1_end.txt
}

function lote2 () {
    touch ${TMP_DIR}/lote2_start.txt
    ${DIR}/bin/extract-data.sh "04 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "05 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "15 Dec 2016 UTC"    
    ${DIR}/bin/extract-data.sh "19 Dec 2016 UTC"    
    touch ${TMP_DIR}/lote2_end.txt
}

function lote3 () {
    touch ${TMP_DIR}/lote3_start.txt
    ${DIR}/bin/extract-data.sh "06 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "07 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "16 Dec 2016 UTC"    
    ${DIR}/bin/extract-data.sh "20 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "21 Dec 2016 UTC"
    touch ${TMP_DIR}/lote3_end.txt
}

function lote4 () {
    touch ${TMP_DIR}/lote4_start.txt
    ${DIR}/bin/extract-data.sh "08 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "09 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "17 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "22 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "23 Dec 2016 UTC"
    touch ${TMP_DIR}/lote4_end.txt
}

function lote5 () {
    touch ${TMP_DIR}/lote5_start.txt
    ${DIR}/bin/extract-data.sh "10 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "11 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "12 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "13 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "24 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "25 Dec 2016 UTC"
    ${DIR}/bin/extract-data.sh "26 Dec 2016 UTC"
    touch ${TMP_DIR}/lote5_end.txt
}


lote1 &
lote2 &
lote3 &
lote4 &
lote5 &

sleep 5

wait_p



/opt/openidea/acm/operator/claro/report/movement_extraction/bin/movement_extraction.sh days 1
