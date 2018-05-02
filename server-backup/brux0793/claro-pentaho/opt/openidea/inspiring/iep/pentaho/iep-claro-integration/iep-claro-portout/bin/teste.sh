#!/bin/bash

REFERENCE_DATE=$(date)

echo $REFERENCE_DATE

START_DATE=$(date -d "$REFERENCE_DATE 119 mins ago" +"%d/%m/%Y %H:%M")
echo $START_DATE

