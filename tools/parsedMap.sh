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

SCR_VERSION="v1.02 03:49 09.12.2012"
# ----= Common =----
#DIR_REAL=$(readlink -f $0)
DIR=`dirname $0`
. $DIR/config.properties
. $DIR/log.utils
cd "$DIR"
WEB_ROOT_PATH=$(readlink -f $WEB_ROOT_PATH)
LOCALES=$(echo $THEME_LOCALES|sed 's/,/ /g')

showConfig()
{
outputH1 "Config:"
outputSub "SOURCE_MAP_FULLPATH: $SOURCE_MAP_FULLPATH"
outputSub "MODULE_PATH: $MODULE_PATH"
outputSub "SOURCE_MAP_ROOT: $SOURCE_MAP_ROOT"
outputSub "WEB_ROOT_PATH: $WEB_ROOT_PATH"
}

showVersion()
{
	outputH1 "Module patching $SCR_VERSION"
}

convertMap(){
local TARGET_MAP_FILE=$1
local TARGET_MAP_FILE_SHORT=$( basename $TARGET_MAP_FILE )
processStart "Convert map file [$TARGET_MAP_FILE_SHORT]..."
local SOURCE_MAP_ROOT_PARSE=`echo "$SOURCE_MAP_ROOT" | sed 's/\//\\\\\//g'`

local WEB_ROOT_PATH_PARSE=`echo "$WEB_ROOT_PATH" | sed 's/\//\\\\\//g'`
sed -i "s/$WEB_ROOT_PATH_PARSE/$SOURCE_MAP_ROOT_PARSE/g" $TARGET_MAP_FILE
processCheck $?
}

scanModules(){
local MODULE_THEME=$1
local MODULE_LANG=$2
local MODULE_LANG_PATH=$3
local SOURCE_MAP_FULLPATH_PARSE=`echo "$SOURCE_MAP_FULLPATH" | sed "s/__THEME__/$MODULE_THEME/g" | sed "s/__LOCALE__/$MODULE_LANG/g"`

for FILE_NAME in $( find $MODULE_LANG_PATH -maxdepth 1 -mindepth 1 -type f -iname "*.js" )
do
	local FILE_NAME_SHORT=$( basename $FILE_NAME )
	if [ ! -f $MODULE_LANG_PATH/$FILE_NAME_SHORT.map ];then
		continue;
	fi
	local MAP_LINK_TEXT="//@ sourceMappingURL=./$FILE_NAME_SHORT.map"
	local RESULT=`cat $FILE_NAME | grep -o "$MAP_LINK_TEXT" | wc -w`;
	if [ $RESULT != '0' ];
	then
		outputSub "$FILE_NAME_SHORT - skip"
	else
		convertMap "$MODULE_LANG_PATH/$FILE_NAME_SHORT.map"
		#outputSub "$FILE_NAME_SHORT - OK"
		echo "$MAP_LINK_TEXT" >>$FILE_NAME
	fi
done
}

scanModuleLang()
{
for MODULE_THEME_PATH in $( find $MODULE_PATH -maxdepth 1 -mindepth 1 -type d \( ! -iname ".*" \) )
do
	for MODULE_LANG_PATH in $( find $MODULE_THEME_PATH -maxdepth 1 -mindepth 1 -type d \( ! -iname ".*" \) )
	do
		local MODULE_THEME=$( basename $MODULE_THEME_PATH )
		local MODULE_LANG=$( basename $MODULE_LANG_PATH )
		outputH1 "Theme: '$MODULE_THEME', locale: '$MODULE_LANG'"
		scanModules $MODULE_THEME $MODULE_LANG "$MODULE_LANG_PATH/"
	done
done
}

showVersion;
showConfig;

scanModuleLang;
