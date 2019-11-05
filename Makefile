SHELL:=/bin/bash

define newsetting
@read -p "$(1) [$(3)]: " thisset ; [[ -z "$$thisset" ]] && echo "$(2) $(3)" >> $(4) || echo "$(2) $$thisset" >> $(4)
endef

define getsetting
$$(grep "^$(2)[ \t]*" $(1) | sed 's/^$(2)[ \t]*//g')
endef

installpath := $(call getsetting,tmp/settings.txt,PATH) 

all:
	@echo "Directions:"
	@echo "  1) make setup"
	@echo "  2) sudo make install"
	@echo ""
	@echo "Use 'make clean' to clear build environment"

install: etc-services
	mkdir -p $(call getsetting,tmp/settings.txt,PATH)
	mkdir -p $(call getsetting,tmp/settings.txt,PATH)/bin
	mkdir -p $(call getsetting,tmp/settings.txt,PATH)/etc
	find build/ -type f | while read line; do cp $$line $(call getsetting,tmp/settings.txt,PATH)$$(echo $$line | sed 's/^build//g') ; done 
	(rm /etc/xinetd.d/xinetcam && ln -s $(call getsetting,tmp/settings.txt,PATH)/etc/xinetcam /etc/xinetd.d/xinetcam) || ln -s $(call getsetting,tmp/settings.txt,PATH)/etc/xinetcam /etc/xinetd.d/xinetcam
	chmod +x $(call getsetting,tmp/settings.txt,PATH)/bin/xinetcam.sh

etc-services:
	[[ -z "$$(grep "$(call getsetting,tmp/settings.txt,PORT)/tcp" /etc/services)" ]] && echo -e "xinetcam\t$(call getsetting,tmp/settings.txt,PORT)/tcp\t# Added by xinetcam Makefile" >> /etc/services
	[[ -z "$$(grep "$(call getsetting,tmp/settings.txt,PORT)/udp" /etc/services)" ]] && echo -e "xinetcam\t$(call getsetting,tmp/settings.txt,PORT)/tcp\t# Added by xinetcam Makefile" >> /etc/services

tmp/xinetd.ok: tmp
	@[[ -n "$$(which xinetd)" ]] && touch tmp/xinetd.ok

setup: build/etc/xinetcam build/bin/xinetcam.sh 

clean:
	rm -rf tmp
	rm -rf build

build/etc/xinetcam: build/etc tmp/port.ok
	[[ ! -f build/etc/xinetcam ]] && m4 -DPORT=$(call getsetting,tmp/settings.txt,PORT) -DPATH="$(call getsetting,tmp/settings.txt,PATH)" service.m4 > build/etc/xinetcam

build/bin: build
	mkdir -p build/bin

build/etc: build
	mkdir -p build/etc

tmp/settings.txt: tmp
	$(call newsetting,Enter install path,PATH,/opt/xinetcam,tmp/settings.txt)
	$(call newsetting,Enter port number,PORT,8080,tmp/settings.txt)

tmp/port.ok: tmp/settings.txt
	@[[ -z "$$(grep "$(call getsetting,tmp/settings.txt,PORT)" /etc/services)" ]] && touch tmp/port.ok

build/bin/xinetcam.sh: build/bin
	cp xinetcam.sh build/bin

build:
	[[ ! -d ./build ]] && mkdir build

tmp:
	[[ ! -d tmp ]] && mkdir tmp
