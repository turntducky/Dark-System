DEBUG = 0
FINALPACKAGE = 1

TARGET = iphone:clang::11.0
ARCHS = arm64 arm64e

export THEOS_DEVICE_IP = 192.168.1.24 #Home
#export THEOS_DEVICE_IP = 10.111.20.65 #School
#export THEOS_DEVICE_IP = 192.168.0.69 #Work

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Darkmode
Darkmode_CFLAGS = -fobjc-arc
Darkmode_FILES = Tweak.xm
Darkmode_FRAMEWORKS = UIKit Coregraphics
Darkmode_EXTRA_FRAMEWORKS += Cephei
SHARED_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "sbreload"
SUBPROJECTS += Darkmode
include $(THEOS_MAKE_PATH)/aggregate.mk
