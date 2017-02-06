#!/bin/sh

sudo apt-get update

sudo apt-get install -y git
git clone https://github.com/macnow/homebridge-raspbian-installer.git
cd homebridge-raspbian-installer
./install.sh
