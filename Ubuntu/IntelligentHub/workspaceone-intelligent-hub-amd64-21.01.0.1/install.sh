#!/bin/sh

preinstall() {
	WS1_USER_NAME=ws1user
	WS1_GROUP_NAME=ws1user
	id -u $WS1_USER_NAME 2>/dev/null
	if [ $? -ne 0 ]; then
	    echo "User \"$WS1_USER_NAME\" does not exist. Creating..."
	    useradd -U -M $WS1_GROUP_NAME
	    echo "Created user \"$WS1_USER_NAME\""
	fi
	
}

install() {
	if [ -f /opt/Workspace-ONE-Intelligent-Hub/bin/ws1HubAgent ]; then
	   rm -rf /var/backups/ws1data_backup
	   mkdir -p /var/backups
	   cp -r /opt/Workspace-ONE-Intelligent-Hub/data/ /var/backups/ws1data_backup
	   /opt/Workspace-ONE-Intelligent-Hub/agent stop
	fi
	cp -r ${PWD}/rootfs/opt/Workspace-ONE-Intelligent-Hub /opt/
	cp -r uninstall.sh /opt/Workspace-ONE-Intelligent-Hub
	rm -r ${PWD}/rootfs
	rm  uninstall.sh
	
}

postinstall() {
	WS1_USER_NAME=ws1user
	WS1_GROUP_NAME=ws1user
	mkdir -p /var/log/ws1Hub/
	if [ -d /var/backups/ws1data_backup ]; then
	    cp -r /var/backups/ws1data_backup/* /opt/Workspace-ONE-Intelligent-Hub/data
	    rm -rf /var/backups/ws1data_backup
	fi
	chown -R $WS1_USER_NAME:$WS1_GROUP_NAME /opt/Workspace-ONE-Intelligent-Hub
	chown -R $WS1_USER_NAME:$WS1_GROUP_NAME /var/log/ws1Hub/
	chmod u=rxs,g=rxs,o=r /opt/Workspace-ONE-Intelligent-Hub/bin/ws1HubAgent
	/opt/Workspace-ONE-Intelligent-Hub/bin/ws1HubUtil -dbMigrate "21.01.0.1"
	/opt/Workspace-ONE-Intelligent-Hub/script/ws1HubSetup.sh -owner $WS1_USER_NAME -version "21.01.0.1"
	/opt/Workspace-ONE-Intelligent-Hub/bin/ws1HubUtil -puppet install
	rm -f install.sh
	
}

preinstall
install
postinstall
