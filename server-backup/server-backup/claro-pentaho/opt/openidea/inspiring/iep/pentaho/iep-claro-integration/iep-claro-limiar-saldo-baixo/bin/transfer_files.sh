#!/bin/bash
DIR="$(cd "`dirname $0`/.." && pwd)"

if [ -f $DIR/bin/.transfer_files.lock ]; then
   echo "$(date +%Y-%m-%d_%H:%M:%S) - Processo ja esta em andamento, essa execucao sera abortada" >> $DIR/bin/transfer.log
   exit 1
fi

echo "lock" > $DIR/bin/.transfer_files.lock

FILE_NAME_START="THRESHOLD_"
DATA=$(date +%Y%m%d%H%M)
IN=$DIR/in
DEST=$DIR/src
SOURCE_PATTERN="acm@brux0020:/uplift/*.TNP"

echo "$(date +%Y-%m-%d_%H:%M:%S) - Iniciando copia de arquivos" >> $DIR/bin/transfer.log

scp $SOURCE_PATTERN $IN

echo "$(date +%Y-%m-%d_%H:%M:%S) - Aguardando 30s para verificacao de crescimento do arquivo" >> $DIR/bin/transfer.log
sleep 30s

for file in $IN/*; do
   size_local=$(ls -l $file | awk '{print $5}')
   filename=$(basename $file)
   size_remote=$(ssh acm@brux0020 "ls -l /uplift/$filename" | awk '{print $5}')
   if [ -z "$size_remote" ]; then
      echo "$(date +%Y-%m-%d_%H:%M:%S) - Arquivo nao encontrado no servidor e sera removido: $file" >> $DIR/bin/transfer.log
      rm -f $file
   else
      #echo "Arquivo copiado: $filename, tamanho local: $size_local, tamanho remoto: $size_remote"
      if [ "$size_local" -eq "$size_remote" ]; then
         echo "$(date +%Y-%m-%d_%H:%M:%S) - Processando arquivo: $filename" >> $DIR/bin/transfer.log
         ssh acm@brux0020 "rm /uplift/$filename"
         #mv $file $DEST
         #Concaternar arquivos:
         cat $file >> $DIR/in/$FILE_NAME_START$DATA.TNP
         rm -f $file
      else
         echo "$(date +%Y-%m-%d_%H:%M:%S) - Arquivo esta crescendo e sera removido: $file" >> $DIR/bin/transfer.log
         rm -f $file
      fi
   fi 
done

echo "$(date +%Y-%m-%d_%H:%M:%S) - Movendo arquivo para ser processado" >> $DIR/bin/transfer.log

mv $DIR/in/$FILE_NAME_START$DATA.TNP $DEST

rm -f $DIR/bin/.transfer_files.lock

echo "$(date +%Y-%m-%d_%H:%M:%S) - Processo finalizado" >> $DIR/bin/transfer.log
