#!/bin/bash

KEY_FILE=$1
PWD=$2

KETTLE_HOME="/opt/openidea/programs/pentaho_kettle/pdi-ce-6.0.1.0-386/data-integration/"

export KETTLE_HOME

PDI_BIN=${KETTLE_HOME}"/kitchen.sh"
DIR="/opt/openidea/acm/operator/claro/customer_update/balance-pdi"

P_PID=$1

# -level=Rowlevel/Debug/Detailed/Basic/Minimal/Nothing/Error -listparam

${PDI_BIN} -file=${DIR}/pdi/job/get-score-zb.kjb -level=Debug \
     " -param:cert_file="${KEY_FILE} \
     " -param:passwd="${PWD}

#rm -rf ${TMP_DIR}

