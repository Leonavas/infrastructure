#!/bin/bash

HOME_DIR="$(cd "`dirname $0`/.." && pwd)"


if [ -f ${HOME_DIR}"/src/boas-vindas-controle-pre-"*".txt" ];
then
    ${HOME_DIR}/bin/run.sh 1 boas-vindas-controle-pre.txt "boas-vindas-controle-pre-[0-9]{8}\.txt"
    process_result=$?
fi

exit $process_result

