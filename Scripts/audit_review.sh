hostname=$(hostname)
date=$(date)

echo -e "##########################################################"
echo -e "## Host: $hostname \t\t\t\t##"
echo -e "## Report Date: $date \t\t##"
echo -e "##########################################################"

echo -e ""
echo -e "##################################################################################"
echo -e "## Ensure the Boot Config File is only Owned by root and Set to Eead/Write only ##"
echo -e "## Command: ls -l /boot/grub2/grub.cfg                                          ##"
echo -e "##################################################################################"
ls -l /boot/grub2/grub.cfg

echo -e ""
echo -e "#####################################################################################################################"
echo -e "## Configure iptables to Limit Incoming Connection, either User Access or Service Connection, to Certain Static IP ##"
echo -e "## Command: iptables -L -n                                                                                         ##"
echo -e "#####################################################################################################################"
iptables -L -n

echo -e ""
echo -e "#######################################################"
echo -e "## Limit ssh incoming connection to ip from specific ##"
echo -e "## Command: iptables -L | grep ssh                   ##"
echo -e "#######################################################"
iptables -L | grep ssh

echo -e ""
echo -e "#######################################################"
echo -e "## Ensure SSH protocol is set to 2                   ##"
echo -e "## Command: cat /etc/ssh/sshd_config | grep Protocol ##"
echo -e "#######################################################"
cat /etc/ssh/sshd_config | grep Protocol

echo -e ""
echo -e "###################################################################"
echo -e "## Disable root Login and other Generic Account Login            ##"
echo -e "## Command: cat /etc/ssh/sshd_config | grep 'PermitRootLogin no' ##"
echo -e "###################################################################"
cat /etc/ssh/sshd_config | grep "PermitRootLogin no"

echo -e ""
echo -e "##########################################################################"
echo -e "## Disable SSH Password Login and only Allow Key Pair Authentication    ##"
echo -e "## Command: cat /etc/ssh/sshd_config | grep 'PasswordAuthentication no' ##"
echo -e "##########################################################################"
cat /etc/ssh/sshd_config | grep "PasswordAuthentication no"

echo -e ""
echo -e "#####################################"
echo -e "## Ensure Crowdstrike is Installed ##"
echo -e "## Command: ps -ef | grep falcon   ##"
echo -e "#####################################"
ps -ef | grep falcon

echo -e ""
echo -e "###########################################"
echo -e "## Configure Network Time Protocol (NTP) ##"
echo -e "## Command: ntpstat                      ##"
echo -e "###########################################"
ntpstat

echo -e ""
echo -e "#######################################################################"
echo -e "## Ensure Logon Warning Banner is configure                          ##"
echo -e "## Command: cat /etc/ssh/sshd_config | grep 'Banner /etc/ssh/banner' ##"
echo -e "#######################################################################"
cat /etc/ssh/sshd_config | grep "Banner /etc/"

echo -e ""
echo -e "##################################"
echo -e "## Logon Warning Banner Message ##"
echo -e "## Command: cat /etc/ssh/banner ##"
echo -e "##################################"
cat /etc/ssh/banner

echo -e ""
echo -e "################################################################"
echo -e "## Redirect log to log aggregation server, Gmoni(wazuh-agent) ##"
echo -e "## Command: systemctl status wazuh-agent                      ##"
echo -e "################################################################"
systemctl status wazuh-agent

echo -e ""
echo -e "#################################################"
echo -e "## Get All Users with authorized_keys Login    ##"
echo -e "## Command: find /home/ | grep authorized_keys ##"
echo -e "#################################################"
find /home/ | grep authorized_keys

echo -e ""
echo -e "###############################################################"
echo -e "## Get Authorized Users Authority                            ##"
echo -e "## Command: find /etc/sudoers.d/* -type f | xargs tail -n +1 ##"
echo -e "###############################################################"
find /etc/sudoers.d/* -type f | xargs tail -n +1