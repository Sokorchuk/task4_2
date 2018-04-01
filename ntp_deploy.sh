#! /bin/bash
#
# task4_2.sh -- ntp service install script
#
# Copyright (C) 2018 Ihor P. Sokorchuk
# Developed for Mirantis Inc. by Ihor Sokorchuk
# Ihor P. Sokorchuk <ihor.sokorchuk@nure.ua>
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 2, as published by the Free Software Foundation.
#
# Usage: task4_2.sh
#
# Files: /etc/ntp.conf
#        /etc/cron.d/ntp
#        /var/backup/ntp/ntp.conf-(UnixTime)
#        /var/backup/ntp/ntp.conf.bak
#        /usr/local/bin/ntp_verify.sh
#

ntp_server='ua.pool.ntp.org'

etc_dir='/etc/'
bin_dir='/usr/local/bin/'
backup_dir='/var/backup/ntp/'

ntp_verify_sh=${bin_dir}ntp_verify.sh

# install NTP package
apt-get install ntp 2>/dev/null || {
   echo 'ERROR: NTP package not installed' >&2
   exit 1
}

# make backup directory
test ! -d $backup_dir && mkdir -p $backup_dir

# modify /etc/ntp.conf
awk '
   BEGIN { issrvaddr = 1; }
   ($1 == "server") && (issrvaddr == 1) { print "server '${ntp_server}'"; issrvaddr = 0; }
   ($1 != "server") { print $0; }
' < ${etc_dir}ntp.conf > ${backup_dir}ntp.conf.bak
# backup /etc/ntp.conf
mv ${etc_dir}ntp.conf ${backup_dir}ntp.conf-$(date +%s)
# change /etc/ntp.conf
cp -f ${backup_dir}ntp.conf.bak ${etc_dir}ntp.conf
# MD5sum for /etc/ntp.conf
md5sum ${etc_dir}ntp.conf > ${backup_dir}ntp.conf.md5

# NTP server restart
${etc_dir}init.d/ntp stop 2>/dev/null
${etc_dir}init.d/ntp start

# create /usr/local/bin/ directory
test ! -e $bin_dir && mkdir -p $bin_dir
# create /usr/local/bin/ntp_veryfy.sh file
test ! -f $ntp_verify_sh && {
   echo "#! /bin/bash
# This file created by task4_2.sh script
#
# start NTP server
${etc_dir}init.d/ntp status &>/dev/null || {
   echo 'NOTICE: ntp is not running'
   ${etc_dir}init.d/ntp start || exit 1
}
# check MD5 checksum and restore /etc/ntp.conf
md5sum ${backup_dir}ntp.conf.md5 &>/dev/null || {
   echo 'NOTICE: /etc/ntp.conf was changed. Calculated diff:'
   diff -a -u ${backup_dir}ntp.conf.bak ${etc_dir}ntp.conf
   cp -f ${backup_dir}ntp.conf.bak ${etc_dir}ntp.conf
   # restart NTP server
   ${etc_dir}init.d/ntp restart
}
#" > $ntp_verify_sh
   chmod 755 $ntp_verify_sh
}

# create /etc/crron.d/ntp file
echo '# This file creted by task4_2.sh
#
# run '${ntp_verify_sh}' at every 1 minute
* * * * * root '$ntp_verify_sh > ${etc_dir}cron.d/ntp

# reload cron files
${etc_dir}init.d/cron reload
