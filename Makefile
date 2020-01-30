export TARGET = iphone:latest:10.0
export ARCHS = armv7 arm64 arm64e

export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libramjet
$(LIBRARY_NAME)_FILES = Ramjet.c
$(LIBRARY_NAME)_PUBLIC_HEADERS = Ramjet.h

SUBPROJECTS = daemon

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-libramjet-stage::
	@# create directories
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/DEBIAN $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)

	@# {pre,post}inst -> /DEBIAN/
	$(ECHO_NOTHING)cp postinst prerm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)

	$(ECHO_NOTHING)cp daemon/com.shade.ramjetd.plist $(THEOS_STAGING_DIR)/Library/LaunchDaemons$(ECHO_END)