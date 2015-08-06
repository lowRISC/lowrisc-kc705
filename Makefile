
# Makefile for the KC705 board implementing the lowRISC SoC

base_dir = $(abspath .)
project_name = lowrisc-chip-imp
CONFIG ?= DefaultConfig

VIVADO = vivado

verilog_lowrisc = ../../../fsim/generated-src/Top.$(CONFIG).v
verilog_srcs = \
	$(verilog_lowrisc) \
	../../../vsrc/chip_top.sv \
	../../../socip/nasti/channel.sv \
	src/config.vh \

default: project

#---------- Project generation ---------
project = $(project_name)/$(project_name).xpr
project: $(project)
$(project): | $(verilog_lowrisc)
	$(VIVADO) -mode batch -source script/make_project.tcl -tclargs $(project_name) $(CONFIG)

vivado: $(project)
	$(VIVADO) $(project) &

bitstream = $(project_name)/$(project_name).runs/impl_1/chip_top.bit
bitstream: $(bitstream)
$(bitstream): $(verilog_lowrisc) $(verilog_srcs) | $(project)
	$(VIVADO) -mode batch -source ../../common/script/make_bitstream.tcl -tclargs $(project_name)

simulation = $(project_name)/$(project_name).sim/xsim.dir/$(project_name)-behav-vcd
simulation: $(simulation)
$(simulation): $(verilog_lowrisc) $(verilog_srcs) | $(project)
	./script/make_simulation.sh

sim-run: | $(simulation)
	cd $(project_name)/$(project_name).sim; xsim -g $(project_name)-behav-vcd &

#---------- Source files ---------
rocket: $(verilog_lowrisc)
$(verilog_lowrisc):
	cd ../../../fsim; make verilog CONFIG=$(CONFIG)

#---------- Other ----------------------
clean:
	rm -f *.log *.jou

cleanall: clean
	rm -fr $(project_name)

.PHONY: vivado bitstream simulation sim-run rocket clean cleanall
