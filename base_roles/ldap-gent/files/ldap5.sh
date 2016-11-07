#!/bin/bash
#
yum -y install openldap-clients openldap-devel compat-openldap authconfig
mkdir  /etc/openldap/cacerts

authconfig --enableforcelegacy --update
authconfig --enableldap --enableldapauth --ldapserver="10.0.8.132 10.106.71.8" --ldapbasedn="dc=eju,dc=com" --update

mkdir /root/config_backup
mv /etc/pam_ldap.conf /etc/nslcd.conf /etc/sudo-ldap.conf /root/config_backup/
echo 'sudoers: files ldap' >> /etc/nsswitch.conf

cat >> /etc/nslcd.conf << EOF
uid nslcd
gid ldap
uri ldap://10.0.8.132 ldap://10.106.71.8
base dc=eju,dc=com
ssl no
tls_cacertdir /etc/openldap/cacerts
EOF

cat >> /etc/ldap.conf << EOF
base dc=eju,dc=com
#nss_initgroups_ignoreusers root,ldap,named,avahi,haldaemon,dbus,radvd,tomcat,radiusd,news,mailman,nscd,gdm
uri ldap://10.0.8.132/ ldap://10.106.71.8
ssl no
tls_cacertdir /etc/openldap/cacerts
pam_password md5
SUDOERS_BASE ou=SUDOers,dc=eju,dc=com
EOF

cat >> /etc/pam_ldap.conf << EOF
base dc=eju,dc=com
uri ldap://10.0.8.132 ldap://10.106.71.8
ssl no
tls_cacertdir /etc/openldap/cacerts
pam_password md5
EOF


cat >> /etc/sudo-ldap.conf << EOF
uri ldap://10.0.8.132/ ldap://10.106.71.8
base dc=eju,dc=com
sudoers_base ou=SUDOers,dc=eju,dc=com
SUDOERS_TIMED true
tls_cacertfile /etc/openldap/cacerts/cacert.pem
tls_reqcert demand
tls_ciphers HIGH:MEDIUM:+SSLv2
EOF

config_file=/etc/sysconfig/network-scripts/ifcfg-`/sbin/route |grep '^default'|awk '{ print $NF }'`
myip=`grep '^IPADDR' $config_file |awk -F'=' '{print $2}'`
echo "pam_filter |(host=$myip)(host=\*)" >> /etc/pam_ldap.conf
echo 'TLS_REQCERT allow' >> /etc/openldap/ldap.conf
chown nslcd:ldap /etc/nslcd.conf /etc/sudo-ldap.conf /etc/pam_ldap.conf
chmod 440  /etc/nslcd.conf /etc/sudo-ldap.conf /etc/pam_ldap.conf
/etc/init.d/nscd restart
echo "/etc/init.d/nscd start" >>/etc/rc.local
