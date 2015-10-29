#=======================================================================
# Makefile for the Hello World programs
#-----------------------------------------------------------------------
# See LICENSE for license details.

include ../../Makefrag

default: all

TARGET = hello

OBJS += \
	hello.o \
	$(DRIVER_DIR)/uart.o \

#--------------------------------------------------------------------
# Build
#--------------------------------------------------------------------

hello.o: hello.c
	$(RISCV_GCC) -static -DBARE_MODE $(RISCV_GCC_OPTS) -c $< -o $@

junk += hello.o
