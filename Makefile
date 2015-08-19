
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

boot_mem = src/boot.mem

testbench_srcs = \
	../../../vsrc/chip_top_tb.sv \

default: project

#---------- Project generation ---------
project = $(project_name)/$(project_name).xpr
project: $(project)
$(project): | $(verilog_lowrisc)
	$(VIVADO) -mode batch -source script/make_project.tcl -tclargs $(project_name) $(CONFIG)
	ln -s $(base_dir)/src/boot.mem $(project_name)/$(project_name).runs/synth_1/boot.mem
	ln -s $(base_dir)/src/boot.mem $(project_name)/$(project_name).sim/sim_1/behav/boot.mem

vivado: $(project)
	$(VIVADO) $(project) &

bitstream = $(project_name)/$(project_name).runs/impl_1/chip_top.bit
bitstream: $(bitstream)
$(bitstream): $(verilog_lowrisc) $(verilog_srcs) $(boot_mem) | $(project)
	$(VIVADO) -mode batch -source ../../common/script/make_bitstream.tcl -tclargs $(project_name)

sim-comp = $(project_name)/$(project_name).sim/sim_1/behav/compile.log
sim-comp: $(sim-comp)
$(sim-comp): $(verilog_lowrisc) $(verilog_srcs) $(testbench_srcs) | $(project)
	cd $(project_name)/$(project_name).sim/sim_1/behav; source compile.sh > /dev/null
	@echo "If error, see $(project_name)/$(project_name).sim/sim_1/behav/compile.log for more details."

sim-elab = $(project_name)/$(project_name).sim/sim_1/behav/elaborate.log
sim-elab: $(sim-elab)
$(sim-elab): $(sim-comp)
	cd $(project_name)/$(project_name).sim/sim_1/behav; source elaborate.sh > /dev/null
	@echo "If error, see $(project_name)/$(project_name).sim/sim_1/behav/elaborate.log for more details."

simulation: $(sim-elab)
	cd $(project_name)/$(project_name).sim/sim_1/behav; xsim tb_behav -key {Behavioral:sim_1:Functional:tb} -tclbatch $(base_dir)/script/simulate.tcl -log $(base_dir)/simulate.log

#---------- Source files ---------
rocket: $(verilog_lowrisc)
$(verilog_lowrisc):
	cd ../../../fsim; make verilog CONFIG=$(CONFIG)

#---------- Other ----------------------
clean:
	rm -f *.log *.jou

cleanall: clean
	rm -fr $(project_name)

.PHONY: vivado bitstream simulation sim-run bootmem rocket clean cleanall
