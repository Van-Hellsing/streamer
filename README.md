Автоматическая базовая настройка и запуск потоков с камеры или камер с помощью [uStreamer](https://github.com/pikvm/ustreamer)

Зависит от [kiauh](https://github.com/th33xitus/kiauh) испрльзуются файлы [globals.sh](https://github.com/th33xitus/kiauh/blob/master/scripts/globals.sh) и [utilities.sh](https://github.com/th33xitus/kiauh/blob/master/scripts/utilities.sh)

При обнаружении новой камеры в папке streamer создаётся файл настроек, webcam\_<port>\_<cam_name>\_<by-path>, содержащий минимум настроек. В папке настроек принтера/принтеров создаются ссылки на файлы} настроек камеры.

git clone https://github.com/Van-Hellsing/streamer.git
  
cd streamer
  
./start.sh
