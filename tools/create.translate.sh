#!/bin/sh
#v1.04
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
DIR_REAL=$(readlink -f $0)
DIR=`dirname $DIR_REAL`
. $DIR/config.properties
. $DIR/log.utils
cd $DIR 
echo "Path: $DIR"
LOCALES=$(echo $THEME_LOCALES|sed 's/,/ /g')


createSOYFileList()
{
TEMPLATES_LIST=""
	outputH1 "Scan SOY files"
	for FILE_NAME in $(find $TEMPLATE_PATH -name *.soy) 
	do
		TEMPLATES_LIST="$TEMPLATES_LIST $FILE_NAME"
		outputSub "found '$FILE_NAME'"
	done
}

createXLF()
{
	outputH1 "Generate XLF files"
	for LOCALE in $LOCALES ; do 
		outputH2 "Locale '$LOCALE'"
		OUTPUT_FILE="$LOCALE_PATH/$LOCALE.xlf"
		if [ -f $OUTPUT_FILE ]; then
  			processStart "Backup old '$LOCALE.xlf'..."
			mv -f "$LOCALE_PATH/$LOCALE.xlf" "$LOCALE_PATH/$LOCALE.old.xlf"
			if [ $? -ne 0 ]; 
			then
				processEnd "ERROR"
				exit 1;
			else
				processEnd "OK"
			fi
		fi
		processStart "Generating '$LOCALE.xlf'..."
		java -jar $TOOL_LOCALE_PATH/SoyMsgExtractor.jar \
		 --sourceLocaleString $LOCALE_SOURCE \
		 --targetLocaleString $LOCALE \
		 --outputPathFormat "$OUTPUT_FILE" \
		 $TEMPLATES_LIST
		if [ $? -ne 0 ]; 
		then
			processEnd "ERROR"
			processStart "Restore '$LOCALE.xlf'..."
			mv -f "$LOCALE_PATH/$LOCALE.old.xlf" "$LOCALE_PATH/$LOCALE.xlf"
			if [ $? -ne 0 ]; 
			then
				processEnd "ERROR"
			else
				processEnd "OK"
			fi
			exit 1;
		else
			processEnd "OK"
		fi
		# /{INPUT_FILE_NAME_NO_EXT}
		# --outputFile $LOCALE_PATH/examples_translated_en.xlf  
	done
}

mergeXLF()
{
for LOCALE in $LOCALES ; do 
	NEW_FILE="$LOCALE_PATH/$LOCALE.xlf"
	LOST_FILE="$LOCALE_PATH/$LOCALE.lost.xlf"
	OLD_FILE="$LOCALE_PATH/$LOCALE.old.xlf"
	echo "$NEW_FILE,$LOST_FILE,$OLD_FILE"
	#exit 1
	if [ -f $OLD_FILE ]; then
		#мержит старый и новый xlf
		PARAM=" -s:$NEW_FILE -xsl:$TOOL_MERGE_PATH/convert.xslt -o:$NEW_FILE old_file=$OLD_FILE "
		if [ -f $LOST_FILE ]; then
			PARAM="$PARAM lost_file=$LOST_FILE "
		fi
		java -cp $TOOL_MERGE_PATH/saxon9he.jar net.sf.saxon.Transform -t $PARAM 
	fi
	#находит пртерянные переводы
	PARAM=" -s:$NEW_FILE -xsl:$TOOL_MERGE_PATH/lost.xslt -o:$LOST_FILE old_file=$OLD_FILE "
	if [ -f $LOST_FILE ]; then
			PARAM="$PARAM lost_file=$LOST_FILE "
	fi
	java -cp $TOOL_MERGE_PATH/saxon9he.jar net.sf.saxon.Transform -t $PARAM
done
}

scanThemes()
{
for THEME_PATH in $( find $THEMES_PATH -maxdepth 1 -mindepth 1 -type d \( ! -iname ".*" \) )
do
	THEME_NANE=$( basename $THEME_PATH )
	outputH1 "Theme: '$THEME_NANE'"
	TEMPLATE_PATH=$THEME_PATH/templates
	LOCALE_PATH=$THEME_PATH/locales
	createSOYFileList
	createXLF
	mergeXLF
done
}

scanThemes
