#this is makefile

ASM		= nasm
GCC		= gcc
LD		= ld
BOOTINCLUDE	= -I boot/include/
KERNELINCLUDE	= -I include/
C_INCLUDE	= include/data_type.h include/protect.h include/const.h
KERNELLIB	= lib/string.asm

TARGET		= boot/boot.bin boot/loader.bin kernel/start.o kernel/kernel.o kernel/string.o kernel/kernel.bin

ENTRY		= -Ttext 0x30400

.PHONY : everything clean all

everything : $(TARGET)

clean : 
	rm  $(TARGET)

all : clean everything

boot/boot.bin : boot/boot.asm
	$(ASM) $(BOOTINCLUDE) $< -o $@

boot/loader.bin : boot/loader.asm boot/include/lib.inc boot/include/data_struct.inc
	$(ASM) $(BOOTINCLUDE) $< -o $@

kernel/start.o : kernel/start.c $(C_INCLUDE)
	$(GCC) $(KERNELINCLUDE) $< -c -m32 -o $@

kernel/kernel.o : kernel/kernel.asm $(KERNELLIB)
	$(ASM) $< $(BOOTINCLUDE) -f elf32 -o $@

kernel/string.o : lib/string.asm
	$(ASM) $< -f elf32 -o $@

kernel/liba.o : lib/liba.asm
	$(ASM) $< -f elf32 -o $@

kernel/kernel.bin : kernel/kernel.o kernel/start.o kernel/string.o kernel/liba.o
	$(LD) -s $(ENTRY) -m elf_i386 kernel/kernel.o kernel/start.o kernel/string.o kernel/liba.o -o $@

building : 
	dd if=boot/boot.bin of=aaa.img bs=512 count=1 conv=notrunc
	sudo mount -o loop aaa.img tmp_mnt/
	sudo cp boot/loader.bin tmp_mnt/
	sudo cp kernel/kernel.bin tmp_mnt/
	sudo umount tmp_mnt
