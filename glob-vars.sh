#define user account, group and current sumcoin version
SUMCOIND_USER="sumcoind" #the user sumcoind will run under
SUMCOIND_GROUP="sumcoind" #the group sumcoind is a member of
SUMCOIN_VER_NO_BIT="sumcoin-0.14.2"
SUMCOIN_VER_W_BIT="$SUMCOIN_VER_NO_BIT.0"

#define directory locations
HOME="/home/sumcoind" #home directory of the sumcoind user, we store some script and tempfiles here
SUMCOIND_BIN_DIR="$HOME/bin" #the directory that stores the binary files of sumcoind
SUMCOIND_DATA_DIR="$HOME/.sumcoin" #the directory that holds the sumcoind data
SUMCOIND_HOME_DIR="$HOME" #home directory of sumcoind user account

#define configuration file locations
SUMCOIND_CONF_FILE="$HOME/.sumcoin/sumcoin.conf" #the sumcoind configuration file

#generate random user and password for rpc access to sumcoind
RPC_USER=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30` #this generates a random rpc username
RPC_PASSWORD=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30` #this generates a random rpc password

#calculate the max connections to insert into sumcoin.conf based on memory
CON_TOTAL=$(grep MemTotal: /proc/meminfo | awk '($2) {CON_TOTAL=($2/1024/8)+0.5/1} END{printf "%0.f\n", CON_TOTAL}')

#define system architecture
ARCH=$(getconf LONG_BIT)

#array to select a random sync node to insert in sumcoin.conf
array=("134.209.173.235" "46.101.36.164" "178.128.254.32" "104.248.222.46" "209.97.130.23" "209.97.130.23")
RANDOM=$$$(date +%s)
selectedarray_one=${array[$RANDOM % ${#array[@]} ]}
selectedarray_two=${array[$RANDOM % ${#array[@]} ]}

#array to select random bootstrap.dat download location
array=("http://bootstrap.sumcoinnode.org/bootstrap.dat") #please add more download locations when we have them
RANDOM=$$$(date +%s)
BOOTSTRAP_DL_LOCATION=${array[$RANDOM % ${#array[@]} ]}

#define download locations
SCRIPT_DL_URL="https://raw.githubusercontent.com/sumcoinlabs/SumcoinNode/master" #the download location of the script files
WEBSITE_DL_URL="https://raw.githubusercontent.com/sumcoinlabs/SumcoinNode/master/shared/www" #the download location of the status page website files

SUMCOIN_FILENAME_64="$SUMCOIN_VER_NO_BIT-x86_64-linux-gnu.tar.gz" #sumcoin x64 file name
SUMCOIN_DL_URL_64="https://download.sumcoin.org/$SUMCOIN_VER_NO_BIT/linux/$SUMCOIN_FILENAME_64" #sumcoin x64 download link

SUMCOIN_FILENAME_32="$SUMCOIN_VER_NO_BIT-i686-pc-linux-gnu.tar.gz" #sumcoin x32 file name
SUMCOIN_DL_URL_32="https://download.sumcoin.org/$SUMCOIN_VER_NO_BIT/linux/$SUMCOIN_FILENAME_32" #sumcoin x32 download link

SUMCOIN_FILENAME_ARM="$SUMCOIN_VER_NO_BIT-arm-linux-gnueabihf.tar.gz" #sumcoin arm file name
SUMCOIN_DL_URL_ARM="https://download.sumcoin.org/$SUMCOIN_VER_NO_BIT/linux/$SUMCOIN_FILENAME_ARM" #sumcoin arm download link - EXPERIMENTAL

SUMCOIN_FILENAME_ARCH64="$SUMCOIN_VER_NO_BIT-aarch64-linux-gnu.tar.gz" #sumcoin arch64 file name
SUMCOIN_DL_URL_ARCH64="https://download.sumcoin.org/$SUMCOIN_VER_NO_BIT/linux/$SUMCOIN_FILENAME_ARCH64" #sumcoin arch64 download link - EXPERIMENTAL
NODESTATUS_DL_URL="$SCRIPT_DL_URL/shared/sumcoin-node-status.py" #the download location of the sumcoin-node-status.py file

#ubuntu specific variables
#define ubuntu directory locations
UBUNTU_UPSTART_CONF_DIR="/etc/init" #the directory that stores the sumcoind upstart configuration file
UBUNTU_WEBSITE_DIR="/usr/share/nginx/html" #the directory that stores the http status page files

#define configuration file locations
UBUNTU_UPSTART_CONF_FILE="sumcoind.conf" #name of the sumcoind upstart script config file. This is not the sumcoin.conf file!

#define download locations
UBUNTU_BASE="$SCRIPT_DL_URL/$DIST" #base directory for ubuntu script files
UBUNTU_UPSTART_DL_URL="$UBUNTU_BASE/sumcoind.conf" #the download location of the upstart.conf file for sumcoind

#debian specific variables
#define debian directory locations
DEBIAN_SYSTEMD_CONF_DIR="/lib/systemd/system" #the directory that stores the sumcoind systemd configuration file
DEBIAN_WEBSITE_DIR="/var/www/html" #the directory that stores the http status page files

#define configuration file locations
DEBIAN_SYSTEMD_CONF_FILE="sumcoind.service" #name of the sumcoind systemd script config file. This is not the sumcoin.conf file!

#define download locations
DEBIAN_BASE="$SCRIPT_DL_URL/$DIST" #base directory for debian script files
DEBIAN_SYSTEMD_DL_URL="$DEBIAN_BASE/sumcoind.service" #the download location of the systemd.conf file for sumcoind

#raspbian specific variables
#define raspbian directory locations
RASPBIAN_SYSTEMD_CONF_DIR="/lib/systemd/system" #the directory that stores the sumcoind systemd configuration file
RASPBIAN_WEBSITE_DIR="/var/www/html" #the directory that stores the http status page files

#define configuration file locations
RASPBIAN_SYSTEMD_CONF_FILE="sumcoind.service" #name of the sumcoind systemd script config file. This is not the sumcoin.conf file!

#define download locations
RASPBIAN_BASE="$SCRIPT_DL_URL/$DIST" #base directory for raspbian script files
RASPBIAN_SYSTEMD_DL_URL="$RASPBIAN_BASE/sumcoind.service" #the download location of the systemd.conf file for sumcoind
