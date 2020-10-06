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

#Get list of available wireless devices
DEVICES=( $(iw dev | sed -ne 's/^.Interface //p') )

function isChannelValid {
		#get valid channels
		DEV_PHY="phy$(iw dev $1 info | sed -ne 's/^.wiphy //p')"
		DEV_CHANNELS=( $(iw "$DEV_PHY" channels | grep -v disabled | grep -E -o '\[[0-9]{1,3}\]' | sed -e 's/\[\(.*\)\]/\1/') )
		if [[ ! "${DEV_CHANNELS[@]}" =~ "$2" ]]; then
			echo "$2 is not a valid channel"
			echo "List of available channels for $1:"
			for CHANNEL in ${DEV_CHANNELS[@]}; do
				echo "$CHANNEL"
			done
			return 1
		else
			return 0
		fi
}

function setChannel {
#	echo "Setting $1 to channel $2"
	isChannelValid "$1" "$2"
	if [[ $? -eq 0 ]]; then
 		sudo iw "$1" set channel "$2" &>/dev/null
 		return $?
 	else
		return 1
	fi
}

function setchan {
	#Set the channels
	case $# in
		0 )
			echo "no arguments provided"
			exit 1
			;;
		1 ) # attempt to set all devices in monitor mode to the specified channel
			CHAN="$1"
			for (( i=0; i<${#DEVICES[@]}; i++ )); do
				if [[ "$(iwconfig ${DEVICES[$i]} | grep -o Monitor)" == "Monitor" ]]; then
					setChannel "${DEVICES[$i]}" $CHAN
					if [[ $? -ne 0 ]]; then
						echo "Failed to set ${DEVICES[$i]} to channel $CHAN"
					else
						echo "${DEVICES[$i]} set to channel $CHAN"
					fi
				else
					echo "${DEVICES[$i]} not in Monitor mode. Channel not set."
				fi
			done
			;;
		2 ) # attempt to set specified device to specified channel
			DEV="$1"
			CHAN="$2"
			if [[ "${DEVICES[@]}" =~ "$DEV" ]]; then
				if [[ "$(iwconfig $DEV | grep -o Monitor)" == "Monitor" ]]; then
					setChannel "$DEV" "$CHAN"
					if [[ $? -eq 0 ]]; then
						echo "$DEV set to channel $CHAN"
						exit 0
					else
						exit 1
					fi
				else
					echo "$DEV must be in monitor mode to set channel"
				fi
			else
				echo "$DEV is not a valid device"
				exit 1
			fi
			;;
		4 ) # attempt to set specified devices to specified channels
			DEVS=( "$1" "$3" )
			CHANS=( "$2" "$4" )
			for (( i=0; i<${#DEVS[@]}; i++ )); do
				if [[ "${DEVICES[@]}" =~ "${DEVS[$i]}" ]]; then
					if [[ "$(iwconfig ${DEVS[$i]} | grep -o Monitor)" == "Monitor" ]]; then
						setChannel "${DEVS[$i]}" "${CHANS[$i]}"
						if [[ $? -ne 0 ]]; then
							echo "Failed to set ${DEVS[$i]} to channel ${CHANS[$i]}"
						else
							echo "${DEVS[$i]} set to channel ${CHANS[$i]}"
						fi
					else
						echo "${DEVS[$i]} not in Monitor mode. Channel not set."
					fi
				else
					echo "${DEVS[$i]} is not a valid device"
				fi
			done
			;;
	esac
}

function main {
	randomInt 1 11
	setchan $? >/dev/null 2>&1
	randomInt 1 15
	sleep $?
}

while true; do
	main
done

exit 0