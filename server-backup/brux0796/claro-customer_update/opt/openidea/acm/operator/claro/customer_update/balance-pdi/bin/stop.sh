#!/bin/bash

DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi
P_PID=$1
TMP_DIR=${DIR}"/tmp/"${P_PID}

function move_to_unp {
    P_DIR=$1
    if [ -d ${TMP_DIR}"/out/new" ]
    then
        mkdir -p ${TMP_DIR}"/out/"${P_DIR}"/unp"
        for f in ${TMP_DIR}"/out/"${P_DIR}"/"*".gz"
        do
            if [ -e $f ]
            then
                mv $f ${TMP_DIR}"/out/"${P_DIR}"/unp/"
            fi
        done
    fi
}

move_to_unp "delete"
move_to_unp "update"
move_to_unp "new"
