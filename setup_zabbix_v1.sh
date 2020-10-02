# ZabbixTest_agent_install
# Installation script Zabbix Agent
# Version 0.0.9
# March 20 2020
# Property of Purkinje Inc.
#!/bin/bash -e

######################################################

# ********* Script must be executed as root ********
#  Ubuntu 16 + 

#  This script assumes the UFW is enabled.

######################################################

# Set FTP server and credentials to upload required details after deploy.
# The final step is to send the hostname and IP of the edge device to the server.

# 	Password could be encoded for example: PASSWD='echo UHVya2luamUK | base64--decode'

# Uncomment the next 3 lines to add FTP server information.
# HOST='your.ftp.server'
# USER='ftp.account.username'
# PASSWD='ftp.account.password'


#####################################################

# Set Zabbix Server IP address (ZABIP) and Communicaiton port (PORT)
  ZABIP=1.2.3.4
  PORT=123

# Set Hostname
  HOSTNAME=`hostname`

# Get Primary IPv4 IP address of primary card and set to the configuration, may be required in some cases.
  AGIP=$(ip -o addr show up primary scope global | while read -r num dev fam addr rest; do echo ${addr%/*}; done)

#  Ubuntu 16 + using UFW for firewall, this script assumes the firewall is enabled.
if [ -x /usr/bin/apt-get ]; then
  apt-get update
  apt-get -y install zabbix-agent
  systemctl enable zabbix-agent

# Injecting custom configurations into Zabbix agent conf file.

  sed -i 's/# EnableRemoteCommands=0/EnableRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf
  sed -i 's/# LogRemoteCommands=0/LogRemoteCommands=1/' /etc/zabbix/zabbix_agentd.conf
  sed -i "s/Server=127.0.0.1/Server=$ZABIP/" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/ServerActive=127.0.0.1/# ServerActive=127.0.0.1/" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/Hostname=Zabbix\ server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf
# sed -i "s/# SourceIP=/SourceIP=$AGIP/" /etc/zabbix/zabbix_agentd.conf
# sed -i "s/# ListenIP=0.0.0.0/ListenIP=$AGIP/" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/# ListenPort=10050/ListenPort=$PORT/" /etc/zabbix/zabbix_agentd.conf
  sed -i 's/# UnsafeUserParameters=0/UnsafeUserParameters=1/' /etc/zabbix/zabbix_agentd.conf
  sed -i 's/# TLSConnect=unencrypted/TLSConnect=psk/' /etc/zabbix/zabbix_agentd.conf
  sed -i 's/# TLSAccept=unencrypted/TLSAccept=psk/' /etc/zabbix/zabbix_agentd.conf
  sed -i "s/# TLSPSKIdentity=/TLSPSKIdentity=purk-zabbix-exchange-001/" /etc/zabbix/zabbix_agentd.conf
echo "TLSPSKFile=/etc/zabbix/zabbix_agentd.psk" >> /etc/zabbix/zabbix_agentd.conf
echo "1f87b595725ac58dd977beef14b97461a7c1045b9a1c96308899ca445566aaff" >> /etc/zabbix/zabbix_agentd.psk


# -----------8<--------customizations and userparams------>8--------------
# For remote file execution and custom userparams,create a zabbix_agentd_userparams.conf
# Include the file from the /etc/zabbix/ folder into the agent load process.

# echo "Include=/etc/zabbix/zabbix_agentd_userparams.conf" >> /etc/zabbix/zabbix_agentd.conf

# Configure Zabbix server to read outputs from the userparams and apply rules and conditions to the agent for remote execution.
# -----------8<------------------------------------------->8-------------

# Open firewall for zabbix communication
  ufw allow from $ZABIP/32 to any port $PORT
  ufw reload

#Restarting zabbix agent
  systemctl restart zabbix-agent

# Preparing details file for zabbix server
echo $HOSTNAME >> ./hostname.txt
echo $AGIP >> ./hostname.txt

#################################################
#----------------FTP PROCESS--------------------#

# Send Required information to FTP Server
# uncomment the next 7 lines

# sftp -n -v $HOST << EOT
# ascii
# user $USER $PASSWD
# prompt
# put ./$HOSTNAME.txt
# bye
# EOT

#################################################
fi

