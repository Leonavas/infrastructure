#!/bin/bash

DAY_PROCESS=$(date -d '10:00:00 0 days ago' +%Y%m%d)

PDI_BIN="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/universal-control-group"

P_PID=$$

rm -rf ${DIR}"/tmp/"${P_PID}

TMP_DIR=${DIR}"/tmp/"${P_PID}
OUT_DIR=${DIR}"/out"
SRC_DIR=${DIR}"/src"
PRC_DIR=${DIR}"/prc"

LISTA_CLARO=${DIR}"/cfg/lista-claro.txt"
NDC_FILE="/opt/openidea/acm/operator/claro/report/common/src/DDD_v2.csv"

TODAY=`date +%d`
TOMORROW=`date +%d -d "1 day"`
if [ ${TOMORROW} -lt ${TODAY} ]; then
    mv ${SRC_DIR}"/amostra-baseline.txt.gz" ${PRC_DIR}"/amostra-baseline.${DAY_PROCESS}.txt.gz"
fi

mkdir -p ${TMP_DIR}

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/1-grupo-controle-universal.kjb -level=Basic \
     " -param:acm.job.dir.out="${OUT_DIR} \
     " -param:acm.job.dir.src="${SRC_DIR} \
     " -param:acm.job.dir.tmp="${TMP_DIR} \
     " -param:acm.job.file.cfg.lista-claro="${LISTA_CLARO} \
     " -param:acm.job.file.cfg.ndc="${NDC_FILE}

if [ "$?" = "0" ]; then

    if [ -e ${OUT_DIR}"/universal-control-group.txt.gz" ]; then

        zcat ${OUT_DIR}"/universal-control-group.txt.gz" > ${TMP_DIR}"/controle_universal.csv"

        scp ${TMP_DIR}"/controle_universal.csv" \
            brux0794:"/opt/openidea/acm/operator/claro/customer_update/optout/ext/"

        cp ${OUT_DIR}"/universal-control-group.txt.gz" \
           "/opt/openidea/acm/operator/claro/customer_update/balance-pdi/ext/unp/universal_control_group_${DAY_PROCESS}.txt.gz"
        touch  "/opt/openidea/acm/operator/claro/customer_update/balance-pdi/ext/unp/universal_control_group.file"

        mv ${OUT_DIR}"/universal-control-group.txt.gz" \
           ${PRC_DIR}"/universal-control-group.${DAY_PROCESS}.txt.gz"

        mv ${SRC_DIR}"/blacklist.txt.gz" ${PRC_DIR}"/blacklist.${DAY_PROCESS}.txt.gz"

        rm ${SRC_DIR}"/lista-claro.txt.gz"
    fi
fi


rm -rf ${TMP_DIR}
