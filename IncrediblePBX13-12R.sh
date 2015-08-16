#!/bin/bash

#    Incredible PBX Copyright (C) 2005-2015, Ward Mundy & Associates LLC.
#    This program installs Asterisk, Incredible PBX and GUI on Cent OS. 
#    All programs copyrighted and licensed by their respective companies.
#
#    Portions Copyright (C) 1999-2015,  Digium, Inc.
#    Portions Copyright (C) 2005-2015,  Sangoma Technologies, Inc.
#    Portions Copyright (C) 2005-2015,  Ward Mundy & Associates LLC
#    Portions Copyright (C) 2014-2015,  Eric Teeter teetere@charter.net
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#    GPL2 license file can be found at /root/COPYING after installation.
#

clear

if [ -e "/etc/pbx/.incredible" ]; then
 echo "Incredible PBX is already installed."
 exit 1
fi

#These are the varables required to make the install script work
#Do NOT change them
version="13-12.2"

clear
echo ".-.                          .-. _ .-.   .-.            .---. .---. .-..-."
echo ": :                          : ::_;: :   : :  v$version  : .; :: .; :: \`' :"
echo ": :,-.,-. .--. .--.  .--.  .-' :.-.: \`-. : :   .--.     :  _.':   .' \`  ' "
#echo $version
echo ": :: ,. :'  ..': ..'' '_.'' .; :: :' .; :: :_ ' '_.'    : :   : .; :.'  \`."
echo ":_;:_;:_;\`.__.':_;  \`.__.'\`.__.':_;\`.__.'\`.__;\`.__.'    :_;   :___.':_;:_;"
echo "Copyright (c) 2005-2015, Ward Mundy & Associates LLC. All rights reserved."
echo " "
echo "WARNING: This install will erase ALL existing GUI configurations!"
echo " "
echo "BY USING THE INCREDIBLE PBX, YOU AGREE TO ASSUME ALL RESPONSIBILITY"
echo "FOR USE OF THE PROGRAMS INCLUDED IN THIS INSTALLATION. NO WARRANTIES"
echo "EXPRESS OR IMPLIED INCLUDING MERCHANTABILITY AND FITNESS FOR PARTICULAR"
echo "USE ARE PROVIDED. YOU ASSUME ALL RISKS KNOWN AND UNKNOWN AND AGREE TO"
echo "HOLD WARD MUNDY, WARD MUNDY & ASSOCIATES LLC, NERD VITTLES, AND THE PBX"
echo "IN A FLASH DEVELOPMENT TEAM HARMLESS FROM ANY AND ALL LOSS OR DAMAGE"
echo "WHICH RESULTS FROM YOUR USE OF THIS SOFTWARE. AS CONFIGURED, THIS"
echo "SOFTWARE CANNOT BE USED TO MAKE 911 CALLS, AND YOU AGREE TO PROVIDE"
echo "AN ALTERNATE PHONE CAPABLE OF MAKING EMERGENCY CALLS. IF ANY OF THESE TERMS"
echo "AND CONDITIONS ARE RULED TO BE UNENFORCEABLE, YOU AGREE TO ACCEPT ONE"
echo "DOLLAR IN U.S. CURRENCY AS COMPENSATORY AND PUNITIVE LIQUIDATED DAMAGES"
echo "FOR ANY AND ALL CLAIMS YOU AND ANY USERS OF THIS SOFTWARE MIGHT HAVE."
echo " "

echo "If you do not agree with these terms and conditions of use, press Ctrl-C now."
read -p "Otherwise, press Enter to proceed at your own risk..."

# Do we need to run first-time setup?
if [ ! -f "/tmp/.incrediblepbx-bootstrapped" ]; then
	clear
	echo ".-.                          .-. _ .-.   .-.            .---. .---. .-..-."
	echo ": :                          : ::_;: :   : :  v$version  : .; :: .; :: \`' :"
	echo ": :,-.,-. .--. .--.  .--.  .-' :.-.: \`-. : :   .--.     :  _.':   .' \`  ' "
	#echo $version
	echo ": :: ,. :'  ..': ..'' '_.'' .; :: :' .; :: :_ ' '_.'    : :   : .; :.'  \`."
	echo ":_;:_;:_;\`.__.':_;  \`.__.'\`.__.':_;\`.__.'\`.__;\`.__.'    :_;   :___.':_;:_;"
	echo "Copyright (c) 2005-2015, Ward Mundy & Associates LLC. All rights reserved."
	echo " "
	echo "Performing first-time setup, one moment please..."
	echo "Ignore any errors pertaining to Grub if your system doesn't use it."
	echo " "
	setenforce 0
	yum -y upgrade --skip-broken # Upgrade the system
	yum -y install net-tools nano wget # Install some initial tools
	sed -i 's|quiet|quiet net.ifnames=0 biosdevdame=0|' /etc/default/grub # Patch grub (ignore any errors if your platform doesn't use it)
	grub2-mkconfig -o /boot/grub2/grub.cfg # Update grub config
	touch /tmp/.incrediblepbx-bootstrapped # So this doesn't run again
	echo "Done! System will reboot in five seconds..."
	echo "Run this script again when your system comes back up."
	sleep 5
	reboot
	exit 2
