#!/bin/sh
#DIR_REAL=$(readlink -f $0)
DIR=`dirname $0`
. $DIR/config.properties
. $DIR/log.utils

for THEME_NANE in $( find $THEMES_PATH -maxdepth 1 -mindepth 1 -type d \( ! -iname ".*" \) )
do
	THEME_NANE=$( basename $THEME_NANE )
	outputH1 "Theme: '$THEME_NANE'"
	rm "$THEMES_PATH/$THEME_NANE/gss/$TIMESTAMP_FNAME"
	rm "$THEMES_PATH/$THEME_NANE/templates/$TIMESTAMP_FNAME"
	rm -r "$WEB_THEMES_PATH/$THEME_NANE/css"
	rm -r "$WEB_THEMES_PATH/$THEME_NANE/js"
done
