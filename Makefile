
# Makefile for the KC705 board implementing the lowRISC SoC

base_dir = $(abspath .)
project_name = lowrisc-chip-imp
CONFIG ?= DefaultConfig

VIVADO = vivado

verilog_lowrisc = ../../../fsim/generated-src/Top.$(CONFIG).v
verilog_srcs = \
	$(verilog_lowrisc) \
	../../../vsrc/chip_top.sv \
	src/config.vh \


default: project

#---------- Project generation ---------
project = $(project_name)/$(project_name).xpr
project: $(project)
$(project):
	$(VIVADO) -mode batch -source script/make_project.tcl -tclargs $(project_name) $(CONFIG)

vivado: $(project)
	$(VIVADO) $(project) &

#---------- Source files ---------
rocket: $(verilog_lowrisc)
$(verilog_lowrisc):
	cd ../../../fsim; make verilog CONFIG=$(CONFIG)

#---------- Other ----------------------
clean:
	rm -f *.log *.jou

cleanall: clean
	rm -fr $(project_name)

.PHONY: vivado rocket clean cleanall