fi

clear
echo ".-.                          .-. _ .-.   .-.            .---. .---. .-..-."
echo ": :                          : ::_;: :   : :  v$version  : .; :: .; :: \`' :"
echo ": :,-.,-. .--. .--.  .--.  .-' :.-.: \`-. : :   .--.     :  _.':   .' \`  ' "
#echo $version
echo ": :: ,. :'  ..': ..'' '_.'' .; :: :' .; :: :_ ' '_.'    : :   : .; :.'  \`."
echo ":_;:_;:_;\`.__.':_;  \`.__.'\`.__.':_;\`.__.'\`.__;\`.__.'    :_;   :___.':_;:_;"
echo "Copyright (c) 2005-2015, Ward Mundy & Associates LLC. All rights reserved."
echo " "
echo "Installing The Incredible PBX. Please wait. This installer runs unattended."
echo "Consider a modest donation to Nerd Vittles while waiting. Return in 30 minutes."
echo "Do NOT press any keys while the installation is underway. Be patient!"
echo " "


# First is the FreePBX-compatible version number
export VER_FREEPBX=12.0

# Second is the Asterisk Database Password (randomized by default)
export ASTERISK_DB_PW=`< /dev/urandom tr -dc A-Za-z0-9 | head -c32`

# Third is the MySQL Admin password. Must be the same as when you install MySQL!! (randomized by default)
export ADMIN_PASS=`< /dev/urandom tr -dc A-Za-z0-9 | head -c32`

# Fourth is the Asterisk Manager password. This must match in both /etc/amportal.conf and /etc/asterisk/manager.conf (randomized by default)
#export MANAGER_PASS=`< /dev/urandom tr -dc A-Za-z0-9 | head -c32`

# Make sure we're running on x64
centos=x86_64
test=`uname -m`
if [[ "$centos" = "$test" ]]; then
 echo " "
else
 echo "This installer requires a 64-bit operating system."
 exit 1
fi

# Figure out what version of CentOS we're on
test=`cat /etc/redhat-release | grep 6`
if [[ -z $test ]]; then
 release="7"
else
 release="6"
fi

# Getting CentOS up to speed
setenforce 0
yum -y update
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
yum -y install deltarpm yum-presto
yum -y install net-tools wget nano kernel-devel kernel-headers
mkdir -p /etc/pbx

# Installing packages needed to work with Asterisk
yum -y install glibc* yum-fastestmirror opens* anaconda* poppler-utils perl-Digest-SHA1 perl-Crypt-SSLeay xorg-x11-drv-qxl dialog binutils* mc sqlite sqlite-devel libstdc++-devel tzdata SDL* syslog-ng syslog-ng-libdbi texinfo uuid-devel libuuid-devel
yum -y install cairo* atk* freetds freetds-devel
yum -y groupinstall additional-devel base cifs-file-server compat-libraries console-internet core debugging development mail-server ftp-server hardware-monitoring java-platform legacy-unix mysql network-file-system-client network-tools php performance perl-runtime security-tools server-platform server-policy system-management system-admin-tools web-server
yum -y install redhat-lsb-core epel-release # EPEL is required to install fail2ban from packages
yum -y install gnutls-devel gnutls-utils mysql* mariadb* libtool-ltdl-devel lua-devel libsrtp-devel speex* php-mysql php-mbstring perl-JSON fail2ban

# Compile LAME from source
cd /usr/src
wget http://sourceforge.net/projects/lame/files/lame/3.99/lame-3.99.5.tar.gz/download -O lame-3.99.5.tar.gz
tar -zxvf lame-3.99.5.tar.gz
rm -f lame-3.99.5.tar.gz
cd lame-3.99.5
./configure
make
make install

