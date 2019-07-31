#!/bin/bash

#load global variables file
wget -q https://raw.githubusercontent.com/sumcoinlabs/SumcoinNode/master/glob-vars.sh -P /root
source /root/glob-vars.sh
rm -f -v /root/glob-vars.sh

#change working directory
cd $HOME

#get current version from repository
wget $SCRIPT_DL_URL/shared/version -P $HOME

#check version
LOC_VERSION=$(sed -n 1p $HOME/scripts/version) #get the current local version number
REP_VERSION=$(sed -n 1p $HOME/version) #get the current version number from the repository

if [ "$LOC_VERSION" -lt "$REP_VERSION" ]
then
	#stop the sumcoin daemon
	echo "We need to update!"
	echo "Stop Sumcoind to make sure it does not lock any files"
	stop sumcoind

	#remove old sumcoind binary
	echo "Removing old sumcoind bin file"
	rm -f -v $SUMCOIND_BIN_DIR/sumcoind
	rm -f -v $SUMCOIND_BIN_DIR/sumcoin-cli

	#gets arch data
	if test $ARCH -eq "64"
	then
	SUMCOIN_DL_URL=$SUMCOIN_DL_URL_64
	SUMCOIN_VER="$SUMCOIN_VER_NO_BIT-x86_64-linux-gnu"
	else
	SUMCOIN_DL_URL=$SUMCOIN_DL_URL_32
	SUMCOIN_VER="$SUMCOIN_VER_NO_BIT-i686-pc-linux-gnu"
	fi

	#download, unpack and move the new sumcoind binary
	echo "Downloading, unpacking and moving new Sumcoind version to $SUMCOIND_BIN_DIR"
	wget $SUMCOIN_DL_URL -P $HOME
	tar zxvf $HOME/$SUMCOIN_VER.tar.gz
	rm -f -v $HOME/$SUMCOIN_VER.tar.gz
	cp -f -v $HOME/$SUMCOIN_VER_NO_BIT/bin/sumcoind $SUMCOIND_BIN_DIR
	cp -f -v $HOME/$SUMCOIN_VER_NO_BIT/bin/sumcoin-cli $SUMCOIND_BIN_DIR
	rm -r -f -v $HOME/$SUMCOIN_VER_NO_BIT

	#start sumcoin daemon
	echo "Starting new sumcoind"
	start sumcoind

	#remove current and move the new version file
	echo "Removing current version file."
	rm -f -v $HOME/scripts/version
	echo "Moving the new version file."
	mv -v $HOME/version $HOME/scripts
	chmod -R 0600 $HOME/scripts/version
	chown -R root:root $HOME/scripts/version

	#update the node status page and sumcoin-node-status.py script if the sumcoin-node-status.py file exists
	NODESTATUS_FILE="$HOME/scripts/sumcoin-node-status.py"

	if [ -f "$NODESTATUS_FILE" ]
	then

		#remove current website files
		echo "removing current website files"
		rm -f -v $UBUNTU_WEBSITE_DIR/banner.png
		rm -f -v $UBUNTU_WEBSITE_DIR/bootstrap.css
		rm -f -v $UBUNTU_WEBSITE_DIR/favicon.ico
		rm -f -v $UBUNTU_WEBSITE_DIR/style.css

		#get update the website files
		echo "Updating current website files"
		wget $WEBSITE_DL_URL/banner.png -P $UBUNTU_WEBSITE_DIR
		wget $WEBSITE_DL_URL/bootstrap.css -P $UBUNTU_WEBSITE_DIR
		wget $WEBSITE_DL_URL/favicon.ico -P $UBUNTU_WEBSITE_DIR
		wget $WEBSITE_DL_URL/style.css -P $UBUNTU_WEBSITE_DIR

		#Remove the current sumcoin-node-status.py file
		echo "Remove sumcoin-node-status.py file"
		rm -f -v $HOME/scripts/sumcoin-node-status.py

		#get updated sumcoin-node-status.py file
		echo "download new sumcoin-node-status.py file"
		wget $NODESTATUS_DL_URL -P $HOME/scripts
		chmod -R 0700 $HOME/scripts/sumcoin-node-status.py
		chown -R root:root $HOME/scripts/sumcoin-node-status.py

		#get the rpcuser and rpcuserpassword from the sumcoin.conf file to inject later
		RPC_USER=$(sed -n 1p $SUMCOIND_CONF_FILE | cut -c9-39) #get the rpcuser  from the sumcoin.conf file
		RPC_PASSWORD=$(sed -n 2p $SUMCOIND_CONF_FILE | cut -c13-42) #get the rpcuserpassword from the sumcoin.conf file

		#Add $UBUNTU_WEBSITE_DIR to the new sumcoin-node-status.py script
		echo "Add the distributions website dir to the sumcoin-nodes-status.py script"
		sed -i -e '13iff = open('"'$UBUNTU_WEBSITE_DIR/index.html'"', '"'w'"')\' $HOME/scripts/sumcoin-node-status.py

		#Add Sumcoin rpc user and password to the  new sumcoin-node-status.py script
		echo "Add Sumcoin rpc user and password to the sumcoin-nodes-tatus.py script"
		sed -i -e '10iget_lcd_info = AuthServiceProxy("http://'"$RPC_USER"':'"$RPC_PASSWORD"'@127.0.0.1:3332")\' $HOME/scripts/sumcoin-node-status.py #add the rpcuser and rpcpassword to the sumcoin-node-status.py script

		#Add a countdown to give sumcoind some time to start before updating the nodestatus page to prevent an access denied error
		echo "Start countdown to give sumcoind some time to start before updating the node status page."
		cdtime=$((1 * 15))
		while [ $cdtime -gt 0 ]; do
			echo -ne "$cdtime\033[0K\r"
			sleep 1
			: $((cdtime--))
		done

		#update the nodestatus page
		python $HOME/scripts/sumcoin-node-status.py
	fi
else
	rm -f -v $HOME/version
	echo "No need to update, exiting."
fi
