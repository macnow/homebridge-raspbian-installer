#!/bin/bash
set -x

UNAME=`uname -m`

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y make libavahi-compat-libdnssd-dev dialog

case "$UNAME" in
    "armv6l")
        wget -r -l1 -e robots=off -np "https://nodejs.org/dist/latest/" -A "node-v*-linux-armv6l.tar.xz"
        cd nodejs.org/dist/latest/
        sudo tar -xf *-linux-armv6l.tar.xz
        cd *-linux-armv6l/
        sudo cp -R * /usr/
        cd ../../../../
        ;;
    "armv7l")
        wget -r -l1 -e robots=off -np "https://nodejs.org/dist/latest/" -A "node-v*-linux-armv7l.tar.xz" -P .
        cd nodejs.org/dist/latest/
        sudo tar -xf *-linux-armv7l.tar.xz
        cd *-linux-armv7l/
        sudo cp -R * /usr/
        cd ../../../../
        ;;
    *)
        curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
        sudo apt-get install -y nodejs
        ;;
esac

mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH
source ~/.profile

npm install -g --unsafe-perm homebridge hap-nodejs node-gyp json homebridge-server
cd ~/.npm-global/homebridge
npm install --unsafe-perm bignum
cd -
cd ~/.npm-global/hap-nodejs/node_modules/mdns
sudo node-gyp BUILDTYPE=Release rebuild
cd -
sudo useradd --system --user-group homebridge
sudo usermod -a -G systemd-journal homebridge

sudo mkdir -p /var/homebridge
sudo cp configs/config.json /var/homebridge/config.json
#printf '%02X:%02X:%02X:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256] $[RANDOM%256]
sudo chown -R homebridge:homebridge /var/homebridge/

sudo cp files/homebridge /etc/default/homebridge
sudo cp files/homebridge.service /etc/systemd/system/homebridge.service
sudo cp files/sudoers /etc/sudoers.d/homebridge

sudo systemctl daemon-reload
sudo systemctl enable homebridge
sudo systemctl start homebridge

chmod +x scripts/*
chmod +x configure.sh

#./configure.sh
