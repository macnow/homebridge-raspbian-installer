#!/bin/bash
set -x

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y git make libavahi-compat-libdnssd-dev

if [ "x$(uname -m)" != "xarmv6l" ]; then
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    wget https://nodejs.org/dist/v6.9.0/node-v6.9.0-linux-armv6l.tar.xz
    sudo tar -xf node-v6.9.0-linux-armv6l.tar.xz
    cd node-v6.9.0-linux-armv6l/
    sudo cp -R * /usr/
    cd -
fi
sudo npm install -g --unsafe-perm homebridge hap-nodejs node-gyp
cd /usr/lib/node_modules/homebridge/
sudo npm install --unsafe-perm bignum
cd -
cd /usr/lib/node_modules/hap-nodejs/node_modules/mdns
sudo node-gyp BUILDTYPE=Release rebuild
cd -
sudo npm install -g json
sudo useradd --system --user-group homebridge
sudo mkdir -p /var/homebridge
sudo cp configs/config.json /var/homebridge/config.json
sudo chown -R homebridge:homebridge /var/homebridge/
sudo cp files/homebridge /etc/default/homebridge
sudo cp files/homebridge.service /etc/systemd/system/homebridge.service
sudo systemctl daemon-reload
sudo systemctl enable homebridge
sudo systemctl start homebridge
chmod +x scripts/*
chmod +x configure.sh
./configure.sh
