#!/bin/bash

#change working directory
cd $HOME

#add a user account for sumcoind
echo "Adding unprivileged user account for sumcoind, building the needed folder structure and setting folder permissions"
useradd -s /usr/sbin/nologin $SUMCOIND_USER

#install ufw firewall configuration package
echo "Installing firewall configuration tool"
apt-get install ufw -y

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

#setup dependencies
echo "Installing dependencies required for building Sumcoin"
sudo apt-get install autoconf libtool libssl-dev libboost-all-dev libminiupnpc-dev -y
sudo apt-get install qt4-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev -y

#setup berkleydb and other build dependencies
echo "Setting up berkleydb"
wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
tar -xzvf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix; ../dist/configure --enable-cxx
make -j2
sudo make install

#build sumcoind
echo "Building Sumcoin"
cd ..
git clone https://github.com/sumcoin-project/sumcoin.git
cd sumcoin/
./autogen.sh
./configure CPPFLAGS="-I/usr/local/BerkeleyDB.4.8/include -O2" LDFLAGS="-L/usr/local/BerkeleyDB.4.8/lib"
make -j2
sudo make install

#Move the already built sumcoind binary
echo "Moving sumcoind to $SUMCOIND_BIN_DIR"
cp -f -v sumcoind $SUMCOIND_BIN_DIR
cp -f -v sumcoin-cli $SUMCOIND_BIN_DIR

#add sumcoind to systemd so it starts on system boot
echo "Adding Sumcoind systemd script to make it start on system boot"
wget --progress=bar:force $RASPBIAN_SYSTEMD_DL_URL -P $RASPBIAN_SYSTEMD_CONF_DIR
chmod -R 0644 $RASPBIAN_SYSTEMD_CONF_DIR/$RASPBIAN_SYSTEMD_CONF_FILE
chown -R root:root $RASPBIAN_SYSTEMD_CONF_DIR/$RASPBIAN_SYSTEMD_CONF_FILE
systemctl enable sumcoind.service #enable sumcoind systemd config file

#do we want to predownload bootstrap.dat
read -r -p "Do you want to download the bootstrap.dat file? If you choose yes your initial blockhain sync will most likely be faster but will take up some extra space on your hard drive (Y/N) " ANSWER
echo
if [[ $ANSWER =~ ^([yY])$ ]]
then
	echo "Downloading bootstrap.dat, this can take a moment"
	wget --progress=bar:force $BOOTSTRAP_DL_LOCATION -P $HOME/.sumcoin
fi

#start sumcoin daemon
echo "Starting sumcoind"
systemctl start sumcoind.service
