ASM=nasm
QEMU=qemu-system-i386

BOOT_DIR=bootloader
KERNEL_DIR=kernel
BUILD_DIR=build

BOOT_SRC=$(BOOT_DIR)/boot.asm
KERNEL_SRC=$(KERNEL_DIR)/main.asm

IMG=$(BUILD_DIR)/main_floppy.img

.PHONY: all run debug clean test test-debug

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

# --- Standalone test program (does not touch the bootloader/kernel build) ---
TEST_DIR=test
TEST_SRC=$(TEST_DIR)/test.asm
TEST_IMG=$(BUILD_DIR)/test.img

$(BUILD_DIR)/test.bin: $(TEST_SRC) | $(BUILD_DIR)
	$(ASM) $(TEST_SRC) -f bin -o $@

$(TEST_IMG): $(BUILD_DIR)/test.bin
	cp $< $@
	truncate -s 1440k $@

test: $(TEST_IMG)
	$(QEMU) -display gtk -drive file=$(TEST_IMG),format=raw,if=floppy

test-debug: $(TEST_IMG)
	$(QEMU) -display gtk -drive file=$(TEST_IMG),format=raw,if=floppy -s -S
