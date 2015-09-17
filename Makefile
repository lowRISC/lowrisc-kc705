# See LICENSE for license details.

#--------------------------------------------------------------------
# global define
#--------------------------------------------------------------------

default: project

base_dir = $(abspath ../../..)
proj_dir = $(abspath .)
mem_gen = $(base_dir)/fpga/common/fpga_mem_gen
generated_dir = $(abspath ./generated-src)

project_name = lowrisc-chip-imp
BACKEND ?= lowrisc_chip.LowRISCBackend
CONFIG ?= DefaultConfig

VIVADO = vivado

include $(base_dir)/Makefrag

.PHONY: default

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

verilog_lowrisc = \
	$(generated_dir)/Top.$(CONFIG).v \
	$(generated_dir)/consts.$(CONFIG).vh \

verilog_srcs = \
	$(verilog_lowrisc) \
	$(base_dir)/vsrc/chip_top.sv \
	$(base_dir)/socip/nasti/channel.sv \
	$(base_dir)/vsrc/config.vh \

boot_mem = src/boot.mem

testbench_srcs = \
	$(base_dir)/vsrc/chip_top_tb.sv \

#--------------------------------------------------------------------
# Build Verilog
#--------------------------------------------------------------------

verilog: $(verilog_lowrisc)

$(generated_dir)/$(MODEL).$(CONFIG).v: $(chisel_srcs)
	cd $(base_dir) && mkdir -p $(generated_dir) && $(SBT) "run $(CHISEL_ARGS) --configDump --noInlineMem"
	cd $(generated_dir) && \
	if [ -a $(MODEL).$(CONFIG).conf ]; then \
	  $(mem_gen) $(generated_dir)/$(MODEL).$(CONFIG).conf >> $(generated_dir)/$(MODEL).$(CONFIG).v; \
	fi

$(generated_dir)/consts.$(CONFIG).vh: $(generated_dir)/$(MODEL).$(CONFIG).v
	echo "\`ifndef CONST_VH" > $@
	echo "\`define CONST_VH" >> $@
	sed -r 's/\(([A-Za-z0-9_]+),([A-Za-z0-9_]+)\)/`define \1 \2/' $(patsubst %.v,%.prm,$<) >> $@
	echo "\`endif // CONST_VH" >> $@

.PHONY: verilog
junk += $(generated_dir)

#--------------------------------------------------------------------
# Project generation
#--------------------------------------------------------------------

project = $(project_name)/$(project_name).xpr
project: $(project)
$(project): | $(verilog_lowrisc)
	$(VIVADO) -mode batch -source script/make_project.tcl -tclargs $(project_name) $(CONFIG)
	ln -s $(proj_dir)/src/boot.mem $(project_name)/$(project_name).runs/synth_1/boot.mem
	ln -s $(proj_dir)/src/boot.mem $(project_name)/$(project_name).sim/sim_1/behav/boot.mem

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
	cd $(project_name)/$(project_name).sim/sim_1/behav; xsim tb_behav -key {Behavioral:sim_1:Functional:tb} -tclbatch $(proj_dir)/script/simulate.tcl -log $(proj_dir)/simulate.log

.PHONY: project vivado bitstream sim-comp sim-elab simulation

#--------------------------------------------------------------------
# Debug helper
#--------------------------------------------------------------------

search-ramb:
	$(VIVADO) -mode batch -source ../../common/script/search_ramb.tcl -tclargs $(project_name)

bit-update: $(project_name)/$(project_name).runs/impl_1/chip_top.new.bit
$(project_name)/$(project_name).runs/impl_1/chip_top.new.bit: src/boot.mem
	data2mem -bm src/boot.bmm -bd $< -bt $(bitstream) -o b $@

.PHONY: search-ramb bit-update

#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean:
	rm -rf *.log *.jou $(junk)

cleanall: clean
	rm -fr $(project_name)

.PHONY: clean cleanall
