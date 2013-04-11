#!/bin/bash
SCR_VERSION="v1.01 16:12 27.12.2012"
DIR=`dirname $0`
. $DIR/config.properties
. $DIR/log.utils
cd "$DIR"
TOOL_CSS=$TOOL_LIBS_PATH/$JAR_CLOSURE_STYLESHEETS
TMP_CSS_FILE=./temp.gss.css
CSS_LIST_FILE=./css.list
MIN_USING=0
FILE_SOURCES=( "$WEB_ROOT_PATH/" )

scanSource()
{
COUNT=0
	outputH1 "Search"
	processStart "Progress."
	for CSS_NAME in $( grep -Eo ^[^=]+ $CSS_LIST_FILE )
	do
		processLive
		for FILE_SOURCE in ${FILE_SOURCES[@]}
		do
			RESULT=`grep -Eor --include=*js --include=*jsp "[ '\"]$CSS_NAME[ '\"]" $FILE_SOURCE | wc -w`;
			if [ $RESULT == '0' ];
			then
				let COUNT++
				echo ""
				echo "unused: $CSS_NAME - 0";
				break
			else
				if [ $RESULT -le $MIN_USING ]; then
					let COUNT++
					echo ""
					echo "used: $CSS_NAME - $RESULT";
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
for THEME_NANE in $( find $THEMES_PATH -maxdepth 1 -mindepth 1 -type d \( ! -iname ".*" \) )
do
	THEME_NANE=$( basename $THEME_NANE )
	outputH1 "Theme: '$THEME_NANE'"

	THEME_PATH=$THEMES_PATH/$THEME_NANE
	GSS_PATH=$THEME_PATH/gss

	loadingCSSConfig

	TOOL_CSS_PARAM=" --pretty-print \
	 --define DEBUG --output-renaming-map-format PROPERTIES \
	   --output-renaming-map $CSS_LIST_FILE \
	 $TOOL_CSS_PARAM_COMMON "
	generateSelectorCSS
	scanSource
done
}

generateSelectorCSS()
{
	createGSSFileList
	outputH1 "GSS"
	processStart "Parsing GSS..."
	java -jar $TOOL_CSS $TOOL_CSS_PARAM \
	   --output-file $TMP_CSS_FILE \
	   $GSS_LIST

	rm $TMP_CSS_FILE

	if [ $? -ne 0 ]; 
	then
		processEnd "ERROR"
		exit 1;
	else
		processEnd "OK"
	fi

}

createGSSFileList()
{
	outputH1 "Scan GSS files"

	FILE_LIST=$(find $GSS_PATH/ $FIND_PARAM -name *.gss)
	for FILE_NAME in $FILE_LIST;
	do
			GSS_LIST="$GSS_LIST $FILE_NAME"
			outputSub "found '$FILE_NAME'"
	done
}

loadingCSSConfig()
{
#Общие настройки для GSS->CSS компилятора
TOOL_CSS_PARAM_COMMON=" "
for PARAM in $( cat $GSS_PATH/fixed.cfg )
do
	TOOL_CSS_PARAM_COMMON="$TOOL_CSS_PARAM_COMMON --excluded-classes-from-renaming $PARAM "
done
for PARAM in $( cat $GSS_PATH/allowed.cfg )
do
	TOOL_CSS_PARAM_COMMON="$TOOL_CSS_PARAM_COMMON --allowed-non-standard-function $PARAM "
done
for PARAM in $( cat $GSS_PATH/allowed_prop.cfg )
do
	TOOL_CSS_PARAM_COMMON="$TOOL_CSS_PARAM_COMMON --allowed-unrecognized-property $PARAM "
done
}

scanThemes
