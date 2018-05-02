#!/bin/bash

if [ $# -eq 3 ];
then
    SPLIT_CFG_FILE=${1}
    VOLUME_CFG_FILE=${2}
    LEFTOVER_CFG_FILE=${3}
else
    echo "Usage: $0 <SPLIT_CFG_FILE> <VOLUME_CFG_FILE> <LEFTOVER_CFG_FILE>"
    exit 1
fi

#===============================================================
#   CONSTANTES
#===============================================================

TODAY=$(date +%Y%m%d)
TOMORROW=$(date --date="1 day" +%Y%m%d)

HOME_DIR="$(cd "`dirname $0`/.." && pwd)"
BIN_DIR=${HOME_DIR}"/bin"

rm -rf ${HOME_DIR}"/trunc/"* ${HOME_DIR}"/split/"*

rm -rf ${HOME_DIR}"/trunc_1dia/"* ${HOME_DIR}"/split_1dia/"*

${BIN_DIR}"/run-split.sh" ${SPLIT_CFG_FILE} ${TODAY} ${TOMORROW}

${BIN_DIR}"/run-volume-control.sh" ${VOLUME_CFG_FILE} ${LEFTOVER_CFG_FILE} ${TODAY}

${BIN_DIR}"/run-volume-control.sh" ${VOLUME_CFG_FILE} ${LEFTOVER_CFG_FILE} ${TOMORROW}

TRUNC_DIR=/opt/openidea/acm/operator/claro/report/mailing/trunc

${BIN_DIR}"/run-split_1dia.sh" ${SPLIT_CFG_FILE} ${TODAY} ${TOMORROW}

${BIN_DIR}"/run-volume-control_1dia.sh" ${VOLUME_CFG_FILE} ${LEFTOVER_CFG_FILE} ${TODAY}

${BIN_DIR}"/run-volume-control_1dia.sh" ${VOLUME_CFG_FILE} ${LEFTOVER_CFG_FILE} ${TOMORROW}

TRUNC_DIR_1DIA=/opt/openidea/acm/operator/claro/report/mailing/trunc_1dia

TRUNC_NUANCE=/opt/openidea/acm/operator/claro/report/mailing/trunc_nuance

cd ${TRUNC_DIR}
rm Volu*
cd ..

cd ${TRUNC_DIR_1DIA}
rm Volu*
cd ..

wc -l trunc/* trunc_1dia/* | awk '{print $1"/"$2}' | awk '{if ($2=="total"){print $1 " "$2} else{print $1 " " $3}}' FS="/" > ${TRUNC_DIR}/Volumetria_total_${TODAY}.txt


echo -e "Bom dia a todos. \n\nSegue a volumetria do mailing disponibilizado hoje em anexo. \n\nOs arquivos de Mailing estão disponíveis em \santoanastacio\interface\uplift\mailing_offline  \n\nOs arquivos de Mailing de Torpedo Fone para Clientes Novos Sem Recarga está disponível em \santoanastacio\interface\uplift\mailing_offline\nuance\ \n\nEm todos os mailings foram inseridos os NTCs de teste. \n\nPeço que acompanhem diariamente esta volumetria para garantir o alinhamento entre todas as partes envolvidas. \n\nAtenciosamente, \n\nKaren Ximenes \nStefanini Inspiring" |/bin/mail -s "[Mailing Offline] Volumetria ${TODAY}" -a ${TRUNC_DIR}/Volumetria_total_${TODAY}.txt -r rsmoya@stefanini.com kcseno@stefanini.com rsmoya@stefanini.com 

 

cd ${TRUNC_DIR}
rm Volu*
cd ..
cd ${TRUNC_DIR_1DIA}
rm Volu*
cd ..

cd ${TRUNC_DIR_1DIA}
mv "D3_FalaMais_14dias"*".txt" "D5_FalaMais_14dias"*".txt" "D7_FalaMais_14dias"*".txt" "D9_FalaMais_14dias"*".txt" "D11_FalaMais_14dias"*".txt" "D13_FalaMais_14dias"*".txt" "D15_FalaMais_14dias"*".txt" "D17_FalaMais_14dias"*".txt" "D19_FalaMais_14dias"*".txt" "D21_FalaMais_14dias"*".txt" "D23_FalaMais_14dias"*".txt" "D25_FalaMais_14dias"*".txt" "D27_FalaMais_14dias"*".txt" "D29_FalaMais_14dias"*".txt" "D3_Ilimitado"*".txt" "D5_Ilimitado"*".txt" "D7_Ilimitado"*".txt" "D9_Ilimitado"*".txt" "D11_Ilimitado"*".txt" "D13_Ilimitado"*".txt" "D15_Ilimitado"*".txt" "D17_Ilimitado"*".txt" "D19_Ilimitado"*".txt" "D21_Ilimitado"*".txt" "D23_Ilimitado"*".txt" "D25_Ilimitado"*".txt" "D27_Ilimitado"*".txt" "D29_Ilimitado"*".txt" "D3_MuitoMais_7dias"*".txt" "D5_MuitoMais_7dias"*".txt" "D7_MuitoMais_7dias"*".txt" "D9_MuitoMais_7dias"*".txt" "D11_MuitoMais_7dias"*".txt" "D13_MuitoMais_7dias"*".txt" "D15_MuitoMais_7dias"*".txt" "D17_MuitoMais_7dias"*".txt" "D19_MuitoMais_7dias"*".txt" "D21_MuitoMais_7dias"*".txt" "D23_MuitoMais_7dias"*".txt" "D25_MuitoMais_7dias"*".txt" "D27_MuitoMais_7dias"*".txt" "D29_MuitoMais_7dias"*".txt" ${TRUNC_NUANCE}

cd ..
mv ${TRUNC_DIR_1DIA}"/"* ${TRUNC_DIR}
cd ${TRUNC_DIR}

