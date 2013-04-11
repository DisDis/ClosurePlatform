#!/bin/bash
SCR_VERSION="v1.01 16:32 20.12.2012"
# ----= Common =----
#DIR_REAL=$(readlink -f $0)
DIR=`dirname $0`
. $DIR/config.properties
. $DIR/log.utils
cd "$DIR"
FILE_SOURCES=( "$WEB_ROOT_PATH/" )
FILE_TEMPLATE_LIST=./templates.list
MIN_USING=1
searchUsingTeplates()
{
	COUNT=0
	outputH1 "Search"
	processStart "Progress."
	for TEMPLATE_NAME in $( cat $FILE_TEMPLATE_LIST )
	do
		processLive
		for FILE_SOURCE in ${FILE_SOURCES[@]}
		do
			RESULT=`grep -or --include=*js --include=*jsp "$TEMPLATE_NAME" $FILE_SOURCE | wc -w`;
			if [ $RESULT == '0' ];
			then
				let COUNT++
				echo ""
				echo "unused: $TEMPLATE_NAME - 0";
				break
			else
				if [ $RESULT -le $MIN_USING ]; then
					let COUNT++
					echo ""
					echo "used: $TEMPLATE_NAME - $RESULT";
				fi
			fi
		done
	done
	if [ $COUNT == 0 ];
	then
		processEnd "OK"
	else 
		processEnd "ERROR"
		echo "Unused: $COUNT"
	fi
}


scanThemes()
{
rm $FILE_TEMPLATE_LIST
for THEME_NANE in $( find $THEMES_PATH -maxdepth 1 -mindepth 1 -type d \( ! -iname ".*" \) )
do
	THEME_NANE=$( basename $THEME_NANE )
	outputH1 "Theme: '$THEME_NANE'"

	THEME_PATH=$THEMES_PATH/$THEME_NANE
	TEMPLATE_PATH=$THEME_PATH/templates
	scanTemplates
done
}

scanTemplates()
{
local FILE_LIST=$(find $TEMPLATE_PATH -name *.soy)
for FILE_NAME in $FILE_LIST; do
	local SOY_NAMESPACE=$( gawk 'match($0,/{namespace +([^}]+)}/,arr) { print arr[1] }' $FILE_NAME )
	gawk "match(\$0,/{template +.([^} ]+)/,arr) { print \"$SOY_NAMESPACE.\"arr[1] }" $FILE_NAME >>$FILE_TEMPLATE_LIST
done
}

scanThemes
searchUsingTeplates
