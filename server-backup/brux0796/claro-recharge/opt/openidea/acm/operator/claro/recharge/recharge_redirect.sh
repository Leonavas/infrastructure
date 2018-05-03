#!/bin/sh

if [ ! $# -eq 1 ]
then
    echo "Usage: $0 <source|backlog>"
    exit 1
else
    CFG_FILE="/opt/openidea/acm/operator/claro/fetcher/config/recharge.cfg"

    if [ ${1} == "backlog" ]
    then
        ORG_STR="/opt/openidea/acm/operator/claro/recharge/source"
        DES_STR="/opt/openidea/acm/operator/claro/recharge/fetcher_backlog"
    elif [ ${1} == "source" ]
    then
        ORG_STR="/opt/openidea/acm/operator/claro/recharge/fetcher_backlog"
        DES_STR="/opt/openidea/acm/operator/claro/recharge/source"
        mv ${ORG_STR}/uplift_recargas_msisdns_*.txt ${DES_STR}/
    else
        echo "Usage: $0 <source|backlog>"
        exit 2
    fi

    sed -i -e "s:^dest_path=${ORG_STR}$:dest_path=${DES_STR}:g" ${CFG_FILE}
fi
