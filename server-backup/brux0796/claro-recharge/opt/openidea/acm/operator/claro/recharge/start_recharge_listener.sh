#!/bin/sh
WATCH_DIR=source
DIR=/opt/openidea/acm/operator/claro/recharge
pidfile=$DIR/inotify.pid
LOGFILE=$DIR/log/recharge_listener.log

if [ -e $pidfile ]; then
        pid=`cat $pidfile`

        if kill -0 &> /dev/null $pid; then
                echo "Already running"
                exit 1
        fi
fi

nohup $DIR/inotify_recharge.sh $DIR/$WATCH_DIR >>$DIR/log/recharge_listener.log 2>&1 &
RETVAL=$?
if [ $RETVAL -eq 1 ]; then
	echo "Already Running"
else
	echo "Recharge Listener started!"
    echo -e "Recharge Listener Started!" >> $LOGFILE
	sleep 1
    #touches only some files in case there are too many to process
    find $DIR/source -maxdepth 1 -type f -exec touch {} \+
fi
