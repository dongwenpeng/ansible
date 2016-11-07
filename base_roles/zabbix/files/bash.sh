#!/usr/bin/env bash
#
ps aux | grep zabbix | awk '{print $2}' | xargs kill &> /dev/null
sed -i '/zabbix_agentd.conf/d' /etc/rc.local

#