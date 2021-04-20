#!/bin/bash

# Log everything
exec 2> ~/eth2-docker.log  # send stderr from to a log file
exec 1>&2                      # send stdout to the same log file
set -ex                         # tell sh to display commands before execution

# Don't run as root
if [[ $EUID -eq 0 ]]; then
   echo "Do not run as root." 
   exit 1
fi


# Create ENV file if needed
ENV_FILE=.env 

if ! [[ -f "$ENV_FILE" ]]; then
    ENV_FILE_GUESS="$(eval realpath default.env)"
    ENV_TEMPLATE=$(whiptail --title "Configure ENV_FILE" --inputbox "No $ENV_FILE file found, press enter to use the default, or choose a backup" 10 60 $ENV_FILE_GUESS 3>&1 1>&2 2>&3)

    # Ask the user
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        echo "your ENV_TEMPLATE is:" $ENV_FILE
    else
        echo "You chose Cancel."
    fi

    # Update The Value in env.
    cp $ENV_TEMPLATE $ENV_FILE
fi

# LOCAL_UID

# Guess LOCAL_UID
LOCAL_UID_GUESS=$(grep LOCAL_UID $ENV_FILE | cut -d "=" -f2 |  sed -e 's/ //g')

LOCAL_UID=$(whiptail --title "Configure LOCAL_UID" --inputbox "What is your LOCAL_UID?" 10 60 $LOCAL_UID_GUESS 3>&1 1>&2 2>&3)

# Ask the user
exitstatus=$?
if [ $exitstatus = 0 ]; then
	echo "your LOCAL_UID is:" $LOCAL_UID
else
	echo "You chose Cancel."
    exit 0
fi

# Update The Value in env.
if ! grep -qF "LOCAL_UID" $ENV_FILE 2>/dev/null ; then
    echo "LOCAL_UID=${LOCAL_UID}" >> $ENV_FILE
fi
echo $LOCAL_UID
sed -i "s/^\(LOCAL_UID\s*=\s*\).*$/\1${LOCAL_UID}/" $ENV_FILE

# ETH1 Client

ETH1_CLIENT=$(whiptail --title "Select Client" --radiolist \
"What eth1 client do you want to Run?  Choose None for 3rd parties like Infura" 15 60 4 \
"NONE" "Infura..." ON \
"geth.yml" "Geth" OFF \
"nm.yml" "Nethermind" OFF \
"oe.yml" "OpenEthereum" OFF \
"besu.yml" "Besu" OFF 3>&1 1>&2 2>&3)

# Ask the user
exitstatus=$?
if [ $exitstatus != 0 ]; then exit 0 ; fi

if [ $ETH1_CLIENT = "NONE" ]; then
	unset ETH1_CLIENT
fi


# ETH2 Client

ETH2_CLIENT=$(whiptail --title "Select Client" --radiolist \
"What eth2 client?" 15 60 4 \
"prysm-base.yml" "Prysm" OFF \
"lh-base.yml" "Lighthouse" ON \
"teku-base.yml" "Teku" OFF \
"nimbus-base" "Nimus" OFF 3>&1 1>&2 2>&3)

# Ask the user
exitstatus=$?
if [ $exitstatus != 0 ]; then exit 0 ; fi

echo $ETH2_CLIENT

# Use Grafana
if (whiptail --title "Select Option" --yesno "Use Grafana yes or no." 10 60) then
	GRAFANA=yes
else
	GRAFANA=no
fi

# Which Grafana should be used
if [ $GRAFANA = "yes" ]; then
	GRAFANA_CLIENT=$(echo $(echo $ETH2_CLIENT | cut -d '-' -f1)-grafana.yml)
else
	unset GRAFANA_CLIENT
fi


# COMPOSE_FILE

# Guess COMPOSE_FILE
COMPOSE_FILE_GUESS=${ETH2_CLIENT}:${ETH1_CLIENT}:${GRAFANA_CLIENT}

if ! (whiptail --title "COMPOSE_FILE look good??" --yesno "$COMPOSE_FILE_GUESS." 10 60) then
    COMPOSE_FILE=$(whiptail --title "Configure COMPOSE_FILE" --inputbox "What is your COMPOSE_FILE?" 10 60 $COMPOSE_FILE_GUESS 3>&1 1>&2 2>&3)	
else
    COMPOSE_FILE=${COMPOSE_FILE_GUESS}
fi

# Ask the user
exitstatus=$?
if [ $exitstatus = 0 ]; then
	echo "your COMPOSE_FILE is:" $COMPOSE_FILE
else
	echo "You chose Cancel."
    exit 0
fi

# Update The Value in env.
if ! grep -qF "COMPOSE_FILE" $ENV_FILE 2>/dev/null ; then
    echo "COMPOSE_FILE=${COMPOSE_FILE}" >> $ENV_FILE
fi
echo $COMPOSE_FILE
sed -i "s/^\(COMPOSE_FILE\s*=\s*\).*$/\1${COMPOSE_FILE}/" $ENV_FILE


# Mainnet or Testnet
# Network

ETH2_NETWORK=$(whiptail --title "Select Network" --radiolist \
"What network?" 15 60 4 \
"mainnet" "Production" OFF \
"pyrmont" "Testnet" ON 3>&1 1>&2 2>&3)

# Update The Value in env.
if [ $ETH2_NETWORK = "mainnet" ]; then
    sed -i "s/^\(NETWORK\s*=\s*\).*$/\1mainnet/" $ENV_FILE
    sed -i "s/^\(ETH1_NETWORK\s*=\s*\).*$/\1mainnet/" $ENV_FILE
    sed -i "s/^GETH1_NETWORK/# GETH1_NETWORK/" $ENV_FILE
elif [ $ETH2_NETWORK = "pyrmont" ]; then
    sed -i "s/^\(NETWORK\s*=\s*\).*$/\1pyrmont/" $ENV_FILE
    sed -i "s/^\(ETH1_NETWORK\s*=\s*\).*$/\1goerli/" $ENV_FILE
    sed -i "s/^# GETH1_NETWORK/GETH1_NETWORK/" $ENV_FILE
else
	echo "You chose Cancel."
    exit 0
fi