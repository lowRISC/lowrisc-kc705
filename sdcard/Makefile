#=======================================================================
# Makefile for the Hello World programs
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

sdcard_test: sdcard_test.o spi.o uart.o syscalls.o crt.o diskio.o ff.o
	$(RISCV_LINK) -o $@ $^ $(RISCV_LINK_OPTS)

sdcard_test.o:sdcard_test.c
	$(RISCV_GCC) -static -DBARE_MODE $(RISCV_GCC_OPTS) -c $< -o $@

syscalls.o:../common/syscalls.c
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

crt.o:../common/crt.S
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

uart.o:../drive/uart.c ../drive/uart.h ../drive/device_map.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

spi.o:../drive/spi.c ../drive/spi.h ../drive/device_map.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

diskio.o: ../fatfs/diskio.c ../fatfs/diskio.h ../drive/spi.h ../drive/device_map.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

ff.o: ../fatfs/ff.c ../fatfs/ff.h ../fatfs/ffconf.h ../fatfs/diskio.h ../drive/spi.h ../drive/device_map.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

sdcard_test.hex: sdcard_test
	elf2hex 16 4096 $< > $@

sdcard_test.dump: sdcard_test
	$(RISCV_DUMP) $(RISCV_DUMP_OPTS) $< > $@

all: sdcard_test.hex

dump: sdcard_test.dump

clean:
	rm -fr *.o sdcard_test *.hex *.dump
