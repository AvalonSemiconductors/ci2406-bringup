ASL_DIR = /run/media/tholin/8a6b8802-051e-45a8-8492-771202e4c08a/asl-avalonsemi
ASL = $(ASL_DIR)/asl
P2BIN = $(ASL_DIR)/p2bin
ARCH = ScrapCPU

PROJECT = Conway

%.p: %.asm
	$(ASL) -cpu $(ARCH) $<

%.bin: %.p
	$(P2BIN) $<

expanded.bin: $(PROJECT).bin
	java ../../../Utils/ExpandROM.java $(PROJECT).bin 4194304

flash: expanded.bin
	sudo flashrom --programmer ch341a_spi --write expanded.bin --chip "W25Q32BV/W25Q32CV/W25Q32DV"

clean:
	rm -rf *.bin *.p

all: clean $(PROJECT)

.PHONY: all
