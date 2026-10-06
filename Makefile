ASM=nasm
QEMU=qemu-system-i386

SRC_DIR=.
BUILD_DIR=build

.PHONY: all run debug clean

all: $(BUILD_DIR)/main.img

$(BUILD_DIR)/main.img: $(BUILD_DIR)/main.bin
	cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/main.img
	truncate -s 1440k $(BUILD_DIR)/main.img

$(BUILD_DIR)/main.bin: $(SRC_DIR)/main.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/main.bin

run: $(BUILD_DIR)/main.img
	$(QEMU) -display gtk -fda $(BUILD_DIR)/main.img

debug: $(BUILD_DIR)/main.img
	$(QEMU) -display gtk -fda $(BUILD_DIR)/main.img -s -S

clean:
	rm -rf $(BUILD_DIR)
