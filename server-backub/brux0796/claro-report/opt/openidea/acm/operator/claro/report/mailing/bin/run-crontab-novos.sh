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

${BIN_DIR}"/run-split.sh" ${SPLIT_CFG_FILE} ${TODAY} ${TOMORROW}

${BIN_DIR}"/run-volume-control.sh" ${VOLUME_CFG_FILE} ${LEFTOVER_CFG_FILE} ${TODAY}

${BIN_DIR}"/run-volume-control.sh" ${VOLUME_CFG_FILE} ${LEFTOVER_CFG_FILE} ${TOMORROW}

TRUNC_DIR=/opt/openidea/acm/operator/claro/report/mailing/trunc


cd ${TRUNC_DIR}
rm Volu*

wc -l  ${TRUNC_DIR}/* >> ${TRUNC_DIR}/Volumetria_total_${TODAY}.txt.tmp

cat ${TRUNC_DIR}/Volumetria_total_${TODAY}.txt.tmp | awk '{print $1 $10}' FS="/" OFS="\t" >> ${TRUNC_DIR}/Volumetria_total_${TODAY}.txt

#echo -e "Bom dia a todos. \n\nSegue a volumetria do mailing disponibilizado hoje em anexo. \n\nOs arquivos de Mailing estão disponíveis em \santoanastacio\interface\uplift\mailing_offline  \n\nEm todos os mailings foram inseridos os NTCs de teste. \n\nPeço que acompanhem diariamente esta volumetria para garantir o alinhamento entre todas as partes envolvidas. \n\nAtenciosamente, \n\nVictor Lahr \nStefanini Inspiring" |/bin/mail -s "[Mailing Offline] Volumetria ${TODAY}" -a ${TRUNC_DIR}/Volumetria_total_${TODAY}.txt -r vlahr@stefanini.com vlahr@stefanini.com dgvaleta@stefanini.com  mbsilva3@stefanini.com rsmoya@stefanini.com mhcardoso@stefanini.com rsbarros3@stefanini.com kcseno@stefanini.com renata.pelatti@claro.com.br alexandre.rezende@claro.com.br fernanda.santosrodrigues@claro.com.br lilian.stoppa@net.com.br

#echo -e "Bom dia a todos. \n\nSegue a volumetria do mailing disponibilizado hoje em anexo. \n\nOs arquivos de Mailing estão disponíveis em \santoanastacio\interface\uplift\mailing_offline  \n\nEm todos os mailings foram inseridos os NTCs de teste. \n\nPeço que acompanhem diariamente esta volumetria para garantir o alinhamento entre todas as partes envolvidas. \n\nAtenciosamente, \n\nKaren Ximenes \nStefanini Inspiring" |/bin/mail -s "[Mailing Offline] Volumetria ${TODAY}" -a ${TRUNC_DIR}/Volumetria_total_${TODAY}.txt -r kcseno@stefanini.com kcseno@stefanini.com dgvaleta@stefanini.com  mbsilva3@stefanini.com rsmoya@stefanini.com mhcardoso@stefanini.com rsbarros3@stefanini.com vlahr@stefanini.com renata.pelatti@claro.com.br alexandre.rezende@claro.com.br fernanda.santosrodrigues@claro.com.br lilian.stoppa@net.com.br
  
#e_rcluiz@stefanini.com renata.pelatti@claro.com.br alexandre.rezende@claro.com.br fernanda.santosrodrigues@claro.com.br lilian.stoppa@net.com.br
 
#echo -e "Bom dia a todos. \n\nSegue a volumetria do mailing disponibilizado hoje em anexo. \n\nOs arquivos de Mailing estão disponíveis em \santoanastacio\interface\uplift\mailing_offline  \n\nEm todos os mailings foram inseridos os NTCs de teste. \n\nPeço que acompanhem diariamente esta volumetria para garantir o alinhamento entre todas as partes envolvidas. \n\nAtenciosamente, \n\nKaren Ximenes \nStefanini Inspiring" |/bin/mail -s "[Mailing Offline] Volumetria ${TODAY}" -a ${TRUNC_DIR}/Volumetria_total_${TODAY}.txt -r kcseno@stefanini.com kcseno@stefanini.com mhcardoso@stefanini.com

#echo -e "Mailing ${TODAY}" |/bin/mail -s "[Mailing Offline] Volumetria ${TODAY}" -a ${TRUNC_DIR}/Volumetria_total_${TODAY}.txt -r kcseno@stefanini.com kcseno@stefanini.com
 

#cd ${TRUNC_DIR}
#rm Volu*

#sftp santoanastacio <<EOF
#cd /d/interface/uplift/mailing_offline
#rm *
#put *.txt
#EOF
