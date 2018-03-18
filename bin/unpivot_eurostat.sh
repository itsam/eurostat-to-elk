#!/bin/bash
# Purpose: unpivot eurostat table
# Written by @mitmirzutun : https://github.com/mitmirzutun/PHP/blob/master/clear.php
# 2018.05.12   S.Kim

# for data of this form:
# citizen,sex,unit,age,asyl_app,geo\time	2016 	2015 	2014 	2013 	2012 	2011 	2010 	2009 	2008 
# AD,F,PER,TOTAL,ASY_APP,AT	0 	0 	0 	0 	0 	0 	0 	0 	0 
# AD,F,PER,TOTAL,ASY_APP,BE	0 	0 	0 	0 	0 	0 	0 	0 	0 
# AD,F,PER,TOTAL,ASY_APP,BG	0 	0 	0 	0 	0 	0 	0 	0 	0 

# set -xv

SCRIPTNAME=$(basename $0 .sh)

function usage {
   echo "Usage: $(basename $0) filename"
}

if [ $# -ne 1 ]; then
  usage;
  exit 2
fi

FILE=$1
if [ ! -f $FILE ]; then
    echo "Sorry, cannot find $FILE , exiting ... "; exit 3
fi
###  Some checks first
# Check if csv looks OK: Number of rows, no blanks before comma, number of cols
BLANKS_BETWEEN=$(grep -c -e '^[A-Za-z]* ,' $FILE)
if [ $BLANKS_BETWEEN -gt 10 ]; then
  echo "Please check if tabula created blanks before the commata, exiting"; exit 3
fi
NUM_LINES=$(wc -l $FILE | cut -f1 -d' ')
if [[ $NUM_LINES -lt 140 ]]; then
  echo "number of lines is $NUM_LINES, seems a bit low, exiting"; exit 3
elif [[ $NUM_LINES -gt 200 ]]; then
  echo "number of lines is $NUM_LINES, seems a bit high, exiting"; exit 3
fi 
# num of cols ... not sure how to do that.

HEADER_FILE=../raw/header.csv
if [ ! -f $HEADER_FILE ]; then
    echo "Sorry, cannot fine $HEADER_FILE , exiting ... "; exit 3
fi

ALREADY_RUN=$(grep -c ASYLANTRAEGE $FILE)
if [ $ALREADY_RUN -ne 0 ]; then
  echo "I think I did this file already, exiting"
  exit 2
fi

# add header, remove Windows endoflines etc
cat $HEADER_FILE $FILE | dos2unix > /tmp/x.csv; mv /tmp/x.csv $FILE

### Cleaning

./clean_csv.sh $FILE

### Add Date

./add_date.sh $FILE

### Some Last Checks
# Check if your csv is clean
csvclean -n $FILE
CLEAN=$?
if [ ! $CLEAN ]; then
  echo "Sorry, your csv is not clean"
fi
echo "Enjoy your file: $FILE"
exit 0

