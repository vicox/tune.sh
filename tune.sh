#!/bin/bash
#
# tune.sh
# A simple script for managing and listening to audio streams.
# Copyright (C) 2010  Georg Schmidl <georg.schmidl@vicox.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

NAME=tune.sh
VERSION=1.0

FILE=$(basename "$0")
HELP="Usage: $FILE [stream name]
Actions:
  -l, --list                              List all the stored streams
  -a, --add [stream name] [stream url]    Add a new stream
  -d, --delete [stream name]              Delete a stored stream
  -v, --version                           Display version
  -h, --help                              Display this help"

DIR=~/.tune/
STREAMS=${DIR}streams.cfg
TMP=${DIR}tmpfile

mkdir -p $DIR
if [ ! -f $STREAMS ]; then
	echo "twit=http://twit.am/listen" > $STREAMS; fi

if [ -z "$1" ]; then echo "$HELP"; exit 1; fi

if [ ${1:0:1} == "-" ]
then
	case "$1" in
		--list|-l)
			if [ $# != 1 ]; then
				echo "Usage: tune --list|-l"; exit 1; fi
			awk -F= '{print $1}' $STREAMS
			;;
		--add|-a)
			if [ $# != 3 ] || [ -z "$1" ] || [ -z "$2" ]; then
				echo "Usage: tune --add|-a [name] [url]"; exit 1; fi 
			awk -F= -v key="$2" '$1!=key {print}' $STREAMS > $TMP
			echo $2=$3 >> $TMP
			mv $TMP $STREAMS
			echo "Added: \"$2\""
			;;
		--delete|-d)
			if [ $# != 2 ] || [ -z "$1" ]; then
				echo "Usage: tune --del-d [name]"; exit 1; fi 
			awk -F= -v key="$2" '$1!=key {print}' $STREAMS > $TMP
			mv $TMP $STREAMS
			echo "Deleted: \"$2\""
			;;
		--version|-v)
			echo "$NAME $VERSION"
			;;
		--help|-h)
			echo "$HELP"
			;;
		*)
			echo "Invalid option: \"$1\""
			echo "$HELP"
			;; 
	esac
	exit 1 
fi

url=$(awk -F= -v key="$1" '$1==key {print $2}' $STREAMS)

if [ -z "$url" ]; then
	echo "I have no record of a stream named \"$1\""; exit 1; fi

mplayer $url
