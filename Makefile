export TARGET = iphone:9.2

ifeq ($(IPAD),1)
export THEOS_DEVICE_IP=192.168.254.6
export THEOS_DEVICE_PORT=22
endif

CFLAGS = -fobjc-arc -flto=thin

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = Ramjet
Ramjet_FILES = Ramjet.m
Ramjet_FRAMEWORKS = Foundation
Ramjet_EXTRA_FRAMEWORKS = CydiaSubstrate

include $(THEOS_MAKE_PATH)/library.mk
