#!/usr/bin/env bash

set -e

source ${HOME}/streamer/streamer.sh

### kiauh function

### kiauh color
green=$(echo -en "\e[92m")
yellow=$(echo -en "\e[93m")
magenta=$(echo -en "\e[35m")
red=$(echo -en "\e[91m")
cyan=$(echo -en "\e[96m")
white=$(echo -en "\e[39m")

### kiauh msg
function status_msg() {
  echo -e "\n${magenta}###### ${1}${white}"
}
function ok_msg() {
  echo -e "${green}[✓ OK] ${1}${white}"
}
function title_msg() {
  echo -e "${cyan}${1}${white}"
}
function print_error() {
  [[ -z ${1} ]] && return

  echo -e "${red}"
  echo -e "#=======================================================#"
  echo -e " ${1} "
  echo -e "#=======================================================#"
  echo -e "${white}"
}
function print_confirm() {
  [[ -z ${1} ]] && return

  echo -e "${green}"
  echo -e "#=======================================================#"
  echo -e " ${1} "
  echo -e "#=======================================================#"
  echo -e "${white}"
}

function dependency_check() {
  local dep=( "${@}" )
  local packages
  status_msg "Checking for the following dependencies:"

  #check if package is installed, if not write its name into array
  for pkg in "${dep[@]}"; do
    echo -e "${cyan}● ${pkg} ${white}"
    [[ ! $(dpkg-query -f'${Status}' --show "${pkg}" 2>/dev/null) = *\ installed ]] && \
    packages+=("${pkg}")
  done

  #if array is not empty, install packages from array
  if (( ${#packages[@]} > 0 )); then
    status_msg "Installing the following dependencies:"
    for package in "${packages[@]}"; do
      echo -e "${cyan}● ${package} ${white}"
    done
    echo

    if sudo apt-get update --allow-releaseinfo-change && sudo apt-get install "${packages[@]}" -y; then
      ok_msg "Dependencies installed!"
    else
      error_msg "Installing dependencies failed!"
      return 1 # exit kiauh
    fi
  else
    ok_msg "Dependencies already met!"
    return
  fi
}

### kiauh functions end

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