if [[ "$release" = "7" ]]; then
	# MySQL has been replaced by MariaDB in CentOS 7, but the scripts expect mysqld
	# Create a faux MySQL "service" that redirects commands to MariaDB
    ln -s /usr/lib/systemd/system/mariadb.service /usr/lib/systemd/system/mysqld.service
    echo "#\!/bin/bash" > /etc/init.d/mysqld
    sed -i 's|\\||' /etc/init.d/mysqld
    echo "service mariadb \$1" >> /etc/init.d/mysqld
    chmod +x /etc/init.d/mysqld
    chkconfig --levels 235 mariadb on
else
	# Not CentOS 7? Just enable mysqld
    chkconfig --levels 235 mysqld on
fi

# Compile iksemel from source
cd /usr/src
wget --no-check-certificate https://iksemel.googlecode.com/files/iksemel-1.4.tar.gz
tar zxvf iksemel*
cd iksemel*
./configure --prefix=/usr --with-libgnutls-prefix=/usr
make
make check
make install
echo "/usr/local/lib" > /etc/ld.so.conf.d/iksemel.conf 
ldconfig
# RPM source: http://rpmfind.net/linux/rpm2html/search.php?query=spandsp
wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/dkdegroot:/asterisk/CentOS_CentOS-6/x86_64/spandsp-0.0.6-35.1.x86_64.rpm
wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/dkdegroot:/asterisk/CentOS_CentOS-6/x86_64/spandsp-devel-0.0.6-35.1.x86_64.rpm
rpm -ivh spandsp*
wait

# Installing RPM Forge repo
if [[ "$release" = "7" ]]; then
    wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
else
    wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
fi
rpm -Uvh rpmforge*

# Install even more packages from the list bundled with this script
# Some aren't available, some are duplicates of things already installed by this script or otherwise
# Something to revisit in the future. No harm running it as-is for now, just time-consuming
cd /root
yum -y install $(cat yumlist.txt)

# Set up NTP
/usr/sbin/ntpdate -su pool.ntp.org

# Setup database
echo "----> Setup database"
pear channel-update pear.php.net
pear install -Z db-1.7.14
wait

# Get the kernel source linkage correct. Thanks to:
# http://linuxmoz.com/asterisk-you-do-not-appear-to-have-the-sources-for-kernel-installed/
cd /lib/modules/`uname -r`
ln -fs /usr/src/kernels/`ls -d /usr/src/kernels/*.x86_64 | cut -f 5 -d "/"` build

#----------------------------------------------#
# Compile Asterisk from source (by Billy Chia) #
#----------------------------------------------#
cd /usr/src

# Download source tarballs
wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-1.4-current.tar.gz
wget http://srtp.sourceforge.net/srtp-1.4.2.tgz
wget http://www.pjsip.org/release/2.2.1/pjproject-2.2.1.tar.bz2
wget http://www.digip.org/jansson/releases/jansson-2.7.tar.gz
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz

# Untar tarballs
tar zxvf dahdi-linux-complete*
tar zxvf libpri*
tar zxvf srtp*
tar zxvf jansson*
tar jxvf pjproject*
tar zxvf asterisk*

# Move the tarballs out of the way
mv *.tar.gz /tmp
mv *.tar.bz2 /tmp

# Add the asterisk user
adduser asterisk -M -d /var/lib/asterisk -s /sbin/nologin -c "Asterisk User"

# Compile DAHDI
cd /usr/src/dahdi-linux-complete*
make all && make install && make config

# Compile libpri
cd /usr/src/libpri*
make && make install

# Compile srtp
cd /usr/src/srtp*
./configure CFLAGS=-fPIC
make && make install

# Compile pjproject
cd /usr/src/pjproject*
CFLAGS='-DPJ_HAS_IPV6=1' ./configure --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr --libdir=/usr/lib64
make dep
make && make install

# Compile Jansson
cd /usr/src/jansson*
./configure
make && make install

# Prepare to compile Asterisk
cd /usr/src/asterisk-13*
contrib/scripts/install_prereq install
contrib/scripts/get_mp3_source.sh

# Clean up and run the bootstrap script
make distclean
autoconf
./bootstrap.sh

# Configure
./configure --libdir=/usr/lib64

# Make menuselect and set some build options
make menuselect.makeopts
menuselect/menuselect --enable-category  MENUSELECT_ADDONS menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-GSM --enable MOH-OPSOUND-WAV --enable EXTRA-SOUNDS-EN-GSM --enable cdr_mysql menuselect.makeopts
menuselect/menuselect --disable app_mysql --disable app_setcallerid --disable func_audiohookinherit menuselect.makeopts

