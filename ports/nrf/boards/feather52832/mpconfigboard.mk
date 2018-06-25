MCU_SERIES = m4
MCU_VARIANT = nrf52
MCU_SUB_VARIANT = nrf52
SOFTDEV_VERSION ?= 2.0.1

LD_FILE = boards/feather52832/custom_nrf52832_dfu_app_$(SOFTDEV_VERSION).ld
BOOTLOADER_PKG = boards/feather52832/bootloader/feather52_bootloader_$(SOFTDEV_VERSION)_s132_single.zip

BOOT_SETTING_ADDR = 0x7F000
NRF_DEFINES += -DNRF52832_XXAA

ifeq ($(OS),Windows_NT)
   NRFUTIL = ../../lib/nrfutil/binaries/win32/nrfutil.exe
else
   NRFUTIL = nrfutil
endif

CFLAGS += -DADAFRUIT_FEATHER52

check_defined = \
    $(strip $(foreach 1,$1, \
    $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
    $(error Undefined make flag: $1$(if $2, ($2))))

.PHONY: dfu-gen dfu-flash boot-flash

dfu-gen:
	$(NRFUTIL) dfu genpkg --sd-req 0xFFFE --dev-type 0x0052 --application $(BUILD)/$(OUTPUT_FILENAME).hex $(BUILD)/dfu-package.zip

dfu-flash:
	@:$(call check_defined, SERIAL, example: SERIAL=/dev/ttyUSB0)
	$(NRFUTIL) dfu serial --package $(BUILD)/dfu-package.zip -p $(SERIAL) -b 115200 --singlebank

dfu-bootloader:
	@:$(call check_defined, SERIAL, example: SERIAL=/dev/ttyUSB0)
	$(NRFUTIL) dfu serial --package $(BOOTLOADER_PKG) -p $(SERIAL) -b 115200