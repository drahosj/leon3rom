OBJECTS=head.o cstart.o

all: ahbrom.vhd ram.elf

ahbrom.vhd: ahbrom rom.bin
	./ahbrom rom.bin $@

rom.bin: rom.elf
	sparc-leon-linux-uclibc-objcopy -O binary rom.elf rom.bin

%.elf: %.lds $(OBJECTS)
	sparc-leon-linux-uclibc-ld -T $< $(OBJECTS) -o $@

%.o: %.c
	sparc-leon-linux-uclibc-gcc -O1 -c $< -o $@
%.o: %.S
	sparc-leon-linux-uclibc-gcc -c $< -o $@

keep_objects: $(OBJECTS)

clean:
	rm ahbrom.vhd *.bin *.elf *.o ahbrom
