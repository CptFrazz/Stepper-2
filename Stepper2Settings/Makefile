ARCHS = arm64

include theos/makefiles/common.mk

BUNDLE_NAME = Stepper2Settings
Stepper2Settings_FILES = Stepper2Settings.mm
Stepper2Settings_INSTALL_PATH = /Library/PreferenceBundles
Stepper2Settings_FRAMEWORKS = UIKit
Stepper2Settings_PRIVATE_FRAMEWORKS = Preferences
Stepper2Settings_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Stepper2Settings.plist$(ECHO_END)
