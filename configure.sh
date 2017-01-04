#!/bin/bash

LINES=$(tput lines)
COLS=$(tput cols)

function menu_main()
{
  unset CMD
  unset OPTIONS
  unset CHOICE
  CMD=(dialog \
    --title "Homebridge configuration tool" \
    --backtitle "Homebridge configuration tool by @macnow" \
    --keep-tite \
    --no-cancel \
    --menu "Select options:" \
    12 50 17)
  OPTIONS=(M "Manage Plugins"
           C "Configuration Editor"
           R "Restart Homebridge"
           Q "Quit")
  CHOICE=$("${CMD[@]}" "${OPTIONS[@]}"  3>&1 1>&2 2>&3 3>&-)

  case $CHOICE in
    M)  menu_plugins;;
    C)  menu_configure;;
    R)  menu_restart;;
    Q)  menu_end;;
  esac
}

function menu_configure()
{
  unset CMD
  unset OPTIONS
  unset CHOICE
  CHOICE=$("dialog \
    --title "/var/homebridge/config.json" \
    --backtitle "Homebridge configuration tool by @macnow - Configuration Editor" \
    --stdout \
    --ok-label Save \
    --editbox /var/homebridge/config.json \
    $((LINES-10)) $((COLS-5))" 3>&1 1>&2 2>&3 3>&-)

  case $CHOICE in
    0)  echo $CHOICE|json -4 > /tmp/config.json$$
        JSON_OUTPUT=$?
        if [[ $JSON_OUTPUT -eq 0 ]]
        then
            sudo mv -f /tmp/config.json$$ /var/homebridge/config.json
            sudo chown homebridge:homebridge /var/homebridge/config.json
            dialog \
              --title "Homebridge configure" \
              --backtitle "Homebridge configurator" \
              --stdout \
              --msgbox "Configuration saved!" \
              5 50
        else
            dialog \
              --title "Homebridge configure" \
              --backtitle "Homebridge configurator" \
              --stdout \
              --msgbox "ERROR: Configuration not saved!" \
              5 50
	      fi
        ;;
  esac
  menu_main
}

function menu_plugins()
{
  unset CMD
  unset OPTIONS
  unset CHOICE
  unset FILES
  CMD=(dialog \
    --title "Homebridge configuration tool" \
    --backtitle "Homebridge configuration tool by @macnow - Plugins Installer" \
    --keep-tite \
    --menu "Select options:" \
    13 50 17)
  FILES=configs/homebridge-*

  c=0
  for f in $FILES
  do
    FILE=${f#'configs/'}
    OPTIONS+=($((++c)) ${FILE%'.json'})
  done
  OPTIONS+=(B "Back")

  CHOICE=$("${CMD[@]}" "${OPTIONS[@]}" 3>&1 1>&2 2>&3 3>&-)
  case $CHOICE in
    B) menu_main;;
    *) if [[ $CHOICE -eq 1 ]]; then
         menu_plugin ${OPTIONS[$CHOICE]}
       else
         menu_plugin ${OPTIONS[2*$CHOICE-1]}
       fi;;
  esac
}

function menu_plugin()
{
  unset CMD
  unset OPTIONS
  unset CHOICE
  CMD=(dialog
    --title "Homebridge configuration tool" \
    --backtitle "Homebridge configuration tool by @macnow - Plugins Installer - $1" \
    --keep-tite \
    --no-cancel \
    --menu "Select options:" \
    12 50 17)
  OPTIONS=(I "Install Plugin"
           U "Update Plugin"
           B "Back")
  CHOICE=$("${CMD[@]}" "${OPTIONS[@]}"  3>&1 1>&2 2>&3 3>&-)

  case $CHOICE in
    I)  dialog \
          --title "$1" \
          --backtitle "Homebridge configuration tool by @macnow - Plugins Installer - $1" \
          --stdout \
          --infobox "Installing plugin...\nThis may take several minutes." \
          4 50
        sudo npm install -g $1
  	    scripts/config-merge.py /var/homebridge/config.json configs/$1.json > /tmp/config.json$$
        sudo mv -f /tmp/config.json$$ /var/homebridge/config.json
  	    sudo chown homebridge:homebridge /var/homebridge/config.json
  	    dialog \
          --title "$1" \
          --backtitle "Homebridge configuration tool by @macnow - Plugins Installer - $1" \
          --stdout \
          --msgbox "$1 plugin installed." \
          5 50;;
    U)  dialog \
          --title "$1" \
          --backtitle "Homebridge configuration tool by @macnow - Plugins Installer - $1" \
          --stdout \
          --infobox "Updating plugin...\nThis may take several minutes..." \
          4 50
  	    sudo npm update -g $1
        dialog \
          --title "$1" \
          --backtitle "Homebridge configuration tool by @macnow - Plugins Installer - $1" \
          --stdout \
          --msgbox "$1 plugin updated." \
          5 50;;
    B)  ;;
  esac
  menu_plugins
}

function menu_restart()
{
	dialog \
    --title "Homebridge configuration tool" \
    --backtitle "Homebridge configuration tool by @macnow - Restart" \
    --stdout \
    --infobox "Homebridge is restarting now!\nThis may take several minutes." \
    4 50
	sudo systemctl restart homebridge
	sleep 3s
	menu_main
}

function menu_end()
{
	dialog \
    --title "Homebridge configuration tool" \
    --backtitle "Homebridge configuration tool by @macnow" \
    --stdout \
    --infobox "Thanks for using.\nFollow me on Twitter: @macnow" \
    4 50
}

menu_main
