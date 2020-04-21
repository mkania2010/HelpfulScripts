#!/bin/bash

# ----------------------------------------------------------------------------------
# Created by u/nolooseends - Original links:
# Reddit thread - https://www.reddit.com/r/homelab/comments/779cha/manual_fan_control_on_r610r710_including_script/
# Github - https://github.com/NoLooseEnds/Scripts/tree/master/R710-IPMI-TEMP
#
# Script for checking the temperature reported by the ambient temperature sensor,
# and if deemed too high send the raw IPMI command to enable dynamic fan control.
#
# Requires:
# ipmitool – apt-get install ipmitool
# https://www.dell.com/support/home/us/en/04/drivers/driversdetails?driverid=w9nmr&oscode=w12r2&productcode=poweredge-r710
#
# Add a setting to crontab
# crontab -e
# "*/5 * * * * /bin/bash /path/to/script/R710-IPMITemp.sh > /dev/null 2>&1"
# ----------------------------------------------------------------------------------


# IPMI SETTINGS:
# Modify to suit your needs.
IPMIHOST=192.168.1.3
IPMIUSER=root
IPMIPW=!PurpleZebrap00p
IPMIEK=0000000000000000000000000000000000000000

# TEMPERATURE
# Change this to the temperature in celcius you are comfortable with.
# If the temperature goes above the set degrees it will send raw IPMI command to enable dynamic fan control
MAXTEMP=27

# This variable sends a IPMI command to get the temperature, and outputs it as two digits. Do not edit unless you know what you're doing.
TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK sdr type temperature |grep Ambient |grep degrees |grep -Po '\d{2}' | tail -1)


if [[ $TEMP > $MAXTEMP ]];
  then
    printf "Warning: Temperature is too high! Activating dynamic fan control! ($TEMP C)" | systemd-cat -t R710-IPMI-TEMP
    echo "Warning: Temperature is too high! Activating dynamic fan control! ($TEMP C)"

    # Enables auto fan control
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x01

  else
    printf "Temperature is OK ($TEMP C)" | systemd-cat -t R710-IPMI-TEMP
    echo "Temperature is OK ($TEMP C)"

    # Set manual fan control - RPM set to 2160
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x09
fi