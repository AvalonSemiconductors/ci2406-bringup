TOOLCHAIN_PATH=/usr/bin/

TOOLCHAIN_PREFIX=riscv64-unknown-elf
ARCH=rv32i_zicsr

# ---- Test patterns for project raven ----

.SUFFIXES:

PATTERN = blink

hex:  ${PATTERN:=.hex}

%.elf: %.c ../../caravel_board/firmware/chipignite/sections.lds ../../caravel_board/firmware/chipignite/crt0_vex.S
	$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)-gcc -I../../caravel_board/firmware/chipignite/ -I../../caravel_board/firmware/chipignite/generated/ -O2 -mabi=ilp32 -march=$(ARCH) -D__vexriscv__ -Wl,-Bstatic,-T,../../caravel_board/firmware/chipignite/sections.lds,--strip-debug -ffreestanding -nostdlib -o $@ ../../caravel_board/firmware/chipignite/crt0_vex.S ../../caravel_board/firmware/chipignite/isr.c $<
	${TOOLCHAIN_PATH}$(TOOLCHAIN_PREFIX)-objdump -D blink.elf > blink.lst

%.hex: %.elf
	$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)-objcopy -O verilog $< $@
	sed -ie 's/@1000/@0000/g' $@

%.bin: %.elf
	$(TOOLCHAIN_PATH)$(TOOLCHAIN_PREFIX)-objcopy -O binary $< $@

flash: blink.hex
	python3 ../../caravel_board/firmware/chipignite/util/caravel_hkflash.py blink.hex

# ---- Clean ----

clean:
	rm -f *.elf *.hex *.bin *.vvp *.vcd

.PHONY: clean hex all flash

