#!/bin/bash
#
# Copia arquivo de FOTO DE SALDO  do servidor Santo Anastacio e move para os locais de processamento
#
#
DIR="$(cd "`dirname $0`/.." && pwd)"

SCRIPT=$(basename $0)
SCRIPT=${SCRIPT%.*}

if [ -f $DIR/bin/.$SCRIPT.lock ]; then
   echo "$(date +%Y-%m-%d_%H:%M:%S) - Processo ja esta em andamento, essa execucao sera abortada" >> $DIR/bin/$SCRIPT.log
   exit 1
fi

echo "lock" > $DIR/bin/.$SCRIPT.lock

IN=$DIR/in/$SCRIPT
DEST=$DIR/fetcher/src/dest_canc_pacotes
SOURCE_PATTERN="acm@10.18.50.175:/D/interface/UPLIFT/UPLIFT_PCTS_CANC_CONTRATO*"
SOURCE_FOLDER="D:\interface\UPLIFT"
SOURCE_IP="10.18.50.175"
SOURCE_USER="acm"

mkdir -p $IN

#echo "$DIR, $IN, $DEST"

scp $SOURCE_PATTERN $IN

echo "$(date +%Y-%m-%d_%H:%M:%S) - Aguardando 30s para verificacao de crescimento do arquivo" >> $DIR/bin/$SCRIPT.log
sleep 30s

for file in $IN/*; do
   size_local=$(ls -l $file | awk '{print $5}')
   filename=$(basename $file)
   size_remote=$(ssh ${SOURCE_USER}"@"${SOURCE_IP} " dir "${SOURCE_FOLDER}"\\${filename}" | grep $filename | awk '{print $3}' | sed -e 's/\.//g')
   if [ -z "$size_remote" ]; then
      echo "$(date +%Y-%m-%d_%H:%M:%S) - Arquivo nao encontrado no servidor e sera removido: $file" >> $DIR/bin/$SCRIPT.log
      rm -f $file
   else
      #echo "Arquivo copiado: $filename, tamanho local: $size_local, tamanho remoto: $size_remote"
      if [ "$size_local" -eq "$size_remote" ]; then
         echo "$(date +%Y-%m-%d_%H:%M:%S) - Arquivo pronto para ser processado: $filename" >> $DIR/bin/$SCRIPT.log
         ssh ${SOURCE_USER}@${SOURCE_IP} "del "${SOURCE_FOLDER}"\\${filename}"
         #$(dos2unix $file)
         #gzip $file
         #scp $file".gz" ${DEST2}
         #scp $file".gz" ${DEST3}
         #scp $file".gz" ${DEST4}
         mv $file ${DEST}
      else
         echo "$(date +%Y-%m-%d_%H:%M:%S) - Arquivo esta crescendo e sera removido: $file" >> $DIR/bin/$SCRIPT.log
         rm -f $file
      fi
   fi 
done

rm -f $DIR/bin/.$SCRIPT.lock

echo "$(date +%Y-%m-%d_%H:%M:%S) - Processo finalizado" >> $DIR/bin/$SCRIPT.log
