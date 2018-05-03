#!/bin/bash

DIR="$(cd "`dirname $0`/.." && pwd)"

if [ -f $DIR/bin/.transfer_files_foto_saldo.lock ]; then
   echo "$(date +%Y-%m-%d_%H:%M:%S) - Processo ja esta em andamento, essa execucao sera abortada" >> $DIR/log/transfer_foto_saldo.log
   exit 1
fi

echo "lock" > $DIR/bin/.transfer_files_foto_saldo.lock

IN=/opt/openidea/acm/operator/claro/fetcher/in/
DEST=/opt/openidea/acm/operator/claro/fetcher/src
FINAL=/opt/openidea/acm/operator/claro/files/balance

echo "$DIR, $IN, $DEST"

cd  $IN
sftp santoanastacio <<EOF
cd /d/interface/uplift
get UPLIFT_SALDOS*
EOF


echo "$(date +%Y-%m-%d_%H:%M:%S) - Aguardando 30s para verificacao de crescimento do arquivo" >> $DIR/log/transfer_foto_saldo.log
sleep 30s

for file in $IN/UPLIFT_SALDOS*; do
   size_local=$(ls -l $file | awk '{print $5}')
   filename=$(basename $file)
   size_remote=$ sftp santoanastacio   <<EOF 
   ls -l /d/interface/uplift/$filename | awk '{print $5}' 
   EOF
   
   if [ -z "$size_remote" ]; then
      echo "$(date +%Y-%m-%d_%H:%M:%S) - Arquivo nao encontrado no servidor e sera removido: $file" >> $DIR/log/transfer_foto_saldo.log
      #rm -f $file
   else
      echo "Arquivo copiado: $filename, tamanho local: $size_local, tamanho remoto: $size_remote"
      if [ "$size_local" -eq "$size_remote" ]; then
         echo "$(date +%Y-%m-%d_%H:%M:%S) - Arquivo pronto para ser processado: $filename" >> $DIR/log/transfer_foto_saldo.log
 #        ssh acm@santoanastacio "rm /d/interface/uplift/$filename"
         mv $file $DEST
		 cd $DEST
		 gzip UPLIFT_SALDOS*txt
      else
         echo "$(date +%Y-%m-%d_%H:%M:%S) - Arquivo esta crescendo e sera removido: $file" >> $DIR/log/transfer_foto_saldo.log
#         rm -f $file
      fi
   fi
done

rm -f $DIR/bin/.transfer_files_foto_saldo.lock

echo "$(date +%Y-%m-%d_%H:%M:%S) - Processo finalizado" >> $DIR/log/transfer_foto_saldo.log

cp $DEST/UPLIFT_SALDOS*gz $FINAL/

