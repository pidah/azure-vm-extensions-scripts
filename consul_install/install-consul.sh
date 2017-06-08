#!/bin/bash
#
# Installs and configures consul for prometheus
#
set -euo pipefail

version="$1"
config_json="$2"

package="consul_${version}_linux_amd64.zip"
url="https://releases.hashicorp.com/consul/${version}/${package}"
bindir="/usr/local/bin"
configdir="/etc/consul.d"
datadir="/var/consul"

# Download
wget "${url}"

# Install
unzip "${package}" -d "${bindir}"

# Prepare consul dirs
mkdir -p "${configdir}" "${datadir}"

# Create configuration
echo "${config_json}" > "${configdir}/config.json"

# Install initscript and enable service
if grep -q 'Ubuntu' /etc/os-release 2>/dev/null; then
    # Use systemd service
    install -m 0755 consul.service /etc/systemd/system/consul.service
    systemctl daemon-reload
    systemctl enable consul
    systemctl start consul
elif grep -q 'CentOS release 6' /etc/redhat-release 2>/dev/null; then
    # Use initscript
    install -m 0755 consul.init /etc/init.d/consul
    chkconfig consul on
    service consul start
fi
