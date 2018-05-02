#!/bin/bash

DIR="$(cd "`dirname $0`/.." && pwd)"
DATE="$(date --date='-1 day'  +%Y%m%d%H%M%S)"

IN=$DIR/bin/aux/ngp
DEST=$DIR/fetcher/src/in_pacotes


zcat ${IN}/*.gz >> $IN/UPLIFT_NGP_CONTRATADOS_${DATE}_00001.txt

mv ${IN}/*.gz ${IN}/bkp

gzip ${IN}/UPLIFT_NGP_CONTRATADOS_${DATE}_00001.txt

mv ${IN}/UPLIFT_NGP_CONTRATADOS_${DATE}_00001.txt.gz ${DEST}
