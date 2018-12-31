export TARGET = iphone:11.2:9.0

ifeq ($(IPAD),1)
export THEOS_DEVICE_IP=192.168.254.4
export THEOS_DEVICE_PORT=22
endif

export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libramjet
libramjet_FILES = Ramjet.m
libramjet_FRAMEWORKS = Foundation

SUBPROJECTS = ramjetdaemon

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-libramjet-stage::
		@# create directories
		$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/include  $(THEOS_STAGING_DIR)/DEBIAN $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)

		@# copy header tp incude
		$(ECHO_NOTHING)cp Ramjet.h $(THEOS_STAGING_DIR)/usr/include$(ECHO_END)

		@# copy scripts
		$(ECHO_NOTHING)cp postinst prerm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)

		@# copy daemon plist
		$(ECHO_NOTHING)cp ramjet.plist $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)
