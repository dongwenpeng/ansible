#!/bin/bash
#
/bin/cat > /etc/profile.d/history.sh << _history
#!/bin/bash
HISTSIZE=5000
HISTFILESIZE=5000
HISTTIMEFORMAT="%F %T "
export HISTSIZE HISTFILESIZE HISTTIMEFORMAT
_history

/bin/cat > /etc/profile.d/ulimit.sh << _ulimit
#!/bin/bash
[ "\$(id -u)" == "0" ] && ulimit -n 819000
_ulimit

/bin/cat > /etc/profile.d/rm.sh << _rm
#!/bin/bash
alias rm="/bin/rm --preserve-root --verbose ${interactive}"
_rm

/bin/cat > /etc/security/limits.conf  << _limits
* soft nproc 10000
* hard nproc 10000
* soft nofile 819000
* hard nofile 819000
_limits

/bin/cat > /etc/security/limits.d/90-nproc.conf << _limits1
root       soft    nproc     unlimited
_limits1

chmod +x /etc/profile.d/ulimit.sh /etc/profile.d/history.sh /etc/profile.d/rm.sh
source /etc/profile.d/ulimit.sh /etc/profile.d/history.sh /etc/profile.d/rm.sh