#=======================================================================
# Makefile for the Hello World programs
#-----------------------------------------------------------------------
# See LICENSE for license details.

default: all

TARGET = sdcard

OBJS += \
	sdcard.o \
	../drive/spi.o \
	../drive/uart.o \
	../fatfs/diskio.o \
	../fatfs/ff.o \

include ../Makefrag

#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

sdcard.o: sdcard.c ../drive/uart.h ../fatfs/ff.h ../fatfs/diskio.h ../drive/spi.h ../drive/device_map.h
	$(RISCV_GCC) -static -DBARE_MODE $(RISCV_GCC_OPTS) -c $< -o $@

junk += sdcard.o
