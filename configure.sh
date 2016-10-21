#!/bin/bash

LINES=$(tput lines)
COLS=$(tput cols)

function menu_main()
{
choose=$(dialog --title "Homebridge configuration tool" --backtitle "Homebridge configuration tool by @macnow" \
--stdout --no-cancel --menu "" 12 50 17 \
1 "Plugins Installer" \
2 "Configuration Editor" \
3 "Homebridge Restart" \
4 "Quit" )

output=$?
if [[ $output != "" || $output == "" ]]
then
    if [[ $choose -eq 1 ]]
    then
    menu_plugins
    elif [[ $choose -eq 2 ]]
    then
    menu_configure
    elif [[ $choose -eq 3 ]]
    then
    menu_restart
    else
    menu_end
    fi
else
menu_end
fi
}

function menu_configure()
{
choose=$(dialog --title "/var/homebridge/config.json" --backtitle "Homebridge configuration tool by @macnow - Configuration Editor" \
--stdout --ok-label Save --editbox /var/homebridge/config.json $((LINES-10)) $((COLS-5)) )
output=$?
if [[ $output != "" || $output == "" ]]
then
    if [[ $output -eq 0 ]]
    then
        echo $choose|json -4 > /tmp/config.json$$ 
        json_output=$?
	if [[ $json_output -eq 0 ]]
        then
            sudo mv -f /tmp/config.json$$ /var/homebridge/config.json
            sudo chown homebridge:homebridge /var/homebridge/config.json
            dialog --title "Homebridge configure" --backtitle "Homebridge configurator" \
            --stdout --msgbox "Configuration saved!" 5 50
        else
            dialog --title "Homebridge configure" --backtitle "Homebridge configurator" \
            --stdout --msgbox "ERROR: Configuration not saved!" 5 50
	fi
        menu_main
    else
        menu_main
    fi
fi

}

function menu_plugins()
{
choose=$(dialog --title "Homebridge plugins installer" --backtitle "Homebridge configuration tool by @macnow - Plugins Installer" \
--stdout --no-cancel --menu "" 13 50 17 \
1 "Belkin WeMo Platform" \
2 "Orvibo Smart Socket Platform" \
3 "TPLink HS100/HS110 WiFi Smart Plug" \
4 "< Back to prev menu" )

output=$?
if [[ $output != "" || $output == "" ]]
then
    if [[ $choose -eq 1 ]]
    then
        menu_plugin homebridge-platform-wemo
    elif [[ $choose -eq 2 ]]
    then
        menu_plugin homebridge-platform-orvibo
    elif [[ $choose -eq 3 ]]
    then
        menu_plugin homebridge-hs100
    else
        menu_main
    fi
else
menu_main
fi
}

function menu_plugin()
{
choose=$(dialog --title "$1" --backtitle "Homebridge configuration tool by @macnow - Plugins Installer - $1" \
--stdout --no-cancel --menu "" 13 50 17 \
1 "Install plugin" \
2 "Update plugin" \
3 "< Back to prev menu" )

output=$?
if [[ $output != "" || $output == "" ]]
then
    if [[ $choose -eq 1 ]]
    then
	dialog --title "$1" --backtitle "Homebridge configuration tool by @macnow - Plugins Installer - $1" \
        --stdout --infobox "Installing plugin...\nThis may take several minutes." 4 50
	sudo npm install -g $1
	scripts/config-merge.py /var/homebridge/config.json configs/$1.json > /tmp/config.json$$
        sudo mv -f /tmp/config.json$$ /var/homebridge/config.json
	sudo chown homebridge:homebridge /var/homebridge/config.json
	dialog --title "$1" --backtitle "Homebridge configuration tool by @macnow - Plugins Installer - $1" \
        --stdout --msgbox "$1 plugin installed." 5 50
	menu_plugins
    elif [[ $choose -eq 2 ]]
    then
	dialog --title "$1" --backtitle "Homebridge configuration tool by @macnow - Plugins Installer - $1" \
        --stdout --infobox "Updating plugin...\nThis may take several minutes..." 4 50
	sudo npm update -g $1
	dialog --title "$1" --backtitle "Homebridge configuration tool by @macnow - Plugins Installer - $1" \
        --stdout --msgbox "$1 plugin updated." 5 50
	menu_plugins
    else
        menu_plugins
    fi
else
menu_plugins
fi
}

function menu_restart()
{
	dialog --title "Homebridge configuration tool" --backtitle "Homebridge configuration tool by @macnow - Restart" \
        --stdout --infobox "Homebridge is restarting now!\nThis may take several minutes." 4 50
	sudo systemctl restart homebridge
	sleep 3s
	menu_main
}

function menu_end()
{
	dialog --title "Homebridge configuration tool" --backtitle "Homebridge configuration tool by @macnow" \
        --stdout --infobox "Thanks for using.\nFollow me on Twitter: @macnow" 4 50
}

menu_main
