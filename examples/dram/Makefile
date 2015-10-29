#=======================================================================
# Makefile for the DRAM test programs
#-----------------------------------------------------------------------
# See LICENSE for license details.

default: all

TARGET = dram

OBJS += \
	dram.o \
	../drive/uart.o \
	../drive/memory.o \

include ../Makefrag

#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

dram.o: dram.c ../drive/memory.h ../drive/uart.h ../drive/device_map.h
	$(RISCV_GCC) -static -DBARE_MODE $(RISCV_GCC_OPTS) -c $< -o $@

junk += dram.o
