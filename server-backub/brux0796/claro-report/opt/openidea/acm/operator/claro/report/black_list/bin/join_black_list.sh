#!/bin/bash

DAY_PROCESS=$(date -d '10:00:00 0 days ago' +%Y%m%d)

PDI_BIN="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/report/black_list"
OUT_DIR=${DIR}"/out"

P_PID=$$

rm -rf ${DIR}"/tmp/"${P_PID}

TMP_DIR=${DIR}"/tmp/"${P_PID}
OUT_DIR=${DIR}"/out"

ls_base_final=$(cd ${DIR}"/src/BASE_FINAL" && ls ""*".txt")
ls_tacs_list=$(cd ${DIR}"/src/TACS" && ls ""*".txt")

base_final=${DIR}"/src/BASE_FINAL/"${ls_base_final}
tacs_list=${DIR}"/src/TACS/"${ls_tacs_list}
blacklist=${DIR}"/src/BLACKLIST"

newblacklist=${TMP_DIR}"/filter_smart_black_list"
newnoblacklist=${TMP_DIR}"/filter_smart_no_black_list"

ndc="/opt/openidea/acm/operator/claro/report/common/src/DDD.csv"

mkdir -p ${TMP_DIR}

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/join_black_list.kjb -level=Basic \
     " -param:acm.job.dir.in.msisdnblocked="${blacklist} \
     " -param:acm.job.dir.tmp="${TMP_DIR} \
     " -param:acm.job.file.in.msisdntac="${base_final} \
     " -param:acm.job.file.in.taclist="${tacs_list}  \
     " -param:acm.job.file.cfg.ndc="${ndc} \
     " -param:acm.job.file.out.newblacklist="${newblacklist} \
     " -param:acm.job.file.out.newnoblacklist="${newnoblacklist}

if [ -e "${newblacklist}.csv" ];
then
    mv "${newblacklist}.csv" ${DIR}"/out/filter_smart_black_list.csv"
    scp ${DIR}"/out/filter_smart_black_list.csv" brux0794:/opt/openidea/acm/operator/claro/report/smartphone/src/filter/
fi

if [ -e "${newnoblacklist}.csv" ];
then
    mv "${newnoblacklist}.csv" ${DIR}"/out/filter_smart_no_black_list.csv"
    scp ${DIR}"/out/filter_smart_no_black_list.csv" brux0794:/opt/openidea/acm/operator/claro/report/smartphone/src/filter/
fi

mv ${base_final} ${DIR}"/prc/"${ls_base_final}"."${DAY_PROCESS}
mv ${tacs_list} ${DIR}"/prc/"${ls_tacs_list}"."${DAY_PROCESS}

for file in ${blacklist}/*.txt
do
    mv ${file} ${file}"."${DAY_PROCESS}
    mv ${file}"."${DAY_PROCESS} ${DIR}"/prc/"
done

rm -rf ${TMP_DIR}
