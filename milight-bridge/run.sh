#!/bin/bash

CONFIG_PATH=/data/options.json
SERVERIP=$(jq --raw-output ".serverip" $CONFIG_PATH)
SERVERPORT=$(jq --raw-output ".serverport" $CONFIG_PATH)
VERSION=$(jq --raw-output ".version" $CONFIG_PATH)

if [ "$SERVERIP" == "" ]; then
  echo "[ERROR] serverip must be specified!"
  exit 1
fi

# Create /share/milightsbridge/data folder
if [ ! -d /share/milightsbridge/data ]; then
  echo "[INFO] Creating /share/milightsbridge folder"
  mkdir -p /share/milightsbridge/data
fi

# Migrate existing config files to handle upgrades from previous version
if [ -e /data/milightsbridge.config ] && [ ! -e /share/milightsbridge/data/milightsbridge.config ]; then
  # Migrate existing milightsbridge.config file
  echo "[INFO] Migrating existing milightsbridge.config from /data to /share/milightsbridge/data"
  mv -f /data/milightsbridge.config /share/milightsbridge/data
fi

# Migrate existing backup files
find /data -name '*.cfgbk' \
  -exec echo "[INFO] Moving existing {} to /share/milightsbridge" \; \
  -exec mv -f {} /share/milightsbridge \;

cd /share/milightsbridge
if [ ! -z $VERSION ] && [ ! "$VERSION" == "" ] && [ ! "$VERSION" == "null" ] && [ ! "$VERSION" == "latest" ]; then
  echo "Manual version override:" $VERSION
else
  #Check the latest version on github
  VERSION="$(curl -sX GET https://api.github.com/repos/bwssytems/milight-bridge/releases/latest | grep 'tag_name' | cut -d\" -f4)"
  VERSION=${VERSION:1}
  echo "Latest version on bwssystems github repo is" $VERSION
fi

# Download jar
if [ ! -f /share/milightsbridge/milight-bridge-"$VERSION".jar ]; then
  echo "Installing version '$VERSION'"
  wget https://github.com/bwssytems/milight-bridge/releases/download/v"$VERSION"/milight-bridge-"$VERSION".jar -O /share/milightsbridge/milight-bridge-"$VERSION".jar
else
  echo "Using existing version '$VERSION'"
fi
echo "Setting correct permissions"
chown -R nobody:users /share/milightsbridge

ADDPARAM="-Dupnp.config.address=$SERVERIP -Dserver.port=$SERVERPORT -Djava.net.preferIPv4Stack=true"
echo -e "Parameters used:\n  Server IP : $SERVERIP\n  Server Port : $SERVERPORT\n  preferIPv4Stack : true"

echo "Starting Home Automation Bridge"
java -jar $ADDPARAM /share/milightsbridge/milight-bridge-"$VERSION".jar 2>&1 | tee /share/milightsbridge/milight-bridge.log
