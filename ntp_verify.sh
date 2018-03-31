#! /bin/bash
# This file created by task4_2.sh script
#
# start NTP server
/etc/init.d/ntp status || {
   /etc/init.d/ntp start || exit 1
}
# check MD5 checksum and restore /etc/ntp.conf
md5sum /var/backup/ntp/ntp.conf.md5 || cp -f /var/backup/ntp/ntp.conf-backup /etc/ntp.conf
# restart NTP server
/etc/init.d/ntp restart
#
