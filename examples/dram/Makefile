#=======================================================================
# Makefile for the DRAM test programs
#-----------------------------------------------------------------------
# See LICENSE for license details.

include ../Makefrag

default: all

TARGET = dram

OBJS += \
	dram.o \
	$(DRIVER_DIR)/uart.o \
	$(DRIVER_DIR)/memory.o \


#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

dram.o: dram.c $(DRIVER_DIR)/memory.h $(DRIVER_DIR)/uart.h $(DRIVER_DIR)/device_map.h
	$(RISCV_GCC) -static -DBARE_MODE $(RISCV_GCC_OPTS) -c $< -o $@

junk += dram.o