# Compile (and wait....)
make && make install && make config && make samples
ldconfig

# Add Flite support
cd /usr/src
if [[ "$release" = "7" ]]; then
    wget http://incrediblepbx.com/Asterisk-Flite-2.2-rc1-flite1.3.tar.gz
    tar zxvf Asterisk-Flite*
    cd Asterisk-Flite*
else
   yum -y install flite flite-devel
   sed -i 's|enabled=1|enabled=0|' /etc/yum.repos.d/epel.repo
   wget http://incrediblepbx.com/Asterisk-Flite-2.2-rc1-flite1.3.tar.gz
   tar zxvf Asterisk-Flite*
   cd Asterisk-Flite*
fi

ldconfig
make
make install

# Add MP3 support
cd /usr/src
wget http://sourceforge.net/projects/mpg123/files/mpg123/1.16.0/mpg123-1.16.0.tar.bz2/download
mv download mpg123.tar.bz2
tar -xjvf mpg123*
cd mpg123*/
./configure && make && make install && ldconfig
ln -s /usr/local/bin/mpg123 /usr/bin/mpg123

# Reconfigure Apache for Asterisk
sed -i "s/User apache/User asterisk/" /etc/httpd/conf/httpd.conf
sed -i "s/Group apache/Group asterisk/" /etc/httpd/conf/httpd.conf

# Start services
if [[ "$release" = "7" ]]; then
    /etc/init.d/dahdi start
    /etc/init.d/asterisk start
else
    service dahdi start
    service asterisk start
    sed -i 's|module.so|mcrypt.so|' /etc/php.d/mcrypt.ini
fi

# Set ownership & permissions for the asterisk user
echo "----> Set ownership & permissions for the Asterisk user and modify Apache"
chown asterisk. /var/run/asterisk
chown -R asterisk. /etc/asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chown -R asterisk. /usr/lib64/asterisk
mkdir /var/www/html
chown -R asterisk. /var/www/

# A few small modifications to Apache.
sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf_orig
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
service httpd restart

# Set MyISAM as default MySQL storage so we can make quick backups
sed -i '/\[mysqld\]/a default-storage-engine=MyISAM' /etc/my.cnf
sed -i '/\[mysqld\]/a innodb=OFF' /etc/my.cnf
service mysqld restart

# Download and extract base install of GUI 
echo "----> Download and extract base install for GUI..."

# Stop Asterisk
service asterisk stop

# Download and extract FreePBX
cd /usr/src
wget http://incrediblepbx.com/freepbx-12.0.70.tgz
tar vxfz freepbx-12.0.70.tgz

# Fix some ownerships
chown asterisk. /var/run/asterisk
chown -R asterisk. /etc/asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chown -R asterisk. /usr/lib/asterisk
chown -R asterisk. /usr/lib64/asterisk
rm -rf /var/www/html

# Set up the database
cd /usr/src/freepbx
mysqladmin -u root create asterisk 
mysqladmin -u root create asteriskcdrdb

mysql -u root -e "GRANT ALL PRIVILEGES ON asterisk.* TO asteriskuser@localhost IDENTIFIED BY '${ASTERISK_DB_PW}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY '${ASTERISK_DB_PW}';"
mysql -u root -e "flush privileges;"

# Delete the default Asterisk config files
rm -f /etc/asterisk/enum.conf
rm -f /etc/asterisk/cdr_mysql.conf
rm -f /etc/asterisk/phone.conf
rm -f /etc/asterisk/manager.conf
rm -f /etc/asterisk/meetme.conf
rm -f /etc/asterisk/indications.conf
rm -f /etc/asterisk/queues.conf
rm -f /etc/asterisk/musiconhold.conf
rm -f /etc/asterisk/modules.conf

# Start Asterisk through FreePBX and run the intstaller
cd /usr/src/freepbx
./start_asterisk start
./install_amp --installdb --username=asteriskuser --password=${ASTERISK_DB_PW} --asteriskuser=asteriskuser --asteriskpass=${ASTERISK_DB_PW} --freepbxip=127.0.0.1 --dbname=asterisk --dbhost=localhost --webroot=/var/www/html --force-overwrite --scripted

# Make sure amportal is on everyone's path
ln -s /usr/local/sbin/amportal /usr/sbin/amportal

# Fix permissions
amportal chown

# Update the framework module
amportal a ma update framework

# Reload, refresh signatures, and fix permissions again
amportal a reload
amportal a ma refreshsignatures
amportal chown

chown -R asterisk. /var/www/

