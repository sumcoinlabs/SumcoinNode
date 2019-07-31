#!/bin/bash

#stop the sumcoin daemon
echo "Stop Sumcoind to make sure it does not lock any files"
stop sumcoind

#remove the upstart script
echo "Removing the sumcoind upstart script"
rm -r -f -v $UBUNTU_UPSTART_CONF_DIR/$UBUNTU_UPSTART_CONF_FILE
initctl reload-configuration #reload the init config

#remove the sumcoind user account and group
echo "Removing the sumcoind user and group"
userdel $SUMCOIND_USER
groupdel $SUMCOIND_GROUP

#check if the sumcoin-node-status.py script exists and remove it if true
NODESTATUS_FILE="$HOME/scripts/sumcoin-node-status.py"

if [ -f "$NODESTATUS_FILE" ]
then
	#Remove the sumcoin-node-status.py file
	echo "Removing the sumcoin node status file"
	rm -f -v $NODESTATUS_FILE

	#remove sumcoin-node-status.py from cron
	echo "Removing sumcoin node status script from cron"
	crontab -l > $HOME/scripts/crontempfile
	sed -i '/sumcoin-node-status.py/d' $HOME/scripts/crontempfile
	crontab $HOME/scripts/crontempfile
	rm $HOME/scripts/crontempfile
	pip uninstall python-bitcoinrpc -y #remove python-bitcoinrpc as it is no longer useful without sumcoind running
fi

#check if the ubuntu-update.sh script exists and remove it if true
UBUNTU_UPDATE_FILE="$HOME/scripts/ubuntu-update.sh"

if [ -f "$UBUNTU_UPDATE_FILE" ]
then

	#Remove the ubuntu-update.sh file
	echo "Removing the ubuntu update file"
	rm -f -v $UBUNTU_UPDATE_FILE

	#remove ubuntu-update.sh from cron
	echo "Removing the update script from cron"
	crontab -l > $HOME/scripts/crontempfile
	sed -i '/ubuntu-update.sh/d' $HOME/scripts/crontempfile
	crontab $HOME/scripts/crontempfile
	rm $HOME/scripts/crontempfile
fi

#Below we check if the wallet.dat file exists in /home/sumcoind/.sumcoin. The project specifically lets sumcoind run with the --disable wallet option so a wallet.dat
#should not exist in /home/sumcoind/.sumcoin but if it does for whatever reason we should back it up just in case

#check if the wallet file exists and back it up if true
WALLET_FILE="$HOME/.sumcoin/wallet.dat"

if [ -f "$WALLET_FILE" ]
then
        #backup the wallet file
        echo "Backing up the wallet.dat file to /root/backup/sumcoind"
        mkdir -p /root/backup/sumcoind
        mv -v $WALLET_FILE /root/backup/sumcoind/wallet.dat
fi

#remove sumcoin specific firewall rules
echo "Removing firewall rules."
ufw delete allow 3333/tcp
iptables -D INPUT -p tcp --syn --dport 3333 -m connlimit --connlimit-above 8 --connlimit-mask 24 -j REJECT --reject-with tcp-reset
iptables -D INPUT -p tcp --syn --dport 3333 -m connlimit --connlimit-above 2 -j REJECT --reject-with tcp-reset
iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport 3333 -j ACCEPT

#remove sumcoind home directory
echo "Removing the sumcoind home directory."
rm -r -f -v $SUMCOIND_HOME_DIR
