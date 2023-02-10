## uStreamer for the klipper web interface.

## uStreamer для веб интерфейса klipper.

Автоматическая базовая настройка и запуск потоков с камеры или камер с помощью [uStreamer](https://github.com/pikvm/ustreamer) для веб интефейса [klipper](https://github.com/Klipper3d/klipper).

При обнаружении новой камеры в папке *~/streamer/webcam\_config* создаётся файл с "базовым" набором параметров запуска uStreamer - *\<port\>\_\<cam_name\>\_\<by-path\>.cfg* и файл *\<cam_name\>\_\<by-path\>.v4l* содержащий доступные, для данной камеры, параметры управления драйвером video4linux.
В папке настроек принтера/принтеров создаётся ссылка на папку с файлами настроек камеры/камер.

Имена принтеров извлекаются из файла настроек [kiauh](https://github.com/th33xitus/kiauh).

Порт трансляции изменяется простым переименованием файла настроек. При переименовании следите за тем чтобы выделеный диапазон был непрерывным и начинался с 8080.

Трансляция доступна по адресу *http://\<ip\>:\<port\>/?action=stream* 

#### Установка

```
cd ~
git clone https://github.com/Van-Hellsing/streamer.git
cd streamer
./start.sh
```
