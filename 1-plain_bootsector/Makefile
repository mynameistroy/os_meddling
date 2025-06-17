# Makefile to build boot sector and create a disk image

DISK = disk.img
BOOT_BIN = boot.bin
ASM_SRC = bootsector.asm
LISTING = boot.lst

# Default target
all: $(DISK)

# Rule to create the disk image and insert the boot sector
$(DISK): $(BOOT_BIN)
	@echo "Creating $(DISK) and inserting boot sector..."
	@dd if=/dev/zero of=$(DISK) bs=512 count=2880 status=none
	@dd if=$(BOOT_BIN) of=$(DISK) bs=512 count=1 conv=notrunc,sync status=none
	@echo "$(DISK) created and bootsector inserted..."

# Rule to build boot.bin from bootsector.asm
$(BOOT_BIN): $(ASM_SRC)
	@echo "Assembling $(ASM_SRC) into $(BOOT_BIN)..."
	@rm -f $(BOOT_BIN)
	@set -e; \
	nasm $(ASM_SRC) -f bin -o $(BOOT_BIN) -g -l $(LISTING); \
	size=$$(stat -f%z $(BOOT_BIN)); \
	if [ $$size -ne 512 ]; then \
		echo "Can't use bootsector, File size is $$size"; \
		exit 1; \
	fi

# Clean up generated files
clean:
	@rm -f $(DISK) $(BOOT_BIN) $(LISTING)

.PHONY: all clean
