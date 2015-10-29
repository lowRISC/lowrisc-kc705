#=======================================================================
# Makefile for the Hello World programs
#-----------------------------------------------------------------------
# See LICENSE for license details.

include ../Makefrag

default: all

TARGET = sdcard

OBJS += \
	sdcard.o \
	$(DRIVER_DIR)/spi.o \
	$(DRIVER_DIR)/uart.o \
	$(DRIVER_DIR)/diskio.o \
	$(DRIVER_DIR)/ff.o \

#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

sdcard.o: sdcard.c $(DRIVER_DIR)/uart.h $(DRIVER_DIR)/ff.h $(DRIVER_DIR)/diskio.h $(DRIVER_DIR)/spi.h $(DRIVER_DIR)/device_map.h
	$(RISCV_GCC) -static -DBARE_MODE $(RISCV_GCC_OPTS) -c $< -o $@

junk += sdcard.o
