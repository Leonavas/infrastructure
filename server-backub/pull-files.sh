#!/bin/bash

#find /opt/openidea/acm/operator/claro/bin -type f -name "*.sh"

# brux0796 
#- scripts /opt/openidea/acm/operator/claro/bin
#claro-bin
#/opt/openidea/acm/server-backup/claro-bin

# CLARO-PRD-01/opt/devops/server-backups/brux0796

# CLARO-PRD-01

ssh acm@brux0796 <<EOF
  find /opt/openidea/acm/operator/claro/bin  \
       -type f -regex ".*\.\(sh\|kjb\|ktr\)" \
       -exec cp --parents {} /opt/openidea/acm/server-backup/claro-bin \;
EOF

#- scripts /opt/openidea/acm/operator/claro/report 
#claro-report
#/opt/openidea/acm/server-backup/claro-report
find /opt/openidea/acm/operator/claro/report  \
     -type f -regex ".*\.\(sh\|kjb\|ktr\)" \
     -exec cp --parents {} /opt/openidea/acm/server-backup/claro-report \;


ssh acm@brux0796 <<EOF
  find /opt/openidea/acm/operator/claro/report  \
       -type f -regex ".*\.\(sh\|kjb\|ktr\)" \
       -exec cp --parents {} /opt/openidea/acm/server-backup/claro-report \;
EOF

ssh acm@brux0796 <<EOF
cd /opt/openidea/acm/ 
rm server-backup.tar 
tar -xf server-backup.tar server-backup
EOF

scp acm@brux0796:/opt/openidea/acm/server-backup.tar \
    /opt/devops/server-backups/brux0796

scp -P 22333 root@200.143.189.254:/opt/devops/server-backups/brux0796/server-backup.tar ./