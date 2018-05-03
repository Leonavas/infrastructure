#!/bin/sh

#sh  /opt/openidea/acm/operator/claro/low_balance_threshold/stop_lsb_listener.sh
#sleep 2

if [ $( ps -ef | grep inotify | grep recharge | wc -l) != 3 ] ;
 then
	sh /opt/openidea/acm/operator/claro/recharge/stop_recharge_listener.sh
	sleep 2
	sh /opt/openidea/acm/operator/claro/recharge/start_recharge_listener.sh
fi

