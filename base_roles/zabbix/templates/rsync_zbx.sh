#!/usr/bin/env bash
#
url={{ zbx_master }}
rsync -avrz --delete --timeout=10 --bwlimit=100 --progress $url::data /etc/zabbix/zabbix_agentd.d/

# restart zabbix-agent
du=`cat /tmp/du.txt 2> /dev/null`
if [ -z $du ];then
  /usr/bin/du -s /etc/zabbix/zabbix_agentd.d/ | awk '{print $1}' >  /tmp/du.txt
else
  next_du=`/usr/bin/du -s /etc/zabbix/zabbix_agentd.d/ | awk '{print $1}'`
  if [ $next_du != $du ];then
    /etc/init.d/zabbix-agent restart >> /tmp/zabbix-agent.txt
  fi
fi
/usr/bin/du -s /etc/zabbix/zabbix_agentd.d/ | awk '{print $1}' >  /tmp/du.txt