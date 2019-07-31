#!/bin/bash

#change working directory
cd $HOME

#add a user account for sumcoind
echo "Adding unprivileged user account for sumcoind, building the needed folder structure and setting folder permissions"
useradd -s /usr/sbin/nologin $SUMCOIND_USER

#install ufw firewall configuration package
echo "Installing firewall configuration tool"
apt-get install ufw -y

#install upstart
echo "Installing upstart"
apt-get install upstart -y

#allow needed firewall ports
echo "Setting up firewall ports and enable firewall"
ufw allow ssh
ufw allow 3333/tcp
iptables -A INPUT -p tcp --syn --dport 3333 -m connlimit --connlimit-above 8 --connlimit-mask 24 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp --syn --dport 3333 -m connlimit --connlimit-above 2 -j REJECT --reject-with tcp-reset
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 3333 -j ACCEPT
ufw --force enable

#create home directory
mkdir -v -p $SUMCOIND_HOME_DIR
chmod -R 0755 $SUMCOIND_HOME_DIR
chown -R $SUMCOIND_USER:$SUMCOIND_GROUP $SUMCOIND_HOME_DIR
#create data directory
mkdir -v -p $SUMCOIND_DATA_DIR
chmod -R 0700 $SUMCOIND_DATA_DIR
chown -R $SUMCOIND_USER:$SUMCOIND_GROUP $SUMCOIND_DATA_DIR
#create conf file
touch $SUMCOIND_CONF_FILE
chmod -R 0600 $SUMCOIND_CONF_FILE
chown -R $SUMCOIND_USER:$SUMCOIND_GROUP $SUMCOIND_CONF_FILE
#create bin directory
mkdir -v -p $SUMCOIND_BIN_DIR
chmod -R 0700 $SUMCOIND_BIN_DIR
chown -R $SUMCOIND_USER:$SUMCOIND_GROUP $SUMCOIND_BIN_DIR

#create sumcoin.conf file
echo "Creating the sumcoin.conf file"
echo "rpcuser=$RPC_USER" >> $SUMCOIND_CONF_FILE
echo "rpcpassword=$RPC_PASSWORD" >> $SUMCOIND_CONF_FILE
echo "rpcallowip=127.0.0.1" >> $SUMCOIND_CONF_FILE
echo "server=1" >> $SUMCOIND_CONF_FILE
echo "daemon=1" >> $SUMCOIND_CONF_FILE
echo "disablewallet=1" >> $SUMCOIND_CONF_FILE
echo "maxconnections=$CON_TOTAL" >> $SUMCOIND_CONF_FILE
echo "addnode=$selectedarray_one" >> $SUMCOIND_CONF_FILE
echo "addnode=$selectedarray_two" >> $SUMCOIND_CONF_FILE

#gets arch data
if test $ARCH -eq "64"
then
SUMCOIN_FILENAME=$SUMCOIN_FILENAME_64
SUMCOIN_DL_URL=$SUMCOIN_DL_URL_64
SUMCOIN_VER="$SUMCOIN_VER_NO_BIT-linux64"
else
SUMCOIN_FILENAME=$SUMCOIN_FILENAME_32
SUMCOIN_DL_URL=$SUMCOIN_DL_URL_32
SUMCOIN_VER="$SUMCOIN_VER_NO_BIT-linux32"
fi

#download, unpack and move the sumcoind binary
echo "Downloading, unpacking and moving sumcoind to $SUMCOIND_BIN_DIR"
wget $SUMCOIN_DL_URL -P $HOME
tar -zxvf $HOME/$SUMCOIN_FILENAME
rm -f -v $HOME/$SUMCOIN_FILENAME
cp -f -v $HOME/$SUMCOIN_VER_NO_BIT/bin/sumcoind $SUMCOIND_BIN_DIR
cp -f -v $HOME/$SUMCOIN_VER_NO_BIT/bin/sumcoin-cli $SUMCOIND_BIN_DIR
rm -r -f -v $HOME/$SUMCOIN_VER_NO_BIT

#add sumcoind to upstart so it starts on system boot
echo "Adding Sumcoind upstart script to make it start on system boot"
wget $UBUNTU_UPSTART_DL_URL -P $UBUNTU_UPSTART_CONF_DIR
chmod -R 0644 $UBUNTU_UPSTART_CONF_DIR/$UBUNTU_UPSTART_CONF_FILE
chown -R root:root $UBUNTU_UPSTART_CONF_DIR/$UBUNTU_UPSTART_CONF_FILE
initctl reload-configuration #reload the init config

#do we want to predownload bootstrap.dat
read -r -p "Do you want to download the bootstrap.dat file? If you choose yes your initial blockhain sync will most likely be faster but will take up some extra space on your hard drive (Y/N) " ANSWER
echo
if [[ $ANSWER =~ ^([yY])$ ]]
then
	echo "Downloading bootstrap.dat, this can take a moment"
	wget $BOOTSTRAP_DL_LOCATION -P $HOME/.sumcoin
fi

#start sumcoin daemon
echo "Starting sumcoind"
start sumcoind
