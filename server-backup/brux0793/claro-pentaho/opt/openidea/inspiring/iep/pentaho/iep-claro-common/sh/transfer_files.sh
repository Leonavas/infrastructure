#!/bin/bash

SSH_OPTIONS="-qo PasswordAuthentication=no -o StrictHostKeyChecking=yes"

port=22
transfer_type="scp"
remove_files=0

#===============================================================
#
# Imprime instrucoes de uso
#
#===============================================================
function usage()
{
    echo "Uso: $0 [-fhrv] [-p PORTA] [-u USER] HOST ARQUIVO DESTINO"
    echo "Transfere arquivos remotos via SCP (ou SFTP como alternativa)"
    echo " "
    echo "    ARQUIVO: Caminho do arquivo buscado. Formato: host:path"
    echo "    DESTINO: Diretorio local para onde o arquivo sera copiado"
    echo
    echo "OPCOES: "
    echo " -p    porta para a transferencia. Padrao: 22"
    echo " -f    Usa o SFTP em vez do SCP"
    echo " -u    username"
    echo " -r    remove arquivos apos a transferencia"
    echo " -v    Modo verbose. Exibe informacoes de debug"
    echo " -h    exibe ajuda"
    echo
}

#===============================================================
#
# Remove arquivos copiados
#
#===============================================================
function removeFiles()
{

    echo "Removendo os arquivos..."
    ssh ${verbose} -o PasswordAuthentication=no -o StrictHostKeyChecking=yes ${host} rm ${from}
    remove_result=$?
    echo "Resultado da remocao: ${remove_result}"
    return $remove_result
}

#===============================================================
#
# Faz a transferencia via SCP
#
#===============================================================
function scpTransfer()
{
    scp ${verbose} -P $port -o PasswordAuthentication=no -o StrictHostKeyChecking=yes ${username}${host}:${from} ${to}
    result=$?
    echo "Resultado da transferencia via SCP: $result"

    if [[ $result -eq 0 && $remove_files -eq 1  ]];
    then
       removeFiles
       exit $?
    fi
    
    exit $result
}

#===============================================================
#
# Faz a transferencia via SFTP
#
#===============================================================
function sftpTransfer()
{
    sftp ${verbose} -o PasswordAuthentication=no -o StrictHostKeyChecking=yes ${username}${host}:${from} ${to}
    result=$?
    echo "Resultado da transferencia via SFTP: $result"

    if [[ $result -eq 0 && $remove_files -eq 1  ]];
    then
       removeFiles
       exit $?
    fi

    exit $result
}

#===============================================================
#   Le as opcoes
#===============================================================
while getopts p:t:u:fhrv opt; do
    case ${opt} in
        p)
            port="${OPTARG}"
            ;;
        f)
            transfer_type="sftp"
            ;;
        u)
            username="${OPTARG}@"
            ;;
        r)
            remove_files=1
            ;;
        v)
            verbose="-v"
            ;;
        h)
            usage
            exit 0
            ;;
        /?)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

# valida se os parametros foram informados
if [ $# -ne 3 ];
then
    usage
    exit 1
fi

host=$1
from=$2
to=$3

mkdir -p "${to}"

if [ "$transfer_type" == "sftp" ];
then
    sftpTransfer
else
    scpTransfer
fi

