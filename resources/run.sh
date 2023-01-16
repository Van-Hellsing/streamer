#!/bin/sh

#cfg_dir="/home/%USER%/printer_data/config"
cfg_dir="/home/%USER%/streamer"
multi_instance_names=$(grep multi_* ${HOME}/.kiauh.ini|awk -F'=' '{print $2}'|sed 's/,/ /g')

if [ -z ${multi_instance_names} ]; then
    multi_instance_names=${HOME}/printer
fi

cam_id=$(udevadm info --query=all --name=$1|grep ID_SERIAL=|awk -F= '{print $2}')
cam_path=$(udevadm info --query=all --name=$1|grep ID_PATH_|awk -F= '{print $2}')


### /dev/video[0-9]->video[0-9]
device=$(echo $1|awk -F/ '{print $3}')

if [ -z "${cam_id}" ]; then
	echo "ID_SERIAL empy. Exit."
	exit 1
fi

cam_cfg=$(ls ${cfg_dir}|grep ${cam_id}_${cam_path})

if [ ! -z ${cam_cfg} ]; then
	echo "File ${cam_cfg} - OK"
else
	### creating a queue
	sec=$(shuf -i 0-10 -n1)
	msec=$(shuf -i 0-100 -n1)
	sleep ${sec}.${msec}

	port=$(ls ${cfg_dir} | grep "^webcam_*" | wc -l)
	port=$((8080+${port}))
	cam_cfg="webcam_"${port}"_"${cam_id}_${cam_path}".cfg"
	echo "File ${cam_cfg} does not exist. We fix it."
	cat << EOF > ${cfg_dir}/${cam_cfg}
--log-level 0
--workers=3
--device-timeout=8
--quality 100
--resolution 640x480
--desired-fps=29
--host=0.0.0.0
--format YUYV
EOF
    for i in ${multi_instance_names}
    do
	chmod 666 ${cfg_dir}/${cam_cfg}
        ln -sf "/home/${USER}/streamer/${cam_cfg}" "${i}_data/config"
    done
fi

port=$(echo ${cam_cfg}|awk -F_ '{print $2}')

/home/%USER%/streamer/ustreamer --device $1 --port ${port} --process-name-prefix ustreamer-$1 --static /home/%USER%/streamer/resources/www-ustreamer/ $(cat ${cfg_dir}/${cam_cfg})

