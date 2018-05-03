#!/bin/sh
DIR=/opt/openidea/acm/operator/claro/recharge
pidfile=$DIR/inotify.pid

if [ -e $pidfile ]; then
        pid=`cat $pidfile`

        if kill -0 &> /dev/null $pid; then
                echo "Already running"
                exit 1
        else
                rm $pidfile
        fi
fi

echo $$ > $pidfile

function handler {

    while IFS=' ' read rootPath event fileName; do

        IFS=',' eventMask=( $event )

        # Is it a file or directory?
        if [ ${#eventMask[@]} -gt 1 ] && [ ${#eventMask[1]} == 'ISDIR' ]; then
            fType="directory"
        else
            fType="file"
            if [ ${eventMask[0]} == "MOVED_TO" ] || [ ${eventMask[0]} == "CLOSE_WRITE" ]; then
                if [[ "'$fileName'" != *.swp* ]] && [[ "'$fileName'" != *processed* ]]
                then
                    $DIR/insert_recharge.sh $DIR/source/$fileName
                fi
            fi
        fi
	
	done
}

if [ $# -lt 1 ]; then
    # Usage information
    echo "USAGE: $0 pathname1 ... [pathnameN]"
    exit 1
fi

inotifywait -qm $@ | handler

