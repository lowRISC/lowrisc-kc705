#=======================================================================
# Makefile for bootloader test
#-----------------------------------------------------------------------
# See LICENSE for license details.


default: all

TARGET = boot

DRIVER_DIR = ../../driver

OBJS += \
	boot.o \
	$(DRIVER_DIR)/spi.o \
	$(DRIVER_DIR)/uart.o \
	$(DRIVER_DIR)/memory.o \
	$(DRIVER_DIR)/elf.o \
	$(DRIVER_DIR)/diskio.o \
	$(DRIVER_DIR)/ff.o \

include ../../Makefrag

#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

boot.o: boot.c $(DRIVER_DIR)/uart.h $(DRIVER_DIR)/memory.h $(DRIVER_DIR)/spi.h $(DRIVER_DIR)/ff.h
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

junk += boot.o
