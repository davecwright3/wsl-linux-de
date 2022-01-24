#!/bin/sh
#
# @author David Wright <davecwright@knights.ucf.edu>
# @brief Set up a WSL v2.0 instance with the xfce DE and
#        xrdp remote desktop server. 
# @modified Sun 23 Aug 2020 04:58:08 PM EDT
 
set -euo pipefail    # stop execution if there are any errors
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6) # get the user's home directory

# check that we are running as root
if [ $(id -u) -ne 0 ]
  then echo 'Please run as root.' 2>&1
  exit 1
fi

# Get the programs we need
apt update && apt upgrade -y
apt install -y xrdp xfce4

# make a backup before we edit this file
cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak

# increase the quality of the server because we will be working locally anyways
sed -i 's/max_bpp=32/#max_bpp=32\nmax_bpp=128/g' /etc/xrdp/xrdp.ini
sed -i 's/xserverbpp=24/#xserverbpp=24\nxserverbpp=128/g' /etc/xrdp/xrdp.ini

# change default server port to 3390 to avoid clashes with default windows RDP server port
sed -i 's/3389/3390/g' /etc/xrdp/xrdp.ini

# let xsession know we want to use xfce
echo xfce4-session > ${USER_HOME}/.xsession

# backup the launch script for xrdp before we edit it
cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak    # backup

# edit the launch script for xrdp
# we want to skip sourcing Xsession things because they break xrdp
# just start xfce
sed -i 's/test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession/#test -x \/etc\/X11\/Xsession && exec \/etc\/X11\/Xsession/g' /etc/xrdp/startwm.sh
sed -i 's/exec \/bin\/sh \/etc\/X11\/Xsession/#exec \/bin\/sh \/etc\/X11\/Xsession/g' /etc/xrdp/startwm.sh
echo 'startxfce4' >> /etc/xrdp/startwm.sh

# put a function in our ~.profile to make launching xrdp easy
cp ${USER_HOME}/.profile ${USER_HOME}/.profile.bak    # backup
echo "
# Function to make handling xrdp easier
function session(){
  sudo /etc/init.d/xrdp \$1
}" >> ${USER_HOME}/.profile

exit 0
