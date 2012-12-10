#!/bin/sh
#	 This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#	 Authors: Igor Demyanov<igor.demyanov@gmail.com>
SCR_VERSION="v1.15 03:28 10.12.2012"
# <script.sh> <DEBUG|RELEASE>
if [ "$1" = "RELEASE" ]; then
	echo "Release mode"
	IS_DEBUG=0
else
	echo "Debug mode"
	IS_DEBUG=1
fi

# ----= Common =----
#DIR_REAL=$(readlink -f $0)
DIR=`dirname $0`
. $DIR/config.properties
. $DIR/log.utils
cd "$DIR"
# ----= JS =----
#--shouldDeclareTopLevelNamespaces
#--should_generate_goog_msg_defs
TOOL_JS_PARAM=" \
	--pluginModules closure.plugins.MyprojectPluginModule \
	--cssHandlingScheme GOOG  \
	--locales $THEME_LOCALES \
	--shouldProvideRequireSoyNamespaces \
	"
	
TOOL_JS=com.google.template.soy.SoyToJsSrcCompiler
#$DIR/cl-templates/js/SoyToJsSrcCompiler.jar
# ----= CSS =----
TOOL_CSS=$DIR/cl-stylesheets/closure-stylesheets.jar

# ----= JAVA =----
TOOL_JAVA_PARAM=""
TOOL_JAVA=$DIR/cl-templates/java/SoyParseInfoGenerator.jar

writeTimeStamp()
{
	if [ $IS_DEBUG -eq 0 ]; then
		#RELEASE
		return 0
	fi
	echo "time" > $1
}

optionsPrint()
{
	outputH1 "Options"
	outputSub "theme name: $THEME_NANE"
	outputSub "theme path: $THEME_PATH"
	outputH2 "Input"
	outputSub "template path: $TEMPLATE_PATH"
	outputSub "locale path: $LOCALE_PATH"
	outputSub "gss path: $GSS_PATH"
	outputH2 "Output"
	#outputSub "java path: $OUTPUT_JAVA_PATH"
	#outputSub "java package: $JAVA_PACKAGE"
	outputSub "js path: $OUTPUT_JS_PATH"
	outputSub "css path: $OUTPUT_CSS_PATH"
	outputH2 "Tools"
	outputSub "js tool : $TOOL_JS"
	outputSub "js params: '$TOOL_JS_PARAM'"
	outputSub "js locales: '$THEME_LOCALES'"
	#outputSub "java tool path : $TOOL_JAVA"
	#outputSub "java params: '$TOOL_JAVA_PARAM'"
	outputSub "css tool : $TOOL_CSS"
	outputSub "css params: '$TOOL_CSS_PARAM'"
}

