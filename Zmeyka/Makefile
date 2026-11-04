TARGET = iphone:clang:6.1:6.0
ARCHS = armv7

PACKAGE_FORMAT = ipa

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Zmeyka

Zmeyka_FILES = $(wildcard Source/*.m)
Zmeyka_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AudioToolbox
Zmeyka_CFLAGS = -fobjc-arc -I./Source
Zmeyka_RESOURCE_DIRS = Resources Icons
Zmeyka_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk

