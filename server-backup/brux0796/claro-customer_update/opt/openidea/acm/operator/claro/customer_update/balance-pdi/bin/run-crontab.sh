#!/bin/bash

dt_0=$(date --date="0 days ago" +%Y%m%d)
dt_1=$(date --date="1 days ago" +%Y%m%d)
dt_2=$(date --date="2 days ago" +%Y%m%d)

P_PID=$$

DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi

################################################################################
# Prevents parallel execution of the same partition
################################################################################
pidfile=${DIR}"/run-crontab.pid"

if [ -e ${pidfile} ];
then
    pid=$(cat ${pidfile})

    if kill -0 &> /dev/null ${pid};
    then
        echo "Already running"
        exit 1
    else
        rm ${pidfile}
    fi
fi

echo ${P_PID} > ${pidfile}

function should_stop {
    __CURRENT_DATE=$(date --date="0 days ago" +%Y%m%d)
    while [ -e ${pidfile} ]
    do
        if [ ${__CURRENT_DATE} -eq ${dt_0} ]
        then
            sleep 60
            __CURRENT_DATE=$(date --date="0 days ago" +%Y%m%d)
        else
            ${DIR}"/bin/stop.sh" ${P_PID}            
        fi
    done
}

NEW_BALANCE_SN_FN="/opt/openidea/acm/operator/claro/files/balance/UPLIFT_SALDOS_"${dt_1}"_00001.txt.gz"

should_stop &

rm -rf ${DIR}/prc/*

${DIR}/bin/gen-score-active-file.sh

${DIR}/bin/gen-score-zb-file.sh

${DIR}/bin/pdi-run-process.sh \
    ${P_PID} \
    ${dt_1} \
    ${NEW_BALANCE_SN_FN} >> ${DIR}/log/run-crontab-${dt_1}.log

if [ ! $? -eq 0 ]
then
    echo "Failed executing Kettle job."
else
    mv ${DIR}"/tmp/"${P_PID}"/out/balance_analysis/Balance_Analysis_${dt_1}.csv.gz" ${DIR}"/out/balance_analysis/."
    
    #FILTER DE CLIENTES RETOMADOS PARA O MAILING
    zcat ${DIR}"/tmp/"${P_PID}"/out/final/balance_1.txt.gz" | sed '1d' | awk '{if($6=="ZB1" && $22<-90){print $2"|Retomado"}}' FS="|" > ${DIR}"/tmp/"${P_PID}"/out/balance_analysis/filter_retomadoa1dia.csv"  
    scp ${DIR}"/tmp/"${P_PID}"/out/balance_analysis/filter_retomadoa1dia.csv" brux0794:/opt/openidea/acm/operator/claro/report/smartphone/src/filter
    rm ${DIR}"/tmp/"${P_PID}"/out/balance_analysis/filter_retomadoa1dia.csv"
   

    mv ${DIR}"/tmp/"${P_PID}"/out/final/balance_1.txt.gz" "/opt/openidea/acm/operator/claro/files/balance/balance_prepago_"${dt_1}".txt.gz"

     zcat "/opt/openidea/acm/operator/claro/files/balance/balance_prepago_"${dt_1}".txt.gz"|sed '1d'|awk '{if ($6=="ZB1"){zb1++; l[91-$23]++} else if ($6=="A") {active++; if ($7<=4){active_threshold++}; if($21<=5){ativo_exp++}}} END{print "Cliente Ativo com Saldo <= R$4: " active_threshold; print "Cliente Ativo com Saldo a expirar: " ativo_exp;  print "Cliente ZB1-01: "l["1"]; print "Cliente ZB1-06: "l["6"]; print "Cliente ZB1-16: "l["16"]; print "Cliente ZB1-31: "l["31"]; print "Cliente ZB1-46: "l["46"]; print "Cliente ZB1-61: "l["61"]; print "Cliente ZB1-76: "l["76"]; print "Cliente ZB1-90: "l["90"]; print "Sync Total: " active_threshold + ativo_exp + l["1"] + l["6"] + l["16"] + l["31"] + l["46"] + l["61"] + l["76"] + l["90"]; print "Base Ativa: "active; print "Base ZB1: "zb1}' FS="|" > ${DIR}"/tmp/"${P_PID}"/resumo_mailing.txt"
     
     #cat ${DIR}"/tmp/"${P_PID}"/resumo_mailing.txt"|/bin/mail -s "Foto Saldo ${dt_1}" e_rcluiz@stefanini.com   

     cat ${DIR}"/tmp/"${P_PID}"/resumo_mailing.txt"|grep "Base" > ${DIR}"/tmp/"${P_PID}"/Base.txt"

     #/bin/mail -s "Base Pre ${dt_1}" alexandre.rezende@claro.com.br e_rcluiz@stefanini.com < ${DIR}"/tmp/"${P_PID}"/Base.txt"

    mv ${DIR}"/tmp/"${P_PID}"/out/final/full_balance.txt.gz" ${DIR}"/out/full_balance_"${dt_1}".txt.gz"

    ${DIR}/bin/generate_campaign_exit.sh ${P_PID}
    ${DIR}/bin/run-balance-analysis.sh 

    if [ -s ${DIR}"/tmp/"${P_PID}"/out/claro/unmapped-plan-customer-data.txt.gz" ]
    then
       zcat ${DIR}"/tmp/"${P_PID}"/out/claro/unmapped-plan-customer-data.txt.gz"|awk 'BEGIN {print "PLAN_CD;TOTAL_LINES"} {l[$3]++} END{for (i in l){print i";"l[i]}}' FS="|" |/bin/mail -s "Planos não mapeados na foto de saldo" kcseno@stefanini.com.br
    fi


fi

zip -j9 ${DIR}/log/run-crontab-${dt_1}.zip ${DIR}/log/run-crontab-${dt_1}.log
#tail -17 ${DIR}/log/run-crontab-${dt_1}.log |/bin/mail -s "Sync execution completed: ${dt_1}" -a ${DIR}/log/run-crontab-${dt_1}.zip operacaouplift@stefanini.com
 
rm ${DIR}/log/run-crontab-${dt_1}.zip

rm -rf ${pidfile} ${DIR}"/tmp/"*
