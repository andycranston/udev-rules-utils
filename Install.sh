#!/bin/bash
#
# @(#) Install.sh, sversion 0.1.0, fversion 001, 06-december-2024
#
# install the eth0.sh script to /usr/local/bin and set up the eth0.service
#

set -u

#
# Main
#

PATH=/bin:/usr/bin:/sbin:/usr/sbin
export PATH

progname=`basename $0`

if [ "`id | cut -d'(' -f2 | cut -d')' -f1`" != "root" ]
then
  echo "$progname: must run this script as the root user" 1>&2
  exit 2
fi

cp -p eth0.sh    /usr/local/bin/eth0.sh
chown root:root  /usr/local/bin/eth0.sh
chmod u=rwx,go=r /usr/local/bin/eth0.sh

cp -p eth0.service /etc/systemd/system/eth0.service
chown root:root    /etc/systemd/system/eth0.service
chmod u=rw,go=r    /etc/systemd/system/eth0.service

systemctl daemon-reload
systemctl enable eth0.service
systemctl start eth0.service

exit 0

# end of file: eth0.service