cleanWorkFolder()
{
	if [ $IS_DEBUG -eq 0 ]; then
		outputH1 "Clean generate folder"
		processStart "Cleaning JS..."
		rm -R $OUTPUT_JS_PATH
		processCheck $?

		#outputH2 "Clean Java"
		#rm -R $OUTPUT_JAVA_PATH/*.java
		#processCheck $?
		processStart "Cleaning CSS..."
		rm -R $OUTPUT_CSS_PATH/*.css
		processCheck $?
#	else
#		outputSub "Skip in DEBUG"
	fi
}

createIfNotExist()
{
	if [ -d $1 ]
	then
		outputSub "Directory '$1' found"
	else 
		#outputSub "Directory '$1' not found"
		mkdir $1
		outputSub "Created '$1'"
	fi
}

createWorkFolder()
{
	outputH1 "Create generate folder"
	createIfNotExist $OUTPUT_JS_PATH
	#createIfNotExist $OUTPUT_JAVA_PATH
	createIfNotExist $OUTPUT_CSS_PATH
}


createSOYFileList()
{
	outputH1 "Scan SOY files"
	FIND_PARAM=""
	if [ $IS_DEBUG -eq 1 ]; then
		#Debug
		if [ -f $TEMPLATE_PATH/$TIMESTAMP_FNAME ]; then
			FIND_PARAM=" -cnewer $TEMPLATE_PATH/$TIMESTAMP_FNAME "
		fi
	fi
	FILE_LIST=$(find $TEMPLATE_PATH $FIND_PARAM -name *.soy)
	for FILE_NAME in $FILE_LIST; do
			FILE_NAME=${FILE_NAME#$TEMPLATE_PATH}
			TEMPLATES_LIST="$TEMPLATES_LIST $FILE_NAME"
			outputSub "found '$FILE_NAME'"
	done
}

createGSSFileList()
{
	outputH1 "Scan GSS files"

	FIND_PARAM=""
	if [ $IS_DEBUG -eq 1 ]; then
		#Debug
		if [ -f $GSS_PATH/$TIMESTAMP_FNAME ]; then
			FIND_PARAM=" -cnewer $GSS_PATH/$TIMESTAMP_FNAME "
		fi
		FILE_LIST=$(find $GSS_PATH/ $FIND_PARAM -name *.gss)
	else
		#Release
		FILE_LIST=$(ls -v $GSS_PATH/*.gss)
	fi

	for FILE_NAME in $FILE_LIST;
	do
			GSS_LIST="$GSS_LIST $FILE_NAME"
			outputSub "found '$FILE_NAME'"
	done
}

compileJS()
{
	createSOYFileList
	outputH1 "SOY"
	if [ "$TEMPLATES_LIST" = "" ];then
		outputSub "No changed files"
		return 0
	fi
	processStart "Compiling SOY..."
	java 	-cp ./cl-templates/js/SoyToJsSrcCompiler.jar:./cl-templates/plugins/cl-t-plugin.jar \
		$TOOL_JS $TOOL_JS_PARAM \
		--inputPrefix $TEMPLATE_PATH \
		--compileTimeGlobalsFile $TEMPLATE_PATH/global.properties \
        	--messageFilePathFormat "$LOCALE_PATH/{LOCALE}.xlf" \
        	--outputPathFormat "$OUTPUT_JS_PATH/{LOCALE}/{INPUT_DIRECTORY}/gen_{INPUT_FILE_NAME_NO_EXT}.js" \
           $TEMPLATES_LIST
	processCheck $?
}

compileDebugCSS()
{
	local PIDS=""
	for FILE_NAME in $GSS_LIST ; do
		ONLY_NAME=$( basename $FILE_NAME)
		if [ "$ONLY_NAME" = "$DEFINITION_GSS" ];then
			#echo "Skip '$DEFINITION_GSS'"
			processLive
			continue
		fi
		ONLY_NAME="$OUTPUT_CSS_PATH/${ONLY_NAME%.*}.css"
		java -jar $TOOL_CSS $TOOL_CSS_PARAM \
	   		--output-file $ONLY_NAME \
	   	$FILE_NAME $GSS_PATH/$DEFINITION_GSS &
		PIDS="$PIDS $!"
	done
	for PID_GSS_COMPILE in $PIDS ; do
			if wait "$PID_GSS_COMPILE"; then 
				processLive
			else
				processEnd "ERROR"
				exit 1;
			fi
	done
	processEnd "OK"
}

compileCSS()
{
	createGSSFileList
	outputH1 "GSS"
	if [ "$GSS_LIST" = "" ];then
		outputSub "No changed files"
		return 0
	fi
	processStart "Compiling GSS..."
if [ $IS_DEBUG -eq 0 ]; then
	java -jar $TOOL_CSS $TOOL_CSS_PARAM \
	   --output-file $OUTPUT_CSS_PATH/compact.css \
	   $GSS_LIST

	if [ $? -ne 0 ]; 
	then
		processEnd "ERROR"
		exit 1;
	else
		processLive
	fi

	java -jar $TOOL_CSS $TOOL_CSS_PARAM \
	   --output-renaming-map-format PROPERTIES \
	   --output-renaming-map $OUTPUT_CSS_PATH/renaming_map.properties \
	    $GSS_LIST > /dev/null

	processCheck $?

	outputSub "generated $OUTPUT_CSS_PATH/compact.css"
else
	compileDebugCSS
fi
}

compileJavaInfo()
{
	outputH1 "Compiling Java info files"
	java -jar $TOOL_JAVA $TOOL_JAVA_PARAM \
	--outputDirectory "$OUTPUT_JAVA_PATH" \
          --javaPackage $JAVA_PACKAGE \
	--javaClassNameSource namespace \
	 $TEMPLATES_LIST
}
showVersion()
{
	outputH1 "Compile SOY&GSS $SCR_VERSION"
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

scanThemes()
{
for THEME_NANE in $( find $THEMES_PATH -maxdepth 1 -mindepth 1 -type d \( ! -iname ".*" \) )
do
	THEME_NANE=$( basename $THEME_NANE )
	outputH1 "Theme: '$THEME_NANE'"

	THEME_PATH=$THEMES_PATH/$THEME_NANE
	TEMPLATE_PATH=$THEME_PATH/templates
	LOCALE_PATH=$THEME_PATH/locales
	GSS_PATH=$THEME_PATH/gss
	TEMPLATES_LIST=""
	GSS_LIST=""
	
	loadingCSSConfig

	# ----= JS =----
	OUTPUT_JS_PATH=$WEB_THEMES_PATH/$THEME_NANE/js
	if [ $IS_DEBUG -eq 0 ]; then
	#RELASE
	TOOL_CSS_PARAM=" \
	--rename CLOSURE --define RELEASE --output-renaming-map $OUTPUT_JS_PATH/renaming_map_compiled.js --output-renaming-map-format CLOSURE_COMPILED \
	 $TOOL_CSS_PARAM_COMMON "
	else
	#DEBUG
	# --rename DEBUG
	TOOL_CSS_PARAM=" --pretty-print \
	 --define DEBUG --output-renaming-map $OUTPUT_JS_PATH/renaming_map.js --output-renaming-map-format CLOSURE_UNCOMPILED \
	 $TOOL_CSS_PARAM_COMMON "
	fi

	# ----= CSS =----
	OUTPUT_CSS_PATH=$WEB_THEMES_PATH/$THEME_NANE/css

	# ----= JAVA =----
	JAVA_PACKAGE=template.theme_$THEME_NANE.generate
	OUTPUT_JAVA_PATH=$DIR/../generate/$THEME_NANE/java/template/theme_$THEME_NANE/generate

	
	cleanWorkFolder
	createWorkFolder
	if [ $IS_DEBUG -eq 1 ]; then
		compileJS &
		PID_SOY=$!
		compileCSS &
		PID_GSS=$!
		wait $PID_SOY || exit 1
		wait $PID_GSS || exit 1
	else
		compileJS
		compileCSS
	fi

	writeTimeStamp "$TEMPLATE_PATH/$TIMESTAMP_FNAME"
	writeTimeStamp "$GSS_PATH/$TIMESTAMP_FNAME"
	#compileJavaInfo
done
}

showVersion
#optionsPrint
scanThemes
showVersion
