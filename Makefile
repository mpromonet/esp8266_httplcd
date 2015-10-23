PORT=/dev/ttyUSB0
BAUD=115200
FIRMWARE=firmware/nodemcu_integer_0.9.6-dev_20150704.bin

all: flash format upload

format: nodemcu-uploader/nodemcu-uploader.py
	python2 nodemcu-uploader/nodemcu-uploader.py --port $(PORT) --baud $(BAUD) file format

list: nodemcu-uploader/nodemcu-uploader.py
	python2 nodemcu-uploader/nodemcu-uploader.py --port $(PORT) --baud $(BAUD) file list

upload: nodemcu-uploader/nodemcu-uploader.py
	python2 nodemcu-uploader/nodemcu-uploader.py --port $(PORT) --baud $(BAUD) upload *.lua $(wildcard *.cfg)

restart: nodemcu-uploader/nodemcu-uploader.py
	python2 nodemcu-uploader/nodemcu-uploader.py --port $(PORT) --baud $(BAUD) node restart

flash: esptool/esptool.py
	python2 esptool/esptool.py --port $(PORT) --baud $(BAUD) write_flash 0x0000 $(FIRMWARE)
	

nodemcu-uploader/nodemcu-uploader.py:
	git submodule init nodemcu-uploader
	git submodule update nodemcu-uploader


esptool/esptool.py:
	git submodule init esptool
	git submodule update esptool

	
