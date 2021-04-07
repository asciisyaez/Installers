#!/usr/bin/env sh
#
# Copyright (C) 2019 VMware, Inc. All rights reserved.
# This product is protected by copyright and intellectual property laws in
# the United States and other countries as well as by international treaties.
# VMware products may be covered by one or more patents listed at
# https://www.vmware.com/go/patents.
#

MY_NAME="ws1hubsetup"
CONF_FILE="/etc/ws1Hub.conf"
CONF_NAME="ws1Hub"

DIRNAME=$(command -v dirname)
READLINK=$(command -v readlink)
MKDIR=$(command -v mkdir)
CHMOD=$(command -v chmod)
MV=$(command -v mv)
CP=$(command -v cp)
SED=$(command -v sed)
CHOWN=$(command -v chown)
LN=$(command -v ln)
CAT=$(command -v cat)
RM=$(command -v rm)
ID=$(command -v id)

WS1HOME="$("$DIRNAME" "$("$DIRNAME" "$("$READLINK" -f "$0")")")"
LOG_DIR="/var/log/$CONF_NAME"
LOGFILE="$LOG_DIR/$MY_NAME.0.log"
WS1_USER_NAME="ws1user"
WS1_GROUP_NAME="ws1user"

init_log() {
    "$MKDIR" -p $LOG_DIR
    >$LOGFILE
    "$CHMOD" 640 $LOGFILE
}

log() {
    echo "$(date) : $@" >>$LOGFILE
    echo "$(date) : $@"
}

die() {
    log $@
    echo >&2 $@
    exit 1
}
## NO inittab is present in systems that have adapted systemd. Systems like Gentoo still use inittab
start_agent_without_systemd() {
    #Add init tab entry to respawn ws1HubAgent on kill or failure
    #respwan will always starts the service when it dies. We can't control the spawning of the process.
    #echo ws1:345:respawn:\""$WS1HOME"/bin/ws1HubAgent\" >>/etc/inittab
    cd /etc/init.d/
    ./$CONF_NAME start >>$LOGFILE 2>&1
}

setup_systemd() {
    "$SED" -i "s:ExecStart=.*:ExecStart=\"$WS1HOME/bin/ws1HubAgent\":" "$WS1HOME"/script/$CONF_NAME.service
    "$SED" -i "s:ExecStop=.*:ExecStop=/bin/sh \"$WS1HOME/agent\" stop:" "$WS1HOME"/script/$CONF_NAME.service
    systemctl disable $CONF_NAME.service >/dev/null 2>&1
    systemctl daemon-reload >>$LOGFILE 2>&1
    "$CHMOD" a+r-x "$WS1HOME"/script/$CONF_NAME.service
    "$CP" "$WS1HOME"/script/$CONF_NAME.service /etc/systemd/system/
    "$CHOWN" $WS1_USER_NAME:$WS1_GROUP_NAME /etc/systemd/system/"$CONF_NAME.service"
    systemctl enable $CONF_NAME.service >>$LOGFILE 2>&1 ||
        die "Could not enable $CONF_NAME.service"
    systemctl reset-failed $CONF_NAME.service >>$LOGFILE 2>&1
	systemctl restart $CONF_NAME.service >>$LOGFILE 2>&1
    systemctl status $CONF_NAME.service >>$LOGFILE 2>&1
}

setup_update_rcd() {
    ## init.d entry to start agent after a system restart
    update-rc.d $CONF_NAME remove >>$LOGFILE 2>&1
    "$CP" "$WS1HOME"/script/$CONF_NAME \
        /etc/init.d/$CONF_NAME >>$LOGFILE 2>&1
    update-rc.d $CONF_NAME defaults >>$LOGFILE 2>&1 ||
        die "Could not update-rc.d for $CONF_NAME"
    start_agent_without_systemd   
}

setup_check_config() {
    ## init.d entriy to start agent after a system restart
    chkconfig --del /etc/init.d/$CONF_NAME >>$LOGFILE 2>&1
    "$CP" "$WS1HOME"/script/$CONF_NAME \
        /etc/init.d/$CONF_NAME >>$LOGFILE 2>&1
    chkconfig --add /etc/init.d/$CONF_NAME >>$LOGFILE 2>&1 ||
        die "Could not add chkconfig for $CONF_NAME"
    start_agent_without_systemd
}

setup_open_rc() {
    "$CP" "$WS1HOME"/script/ws1Hubd \
    /etc/init.d/ >>$LOGFILE 2>&1
    rc-update add ws1Hubd default >>$LOGFILE 2>&1
    rc-service ws1Hubd start >>$LOGFILE 2>&1
}

