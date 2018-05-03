#!/bin/bash

dt_0=$(date --date="0 days ago" +%Y%m%d)

DIR=/opt/openidea/acm/operator/claro/customer_update/balance-pdi

mv ${DIR}/ext/score_active.txt.gz ${DIR}/ext/unp/score_active_${dt_0}.txt.gz
mv ${DIR}/ext/score_zb.txt.gz ${DIR}/ext/unp/score_zb_${dt_0}.txt.gz
mv ${DIR}/ext/technology_segmentation.txt.gz ${DIR}/ext/unp/technology_segmentation_${dt_0}.txt.gz
mv ${DIR}/ext/universal_control_group.txt.gz ${DIR}/ext/unp/universal_control_group_${dt_0}.txt.gz
mv ${DIR}/ext/uplift_optinout.txt.gz ${DIR}/ext/unp/uplift_optinout_${dt_0}.txt.gz

touch ${DIR}/ext/unp/score_active.file
touch ${DIR}/ext/unp/score_zb.file
touch ${DIR}/ext/unp/technology_segmentation.file
touch ${DIR}/ext/unp/universal_control_group.file
touch ${DIR}/ext/unp/uplift_optinout.file

