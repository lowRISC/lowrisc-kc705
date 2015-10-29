#=======================================================================
# Makefile for the Hello World programs
#-----------------------------------------------------------------------
# See LICENSE for license details.

default: all

TARGET = hello

DRIVER_DIR = ../../driver

OBJS += \
	hello.o \
	$(DRIVER_DIR)/uart.o \

include ../../Makefrag

#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

hello.o: hello.c
	$(RISCV_GCC) -static -DBARE_MODE $(RISCV_GCC_OPTS) -c $< -o $@

junk += hello.o