# Link music on hold directories
ln -s /var/lib/asterisk/moh /var/lib/asterisk/mohmp3
rm -rf /var/lib/asterisk/mohmp3/moh
rm -rf /var/lib/asterisk/moh/moh

# Uninstall proprietary modules
amportal a ma uninstall sipstation
amportal a ma uninstall sms
amportal a ma uninstall isymphony
amportal a ma uninstall cxpanel
amportal a ma uninstall webrtc
amportal a ma uninstall ucp
amportal a ma uninstall customappsreg

# Clean up the uninstalled modules
rm -rf /var/www/html/admin/modules/sipstation
rm -rf /var/www/html/admin/modules/sms
rm -rf /var/www/html/admin/modules/isymphony
rm -rf /var/www/html/admin/modules/cxpanel
rm -rf /var/www/html/admin/modules/webrtc
rm -rf /var/www/html/admin/modules/ucp

# Restart services
service mysqld restart
service httpd restart
amportal restart
amportal a r
service iptables stop

# Now it's time to set the MySQL root password
mysqladmin -u root password ${ADMIN_PASS}

# Update the Asterisk Manager password
#sed -i "s|AMPMGRPASS=amp111|AMPMGRPASS=${MANAGER_PASS}|" /etc/amportal.conf
#sed -i "s|amp111|${MANAGER_PASS}|" /etc/asterisk/manager.conf

# Installing Incredible PBX GUI
cd /
amportal stop
service asterisk stop
service httpd stop
service mysqld stop

# FIX htaccess and MaxClient settings in Apache setup for proper GUI operation
sed -i 's|AllowOverride None|AllowOverride All|' /etc/httpd/conf/httpd.conf
sed -i 's|256|5|' /etc/httpd/conf/httpd.conf

echo "Ready to load Incredible PBX GUI image now..."

