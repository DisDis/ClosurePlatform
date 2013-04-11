#!/bin/bash
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
# ----= Common =----
#DIR_REAL=$(readlink -f $0)
DIR=`dirname $0`
. $DIR/config.properties
. $DIR/log.utils
command -v gawk >/dev/null 2>&1 || { echo >&2 "Require gawk but it's not installed.  Aborting."; exit 1; }
echo "Parsing '$JAVA_CONSTANTS_FILE'"
gawk 'match($0,/ +String +([^ ]+) += +\"([^ ]+)\" *;/,arr) { print arr[1]":"arr[2] }' $JAVA_CONSTANTS_FILE >$CONSTANTS_MAP
RESULT=0
for PARAM in $( cat $CONSTANTS_MAP )
		do
			KEY=${PARAM%:*}
			VALUE=${PARAM##*:}
	if [ "$KEY" != "$VALUE" ]
	then
		echo " '$KEY' == '$VALUE'"
		RESULT=1
	fi
done
if [ "$RESULT" != "0" ]
then
	echo "Please fix problems"
	exit 1
fi

