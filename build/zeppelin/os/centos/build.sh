#!/bin/bash
set -e
#echo "# Script version : 0.6"
#echo "# ZCI-ENV File   : $ZCI_ENV"
#source /reposhare/$ZCI_ENV

#SPARK_SHARE=/reposhare/$BUILD_TYPE
#USER_HOME=/reposhare/users/$CONT_NAME
#ZEPPELIN_HOME=$USER_HOME/zeppelin


# ----------------------------------------------------------------------
# Init
# ----------------------------------------------------------------------
ln -s /reposhare/firefox/firefox /usr/bin/firefox


# ----------------------------------------------------------------------
# Open XVFB
# ----------------------------------------------------------------------
dbus-uuidgen > /var/lib/dbus/machine-id
Xvfb $DISPLAY -ac -screen 0 1280x1024x24 &


# ----------------------------------------------------------------------
# Move to Zeppelin
# ----------------------------------------------------------------------
#cd $ZEPPELIN_HOME


# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
