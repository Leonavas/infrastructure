#!/bin/bash

if [ $# -eq 1 ]; then
    DATA_MOV=$(date -d "$(date +%Y%m01) - $1 month" +%Y%m%d)
else
    DATA_MOV=$(date -d "$(date +%Y%m01) - 1 month" +%Y%m%d)
fi

DAY_PROCESS=$(date -d '10:00:00 0 days ago' +%Y%m%d)

PDI_BIN="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/dw-technology"

P_PID=$$

rm -rf ${DIR}"/tmp/"${P_PID}

TMP_DIR=${DIR}"/tmp/"${P_PID}
OUT_DIR=${DIR}"/out"
PRC_DIR=${DIR}"/prc"

NDC_FILE="/opt/openidea/acm/operator/claro/report/common/src/DDD_v2.csv"
SEGMENT_FILE=${DIR}"/cfg/segment-config.csv"

mkdir -p ${TMP_DIR}

TODAY=`date +%d`
TOMORROW=`date +%d -d "1 day"`
if [ ${TOMORROW} -lt ${TODAY} ]; then
    mv ${OUT_DIR}"/technology_segmentation_"*".txt.gz" ${PRC_DIR}"/"
fi

PDI_FG=1
#for __file in $(ls -l ${OUT_DIR}"/technology_segmentation_"*".txt.gz"|awk '{print $9}'); do 
#    rm -rf ${TMP_DIR}
#    echo "File ${__file} already exists. Exiting..."
#    PDI_FG=0
#done

if [ ${PDI_FG} -eq 1 ]; then
    echo "Execution date: ${DAY_PROCESS}, data-mov: ${DATA_MOV}"

    # -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

    ${PDI_BIN} -file=${DIR}/pdi/job/1-technology-data-dump.kjb -level=Basic \
         " -param:acm.job.dir.out="${OUT_DIR} \
         " -param:acm.job.dir.tmp="${TMP_DIR} \
         " -param:acm.job.file.cfg.ndc="${NDC_FILE} \
         " -param:acm.job.file.cfg.segment="${SEGMENT_FILE} \
         " -param:acm.job.param.data-mov="${DATA_MOV} > ${DIR}/log/run-crontab-${DAY_PROCESS}.log
fi

if [ $? -eq 0 ]; then
    if [ -e "${OUT_DIR}/technology_segmentation_${DATA_MOV}.txt.gz" ]; then
    
#        scp "${OUT_DIR}/technology_segmentation_${DATA_MOV}.txt.gz" \
 #           brux0794:/opt/openidea/acm/operator/claro/report/smartphone/src/technology_segmentation.txt.gz
            
        cp -p ${OUT_DIR}"/technology_segmentation_"${DATA_MOV}".txt.gz" \
              "/opt/openidea/acm/operator/claro/customer_update/balance-pdi/ext/unp/"
              
        touch "/opt/openidea/acm/operator/claro/customer_update/balance-pdi/ext/unp/technology_segmentation.file"
	fi
else
    echo FAIL
fi
	 
rm -rf ${TMP_DIR}
