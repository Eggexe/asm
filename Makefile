ASM=nasm
QEMU=qemu-system-i386

BOOT_DIR=bootloader
KERNEL_DIR=kernel
BUILD_DIR=build

BOOT_SRC=$(BOOT_DIR)/boot.asm
KERNEL_SRC=$(KERNEL_DIR)/main.asm

IMG=$(BUILD_DIR)/main_floppy.img

.PHONY: all run debug clean

all: $(IMG)

# FAT12 floppy: bootloader goes in sector 0, kernel is copied in as a file
$(IMG): $(BUILD_DIR)/bootloader.bin $(BUILD_DIR)/kernel.bin
	dd if=/dev/zero of=$(IMG) bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(IMG)
	dd if=$(BUILD_DIR)/bootloader.bin of=$(IMG) conv=notrunc
	mcopy -i $(IMG) $(BUILD_DIR)/kernel.bin "::kernel.bin"

$(BUILD_DIR)/bootloader.bin: $(BOOT_SRC) | $(BUILD_DIR)
	$(ASM) $(BOOT_SRC) -f bin -o $@

$(BUILD_DIR)/kernel.bin: $(KERNEL_SRC) | $(BUILD_DIR)
	$(ASM) $(KERNEL_SRC) -f bin -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

run: $(IMG)
	$(QEMU) -display gtk -drive file=$(IMG),format=raw,if=floppy

debug: $(IMG)
	$(QEMU) -display gtk -drive file=$(IMG),format=raw,if=floppy -s -S

clean:
	rm -rf $(BUILD_DIR)/*
