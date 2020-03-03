TARGET = iphone:clang::11.0
ARCHS = arm64 arm64e
SDKVERSION = 11.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Darkmode
Darkmode_CFLAGS = -fobjc-arc
Darkmode_FILES = DARKAppearanceSettings.m DARKRootListController.m
Darkmode_INSTALL_PATH = /Library/PreferenceBundles
Darkmode_FRAMEWORKS = UIKit
Darkmode_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS += Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Darkmode.plist$(ECHO_END)