chattr +i /etc/amportal.conf
chattr +i /etc/my.cnf
chattr +i /usr/local/sbin/*

wget http://incrediblepbx.com/incredible13-12-image.tar.gz
tar zxvf incredible13-12-image.tar.gz
rm -f incredible13-12-image.tar.gz

chown -R asterisk:asterisk /var/www/html/*
chattr -i /usr/local/sbin/amportal
chattr -i /etc/amportal.conf
chattr -i /etc/my.cnf
rm -f /usr/local/sbin/halt
rm -f /usr/local/sbin/reboot
rm -rf /etc/mysql

service mysqld start
service httpd start
amportal start
gui-fix

sed -i 's|$ttspick = 1|$ttspick = 0|' /var/www/html/reminders/index.php

# trim the number of Apache processes
echo " " >> /etc/httpd/conf/httpd.conf
echo "<IfModule prefork.c>" >> /etc/httpd/conf/httpd.conf
echo "StartServers       3" >> /etc/httpd/conf/httpd.conf
echo "MinSpareServers    3" >> /etc/httpd/conf/httpd.conf
echo "MaxSpareServers   4" >> /etc/httpd/conf/httpd.conf
echo "ServerLimit      5" >> /etc/httpd/conf/httpd.conf
echo "MaxClients       256" >> /etc/httpd/conf/httpd.conf
echo "MaxRequestsPerChild  4000" >> /etc/httpd/conf/httpd.conf
echo "</IfModule>" >> /etc/httpd/conf/httpd.conf
echo " " >> /etc/httpd/conf/httpd.conf

# fix phpMyAdmin for CentOS 7
sed -i 's|localhost|127.0.0.1|' /var/www/html/maint/phpMyAdmin/config.inc.php
service mysqld start
service httpd start
amportal start
amportal a r
asterisk -rx "database deltree dundi"
mkdir /etc/pbx
touch /etc/pbx/.incredible

echo "Randomizing all of your extension 701 and DISA passwords..."
lowest=111337
highest=982766
ext701=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
disapw=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
vm701=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
adminpw=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
mysql -uroot -p${ADMIN_PASS} asterisk <<EOF
use asterisk;
update sip set data="$ext701" where id="701" and keyword="secret";
update disa set pin="$disapw" where disa_id=1;
update admin set value='true' where variable="need_reload";
EOF
sed -i 's|1234|'$vm701'|' /etc/asterisk/voicemail.conf
sed -i 's|701 =|;701 =|' /etc/asterisk/voicemail.conf
sed -i 's|1234 =|;1234 =|' /etc/asterisk/voicemail.conf
echo "701 => $vm701,701,yourname98199x@gmail.com,,attach=yes|saycid=yes|envelope=yes|delete=no" > /tmp/email.txt
sed -i '/\[default\]/r /tmp/email.txt' /etc/asterisk/voicemail.conf
rm -f /tmp/email.txt

/var/lib/asterisk/bin/module_admin reload
rm -f /var/www/html/piaf-index.tar.gz

# Configuring IPtables
# Rules are saved in /etc/iptables
sed -i 's|INPUT ACCEPT|INPUT DROP|' /etc/sysconfig/ip6tables
# Here's the culprit...
# changing the next rule to DROP will kill the GUI on some hosted platforms like Digital Ocean
# but you get constant noise in the log where they're doing some heartbeat stuff
sed -i '/OUTPUT ACCEPT/a -A INPUT -s ::1 -j ACCEPT' /etc/sysconfig/ip6tables
# server IP address is?
if [[ "$release" = "7" ]]; then
 serverip=`ifconfig | grep "inet" | head -1 | cut -f 2 -d ":" | tail -1 | cut -f 10 -d " "`
else
 serverip=`ifconfig | grep "inet" | head -1 | cut -f 2 -d ":" | tail -1 | cut -f 1 -d " "`
fi
# user IP address while logged into SSH is?
userip=`echo $SSH_CONNECTION | cut -f 1 -d " "`
# public IP address in case we're on private LAN
publicip=`curl -s -S --user-agent "Mozilla/4.0" http://myip.pbxinaflash.com | awk 'NR==2'`
# WhiteList all of them by replacing 8.8.4.4 and 8.8.8.8 and 74.86.213.25 entries
cp /etc/sysconfig/iptables /etc/sysconfig/iptables.orig
cd /etc/sysconfig
# yep we use the same iptables rules on the Ubuntu platform
wget http://pbxinaflash.com/iptables4-ubuntu14.tar.gz
tar zxvf iptables4-ubuntu14.tar.gz
rm -f iptables4-ubuntu14.tar.gz
cp rules.v4.ubuntu14 iptables
sed -i 's|8.8.4.4|'$serverip'|' /etc/sysconfig/iptables
sed -i 's|8.8.8.8|'$userip'|' /etc/sysconfig/iptables
sed -i 's|74.86.213.25|'$publicip'|' /etc/sysconfig/iptables
badline=`grep -n "\-s  \-p" /etc/sysconfig/iptables | cut -f1 -d: | tail -1`
while [[ "$badline" != "" ]]; do
sed -i "${badline}d" /etc/sysconfig/iptables
badline=`grep -n "\-s  \-p" /etc/sysconfig/iptables | cut -f1 -d: | tail -1`
done
sed -i 's|-A INPUT -s  -j|#-A INPUT -s  -j|g' /etc/sysconfig/iptables

# chronyd causes problems
if [[ "$release" = "7" ]]; then
 chkconfig chronyd off
 service chronyd stop
 systemctl disable firewalld.service
 systemctl stop firewalld.service
else
 cd /usr/local/sbin
 wget http://incrediblepbx.com/iptables-restart-6.tar.gz
 tar zxvf iptables-restart-6.tar.gz
 rm -f iptables-restart-6.tar.gz
fi
service iptables restart
service ip6tables restart
chkconfig iptables on
chkconfig ip6tables on
chkconfig httpd on
service httpd restart
if [[ "$release" = "7" ]]; then
 systemctl enable ntpd.service
 systemctl start ntpd.service
else
 chkconfig ntpd on
 service ntpd start
fi
sed -i '/Starting/a mkdir /var/run/fail2ban' /etc/rc.d/rc3.d/S92fail2ban
sed -i '/Starting/a mkdir /var/run/fail2ban' /etc/init.d/fail2ban
cd /etc/fail2ban
wget http://incrediblepbx.com/jail-R.tar.gz
tar zxvf jail-R.tar.gz
rm -f jail-R.tar.gz
service fail2ban start
chkconfig fail2ban on
service sendmail start
chkconfig sendmail on
if [[ "$release" = "7" ]]; then
 systemctl enable sshd.service
else
 chkconfig sshd on
fi

# Installing WebMin from /root rpm
# you may not get the latest but it won't blow up either
echo "Installing WebMin..."
cd /root
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.750-1.noarch.rpm
rpm -Uvh webmin*
sed -i 's|10000|9001|g' /etc/webmin/miniserv.conf
service webmin restart
chkconfig webmin on

echo "Installing command line gvoice for SMS messaging..."
cd /root
easy_install -U setuptools
yum -y install python-simplejson
yum -y install mercurial
hg clone https://code.google.com/r/kkleidal-pygooglevoiceupdate/
cd kk*
python setup.py install
cp -p bin/gvoice /usr/bin/.

echo "asterisk ALL = NOPASSWD: /sbin/shutdown" >> /etc/sudoers
echo "asterisk ALL = NOPASSWD: /sbin/reboot" >> /etc/sudoers
echo "asterisk ALL = NOPASSWD: /usr/bin/gvoice" >> /etc/sudoers
echo " "

echo "Installing NeoRouter client..."
cd /root
wget http://download.neorouter.com/Downloads/NRFree/Update_2.1.2.4326/Linux/CentOS/nrclient-2.1.2.4326-free-centos-x86_64.rpm
yum -y install nrclient*

# tidy up stuff for CentOS 6.5
if [[ "$release" = "6" ]]; then
    cd /usr/local/sbin
    wget http://incrediblepbx.com/status66.tar.gz
    tar zxvf status66.tar.gz
    rm -f status66.tar.gz
fi

# Adding timezone-setup module for CentOS
cd /root
wget http://pbxinaflash.com/timezone-setup.tar.gz
tar zxvf timezone-setup.tar.gz
rm -f timezone-setup.tar.gz

# fix /etc/hosts so SendMail works with Asterisk
sed -i 's|localhost |pbx.local localhost |' /etc/hosts

# adding Port Knock daemon: knockd
cd /root
yum -y install libpcap* curl gawk
wget http://nerdvittles.dreamhosters.com/pbxinaflash//source/knock/knock-server-0.5-7.el6.nux.x86_64.rpm
rpm -ivh knock-server*
rm -f knock-server*.rpm
echo "[options]" > /etc/knockd.conf
echo "       logfile = /var/log/knockd.log" >> /etc/knockd.conf
echo "" >> /etc/knockd.conf
echo "[opencloseALL]" >> /etc/knockd.conf
echo "        sequence      = 7:udp,8:udp,9:udp" >> /etc/knockd.conf
echo "        seq_timeout   = 15" >> /etc/knockd.conf
echo "        tcpflags      = syn" >> /etc/knockd.conf
echo "        start_command = /sbin/iptables -A INPUT -s %IP% -j ACCEPT" >> /etc/knockd.conf
echo "        cmd_timeout   = 3600" >> /etc/knockd.conf
echo "        stop_command  = /sbin/iptables -D INPUT -s %IP% -j ACCEPT" >> /etc/knockd.conf
chmod 640 /etc/knockd.conf
# randomize ports here
lowest=6001
highest=9950
knock1=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
knock2=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
knock3=$[ ( $RANDOM % ( $[ $highest - $lowest ] + 1 ) ) + $lowest ]
sed -i 's|7:udp|'$knock1':tcp|' /etc/knockd.conf
sed -i 's|8:udp|'$knock2':tcp|' /etc/knockd.conf
sed -i 's|9:udp|'$knock3':tcp|' /etc/knockd.conf
if [[ "$release" = "7" ]]; then
    EPORT=`ifconfig | head -1 | cut -f 1 -d ":"`
    echo "OPTIONS=\"-i $EPORT\"" > /etc/sysconfig/knockd
else
    chkconfig --level 2345 knockd on
    service knockd start
fi
yum -y install ftp://rpmfind.net/linux/dag/redhat/el6/en/x86_64/dag/RPMS/miniupnpc-1.5-1.el6.rf.x86_64.rpm
upnpc -r 5060 udp $knock1 tcp $knock2 tcp $knock3 tcp

# clear out proprietary logos and final cleanup
cd /root
/root/logos-b-gone
rm -f anaconda*
rm -f epel*
rm -f install.*
rm -f nrclient*
rm -f rpmforge*
rm -f yumlist.*

yum -y install dos2unix unix2dos
ln -s /usr/sbin/sendmailmp3 /usr/bin/sendmailmp3
cd /root

# Add the MySQL admin password to odbc-gen.sh
sed -i "s|passw0rd|${ADMIN_PASS}|" /root/odbc-gen.sh

# and some bug fixes
chmod 664 /var/log/asterisk/full
sed -i 's|libmyodbc.so|libmyodbc5.so|' /root/odbc-gen.sh
sed -i 's|mysql restart|mysqld restart|' /root/odbc-gen.sh
sed -i 's|/var/run/mysqld/mysqld.sock|/var/lib/mysql/mysql.sock|' /root/odbc-gen.sh
/root/odbc-gen.sh
echo "[cel]" >> /etc/asterisk/cel_odbc_custom.conf
echo "connection=MySQL-asteriskcdrdb" >> /etc/asterisk/cel_odbc_custom.conf
echo "loguniqueid=yes" >> /etc/asterisk/cel_odbc_custom.conf
echo "table=cel" >> /etc/asterisk/cel_odbc_custom.conf
/var/lib/asterisk/bin/freepbx_setting SIGNATURECHECK 0
amportal a r

# Add HTTP security
echo "Include /etc/pbx/httpdconf/*" >> /etc/httpd/conf/httpd.conf
service httpd restart

# unload res_hep unless your system support IPv6
echo "noload = res_hep.so" >> /etc/asterisk/modules.conf

# remove the Ubuntu fax installer
rm -f /root/incrediblefax11_ubuntu14.sh

if [[ "$release" = "7" ]]; then
    mv /usr/local/sbin/status /usr/local/sbin/status6
    cp -p /root/status7 /usr/local/sbin/status
    chmod +x /usr/local/sbin/status
    systemctl stop firewalld
    systemctl mask firewalld
    yum -y install iptables-services
    systemctl enable iptables
    systemctl restart iptables
    iptables-restart
    rpm -e postfix
    yum -y install sendmail
    service sendmail restart
fi

# set up the root login scripts
echo 'export PS1="WARNING: Always run Incredible PBX behind a secure hardware-based firewall.  \n\[$(tput setaf 2)\]\u@\h:\w $ \[$(tput sgr0)\]"' >> /root/.bash_profile
echo '/root/update-IncrediblePBX' >> /root/.bash_profile
echo 'status -p' >> /root/.bash_profile

# change overwrite defaults
sed -i 's|rm -i|rm -f|' /root/.bashrc
sed -i 's|cp -i|cp -f|' /root/.bashrc
sed -i 's|mv -i|mv -f|' /root/.bashrc

# change Asterisk to run as asterisk user
amportal kill
chown -R asterisk:asterisk /var/run/asterisk
sed -i '/END INIT INFO/a AST_USER="asterisk"\nAST_GROUP="asterisk"' /etc/init.d/asterisk
amportal start

# patch GoogleTTS
cd /tmp
git clone https://github.com/zaf/asterisk-googletts.git
cd asterisk-googletts
chown asterisk:asterisk goo*
sed -i 's|speed = 1|speed = 1.3|' googletts.agi
cp -p goo* /var/lib/asterisk/agi-bin/.
cd cli
chown asterisk:asterisk goo*
cp -p goo* /var/lib/asterisk/agi-bin/.

# Update passwords in helper scripts
find /root/ -type f -print0 | xargs -0 sed -i "s/passw0rd/${ADMIN_PASS}/g"
find /root/ -type f -print0 | xargs -0 sed -i "s/amp109/${ASTERISK_DB_PW}/g"

clear
echo "Knock ports for access to $publicip set to TCP: $knock1 $knock2 $knock3" > /root/knock.FAQ
echo "UPnP activation attempted for UDP 5060 and your knock ports above." >> /root/knock.FAQ
echo "To enable knockd on your server, issue the following commands:" >> /root/knock.FAQ
echo "  chkconfig --level 2345 knockd on" >> /root/knock.FAQ
echo "  service knockd start" >> /root/knock.FAQ
echo "To enable remote access, issue these commands from any remote server:" >> /root/knock.FAQ
echo "nmap -p $knock1 $publicip && nmap -p $knock2 $publicip && nmap -p $knock3 $publicip" >> /root/knock.FAQ
echo "Or install iOS PortKnock or Android DroidKnocker on remote device." >> /root/knock.FAQ
echo " "

echo "*** Reset your Incredible PBX GUI admin password. Run /root/admin-pw-change NOW!"
echo "*** Configure your correct time zone by running: /root/timezone-setup"
echo "*** For fax support, run: /root/incrediblefax11.sh"
echo " "
echo "WARNING: Server access locked down to server IP address and current IP address."
echo "*** Modify /etc/sysconfig/iptables and restart IPtables BEFORE logging out!"
echo "To restart IPtables, issue command: service iptables restart"
echo " "
echo "Knock ports for access to $publicip set to TCP: $knock1 $knock2 $knock3"
echo "UPnP activation attempted for UDP 5060 and your knock ports above."
echo "To enable knockd server for remote access, read /root/knock.FAQ"
echo " "
echo "You may access webmin as root at https://$serverip:9001"
echo " "
systemctl restart sshd.service

echo "Have a great day!"
