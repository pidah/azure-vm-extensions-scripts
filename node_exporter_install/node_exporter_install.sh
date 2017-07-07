#!/bin/bash

VERSION="0.14.0"
CHECKSUM="d5980bf5d0dc7214741b65d3771f08e6f8311c86531ae21c6ffec1d643549b2e"
URL="https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz"
USER="node_exporter"
GROUP="node_exporter"
INSTALL_PATH="/opt/node_exporter"
CONF="/etc/default"

set -e

# Check daemon and config dirs
[ ! -d $INSTALL_PATH ] && mkdir -p $INSTALL_PATH
[ ! -d $CONF ] && mkdir -p $CONF

# Download tarball
curl -sL $URL -o "$INSTALL_PATH/node_exporter-$VERSION.linux-amd64.tar.gz"

# Check consistency
echo "$CHECKSUM  $INSTALL_PATH/node_exporter-$VERSION.linux-amd64.tar.gz" | sha256sum -c


# Unarchive tarball and clean
tar zxf $INSTALL_PATH/node_exporter-$VERSION.linux-amd64.tar.gz -C $INSTALL_PATH --strip-components=1
rm -f $INSTALL_PATH/node_exporter-$VERSION.linux-amd64.tar.gz

# Create user and group
grep -q $GROUP /etc/group || groupadd $GROUP
id -u $USER || useradd -g $GROUP -d $INSTALL_PATH $USER

# Change ownership
chown -R $USER:$GROUP $INSTALL_PATH

# Service installation
	
if [ -f /etc/redhat-release ] && grep 'release 6' /etc/redhat-release >/dev/null; then
	# install gosu package
	curl -sL https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 -o /usr/local/bin/gosu
	chmod +x /usr/local/bin/gosu
	# copy node_exporter config
	install -m 0644 node_exporter.conf $CONF/node_exporter
	# install service
    install -m 0755 node_exporter.sysvinit.redhat /etc/init.d/node_exporter
    chkconfig --add node_exporter
    service node_exporter start
else
    # Use systemd service
    install -m 0755 node_exporter.service /etc/systemd/system/node_exporter.service
    systemctl daemon-reload
    systemctl enable node_exporter
	systemctl start node_exporter
fi