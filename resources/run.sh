#!/usr/bin/env bash

cfg_dir="/home/%USER%/streamer/webcam_config"
multi_instance_names=$(grep multi_* ${HOME}/.kiauh.ini|awk -F'=' '{print $2}'|sed 's/,/ /g')

cam_id=$(udevadm info --query=all --name=$1|grep ID_SERIAL=|awk -F= '{print $2}')
cam_path=$(udevadm info --query=all --name=$1|grep ID_PATH_|awk -F= '{print $2}')
cam_cfg=${cam_id}_${cam_path}".cfg"
cam_v4l=${cam_id}_${cam_path}".v4l"

echo

### /dev/video[0-9]->video[0-9]
device=$(echo $1|awk -F/ '{print $3}')

if [ -z "${cam_id}" ]; then
	echo "ID_SERIAL empy. Exit."
	echo
	exit 1
fi

if [ ! -z "$(ls ${cfg_dir}|grep ${cam_cfg})" ]; then
	echo "File ${cam_cfg} - OK"
	echo
else
	### creating a queue
	sec=$(shuf -i 0-10 -n1)
	msec=$(shuf -i 0-100 -n1)
	sleep ${sec}.${msec}

	port=$(ls ${cfg_dir} | grep ".cfg" | wc -l)
	port=$((8080+${port}))
	echo "File ${cam_cfg} does not exist. We fix it."
	echo
	cat << EOF > ${cfg_dir}/${port}_${cam_cfg}
--format YUYV
--resolution 640x480
--desired-fps=29
--log-level 0
--workers=3
--device-timeout=8
--quality 100
--host=0.0.0.0
EOF
fi

if [ ! -z "$(ls ${cfg_dir}|grep ${cam_v4l})" ]; then
	echo "File ${cam_v4l} - OK"
	echo
else
	echo "File ${cam_v4l} does not exist. We fix it."
	echo
	v4l2-ctl --list-ctrls-menu --device $1 >> ${cfg_dir}/${cam_v4l}
	cat << EOF >> ${cfg_dir}/${cam_v4l}

Example: brightness=100
         contrast=100
EOF
	sed '/^[^/n]/s/^/#/' -i ${cfg_dir}/${cam_v4l}
fi

for i in $(grep "^[^#*/;]" ${cfg_dir}/${cam_v4l}); do
	v4l2-ctl --device $1 --set-ctrl=${i}
done

port=$(ls ${cfg_dir}|grep ${cam_cfg}|awk -F_ '{print $1}')
	
/home/%USER%/streamer/ustreamer --device $1 --port ${port} --process-name-prefix ustreamer-$1 --static /home/%USER%/streamer/resources/www-ustreamer/ $(cat ${cfg_dir}/${port}_${cam_cfg})

