#!/bin/bash

version=$(curl -s https://github.com/prometheus/node_exporter/releases/latest | grep -o 'href=".*"' | sed 's/.*tag.v//;s/"//')

node_exporter="node_exporter-${version}.linux-amd64"
node_exporter_url="https://github.com/prometheus/node_exporter/releases/download/v${version}/${node_exporter}.tar.gz"

function node_exporter_install()
{
    current_version="$(/usr/bin/node_exporter --version 2>/dev/null | grep 'node_exporter, version' | awk '{print $3}' || echo '0')"
    if [ "$current_version" != "$version" ]; then
        # create user
        getent group prometheus >/dev/null || groupadd -r prometheus -g 755
        getent passwd prometheus >/dev/null || \
          useradd -r -g prometheus \
            -d /var/lib/prometheus \
            -s /sbin/nologin -u 755 \
            -c "Prometheus services" \
            prometheus

        if [ ! -e /usr/local/bin/gosu ]; then
            gosu_version=$(curl -s https://github.com/tianon/gosu/releases/latest | grep -o 'href=".*"' | sed 's/.*tag.\([^/]*\)/\1/;s/"//;s/^v//')
            gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
            curl -so /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${gosu_version}/gosu-amd64"
            curl -so /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${gosu_version}/gosu-amd64.asc"
            gpg --verify /usr/local/bin/gosu.asc
            rm /usr/local/bin/gosu.asc
            rm -r /root/.gnupg/
            chmod +x /usr/local/bin/gosu
        fi

        # Install Prometheus
        mkdir -p /tmp/.prometheus/
        cd /tmp/.prometheus/
        wget ${node_exporter_url} -O ${node_exporter}.tar.gz
        tar xzvf ${node_exporter}.tar.gz ${node_exporter}/node_exporter

        if [ -e /usr/bin/node_exporter ]; then
            pkill node_exporter
            rm -f /usr/bin/node_exporter
        fi

        mv -f ${node_exporter}/node_exporter /usr/bin/node_exporter

        mkdir -p /var/{run,log}/prometheus
        rm -rf /tmp/.prometheus/
        # mkdir -p /etc/default/
        # echo START >> /etc/default/prometheus
    else
        echo "Prometheus node_exporter is up-to-date (${version})"
    fi
}

node_exporter_install