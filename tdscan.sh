#!/bin/bash

function randomInt {
	case $# in
		1 )
			min=0
			max="$1"
			;;
		2 )
			if [[ "$1" -lt "$2" ]]; then
				min="$1"
				max="$2"
			elif [[ "$1" -gt "$2" ]]; then
				min="$2"
				max="$1"
			else
				min=0
				max="$1"
			fi
			;;
		* )
			echo "wrong!"
			return 0
			;;
	esac

	range=$(($max - $min + 1))
	return "$(($(($RANDOM%$range))+$min))"

}

while true; do
	randomInt 1 11
	setchan $? > /dev/null 2>&1
	randomInt 1 15
	sleep $?
done