setup_autostart() {
    ###systemd - preferred method.
    ###Should work on all systemd supported flavors of linux
    ###Ubuntu, Fedora, Redhat, Debian, CentOS

    command -v systemctl >>$LOGFILE 2>&1 && [ -d /run/systemd/system ] 
    systemd_supported=$?

    ###system V for backward compatibility in Ubuntu, Debian

    command -v update-rc.d >>$LOGFILE 2>&1
    update_rc_exists=$?

    ###system V support for backward compatibility in Fedora, Redhat, centOS

    command -v chkconfig >>$LOGFILE 2>&1
    check_config_exists=$?

    ###Open-rc support for Gentoo based systems like Alpine

    command -v rc-update >>$LOGFILE 2>&1
    open_rc_supported=$? 

    if [ $systemd_supported -eq 0 ]; then
        log "systemd setup"
        setup_systemd
    elif [ $update_rc_exists -eq 0 ]; then
        log "update-rc.d exists"
        setup_update_rcd
    elif [ $check_config_exists -eq 0 ]; then
        log "check config exists"
        setup_check_config
    elif [ $open_rc_supported -eq 0 ]; then
        log "open-rc exists"
        setup_open_rc
    elif [ -d /etc/rc.d ] && [ -x /etc/rc.d/rc.local ];then
    ## For BSD style init systems like Slackware
        "$CP" "$WS1HOME"/script/$CONF_NAME \
        /etc/init.d/$CONF_NAME >>$LOGFILE 2>&1
        "$SED" -i '/exit/d' /etc/rc.d/rc.local
        echo "/bin/sh /etc/init.d/$CONF_NAME start" >> /etc/rc.d/rc.local
        echo "exit 0" >> /etc/rc.d/rc.local
        start_agent_without_systemd
        log "modified /etc/rc.d/rc.local"
    elif [ -x /etc/rc.local ];then
    ## For Devuan and Void
        "$CP" "$WS1HOME"/script/$CONF_NAME \
        /etc/init.d/$CONF_NAME >>$LOGFILE 2>&1
        "$SED" -i '/exit/d' /etc/rc.local
        echo "/bin/sh /etc/init.d/$CONF_NAME start" >> /etc/rc.local
        echo "exit 0" >> /etc/rc.local
        start_agent_without_systemd
        log "modified /etc/rc.local"
    elif [ -d /etc/rc5.d ]; then
    ## For other SystemV init systems
        "$CP" "$WS1HOME"/script/$CONF_NAME \
        /etc/init.d/$CONF_NAME >>$LOGFILE 2>&1
        "$LN" -f -s /etc/init.d/$CONF_NAME /etc/rc5.d/S99$CONF_NAME
        start_agent_without_systemd
        log "created /etc/rc5.d/S99$CONF_NAME"
    elif [ -d /etc/rc4.d ]; then
        "$CP" "$WS1HOME"/script/$CONF_NAME \
        /etc/init.d/$CONF_NAME >>$LOGFILE 2>&1
        "$LN" -f -s /etc/init.d/$CONF_NAME /etc/rc4.d/S99$CONF_NAME
        start_agent_without_systemd
        log "created /etc/rc4.d/S99$CONF_NAME"
    elif [ -d /etc/rc3.d ]; then
        "$CP" "$WS1HOME"/script/$CONF_NAME \
        /etc/init.d/$CONF_NAME >>$LOGFILE 2>&1
        "$LN" -f -s /etc/init.d/$CONF_NAME /etc/rc3.d/S99$CONF_NAME
        start_agent_without_systemd
        log "created /etc/rc3.d/S99$CONF_NAME"
    elif [ -f /etc/init.d/rcS ]; then
        "$CP" "$WS1HOME"/script/$CONF_NAME \
        /etc/init.d/$CONF_NAME >>$LOGFILE 2>&1
        "$LN" -f -s /etc/init.d/$CONF_NAME /etc/init.d/S99$CONF_NAME
        start_agent_without_systemd
        log "created /etc/init.d/S99$CONF_NAME"
    else
        log "Could not setup auto start"
    fi
}

is_root_user() {
    if [ $("$ID" -u) -ne 0 ]; then
        die "You must be a root user"
    fi
}

################################################################################
# main
################################################################################
init_log

# check for root user
is_root_user

while [ $# -gt 0 ]; do
    key="$1"
    case $key in
    -owner)
        WS1_USER_NAME=$2
        shift
        ;;
    -version)
       AGENT_VERSION=$2
       shift
       ;;
    -h | -help | --help)
        echo "Usage:"
        echo "$0 [ -owner <username> ]"
        exit 0
        ;;
    *)
        log "Invalid arguments"
        exit -1
        ;;
    esac
    shift
done

# Write the config file
"$CAT" <<EOF >$CONF_FILE
<airwatch>
<home>$WS1HOME</home>
<ipc>$WS1HOME</ipc>
<bin>$WS1HOME/bin</bin>
<data>$WS1HOME/data</data>
<config>$WS1HOME/config</config>
<script>$WS1HOME/script</script>
<logs>/var/log/$CONF_NAME</logs>
</airwatch>
EOF

# Change the file permission of '/etc/ws1Hub.conf' to user read-only.
"$CHMOD" 400 $CONF_FILE
"$CHOWN" -R $WS1_USER_NAME:$WS1_GROUP_NAME $CONF_FILE

WS1_USER_ID=$("$ID" -u $WS1_USER_NAME)
WS1_GROUP_ID=$("$ID" -g $WS1_USER_NAME)

# update user info into General-Config
"$SED" -i "s|<Version>.*</Version>|<Version>$AGENT_VERSION</Version>|g" \
    "$WS1HOME"/config/GeneralConfig.conf
"$SED" -i "s|<UserName>.*</UserName>|<UserName>$WS1_USER_NAME</UserName>|g" \
    "$WS1HOME"/config/GeneralConfig.conf
"$SED" -i "s|<UserID>.*</UserID>|<UserID>$WS1_USER_ID</UserID>|g" \
    "$WS1HOME"/config/GeneralConfig.conf
"$SED" -i "s|<GroupID>.*</GroupID>|<GroupID>$WS1_GROUP_ID</GroupID>|g" \
    "$WS1HOME"/config/GeneralConfig.conf

# Update AgentData.db file permission
if [ -f "$WS1HOME"/data/AgentData.db ]; then
    "$CHMOD" 600 "$WS1HOME"/data/AgentData.db
fi

#setup start agent after a system restart
setup_autostart

exit 0
