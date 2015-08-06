#!/bin/bash

# Xilinx Vivado script
# Version: Vivado 2014.4
# Function:
#   Generate a vivado (iSim) simulation project for the loRISC SoC

orig_path=$PWD
project_name=lowrisc-chip-imp
sim_path=$orig_path/$project_name/$project_name.sim
src_path=$orig_path/$project_name/$project_name.srcs

# check Xilinx Vivado is available
if [ "$XILINX_VIVADO" == "" ]
then
    "Error: Xilinx Vivado not available!"
    exit 1
fi

# build the simulation path
if [ ! -e $sim_path ]
then 
    mkdir $sim_path
fi

# go to the simulation path
cd $sim_path

# get the source files
svlog_srcs=(
    $orig_path/../../../socip/nasti/channel.sv
    $orig_path/../../../vsrc/chip_top.sv
    $orig_path/../../../vsrc/chip_top_tb.sv
    $orig_path/../../../vsrc/axi_bram_ctrl_top.sv
)

vlog_srcs=(
    $orig_path/../../../fsim/generated-src/Top.DefaultConfig.v
    $XILINX_VIVADO/data/verilog/src/glbl.v
)

bram_srcs=(
    $src_path/sources_1/ip/axi_bram_ctrl_0/blk_mem_gen_v8_2/simulation/blk_mem_gen_v8_2.v
)

bram_ctl_srcs=(
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/srl_fifo.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/axi_bram_ctrl_funcs.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/coregen_comp_defs.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/axi_lite_if.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/checkbit_handler_64.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/checkbit_handler.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/correct_one_bit_64.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/correct_one_bit.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/xor18.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/parity.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/ecc_gen.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/lite_ecc_reg.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/axi_lite.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/sng_port_arb.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/ua_narrow.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/wrap_brst.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/rd_chnl.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/wr_chnl.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/full_axi.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/axi_bram_ctrl_top.vhd
    $src_path/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_v4_0/hdl/vhdl/axi_bram_ctrl.vhd
)

axi_ipif_srcs=(
    $src_path/sources_1/ip/axi_uart16550_0/axi_lite_ipif_v3_0/hdl/src/vhdl/ipif_pkg.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_lite_ipif_v3_0/hdl/src/vhdl/pselect_f.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_lite_ipif_v3_0/hdl/src/vhdl/address_decoder.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_lite_ipif_v3_0/hdl/src/vhdl/slave_attachment.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_lite_ipif_v3_0/hdl/src/vhdl/axi_lite_ipif.vhd
)

cdc_srcs=(
    $src_path/sources_1/ip/axi_uart16550_0/lib_cdc_v1_0/hdl/src/vhdl/cdc_sync.vhd
)

pkg_srcs=(
    $src_path/sources_1/ip/axi_uart16550_0/lib_pkg_v1_0/hdl/src/vhdl/lib_pkg.vhd
    )

srl_fifo_srcs=(
    $src_path/sources_1/ip/axi_uart16550_0/lib_srl_fifo_v1_0/hdl/src/vhdl/cntr_incr_decr_addn_f.vhd
    $src_path/sources_1/ip/axi_uart16550_0/lib_srl_fifo_v1_0/hdl/src/vhdl/dynshreg_f.vhd
    $src_path/sources_1/ip/axi_uart16550_0/lib_srl_fifo_v1_0/hdl/src/vhdl/srl_fifo_rbu_f.vhd
    $src_path/sources_1/ip/axi_uart16550_0/lib_srl_fifo_v1_0/hdl/src/vhdl/srl_fifo_f.vhd
)

uart166550_srcs=(
    $src_path/sources_1/ip/axi_uart16550_0/axi_uart16550_v2_0/hdl/src/vhdl/rx_fifo_control.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_uart16550_v2_0/hdl/src/vhdl/xuart_tx_load_sm.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_uart16550_v2_0/hdl/src/vhdl/tx_fifo_block.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_uart16550_v2_0/hdl/src/vhdl/tx16550.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_uart16550_v2_0/hdl/src/vhdl/rx_fifo_block.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_uart16550_v2_0/hdl/src/vhdl/rx16550.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_uart16550_v2_0/hdl/src/vhdl/uart16550.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_uart16550_v2_0/hdl/src/vhdl/ipic_if.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_uart16550_v2_0/hdl/src/vhdl/xuart.vhd
    $src_path/sources_1/ip/axi_uart16550_0/axi_uart16550_v2_0/hdl/src/vhdl/axi_uart16550.vhd
)

vhdl_srcs=(
    $src_path/sources_1/ip/axi_bram_ctrl_0/sim/axi_bram_ctrl_0.vhd
    $src_path/sources_1/ip/axi_uart16550_0/sim/axi_uart16550_0.vhd
)

# compile verilog sources
for f in ${vlog_srcs[*]}
do
    xvlog -m64 -work xil_defaultlib $f
done

# compile system-verilog sources
for f in ${svlog_srcs[*]}
do
    xvlog -m64 -sv -d SIMULATION -i $orig_path/src -i $orig_path/../../../fsim/generated-src -work xil_defaultlib $f
done

#compile bram sources
for f in ${bram_srcs[*]}
do
    xvlog -m64 -work blk_mem_gen_v8_2 $f
done

# compile bram-ctrl sources
for f in ${bram_ctl_srcs[*]}
do
    xvhdl -m64 -work axi_bram_ctrl_v4_0 $f
done

# compile axi/ipif sources
for f in ${axi_ipif_srcs[*]}
do
    xvhdl -m64 -work axi_lite_ipif_v3_0 $f
done

# compile cdc sources
for f in ${cdc_srcs[*]}
do
    xvhdl -m64 -work lib_cdc_v1_0 $f
done

# compile pkg sources
for f in ${pkg_srcs[*]}
do
    xvhdl -m64 -work lib_pkg_v1_0 $f
done

# compile srl_fifo sources
for f in ${srl_fifo_srcs[*]}
do
    xvhdl -m64 -work lib_srl_fifo_v1_0 $f
done

# compile uart sources
for f in ${uart166550_srcs[*]}
do
    xvhdl -m64 -work axi_uart16550_v2_0 $f
done

# compile vhdl sources
for f in ${vhdl_srcs[*]}
do
    xvhdl -m64 -work xil_defaultlib $f
done

# elaborate the design
xelab -m64 -debug all --timescale 1ns/1ps -L blk_mem_gen_v8_2 -L axi_bram_ctrl_v4_0 -L xil_defaultlib -L axi_lite_ipif_v3_0 -L lib_cdc_v1_0 -L lib_pkg_v1_0 -L lib_srl_fifo_v1_0 -L axi_uart16550_v2_0 -L unisims_ver -L unimacro_ver -L secureip --snapshot $project_name-behav-vcd xil_defaultlib.tb xil_defaultlib.glbl

# link the boot.mem
ln -s $orig_path/src/boot.mem boot.mem

cd $orig_path
