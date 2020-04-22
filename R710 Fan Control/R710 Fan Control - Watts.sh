#!/bin/bash

# ----------------------------------------------------------------------------------
# Created by u/nolooseends - Original links:
# Reddit thread - https://www.reddit.com/r/homelab/comments/779cha/manual_fan_control_on_r610r710_including_script/
# Github - https://github.com/NoLooseEnds/Scripts/tree/master/R710-IPMI-TEMP
#
# Script for checking the wattage reported,and if deemed too
# high, send the raw IPMI command to enable dynamic fan control.
#
# Requires:
# ipmitool – apt-get install ipmitool
#
# Add a job to crontab - the example below will run every 5 minutes
# crontab -e
# */5 * * * * /bin/bash /path/to/script/R710-IPMITemp.sh > /dev/null 2>&1
#
# The echo lines are mainly incase the script is run on the command line
# ----------------------------------------------------------------------------------

# IPMI Settings
IPMIHOST=10.0.0.1
IPMIUSER=root
IPMIPW='calvin'

# Wattage over which automatic fan control will engage
MAXWATTS=200

# Another needed variable
IPMIEK=0000000000000000000000000000000000000000

while ! [[ "$WATTS" =~ ^[0-9]{3}$ ]]; do
	echo "Getting wattage"
	WATTS=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK sdr type 'Current' | grep 'System Level' | grep Watts | grep -Po '\d{3}')
	echo "Request exited (Watts: $WATTS)"
done

if [[ $WATTS > $MAXWATTS ]]; then
	if [[ $(cat /tmp/ipmiControl.txt) != "auto" ]]; then
		# Logging, run "journalctl -f" to see new entries
		printf "Warning: Watt usage is high, setting auto fan control (Watts: $WATTS)" | systemd -t IPMI-CONTROL
		echo "Warning: Watt usage is too high, setting auto fan control (Watts: $WATTS)"

		# Enables auto fan control
		ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x01

		echo "Setting lastRun"
		echo "auto" > /tmp/ipmiControl.txt
	else
		printf "Fans already set to auto, exiting (Watts: $WATTS)" | systemd-cat -t IPMI-CONTROL
		echo "Fans already set to auto, exiting (Watts: $WATTS)"
	fi

else
	if [ -f /tmp/ipmiControl.txt ]; then
		LASTUPDATE=$(date -r /tmp/ipmiControl.txt +%s)
		NOW=$(date +%s)
		FILE_AGE=$((NOW - LASTUPDATE))
		echo "age $FILE_AGE"
	fi

	if [[ $(cat /tmp/ipmiControl.txt) != "slow" || FILE_AGE -gt 21600 ]]; then

		printf "Watt usage is OK (Watts: $WATTS)" | systemd-cat -t IPMI-CONTROL
		echo "Watt usage is OK (Watts: $WATTS)"

		# Set manual fan control - should always be uncommented
		ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00

		# ----- Choose one to run -----
		# Set RPM to 3000
		#ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x10

		# Set RPM to 2160
		ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x0a

		# Set RPM to 1560
		#ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x09

		echo "Setting lastRun"
		echo "slow" > /tmp/ipmiControl.txt
	
	else
		printf "Fans already set to slow, exiting (Watts: $WATTS)" | systemd-cat -t IPMI-CONTROL
		echo "Fans already set to slow, exiting (Watts: $WATTS)"
	fi
fi