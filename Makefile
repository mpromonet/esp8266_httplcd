all: flash upload

format: nodemcu-uploader/nodemcu-uploader.py
	python2 nodemcu-uploader/nodemcu-uploader.py --port /dev/ttyUSB0 --baud 115200 file format

list: nodemcu-uploader/nodemcu-uploader.py
	python2 nodemcu-uploader/nodemcu-uploader.py --port /dev/ttyUSB0 --baud 115200 file list

upload: nodemcu-uploader/nodemcu-uploader.py
	python2 nodemcu-uploader/nodemcu-uploader.py --port /dev/ttyUSB0 --baud 115200 upload *.lua

flash:
	python2 esptool/esptool.py --port /dev/ttyUSB0 --baud 115200 write_flash 0x0000 firmware/nodemcu_integer_0.9.6-dev_20150704.bin

nodemcu-uploader/nodemcu-uploader.py:
	git submodule init nodemcu-uploader
	git submodule update nodemcu-uploader


esptool/esptool.py:
	git submodule init esptool
	git submodule update esptool

	
