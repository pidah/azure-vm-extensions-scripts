#!/bin/bash

INSTALL_DIR="/opt/metrics.sh"
CONF_DIR="/etc/metrics.sh"

set -e

# Check directories
[ ! -d $INSTALL_DIR ] && mkdir -p $INSTALL_DIR
[ ! -d $CONF_DIR ] && mkdir -p $CONF_DIR

# Install git and nc
if grep -q 'Ubuntu' /etc/os-release 2>/dev/null; then
    apt-get install -y netcat git
elif grep -q 'CentOS' /etc/redhat-release 2>/dev/null; then
	yum install -y nc git
fi

# Copy config
install -m 0600 metrics.ini $CONF_DIR/metrics.ini

# Clone distrib
git clone "https://github.com/pstadler/metrics.sh" $INSTALL_DIR

# Create init script
ln -s $INSTALL_DIR/init.d/metrics.sh /etc/init.d/metrics.sh

# Copy custom scripts
for file in metrics/*
do
	install -m 0644 $file $INSTALL_DIR/metrics/custom/$(basename $file)
done

if grep -q 'Ubuntu' /etc/os-release 2>/dev/null; then
	update-rc.d metrics.sh defaults
	service metrics.sh start
elif grep -q 'CentOS' /etc/redhat-release 2>/dev/null; then
	/sbin/chkconfig --add metrics.sh
	service metrics.sh start
fi
