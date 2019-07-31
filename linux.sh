#!/bin/bash

#load global variables file
wget -q https://raw.githubusercontent.com/sumcoinlabs/SumcoinNode/master/glob-vars.sh -P /root
source /root/glob-vars.sh
rm -f -v /root/glob-vars.sh

#change working directory
cd $HOME
clear

echo ""
echo "-----------------------------------------------------------------------"
echo "version = $SUMCOIN_VER_NO_BIT"
echo ""
echo "Welcome to the sumcoinnode.org Sumcoin full node script for Linux."
echo "This script will install, update or remove a Sumcoin full node."
echo "We will ask you some questions do determine what we need to do."
echo "To start please select an option from the menu below."
echo "For more information or help visit http://sumcoinnode.org"
echo ""
echo "-----------------------------------------------------------------------"
echo ""

#create operating system choice menu
PS3="Please select your choice: "
CHOICE=("Install" "Update" "Remove" "Exit")
select CHC in "${CHOICE[@]}"
do
	case $CHC in
		"Install")
				wget $SCRIPT_DL_URL/linux-install.sh -P $HOME
				source $HOME/linux-install.sh
				rm -f -v linux.sh

				#we are done. exit the script
				exit
			;;
		"Update")
				#define distribution
				wget $SCRIPT_DL_URL/linux-update.sh -P $HOME
				source $HOME/linux-update.sh
				rm -f -v linux.sh

				#we are done. exit the script
				exit
			;;
		"Remove")
				#define distribution
				wget $SCRIPT_DL_URL/linux-remove.sh -P $HOME
				source $HOME/linux-remove.sh
				rm -f -v linux.sh

				#we are done. exit the script
				exit
			;;
		"Exit")
				echo ""
				rm -f /root/linux.sh
				break
			;;
		*) echo "Invalid option.";;
	esac
done
