#!/bin/bash
origin_folder=/home/dlandi/learning/tests/campanhas
temporary_folder=/tmp/campanhas
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

function moveFiles(){

while read x; do
	mkdir -p $3/${pastas_eventprocess[$1]}/
    mv $x $3/${pastas_eventprocess[$1]}/
done << EOF
$(ls $2/${campanhas_iep[$1]}*)
EOF

}

function sendFilesToEventProcess(){
while read file; do
	scp_result=$(echo scp ${SSH_OPTIONS} $temporary_folder/$1/${file} $dest_name:$dest_folder/${1})
    
    scp_result=$?

	if [ $scp_result -eq 0 ];
	then
        echo scp ${SSH_OPTIONS} $temporary_folder/$1/${file} $dest_name:$dest_folder/${1};
    else
        [ -d $temporary_folder/../error ] || mkdir $temporary_folder/../error
        mv $temporary_folder/$1/$file $temporary_folder/../error/
    fi
done << EOF
$(ls $temporary_folder/$1)
EOF
}

function moveFilesByType(){
	for i in {0..9}
	do
	    moveFiles $i $1 $2
	done
}

echo $READ_FROM_BACKLOG

if [ $READ_FROM_BACKLOG == "Y" ];
then
	moveFilesByType $temporary_folder/../error $temporary_folder
fi

moveFilesByType $origin_folder $temporary_folder

for i in 346_ZB60  active000  active400p  controleInvoluntarioZB  dualchip  exp5d  zb15
do
    sendFilesToEventProcess $i
done