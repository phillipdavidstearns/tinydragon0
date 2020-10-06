#!/bin/bash

DEVICES=( "wlan1" "wlan2" )
DEV_LIST=( $(iw dev | sed -ne 's/^.Interface //p') )

for (( i=0; i<${#DEVICES[@]}; i++ )); do
	#check whether the supplied devices are available
	if [[ "${DEV_LIST[@]}" =~ "${DEVICES[$i]}" ]]; then
		#check if the device is in monitor mode
		if [[ ! "$(iwconfig ${DEVICES[$i]} | grep -o Managed)" == "Managed" ]]; then
			echo "Placing ${DEVICES[$i]} in Managed mode"
			sudo ip link set "${DEVICES[$i]}" down
			sudo iwconfig "${DEVICES[$i]}" mode managed
			sudo ip link set "${DEVICES[$i]}" up
		elif [[ "$(iwconfig ${DEVICES[$i]} | grep -o Managed)" == "Managed" ]]; then
			echo "${DEVICES[$i]} is already in Managed mode."
		fi
fi
done

unset DEVICES DEV_LIST

exit 0
