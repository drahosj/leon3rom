OBJECTS=head.o cstart.o
TARGET=sparc-elf
TOOLCHAIN=$(HOME)/x-tools/$(TARGET)

all: ahbrom.vhd ram.elf

ahbrom.vhd: ahbrom rom.bin
	./ahbrom rom.bin $@

rom.bin: rom.elf
	$(TARGET)-objcopy -O binary rom.elf rom.bin

%.elf: %.lds $(OBJECTS)
	$(TARGET)-ld -T $< $(OBJECTS) $(TOOLCHAIN)/$(TARGET)/lib/libc.a -o $@

%.o: %.c
	$(TARGET)-gcc -O1 -c $< -o $@
%.o: %.S
	$(TARGET)-gcc -c $< -o $@

keep_objects: $(OBJECTS)

clean:
	rm ahbrom.vhd *.bin *.elf *.o ahbrom
