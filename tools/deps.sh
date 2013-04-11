#!/bin/sh
DIR=`dirname $0`
#cd $DIR
#echo "Path: $DIR"
DIR_WORK=$DIR/../WebUI/js/
THEME=default
LOCALE=ru

./closure/calcdeps.py \
  -p $DIR_WORK/closure/ \
  -p $DIR_WORK/common/ \
  -p $DIR_WORK/example/ \
  -p $DIR_WORK/pages/ \
  -p $DIR_WORK/states/ \
  -p $DIR_WORK/../themes/$THEME/js/$LOCALE/ \
  -o deps > $DIR_WORK/closure/goog/deps.js
