#=======================================================================
# Makefile for reset (preparation for bootloader)
#-----------------------------------------------------------------------
# See LICENSE for license details.

default: all

TARGET = reset

OBJS += \
	reset.o \
	../drive/uart.o \

include ../Makefrag

#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

reset.o: reset.c ../drive/device_map.h
	$(RISCV_GCC) -static -DBARE_MODE $(RISCV_GCC_OPTS) -c $< -o $@

junk += reset.o
