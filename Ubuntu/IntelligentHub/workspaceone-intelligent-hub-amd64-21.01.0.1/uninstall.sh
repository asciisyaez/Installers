#!/bin/sh

preremove() {
	/opt/Workspace-ONE-Intelligent-Hub/agent stop
	if [ "$1" = "upgrade" ]; then
	   rm -rf /var/backups/ws1data_backup
	   mkdir -p /var/backups
	   cp -r /opt/Workspace-ONE-Intelligent-Hub/data/ /var/backups/ws1data_backup
	else
	   /opt/Workspace-ONE-Intelligent-Hub/bin/ws1HubUtil -puppet uninstall
	   /opt/Workspace-ONE-Intelligent-Hub/agent unenroll
	fi
	/opt/Workspace-ONE-Intelligent-Hub/agent cleanup
	
}

remove() {
	rm -f /etc/ws1Hub.conf
	rm -f /etc/systemd/system/ws1Hub.service
	rm -f /etc/init.d/ws1Hub
	
}

postremove() {
	if [ "$1" != "upgrade" ]; then
	    rm -rf /opt/Workspace-ONE-Intelligent-Hub
	    rm -rf /var/log/ws1Hub 
	    rm -rf /var/backups/ws1data_backup
	fi
	
}

preremove
remove
postremove
