#! /bin/bash
# This file created by task4_2.sh script
#
# start NTP server
/etc/init.d/ntp status &>/dev/null || {
   echo 'NOTICE: ntp is not running'
   /etc/init.d/ntp start || exit 1
}
# check MD5 checksum and restore /etc/ntp.conf
md5sum /var/backup/ntp/ntp.conf.md5 &>/dev/null || {
   echo 'NOTICE: /etc/ntp.conf was changed. Calculated diff:'
   diff -a -u /var/backup/ntp/ntp.conf.bak /etc/ntp.conf
   cp -f /var/backup/ntp/ntp.conf.bak /etc/ntp.conf
   # restart NTP server
   /etc/init.d/ntp restart
}
#
