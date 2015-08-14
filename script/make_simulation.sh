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
    echo "Error: Xilinx Vivado not available!"

    # Do not exit if the script is sourced
    if [ "${BASH_SOURCE[0]}" == "$0" ]
    then
        exit 0
    else
        return
    fi
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

mig_srcs=(
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_ctrl_addr_decode.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_ctrl_read.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_ctrl_reg.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_ctrl_reg_bank.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_ctrl_top.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_ctrl_write.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_ar_channel.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_aw_channel.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_b_channel.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_cmd_arbiter.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_cmd_fsm.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_cmd_translator.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_fifo.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_incr_cmd.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_r_channel.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_simple_fifo.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_w_channel.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_wr_cmd_fsm.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_axi_mc_wrap_cmd.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_a_upsizer.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_axi_register_slice.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_axi_upsizer.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_axic_register_slice.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_carry_and.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_carry_latch_and.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_carry_latch_or.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_carry_or.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_command_fifo.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_comparator.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_comparator_sel.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_comparator_sel_static.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_r_upsizer.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/axi/mig_7series_v2_3_ddr_w_upsizer.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v2_3_clk_ibuf.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v2_3_infrastructure.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v2_3_iodelay_ctrl.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v2_3_tempmon.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_arb_mux.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_arb_row_col.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_arb_select.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_bank_cntrl.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_bank_common.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_bank_compare.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_bank_mach.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_bank_queue.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_bank_state.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_col_mach.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_mc.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_rank_cntrl.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_rank_common.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_rank_mach.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v2_3_round_robin_arb.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v2_3_ecc_buf.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v2_3_ecc_dec_fix.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v2_3_ecc_gen.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v2_3_ecc_merge_enc.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v2_3_fi_xor.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ip_top/mig_7series_v2_3_mem_intfc.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ip_top/mig_7series_v2_3_memc_ui_top_axi.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_byte_group_io.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_byte_lane.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_calib_top.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_if_post_fifo.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_mc_phy.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_mc_phy_wrapper.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_of_pre_fifo.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_4lanes.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_ck_addr_cmd_delay.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_dqs_found_cal.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_dqs_found_cal_hr.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_init.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_ocd_cntlr.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_ocd_data.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_ocd_edge.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_ocd_lim.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_ocd_mux.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_ocd_po_cntlr.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_ocd_samp.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_oclkdelay_cal.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_prbs_rdlvl.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_rdlvl.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_tempmon.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_top.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_wrcal.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_wrlvl.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_phy_wrlvl_off_delay.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_ddr_prbs_gen.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_poc_cc.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_poc_edge_store.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_poc_meta.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_poc_pd.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_poc_tap_base.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v2_3_poc_top.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v2_3_ui_cmd.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v2_3_ui_rd_data.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v2_3_ui_top.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v2_3_ui_wr_data.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/mig_7series_0.v
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/user_design/rtl/mig_7series_0_mig_sim.v
    )

axi_cb_srcs=(
    


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

# mig verilog source
for f in ${mig_srcs[*]}
do
    xvlog -m64 -work xil_defaultlib $f
done
xvlog -m64 -d x1Gb -d sg125 -d x8 -work xil_defaultlib \
    $src_path/sources_1/ip/mig_7series_0/mig_7series_0/example_design/sim/ddr3_model.v

# elaborate the design
xelab -m64 -debug all --timescale 1ns/1ps -L blk_mem_gen_v8_2 -L axi_bram_ctrl_v4_0 -L xil_defaultlib -L axi_lite_ipif_v3_0 -L lib_cdc_v1_0 -L lib_pkg_v1_0 -L lib_srl_fifo_v1_0 -L axi_uart16550_v2_0 -L unisims_ver -L unimacro_ver -L secureip --snapshot $project_name-behav-vcd xil_defaultlib.tb xil_defaultlib.glbl

# link the boot.mem
ln -s $orig_path/src/boot.mem boot.mem

cd $orig_path
