#!/bin/bash

DEFAULT_XIL_PATH=/opt/Xilinx/14.6
RULES_FILE=/ISE_DS/ISE/bin/lin/xusbdfwu.rules


if [ $UID -ne 0 ]
then
    echo "This script must be run as root."
    exit 0
fi

echo "Enter path to Xilinx tools (Blank will default to: '$DEFAULT_XIL_PATH')"
echo -e ": \c "
read XIL_PATH 
       
if [ -z $XIL_PATH ]
then
    XIL_PATH=$DEFAULT_XIL_PATH
    echo "Using default: $XIL_PATH"
fi

if [ ! -f $XIL_PATH/$RULES_FILE ]
then
    echo "Could not find the xusbdfwu.rules file"
    exit -1
fi

cat > /etc/udev/rules.d/99-libusb-driver.rules << END
ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="03fd", MODE="666"
END

cp /$XIL_PATH/$RULES_FILE /etc/udev/rules.d/

sed -i -e 's/TEMPNODE/tempnode/' -e 's/SYSFS/ATTRS/g' -e 's/BUS/SUBSYSTEMS/' /etc/udev/rules.d/xusbdfwu.rules

yum install fxload libusb-devel -y

cp $XIL_PATH/ISE_DS/ISE/bin/lin/xusb*.hex /usr/share/

udevadm control --reload-rules

echo "Unplug and replug in usb cable"
echo "Done"

exit 0

