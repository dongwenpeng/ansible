#!/bin/bash
#
# CentOS6
grep 6 /etc/redhat-release &> /dev/null
if [ $? = 0 ];then
    service iptables stop &> /dev/null
    chkconfig iptables off &> /dev/null
fi
# CentOS7
grep 7 /etc/redhat-release &> /dev/null
if [ $? = 0 ];then
    systemctl stop firewalld.service &> /dev/null
    systemctl disable firewalld.service &> /dev/null
fi