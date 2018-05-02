#!/bin/bash

if [ ! $# -eq 1 ]
then
    echo "Usage $0 < 1 para segunda / 2 para terca a quinta / 3 para sexta>"
    exit 1
fi

###################
#### Variaveis ####
###################
current_day=$(date +%Y%m%d)
bef_1day=$(date --date="1 days ago" +%Y%m%d)

####################
#### Diretorios ####
####################
DIR_MAILING_OUT="/opt/openidea/acm/operator/claro/report/mailing/out/"
DIR_MAILING_FINAL="/opt/openidea/acm/operator/claro/report/mailing/out/mailing_final/"

#####################################################
######### Limpa o diretorio a ser utilizado #########
#####################################################

echo "Limpando o diretorio /out /mailing_final "

rm ${DIR_MAILING_OUT}/*$bef_1day*
rm ${DIR_MAILING_FINAL}/*

echo ""
#################################################
########## Gera arquivos para segunda  ##########
#################################################

if [ $1 == 1 ]; then

echo "Iniciando mailing de segunda-feira"
echo ""


#####################################################
#### Funcao que divide a volumetria dos mailings ####
#####################################################

 function split_mailing {
     __fn=$1
     __new_fn=$2
     __nr_files=$3
     __max_lines=$4
     __lines=$(wc -l ${__fn} |awk '{print $1}')
 
     __sp_lines=$((1+${__lines}/${__nr_files}))
 
 #    sort -T ${dir} ${__f} > ${__f}".sort"
 #    mv ${__f}".sort" ${__f}
 
     split --lines=${__sp_lines} --numeric-suffixes --suffix-length=1 ${__fn} ${__new_fn}"."
 
     for __f in ${__new_fn}"."*
     do
         cat ${__f} | sort -R -T ${DIR_MAILING_OUT}|head -${__max_lines} > ${__f}".unix"
         awk 'sub("$", "\r")' ${__f}".unix" > ${__f}".txt"
         zip -mj9 ${__f}".zip" ${__f}".txt"
         rm ${__f}
        # echo ${__f}
 
     done
 }

NR_FILES=2
 
split_mailing ${DIR_MAILING_OUT}"/clarogiga_optin_"${current_day}".txt" ${DIR_MAILING_FINAL}"/clarogiga_optin_"${current_day} ${NR_FILES} 400000    
split_mailing ${DIR_MAILING_OUT}"/clarogiga_optout_"${current_day}".txt"  ${DIR_MAILING_FINAL}"/clarogiga_optout_"${current_day} ${NR_FILES} 400000
split_mailing ${DIR_MAILING_OUT}"/clarosupergiga_optin_"${current_day}".txt" ${DIR_MAILING_FINAL}"/clarosupergiga_optin_"${current_day} ${NR_FILES} 400000    
split_mailing ${DIR_MAILING_OUT}"/clarosupergiga_optout_"${current_day}".txt"  ${DIR_MAILING_FINAL}"/clarosupergiga_optout_"${current_day} ${NR_FILES} 350000

##########################################
####### Definicao de prioridade ZB #######
##########################################
head -249993 ${DIR_MAILING_OUT}/zb15_smartphone_progressiva_${current_day}.txt >> ${DIR_MAILING_FINAL}/zb15_smartphone_progressiva_${current_day}.txt
head -249993 ${DIR_MAILING_OUT}/zb15_smartphone_regressiva_${current_day}.txt  >> ${DIR_MAILING_FINAL}/zb15_smartphone_regressiva_${current_day}.txt
head -249993 ${DIR_MAILING_OUT}/zb30_smartphone_progressiva_${current_day}.txt >> ${DIR_MAILING_FINAL}/zb30_smartphone_progressiva_${current_day}.txt
head -249993 ${DIR_MAILING_OUT}/zb30_smartphone_regressiva_${current_day}.txt  >> ${DIR_MAILING_FINAL}/zb30_smartphone_regressiva_${current_day}.txt

cat ${DIR_MAILING_OUT}/mailing_adicional.txt >> ${DIR_MAILING_FINAL}/zb15_smartphone_progressiva_${current_day}.txt
cat ${DIR_MAILING_OUT}/mailing_adicional.txt >> ${DIR_MAILING_FINAL}/zb15_smartphone_regressiva_${current_day}.txt
cat ${DIR_MAILING_OUT}/mailing_adicional.txt >> ${DIR_MAILING_FINAL}/zb30_smartphone_progressiva_${current_day}.txt
cat ${DIR_MAILING_OUT}/mailing_adicional.txt >> ${DIR_MAILING_FINAL}/zb30_smartphone_regressiva_${current_day}.txt



###########################################
# Gera arquivos de Terça a Quinta  ########
###########################################

elif [ $1 == 2 ]; then

echo "Iniciando mailing de terça/quarta/quinta"
echo ""

#########################################
#### Definicao de prioridade Consumo ####
#########################################


cp ${DIR_MAILING_OUT}/clarogiga_optin_${current_day}.txt ${DIR_MAILING_FINAL}/clarogiga_optin_${current_day}.txt
cp ${DIR_MAILING_OUT}/clarogiga_optout_${current_day}.txt ${DIR_MAILING_FINAL}/clarogiga_optout_${current_day}.txt
cp ${DIR_MAILING_OUT}/clarosupergiga_optin_${current_day}.txt ${DIR_MAILING_FINAL}/clarosupergiga_optin_${current_day}txt
cp ${DIR_MAILING_OUT}/clarosupergiga_optout_${current_day}.txt ${DIR_MAILING_FINAL}/clarosupergiga_optout_${current_day}.txt


##########################################
####### Definicao de prioridade ZB #######
##########################################

head -249993 ${DIR_MAILING_OUT}/zb15_smartphone_progressiva_${current_day}.txt >> ${DIR_MAILING_FINAL}/zb15_smartphone_progressiva_${current_day}.txt
head -249993 ${DIR_MAILING_OUT}/zb15_smartphone_regressiva_${current_day}.txt  >> ${DIR_MAILING_FINAL}/zb15_smartphone_regressiva_${current_day}.txt
head -249993 ${DIR_MAILING_OUT}/zb30_smartphone_progressiva_${current_day}.txt >> ${DIR_MAILING_FINAL}/zb30_smartphone_progressiva_${current_day}.txt
head -249993 ${DIR_MAILING_OUT}/zb30_smartphone_regressiva_${current_day}.txt  >> ${DIR_MAILING_FINAL}/zb30_smartphone_regressiva_${current_day}.txt

cat ${DIR_MAILING_OUT}/mailing_adicional.txt >> ${DIR_MAILING_FINAL}/zb15_smartphone_progressiva_${current_day}.txt
cat ${DIR_MAILING_OUT}/mailing_adicional.txt >> ${DIR_MAILING_FINAL}/zb15_smartphone_regressiva_${current_day}.txt
cat ${DIR_MAILING_OUT}/mailing_adicional.txt >> ${DIR_MAILING_FINAL}/zb30_smartphone_progressiva_${current_day}.txt
cat ${DIR_MAILING_OUT}/mailing_adicional.txt >> ${DIR_MAILING_FINAL}/zb30_smartphone_regressiva_${current_day}.txt


#################################################
########### Gera arquivos de Sexta  #############
#################################################

elif [ $1 == 3 ]; then

echo "Iniciando mailing de sexta"
echo ""

#########################################
#### Definicao de prioridade Consumo ####
#########################################

head -200000 ${DIR_MAILING_OUT}/clarogiga_optin_${current_day}.txt >> ${DIR_MAILING_FINAL}/clarogiga_optin_${current_day}.txt
head -200000 ${DIR_MAILING_OUT}/clarogiga_optout_${current_day}.txt  >> ${DIR_MAILING_FINAL}/clarogiga_optout_${current_day}.txt
head -250000 ${DIR_MAILING_OUT}/clarosupergiga_optin_${current_day}.txt >> ${DIR_MAILING_FINAL}/clarosupergiga_optin_${current_day}.txt
head -250000 ${DIR_MAILING_OUT}/clarosupergiga_optout_${current_day}.txt  >> ${DIR_MAILING_FINAL}/clarosupergiga_optout_${current_day}.txt


##########################################
####### Definicao de prioridade ZB #######
##########################################

function split_mailing {
     __fn=$1
     __new_fn=$2
     __nr_files=$3
     __max_lines=$4
     __lines=$(wc -l ${__fn} |awk '{print $1}')
 
     __sp_lines=$((1+${__lines}/${__nr_files}))
 
 #    sort -T ${dir} ${__f} > ${__f}".sort"
 #    mv ${__f}".sort" ${__f}
 
     split --lines=${__sp_lines} --numeric-suffixes --suffix-length=1 ${__fn} ${__new_fn}"."
 
     for __f in ${__new_fn}"."*
     do
         cat ${__f} | sort -R -T ${DIR_MAILING_OUT}|head -${__max_lines} > ${__f}".unix"
         awk 'sub("$", "\r")' ${__f}".unix" > ${__f}".txt"
         zip -mj9 ${__f}".zip" ${__f}".txt"
         rm ${__f}
        # echo ${__f}
 
     done
 }

NR_FILES=2
 
split_mailing ${DIR_MAILING_OUT}"/zb15_smartphone_progressiva_"${current_day}".txt" ${DIR_MAILING_FINAL}"/zb15_smartphone_progressiva_"${current_day} ${NR_FILES} 400000    
split_mailing ${DIR_MAILING_OUT}"/zb15_smartphone_regressiva_"${current_day}".txt"  ${DIR_MAILING_FINAL}"/zb15_smartphone_regressiva_"${current_day} ${NR_FILES} 400000
split_mailing ${DIR_MAILING_OUT}"/zb30_smartphone_progressiva_"${current_day}".txt" ${DIR_MAILING_FINAL}"/zb30_smartphone_progressiva_"${current_day} ${NR_FILES} 400000    
split_mailing ${DIR_MAILING_OUT}"/zb30_smartphone_regressiva_"${current_day}".txt"  ${DIR_MAILING_FINAL}"/zb30_smartphone_regressiva_"${current_day} ${NR_FILES} 400000

fi
#################################
#### Torpedo phone ##############
#################################
 
cp ${DIR_MAILING_OUT}"/zb15_torpedo_phone_smartphone_progressiva_"${current_day}".txt" ${DIR_MAILING_FINAL}"/zb15_torpedo_phone_smartphone_progressiva_"${current_day}".txt"
cp ${DIR_MAILING_OUT}"/zb30_torpedo_phone_smartphone_progressiva_"${current_day}".txt" ${DIR_MAILING_FINAL}"/zb30_torpedo_phone_smartphone_progressiva_"${current_day}".txt"

#################################
##### Volumetria ################
################################# 

cd ${DIR_MAILING_FINAL}

   wc -l *txt  > "volumetria_mailing_offline_"${current_day}".txt"
   wc -l *unix |sed 's/.unix//g'|awk 'sub("$", "\r")' >> "volumetria_mailing_offline_"${current_day}".txt"

#echo -e "Bom dia a todos. \n\nSegue a volumetria do mailing disponibilizado hoje em anexo. \n\nOs arquivos de Mailing estão disponíveis em \santoanastacio\interface\uplift\mailing_offline \n \n\nPeço que acompanhem diariamente esta volumetria para garantir o alinhamento entre todas as partes envolvidas. \n\nAtenciosamente, \n\nKaren Ximenes \nStefanini Inspiring" |/bin/mail -s "[Mailing Offline] Volumetria ${current_day}" -r kcseno@stefanini.com -a ${dir_sort}/volumetria_mailing_offline_${current_day}.txt -a  -a ${DIR_MAILING_OUT}/nuance_sftp/volumetria_mailing_TORPEDO_PHONE_${current_day}.txt kcseno@stefanini.com e_rcluiz@stefanini.com renata.pelatti@claro.com.br alexandre.rezende@claro.com.br fernanda.santosrodrigues@claro.com.br lilian.stoppa@net.com.br

#echo -e "Volumetria do Mailing" |/bin/mail -s "[Mailing Offline] Volumetria ${current_day}" -r kcseno@stefanini.com -a ${DIR_MAILING_FINAL}/volumetria_mailing_offline_${current_day}.txt kcseno@stefanini.com 

#echo -e "Bom dia a todos. \n\nSegue a volumetria do mailing disponibilizado hoje em anexo. \n\nOs arquivos de Mailing estão disponíveis em \santoanastacio\interface\uplift\mailing_offline  \n \n\nPeço que acompanhem diariamente esta volumetria para garantir o alinhamento entre todas as partes envolvidas. \n\nAtenciosamente, \n\nKaren Ximenes \nStefanini Inspiring" |/bin/mail -s "[Mailing Offline] Volumetria ${current_day}" -r kcseno@stefanini.com -a ${DIR_MAILING_FINAL}/volumetria_mailing_offline_${current_day}.txt kcseno@stefanini.com e_rcluiz@stefanini.com renata.pelatti@claro.com.br alexandre.rezende@claro.com.br fernanda.santosrodrigues@claro.com.br lilian.stoppa@net.com.br

echo -e "Bom dia a todos. \n\nSegue a volumetria do mailing disponibilizado hoje em anexo. \n\nOs arquivos de Mailing estão disponíveis em \santoanastacio\interface\uplift\mailing_offline  \n\nNos seguintes mailings: \nzb15_smartphone_progressiva_${current_day}.txt \nzb15_smartphone_regressiva_${current_day}.txt \nzb30_smartphone_progressiva_${current_day}.txt \nzb30_smartphone_regressiva_${current_day}.txt \n\nForam inseridos os seguintes NTCs: \n11992499095 \n11993305066 \n11992279643 \n19991932922 \n11963394099 \n11976228953 \n19992920073 \n\nPeço que acompanhem diariamente esta volumetria para garantir o alinhamento entre todas as partes envolvidas. \n\nAtenciosamente, \n\nKaren Ximenes \nStefanini Inspiring" |/bin/mail -s "[Mailing Offline] Volumetria ${current_day}" -r kcseno@stefanini.com -a ${DIR_MAILING_FINAL}/volumetria_mailing_offline_${current_day}.txt kcseno@stefanini.com e_rcluiz@stefanini.com renata.pelatti@claro.com.br alexandre.rezende@claro.com.br fernanda.santosrodrigues@claro.com.br lilian.stoppa@net.com.br


##########################################
###### Mover para Santo Anastacio ########
##########################################

cd ${DIR_MAILING_FINAL}

sftp santoanastacio <<EOF
cd /d/interface/uplift/mailing_offline
put *.txt
put *.zip
EOF

##########################################
######## Mover para Jundiai ##############
##########################################

#scp ${DIR_MAILING_FINAL}zb*  acm@jundiai:/home/nuance_uplift/

##########################################
##### Remocao de arquivos temporarios#####
##########################################

rm ${DIR_MAILING_OUT}*${bef_1day}*.txt
rm ${DIR_MAILING_OUT}/*.unix
rm ${DIR_MAILING_FINAL}/*.unix
rm ${DIR_MAILING_FINAL}/*tmp
rm ${DIR_MAILING_OUT}/*.unix
rm ${DIR_MAILING_OUT}/*tmp

