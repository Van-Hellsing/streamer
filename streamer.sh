#!/usr/bin/env bash

set -e

systemd="/etc/systemd/system"
udev="/etc/udev/rules.d"

app_home="${HOME}/streamer"
cfg_dir="webcam_config"
resources="${app_home}/resources"
run="run.sh"
rules="streamer.rules"
service="streamer@.service"
repo="https://github.com/pikvm/ustreamer.git"

#=================================================#
#==============   INSTALL STREAMER   =============#
#=================================================#

function install_streamer() {

  ### return early if streamer@.service already exists
  if [[ -f "${systemd}/${service}" ]]; then
    print_error "Looks like  streamer is already installed!\n Please remove it first before you try to re-install it!"
    return
  fi

  status_msg "Initializing streamer installation ..."

  ### check and install dependencies if missing
  local dep=(git build-essential libevent-dev libbsd-dev)
  if apt-cache search libjpeg-dev | grep -Eq "^libjpeg-dev "; then
    dep+=(libjpeg-dev)
  elif apt-cache search libjpeg8-dev | grep -Eq "^libjpeg8-dev "; then
    dep+=(libjpeg8-dev)
  fi

  dependency_check "${dep[@]}"

  ### clone ustreamer
  status_msg "Cloning uStreamer from ${repo} ..."
  [[ -d "${app_home}/ustreamer" ]] && rm -rf "${app_home}/ustreamer"

  cd "${app_home}" || exit 1
  if ! git clone "${repo}" ${app_home}/ustreamer; then
    print_error "Cloning uStreamer from\n ${repo}\n failed!"
    exit 1
  fi
  ok_msg "Cloning complete!"

  ### compiling ustreamer
  status_msg "Compiling uStreamer ..."
  cd "${app_home}/ustreamer"
  if ! make; then
    print_error "Compiling uStreamer failed!"
    exit 1
  fi

  ### garbage collection
  cp ${app_home}/ustreamer/src/ustreamer.bin /tmp/ustreamer
  cp ${app_home}/ustreamer/src/ustreamer-dump.bin /tmp/ustreamer-dump
  rm -rf ${app_home}/ustreamer
  mv /tmp/ustreamer* ${app_home}
  ok_msg "Compiling complete!"
  status_msg "Installing streamer ..."

  ### create cfg_dir
  status_msg "Create config dir ..."
  mkdir -p "${app_home}/${cfg_dir}"
  cfg_link
  ok_msg "Config dir - OK"

  ### create udev rules usb cam
  status_msg "Creating streamer udev rules ..."
  sudo cp ${resources}/${rules} ${udev}/99-${rules}
  ok_msg " streamer udev rules created!"

  ### create systemd service
  status_msg "Creating streamer service ..."
  sudo cp "${resources}/${service}" "${systemd}"
  sudo sed -i "s|%USER%|${USER}|g" "${systemd}/${service}"
  ok_msg " Streamer service created!"

  ### create start script
  cp ${resources}/${run} ${app_home}
  sudo sed -i "s|%USER%|${USER}|g" "${app_home}/${run}"

  ### starting streamer service
  status_msg "Starting streamer service, please wait ..."
  # it doesn't work
  #sudo systemctl daemon-reload
  #sudo systemctl reset-failed
  #sudo udevadm control --reload-rules && sudo udevadm trigger
  # zakat solnca vruchnuy
  run_list=$(ls /dev/video*)
  for i in ${run_list}
  do
    sudo udevadm info --query all --name ${i}|grep capture &> /dev/null && device=$(echo ${i}|awk -F/ '{print $3}') || device=""
    if [ ! -z ${device} ]; then
      sudo systemctl start streamer@${device}.service 
      echo "start streamer@${device}.service"
    fi
  done

  ### confirm message
  local confirm_msg="Streamer has been set up!"

  print_confirm "${confirm_msg}"

  ### print webcam ip adress/url
  local ip
  ip=$(hostname -I | cut -d" " -f1)
  ###
  local cam_url="http://${ip}:8080/?action=stream"
  local cam_url_alt="http://${ip}/webcam/?action=stream"
  local cam_url2="http://${ip}:8081/?action=stream"
  local cam_url_alt2="http://${ip}/webcam2/?action=stream"
  ### 
  echo -e " ${cyan}● Webcam1 URL:${white} ${cam_url}"
  echo -e " ${cyan}● Webcam1 URL:${white} ${cam_url_alt}"
  echo
  echo -e " ${cyan}● Webcam2 URL:${white} ${cam_url2}"
  echo -e " ${cyan}● Webcam2 URL:${white} ${cam_url_alt2}"
  echo -e " ${cyan}● etc..."
  echo -e " ${white} "
}

#=================================================#
#============== REMOVE STREAMER =================#
#=================================================#

function remove_streamer() {
  services_action "stop"

  if [ -e "${systemd}/${service}" ]; then
    status_msg "Removing streamer service ..."
    sudo rm -f "${systemd}/${service}"
    ok_msg "Streamer Service removed!"
  fi
  ### reloading units
  sudo systemctl daemon-reload

  if [ -e "${udev}/99-${rules}" ]; then
    status_msg "Removing streamer udev rules ..."
    sudo rm -f "${udev}/99-${rules}"
    ok_msg "Streamer udev rules removed!"
  fi

  ### remove uStreamer
  if [ -e "${app_home}/ustreamer" ]; then
    status_msg "Removing uStreamer ..."
    echo "${app_home}/ustream* ${app_home}/run.sh"
    rm -f "${app_home}/ustreamer"
    rm -f "${app_home}/ustreamer-dump"
    rm -f "${app_home}/run.sh"
    ok_msg "uStreamer removed!"
  fi
  rm_cfg_link
  print_confirm "Streamer successfully removed!"
}

#=====

function printer_names(){
  multi_instance_names=$(grep multi_ ${HOME}/.kiauh.ini|awk -F'=' '{print $2}'|sed 's/,/ /g')
  if [ -z "${multi_instance_names}" ]; then
    multi_instance_names="printer"
  fi
}

function rm_cfg_link(){
  printer_names	
  for i in ${multi_instance_names}; do
    if [ ! -e "${HOME}/${i}_data/config/${cfg_dir}" ]; then
      status_msg "Remove webcam config in ${i}_data..."
      rm -f "${HOME}/${i}_data/config/${cfg_dir}"
      ok_msg "Remove webcam config in ${i}_data done"
    fi
  done
}

function rm_cfg(){
  if [ -d "${app_home}/${cfg_dir}" ]; then
  #if [ ! -z "$(ls ${app_home}/${cfg_dir})" ]; then
    status_msg "Remove webcam config in streamer..."
    rm_file="$(ls ${app_home}/${cfg_dir})"
    for i in ${rm_file}; do
      rm -f ${app_home}/${cfg_dir}/${i}
    done
    ok_msg "Remove webcam config in streamer done"
  fi
}

### other

function cfg_link(){
  printer_names
  for i in ${multi_instance_names}; do
    if [ ! -z "${HOME}/${i}_data/config/${cfg_dir}" ]; then
      status_msg "Create webcam config in ${i}_data..."
      ln -sf "${app_home}/${cfg_dir}" "${HOME}/${i}_data/config"
      ok_msg "Create webcam config in ${i}_data done"
    fi
  done
}

function services_action() {
  active_service=$(sudo systemctl list-units|grep streamer@|awk '{print $1}')

  for i in ${active_service}
    do
      if [ ! -z "${i}" ]; then
        echo "${1} ${i}"
        sudo systemctl ${1} ${i}
        ok_msg "Streamer Service ${1}!"
      fi
  done
}
