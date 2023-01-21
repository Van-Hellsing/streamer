#!/usr/bin/env bash

set -e

source ${HOME}/streamer/streamer.sh
source ${HOME}/kiauh/scripts/globals.sh
source ${HOME}/kiauh/scripts/utilities.sh

set_globals

function menu(){

echo
echo "		1 - install"
echo "		2 - uninstall"
echo "		3 - remove config webcams"
echo "		4 - restart services"
echo
echo "		   other - exit"
echo
}

while true; do
  menu
  read -p "		Perform action: " action
  case "${action}" in
    1)
      install_streamer;;
    2)
      remove_streamer;;
    3)
      rm_cfg;;      
    4)
      services_action "restart";;      
    *)
      exit;;
  esac
done

