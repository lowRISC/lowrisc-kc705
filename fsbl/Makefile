#=======================================================================
# Makefile for Fisr Stage Bootloader (FSBL)
#-----------------------------------------------------------------------
# See LICENSE for license details.

# check RISCV environment variable
ifndef RISCV
$(error Please set environment variable RISCV. Please take a look at README)
endif

default: all

TARGET = fsbl

all: $(TARGET)

junk += $(TARGET)
.PHONY: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX=riscv64-unknown-elf-
RISCV_GCC = $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS = -MMD -MP -Wall -Werror -D__NO_INLINE__ -mcmodel=medany -O2 -std=gnu99 -Wno-unused -Wno-attributes -fno-delete-null-pointer-checks  -I. -I../fsbl
RISCV_LINK_OPTS = -nostartfiles -nostdlib -static -T fsbl.ld -L../softfloat -lsoftfloat -lgcc


#--------------------------------------------------------------------
# Objects
#--------------------------------------------------------------------
OBJS = \
	mtrap.o \
	minit.o \
	emulation.o \
	sbi_impl.o \
	init.o \
	file.o \
	handlers.o \
	frontend.o \
	elf.o \
	console.o \
	vm.o \
	string.o \
	mentry.o \
	entry.o \
	fp_asm.o \
	sbi_entry.o \
	sbi.o \
	fsbl \

HEADERS += \
	$(wildcard *.h) \

junk += $(OBJS)

#--------------------------------------------------------------------
# Building Targets
#--------------------------------------------------------------------

../softfloat/libsoftfloat.a: $(wildcard ../softfloat/*)
	cd ../softfloat && make

%.o: %.c $(HEADERS)
	$(RISCV_GCC) $(RISCV_GCC_OPTS) -c $< -o $@

$(TARGET): $(OBJS) ../softfloat/libsoftfloat.a
	$(RISCV_LINK) -o $@ $(OBJS) $(RISCV_LINK_OPTS)

#--------------------------------------------------------------------
# clean up
#--------------------------------------------------------------------

clean:
	rm -rf $(junk)
	cd ../softfloat && make clean

.PHONY: clean
