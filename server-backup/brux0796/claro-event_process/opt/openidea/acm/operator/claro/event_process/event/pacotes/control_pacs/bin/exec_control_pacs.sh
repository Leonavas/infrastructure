#!/bin/bash


if [ $# -eq 1 ];
then
    DAY_PROCESS=$(date -d '10:00:00 1 days ago' +%Y%m%d)
    elif [ $# -eq 2 ];
    then
	DAY_PROCESS=${2}
        else
            echo "Usage: $0 <PID> <DATE_OF_PROCESS_FILE:yyyyMMdd>"
	    exit 1
fi

echo $0" "$1" "${DAY_PROCESS}

PDI_BIN="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/event_process/event/pacotes/control_pacs"
ADESAO_DIR="/opt/openidea/acm/operator/claro/event_process/event/pacotes/control_pacs/out"
DESADESAO_DIR="/opt/openidea/acm/operator/claro/event_process/event/pacotes/control_pacs/out"
PACOTES_DIR="/opt/openidea/acm/operator/claro/event_process/event/pacotes"

mv "/opt/openidea/acm/operator/claro/event_process/event/pacotes/prc/UPLIFT_PCTS_CONTRATADOS_${DAY_PROCESS}"*".txt.gz" ${DIR}"/src/"

if [ ! -f ${DIR}"/src/UPLIFT_PCTS_CONTRATADOS_${DAY_PROCESS}"*".txt.gz" ];
then
    echo "File not found: ${DIR}/src/UPLIFT_PCTS_CONTRATADOS_${DAY_PROCESS}*.txt.gz"
    exit 1
fi

P_PID=$1

date_1day_ago=$(date -d ''${DAY_PROCESS}' 10:00:00 1 days ago' +%Y%m%d)


rm -rf ${DIR}"/tmp/"${P_PID}

TMP_DIR=${DIR}"/tmp/"${P_PID}
OUT_DIR=${DIR}"/out"

PROCESS="Dados"
#PROCESS="Reproc"

pcrf_pac=$(cd ${DIR}"/src/" && ls "UPLIFT_PCTS_CONTRATADOS_${DAY_PROCESS}"*".txt.gz")

addpcrf=${DIR}"/src/${pcrf_pac}"
errorpac=${DIR}"/log/error_pacs_${DAY_PROCESS}"
fulladdpaclist=${DIR}"/prc/FULL_ADD_PACS_LIST_${date_1day_ago}.txt.gz"
newfulladdpaclist=${TMP_DIR}"/NEW_FULL_ADD_PACS_LIST_${DAY_PROCESS}"
pacprocess=${DIR}"/cfg/processPacsPCRF.txt"
prioritypacs=${DIR}"/cfg/lookupPiorityPacs.txt"
adesao=${DIR}"/out/adesao_pac_diario_${DAY_PROCESS}"
desadesao=${DIR}"/out/desadesao_pac_diario_${DAY_PROCESS}"
ndc="/opt/openidea/acm/operator/claro/report/common/src/DDD.csv"
adesaodirectpac=${DIR}"/out/adesaoDirectPCRF_${DAY_PROCESS}"
directpacprocess=${DIR}"/cfg/directProcessPacsPCRF.txt"
desadesaodirectpac=${DIR}"/out/desadesaoDirectPCRF"
compulsorio=${DIR}"/src/compulsorio.txt.gz"
newfulladdpacdiariolist=${TMP_DIR}"/NEW_FULL_ADD_PAC_DIARIO_LIST_${DAY_PROCESS}"
fulladdpacdiariolist=${TMP_DIR}"/NEW_FULL_ADD_PAC_DIARIO_LIST_${DAY_PROCESS}.txt.gz"
newfulladdanypaclist=${TMP_DIR}"/NEW_FULL_ADD_ANYPAC_LIST_${DAY_PROCESS}"
fulladdanypaclist=${TMP_DIR}"/NEW_FULL_ADD_ANYPAC_LIST_${DAY_PROCESS}.txt.gz"


mkdir -p ${TMP_DIR}

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/control_pacs.kjb -level=Detailed \
     " -param:acm.job.dir.tmp="${TMP_DIR} \
     " -param:acm.job.file.in.addpcrf="${addpcrf} \
     " -param:acm.job.file.out.errorpac="${errorpac} \
     " -param:acm.job.file.in.fulladdpaclist="${fulladdpaclist} \
     " -param:acm.job.file.out.newfulladdpaclist="${newfulladdpaclist} \
     " -param:acm.job.file.cfg.pacprocess="${pacprocess} \
     " -param:acm.job.file.cfg.process="${PROCESS} \
     " -param:acm.job.file.out.adesao="${adesao} \
     " -param:acm.job.file.out.desadesao="${desadesao} \
     " -param:acm.job.file.cfg.ndc="${ndc} \
     " -param:acm.job.file.out.adesaodirectpac="${adesaodirectpac} \
     " -param:acm.job.file.cfg.directpacprocess="${directpacprocess} \
     " -param:acm.job.file.out.desadesaodirectpac="${desadesaodirectpac} \
     " -param:acm.job.file.in.compulsorio="${compulsorio} \
     " -param:acm.job.file.out.newfulladdpacdiariolist="${newfulladdpacdiariolist} \
     " -param:acm.job.file.in.fulladdpacdiariolist="${fulladdpacdiariolist} \
     " -param:acm.job.file.in.fulladdanypaclist="${fulladdanypaclist} \
     " -param:acm.job.file.out.newfulladdanypaclist="${newfulladdanypaclist} \
     " -param:acm.job.file.cfg.prioritypacs="${prioritypacs}


if [ -e "${newfulladdpaclist}.txt.gz" ];
then
    mv ${newfulladdpaclist}".txt.gz" ${DIR}"/prc/FULL_ADD_PACS_LIST_${DAY_PROCESS}.txt.gz"
fi

if [ -e "${newfulladdanypaclist}.txt.gz" ];
then
    mv ${newfulladdanypaclist}".txt.gz" ${DIR}"/prc/FULL_ADD_ANYPACS_LIST_${DAY_PROCESS}.txt.gz"
fi


if [ -e ${DIR}"/src/UPLIFT_PCTS_CONTRATADOS_${DAY_PROCESS}"*".txt.gz" ];
then
    mv ${DIR}"/src/"${pcrf_pac} ${PACOTES_DIR}"/prc/"${pcrf_pac} 
fi

#if [ -e "${adesao}.csv" ];
#then
    #mv ${adesao}".csv" ${ADESAO_DIR}"/adesao_pac_diario_${DAY_PROCESS}.csv"
#fi

if [ -e "${desadesao}.csv" ];
then
    #mv ${desadesao}".csv" ${DESADESAO_DIR}"/desadesao_pac_diario_${DAY_PROCESS}.csv"
    rm "${desadesao}.csv"
fi

if [ -e "${adesaodirectpac}.csv" ];
then
    mv ${adesaodirectpac}".csv" ${ADESAO_DIR}"/adesao_pac_pcrf_${DAY_PROCESS}.csv"
fi

if [ -e "${desadesaodirectpac}.csv" ];
then
    #mv ${desadesaodirectpac}".csv" ${DESADESAO_DIR}"/desadesao_pac_pcrf_${DAY_PROCESS}.csv"
    rm ${desadesaodirectpac}".csv"
fi

$(cat ${ADESAO_DIR}"/adesao_pac_pcrf_${DAY_PROCESS}.csv" >> ${ADESAO_DIR}"/adesao_pac_diario_${DAY_PROCESS}.csv")
#$(cat ${DESADESAO_DIR}"/desadesao_pac_pcrf_${DAY_PROCESS}.csv" >> ${DESADESAO_DIR}"/desadesao_pac_diario_${DAY_PROCESS}.csv")
$(cp ${DIR}"/prc/FULL_ADD_PACS_LIST_${DAY_PROCESS}.txt.gz" ${TMP_DIR}"/")
#$(gunzip ${TMP_DIR}"/FULL_ADD_PACS_LIST_${DAY_PROCESS}.txt.gz")
#mv ${TMP_DIR}"/FULL_ADD_PACS_LIST_${DAY_PROCESS}.txt" ${TMP_DIR}"/remove_pacote_diario_list.csv"
#$(scp ${TMP_DIR}"/remove_pacote_diario_list.csv" brux0794:/opt/openidea/acm/operator/claro/report/smartphone/src/remove/)

rm ${ADESAO_DIR}"/adesao_pac_pcrf_${DAY_PROCESS}.csv"
#rm ${DESADESAO_DIR}"/desadesao_pac_pcrf_${DAY_PROCESS}.csv"


mv ${ADESAO_DIR}"/adesao_pac_diario_"${DAY_PROCESS}".csv" ${ADESAO_DIR}"/UPLIFT_PCTS_CONTRATADOS_C_"${DAY_PROCESS}".txt"
$(gzip ${ADESAO_DIR}"/UPLIFT_PCTS_CONTRATADOS_C_"${DAY_PROCESS}".txt") 
cp ${ADESAO_DIR}"/UPLIFT_PCTS_CONTRATADOS_C_"${DAY_PROCESS}".txt.gz" ${PACOTES_DIR}"/prc/"
#executar adesão
#/opt/openidea/acm/operator/claro/event_process/generic_input.sh /opt/openidea/acm/operator/claro/event_process/cfg/pacote_PCRF.cfg
#$(/opt/openidea/acm/operator/claro/event_process/event/pacotes/generate_pct_evt.sh)



#mv ${DESADESAO_DIR}"/desadesao_pac_diario_"*".csv" "UPLIFT_PCTS_CONTRATADOS_D_"${DAY_PROCESS}".txt"
#executar desadesão
#/opt/openidea/acm/operator/claro/event_process/generic_input.sh /opt/openidea/acm/operator/claro/event_process/cfg/pacote_cancel_PCRF.cfg
#$(/opt/openidea/acm/operator/claro/event_process/event/pacotes/generate_cancel_pct_evt.sh)


rm -rf ${TMP_DIR}
