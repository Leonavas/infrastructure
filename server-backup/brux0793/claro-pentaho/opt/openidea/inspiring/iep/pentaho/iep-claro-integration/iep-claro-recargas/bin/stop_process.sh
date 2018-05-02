#!/bin/bash

#===============================================================
#   CONSTANTES
#===============================================================
HOME_DIR="$(cd "`dirname $0`/.." && pwd)"

FORCE_STOP=0

#===============================================================
#   FUNCOES
#===============================================================
function usage()
{
    echo "Uso: $0 [-fh]"
    echo "Inicia parada do processo de recarga."
    echo "Se a opcao -f estiver ligada, o processo para enviar recargas ao IEP"
    echo "Se a opcao -f estiver desligada, o processo aguarda o termino do envio das recargas ao IEP"
    echo " "
    echo " Opcoes:"
    echo " -f    Forca parada"
    echo " -h    Exibe ajuda"
}

#===============================================================
#   MAIN SCRIPT
#===============================================================

#===============================================================
#   READ THE OPTIONS
#===============================================================
while getopts fh opt; do
    case ${opt} in
        f)
            FORCE_STOP=1
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Opcao invalida: -$OPTARG" >&2
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

echo "Criando arquivo de parada. O job sera finalizado em breve"
touch ${HOME_DIR}/var/stop

if [ $FORCE_STOP -eq 1 ];
then
    touch ${HOME_DIR}/var/force_stop
fi