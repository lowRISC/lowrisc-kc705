#=======================================================================
# Makefile for bootloader test
#-----------------------------------------------------------------------
# See LICENSE for license details.

default: all

TARGET = boot

OBJS += \
	boot.o \
	../drive/spi.o \
	../drive/uart.o \
	../drive/memory.o \
	../drive/elf.o \
	../fatfs/diskio.o \
	../fatfs/ff.o \

include ../Makefrag

#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

boot.o: boot.c ../drive/uart.h ../drive/memory.h ../drive/spi.h ../fatfs/ff.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

junk += boot.o
