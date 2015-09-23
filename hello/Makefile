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
RISCV_GCC_OPTS = -static -Wa,-march=RVIMAFD -std=gnu99 -g -ffast-math -fno-common -fno-builtin-printf -I../common -I../drive -I../../riscv-tests/env
RISCV_DUMP_OPTS = -D -S -l
RISCV_LINK = $(RISCV_GCC) -T ../common/test.ld
RISCV_LINK_OPTS = -nostdlib -nostartfiles -ffast-math -lc -lgcc


#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

hello: hello.o uart.o syscalls.o crt.o
	$(RISCV_LINK) -o $@ $^ $(RISCV_LINK_OPTS)

hello.o:hello.c
	$(RISCV_GCC) -static -DBARE_MODE $(RISCV_GCC_OPTS) -c $< -o $@

syscalls.o:../common/syscalls.c
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

crt.o:../common/crt.S
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

uart.o:../drive/uart.c ../drive/uart.h ../drive/device_map.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

hello.hex: hello
	elf2hex 16 4096 $< > $@

hello.dump: hello
	$(RISCV_DUMP) $(RISCV_DUMP_OPTS) $< > $@

all: hello.hex

dump: hello.dump

clean:
	rm -fr *.o hello *.hex *.dump
