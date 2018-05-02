#!/bin/bash

if [ $# -eq 1 ]
then
    INPUT_DATE=$1
else
    INPUT_DATE=$(date --date="1 days ago")
fi

REPORT_DATE=$(date --date="${INPUT_DATE}" +%Y%m)
EXTRACT_DATE=${INPUT_DATE}

DIR=/opt/openidea/acm/operator/claro/report/campaign-detailed-movement

find ${DIR}/log/*.* -type f -mtime +7 -delete

sh ${DIR}/bin/extract-data.sh "${EXTRACT_DATE}"
if ! [ $? -eq 0 ]; then
    exit 1
fi

sh ${DIR}/bin/parse-files.sh "${REPORT_DATE}"
if ! [ $? -eq 0 ]; then
    exit 2
fi

sh ${DIR}/bin/campaign-analysis.sh "${REPORT_DATE}"
if ! [ $? -eq 0 ]; then
    exit 3
fi

sh ${DIR}/bin/no-incentive-detail.sh "${REPORT_DATE}"
if ! [ $? -eq 0 ]; then
    exit 4
fi
