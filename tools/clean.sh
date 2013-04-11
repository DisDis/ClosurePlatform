#!/bin/sh
#DIR_REAL=$(readlink -f $0)
DIR=`dirname $0`
. $DIR/config.properties
. $DIR/log.utils

for THEME_NANE in $( find $THEMES_PATH -maxdepth 1 -mindepth 1 -type d \( ! -iname ".*" \) )
do
	THEME_NANE=$( basename $THEME_NANE )
	outputH1 "Theme: '$THEME_NANE'"
	if [ -f $THEMES_PATH/$THEME_NANE/gss/$TIMESTAMP_FNAME ]
	then
		rm "$THEMES_PATH/$THEME_NANE/gss/$TIMESTAMP_FNAME"
	fi
	if [ -f $THEMES_PATH/$THEME_NANE/templates/$TIMESTAMP_FNAME ]
	then
		rm "$THEMES_PATH/$THEME_NANE/templates/$TIMESTAMP_FNAME"
	fi
	if [ -d $WEB_THEMES_PATH/$THEME_NANE/css ]
	then
		rm -r "$WEB_THEMES_PATH/$THEME_NANE/css"
	fi

	if [ -d $WEB_THEMES_PATH/$THEME_NANE/js ]
	then
		rm -r "$WEB_THEMES_PATH/$THEME_NANE/js"
	fi
done
