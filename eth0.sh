#!/bin/bash
#
# @(#) eth0.sh, sversion 0.1.0, fversion 001, 06-december-2024
#

PATH=/bin:/usr/bin:/sbin:/usr/sbin
export PATH

nicname=ens18
newname=eth0

if [ $# -ge 1 ]
then
  nicname=$1
fi

if [ $# -ge 2 ]
then
  newname=$2
fi

macaddress=`ip addr show $nicname | grep link/ether | awk '{ print $2 }'`

if [ "$macaddress" != "" ]
then
  if [ `expr length "$macaddress"` -eq 17 ]
  then
    echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="'${macaddress}'", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="'${nicname}'", NAME="'${newname}'"' > /etc/udev/rules.d/70-persistent-net.rules
  fi
fi

exit 0

# end of file: eth0.sh
