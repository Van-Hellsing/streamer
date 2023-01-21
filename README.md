## uStreamer for the klipper web interface.

## uStreamer для веб интерфейса klipper.

Автоматическая базовая настройка и запуск потоков с камеры или камер с помощью [uStreamer](https://github.com/pikvm/ustreamer) для веб интефейса [klipper](https://github.com/Klipper3d/klipper).

Зависит от [kiauh](https://github.com/th33xitus/kiauh),он должен быть установлен, испрльзуются файлы [globals.sh](https://github.com/th33xitus/kiauh/blob/master/scripts/globals.sh) и [utilities.sh](https://github.com/th33xitus/kiauh/blob/master/scripts/utilities.sh).

При обнаружении новой камеры в папке *~/streamer/webcam\_config* создаётся файл настроек, *webcam\_\<port\>\_\<cam_name\>\_\<by-path\>.cfg*, содержащий минимум настроек.
В папке настроек принтера/принтеров создаётся ссылка на папку с файлами настроек камеры/камер.

Порт трансляции изменяется простым переименованием файла настроек. При переименовании следите за тем чтобы выделеный диапазон был непрерывным и начинался с 8080.

Трансляция доступна по адресу *http://\<ip\>:\<port\>/?action=stream* 

#### Установка

```
cd ~
git clone https://github.com/Van-Hellsing/streamer.git
cd streamer
./start.sh
```
