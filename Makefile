export TARGET = iphone:9.2

CFLAGS = -fobjc-arc -flto=thin

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = Ramjet
Ramjet_FILES = Ramjet.m
Ramjet_EXTRA_FRAMEWORKS = CydiaSubstrate

include $(THEOS_MAKE_PATH)/library.mk
