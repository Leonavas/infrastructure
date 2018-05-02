#!/bin/bash

origin_folder=/opt/openidea/inspiring/iep/iep-claro-server/var/log/campanha
temporary_folder=/opt/openidea/inspiring/iep/migration/tmp
dest_folder=/opt/openidea/acm/operator/claro/event_process/event/smartphone_mailing/src
dest_name=brux0796
READ_FROM_BACKLOG="N"
SSH_OPTIONS="-qo PasswordAuthentication=no -o StrictHostKeyChecking=yes"
#===============================================================
#   READ THE OPTIONS
#===============================================================
while getopts ":b" opt; do
  case $opt in
    b)
      READ_FROM_BACKLOG="Y"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

#seta as campanhas no IEP por nome ordenadamente
campanhas_iep=();
campanhas_iep[0]="AtivoOptout";
campanhas_iep[1]="ZBFimRegua";
campanhas_iep[2]="ZBControleInvoluntario";
campanhas_iep[3]="ZBPilotoRSePS";
campanhas_iep[4]="ZBPilotoNE";
campanhas_iep[5]="ZBAtivoDualSim";
campanhas_iep[6]="AtivoRevalidacaoSaldo";
campanhas_iep[7]="AtivoTM";
campanhas_iep[8]="ZBComRetomada";
campanhas_iep[9]="ZBSemRetomada";

#seta os nomes das pastas de destino (para processamento no EventProcess) ordenadamente
pastas_eventprocess=();
pastas_eventprocess[0]="active400p";
pastas_eventprocess[1]="346_ZB60";
pastas_eventprocess[2]="controleInvoluntarioZB";
pastas_eventprocess[3]="zb15";
pastas_eventprocess[4]="zb15";
pastas_eventprocess[5]="dualchip";
pastas_eventprocess[6]="exp5d";
pastas_eventprocess[7]="active000";
pastas_eventprocess[8]="zb15";
pastas_eventprocess[9]="zb15";

function log()
{
    message=$1
    date=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[${date}] ${message}"
}

function moveFiles(){
    campaign_name=$1
    source_dir=$2
    dest_dir=$3

    for campaign_file in $(ls $source_dir/${campanhas_iep[$campaign_name]}_*);
    do
        mkdir -p $dest_dir/${pastas_eventprocess[$campaign_name]}/
        mv $campaign_file $dest_dir/${pastas_eventprocess[$campaign_name]}/
    done
}

function sendFilesToEventProcess(){
    acm_campaign_dir=$1

    nfiles=$(ls $temporary_folder/$acm_campaign_dir | wc -l)

    if [ $nfiles -eq 0 ];
    then
        log "Nenhum arquivo encontrado para a campanha ${acm_campaign_dir}"
        return 0;
    fi

    log "Arquivos para mover: ${nfiles}"

    for file in $(ls $temporary_folder/$acm_campaign_dir);
    do
        log "Movendo arquivo ${file}"
        scp_result=$(scp ${SSH_OPTIONS} $temporary_folder/$acm_campaign_dir/${file} $dest_name:$dest_folder/$acm_campaign_dir)
    
        scp_result=$?

        if [ $scp_result -eq 0 ];
        then
            log "Arquivo ${file} movido com sucesso"
            rm $temporary_folder/$acm_campaign_dir/${file}
        else
            log "Erro ao mover arquivo ${file}. Retorno: $scp_result"
            mkdir -p $temporary_folder/../error
            mv $temporary_folder/$acm_campaign_dir/$file $temporary_folder/../error/
        fi
    done
}

function moveFilesByType(){
    for i in {0..9}
    do
        moveFiles $i $1 $2
    done
}

log "Processa backlog: ${READ_FROM_BACKLOG}"

if [ $READ_FROM_BACKLOG == "Y" ];
then
    moveFilesByType $temporary_folder/../error $temporary_folder
fi

moveFilesByType $origin_folder $temporary_folder

for acm_campaign in 346_ZB60  active000  active400p  controleInvoluntarioZB  dualchip  exp5d  zb15
do
    sendFilesToEventProcess $acm_campaign
done
