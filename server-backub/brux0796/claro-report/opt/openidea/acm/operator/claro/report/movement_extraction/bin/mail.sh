#!/bin/bash

if [ $# -lt 4 ];then
    echo -e "Usage: $0 <WORK_DIR> <FILE> <TITLE> <TO>"
    exit 1
fi

start_exec_time=$(date +%s)

WORK_DIR=$1
FILE=$2
TITLE=$3
TO=$4

OLD_PWD=$PWD

cd $WORK_DIR

if [ $(ls -l $FILE | awk '{print $5}' FS=" ") -gt 40000000 ];
then
    rm -f $FILE"-split."*

    bzip2 --best --small $FILE

    split --numeric-suffixes --bytes=7MB $FILE".bz2" $FILE".bz2-split."

    rm $FILE".bz2"

    ls -lh $FILE".bz2-split."* | awk '{print $5 " | " $9}' FS=" " > $FILE".list"

    total_files=$(ls -l $FILE".bz2-split."* | wc -l)

    i=1
    for file in $FILE".bz2-split."*
    do
        NEW_TITLE=$TITLE" "$i"/"$total_files
        cat $FILE".list" | /bin/mail -s "$NEW_TITLE" -a $file $TO
        i=$(($i+1))
        sleep 60
    done

    rm $FILE".list"
else
    if [ $(wc -l $FILE|awk '{print $1}') -lt 1000 ]
    then
        cat $FILE| /bin/mail -s "$TITLE" -a $FILE $TO
    else
        zip -mj9 $FILE".zip" $FILE
        ls -lh $FILE".zip" | awk '{print $5 " | " $9}' FS=" "| /bin/mail -s "$TITLE" -a $FILE".zip" $TO
    fi
fi
