#/bin/sh
LOGFILE=/opt/openidea/acm/operator/claro/recharge/log/recharge_listener.log

ps aux | grep inotify_recharge.sh | awk '{ if (NR <=2) { print $2 } }' | xargs kill -9 2>/dev/null
ps aux | grep "/opt/openidea/acm/operator/claro/recharge/source" | grep -v "grep" | awk '{ print $2 }' | xargs kill -9 2>/dev/null
RETVAL=$?
if [ $RETVAL -eq 0 ]; then
        echo "Recharge Listener stoped."
        echo -e "Recharge Listener Stoped!" >> $LOGFILE
else
	echo "Recharge Listener is not running."
fi
