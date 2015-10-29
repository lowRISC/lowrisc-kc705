#=======================================================================
# Makefile for reset (preparation for bootloader)
#-----------------------------------------------------------------------
# See LICENSE for license details.

default: all

TARGET = reset

DRIVER_DIR = ../../driver

OBJS += \
	reset.o \
	$(DRIVER_DIR)/uart.o \
	$(DRIVER_DIR)/memory.o \

include ../../Makefrag

#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

reset.o: reset.c $(DRIVER_DIR)/device_map.h
	$(RISCV_GCC) -static -DBARE_MODE $(RISCV_GCC_OPTS) -c $< -o $@

junk += reset.o
