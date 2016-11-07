#!/bin/bash
#
yum install -y nss-pam*
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


cat >> /etc/sudo-ldap.conf << EOF
uri ldap://10.0.8.132/ ldap://10.106.71.8
base dc=eju,dc=com
sudoers_base ou=SUDOers,dc=eju,dc=com
SUDOERS_TIMED true
tls_cacertfile /etc/openldap/cacerts/cacert.pem
tls_reqcert demand
tls_ciphers HIGH:MEDIUM:+SSLv2
EOF


echo 'TLS_REQCERT allow' >> /etc/openldap/ldap.conf
chown nslcd:ldap /etc/nslcd.conf /etc/sudo-ldap.conf 
chmod 440  /etc/nslcd.conf /etc/sudo-ldap.conf
systemctl restart nslcd