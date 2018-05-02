#!/bin/bash

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/report/sos-recarga"

P_PID=$$

TMP_DIR=${DIR}"/tmp/"${P_PID}

REC_DIR=${DIR}"/src"
DDD_CFG="/opt/openidea/acm/operator/claro/report/common/src/DDD.csv"

BALANCE_DT=$(date --date="1 day ago" +%Y%m%d)

REC_M0=$(date --date="0 month ago" +%Y%m)
REC_M1=$(date --date="1 month ago" +%Y%m)
REC_M2=$(date --date="2 month ago" +%Y%m)
REC_M3=$(date --date="3 month ago" +%Y%m)

echo "${BALANCE_DT} ${REC_M0} ${REC_M1} ${REC_M2} ${REC_M3}"

cp -p /opt/openidea/acm/operator/claro/report/recharge_aggregation/out/uplift*${REC_M0}*gz ${REC_DIR}/
cp -p /opt/openidea/acm/operator/claro/report/recharge_aggregation/out/uplift*${REC_M1}*gz ${REC_DIR}/
cp -p /opt/openidea/acm/operator/claro/report/recharge_aggregation/out/uplift*${REC_M2}*gz ${REC_DIR}/
cp -p /opt/openidea/acm/operator/claro/report/recharge_aggregation/out/uplift*${REC_M3}*gz ${REC_DIR}/

mkdir -p ${TMP_DIR}"/sort" ${TMP_DIR}"/out"

rm -rf ${DIR}"/out/"*

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/1-run.kjb -level=Basic \
     " -param:acm.job.dir.in.recharge="${REC_DIR} \
     " -param:acm.job.dir.out="${TMP_DIR}"/out" \
     " -param:acm.job.dir.sort="${TMP_DIR}"/sort" \
     " -param:acm.job.file.cfg.faixa-zb1="${DIR}"/cfg/zb1.txt" \
     " -param:acm.job.file.cfg.ndc="${DDD_CFG} \
     " -param:acm.job.file.in.balance=/opt/openidea/acm/operator/claro/files/balance/balance_prepago_${BALANCE_DT}.txt.gz" \
     " -param:acm.job.param.in.recharge-m0="${REC_M0} \
     " -param:acm.job.param.in.recharge-m1="${REC_M1} \
     " -param:acm.job.param.in.recharge-m2="${REC_M2} \
     " -param:acm.job.param.in.recharge-m3="${REC_M3}

if [ $? -eq 0 ]; then

    echo "PDI Return code: $?"

    mv ${TMP_DIR}"/out/"* ${DIR}"/out"

    rm -r ${TMP_DIR} \
          ${REC_DIR}/uplift*${REC_M0}*gz \
          ${REC_DIR}/uplift*${REC_M1}*gz \
          ${REC_DIR}/uplift*${REC_M2}*gz \
          ${REC_DIR}/uplift*${REC_M3}*gz

else
    echo "PDI Return code: $?"
    rm -rf ${TMP_DIR}
fi
