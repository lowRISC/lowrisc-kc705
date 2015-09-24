#=======================================================================
# Makefile for bootloader test
#-----------------------------------------------------------------------

default: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX=riscv64-unknown-elf-
RISCV_GCC = $(RISCV_PREFIX)gcc
RISCV_DUMP = $(RISCV_PREFIX)objdump
RISCV_GCC_OPTS = -static -Wa,-march=RVIMAFD -std=gnu99 -g -ffast-math -fno-common -fno-builtin-printf -I../common -I../drive -I../../riscv-tests/env -I../fatfs
RISCV_DUMP_OPTS = -D -S -l
RISCV_LINK = $(RISCV_GCC) -T ../common/test.ld
RISCV_LINK_OPTS = -nostdlib -nostartfiles -ffast-math -lc -lgcc


#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

boot: boot.o spi.o uart.o memory.o syscalls.o crt.o diskio.o ff.o elf.o
	$(RISCV_LINK) -o $@ $^ $(RISCV_LINK_OPTS)

boot.o:boot.c ../drive/uart.h ../drive/memory.h ../drive/spi.h ../fatfs/ff.h 
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

syscalls.o:../common/syscalls.c
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

crt.o:../common/crt.S
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

uart.o:../drive/uart.c ../drive/uart.h ../drive/device_map.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

memory.o:../drive/memory.c ../drive/memory.h ../drive/device_map.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

spi.o:../drive/spi.c ../drive/spi.h ../drive/device_map.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

diskio.o: ../fatfs/diskio.c ../fatfs/diskio.h ../drive/spi.h ../drive/device_map.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

ff.o: ../fatfs/ff.c ../fatfs/ff.h ../fatfs/ffconf.h ../fatfs/diskio.h ../drive/spi.h ../drive/device_map.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

elf.o:../drive/elf.c ../drive/elf.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

boot.hex: boot
	elf2hex 16 4096 $< > $@

boot.dump: boot
	$(RISCV_DUMP) $(RISCV_DUMP_OPTS) $< > $@

all: boot.hex

dump: boot.dump

clean:
	rm -fr *.o boot *.hex *.dump
