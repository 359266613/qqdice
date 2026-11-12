DEBUG = 0
FINALPACKAGE = 1

ARCHS = arm64 arm64e

include AxsQQDiceBuild.mk
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AxsQQDice
AxsQQDice_FILES = $(filter-out Hooks/AxsQQDiceMain.xm Hooks/AxsQQDiceProtocol.xm,$(wildcard Hooks/*.xm)) $(wildcard Sources/*.m Controllers/*.m)
AxsQQDice_CFLAGS = -fobjc-arc -I./Headers -I./Sources -I./Controllers
AxsQQDice_FRAMEWORKS = UIKit Foundation CoreFoundation
AxsQQDice_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
