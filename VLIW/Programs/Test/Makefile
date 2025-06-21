ASL_DIR = /run/media/tholin/8a6b8802-051e-45a8-8492-771202e4c08a/asl-avalonsemi
ASL = $(ASL_DIR)/asl
P2BIN = $(ASL_DIR)/p2bin
ARCH = VLIW

PROJECT = test

%.p: %.asm serial.asm sdcard.asm ext4.asm mbr.asm
	$(ASL) -L -cpu $(ARCH) $<

%.bin: %.p
	$(P2BIN) $<

$(PROJECT): $(PROJECT).bin
	java ToVerilogHex.java $(PROJECT).bin ../../Sim/raminit.txt
	java ToConstArray.java $(PROJECT).bin > pgmdata.h

clean:
	rm -rf *.bin *.p

all: clean $(PROJECT)

.PHONY: all
