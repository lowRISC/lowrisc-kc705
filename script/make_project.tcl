# Xilinx Vivado script
# Version: Vivado 2014.4
# Function:
#   Generate a vivado project for the loRISC SoC

set mem_data_width {128}
set axi_id_width {5}

set origin_dir "."
set project_name [lindex $argv 0]
set CONFIG [lindex $argv 1]
set common_dir "../../common"

# Set the directory path for the original project from where this script was exported
set orig_proj_dir [file normalize $origin_dir/$project_name]

# Create project
create_project $project_name $origin_dir/$project_name

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $project_name]
set_property "board_part" "xilinx.com:kc705:part0:1.1" $obj
set_property "default_lib" "xil_defaultlib" $obj
set_property "simulator_language" "Mixed" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set files [list \
 [file normalize $origin_dir/../../../fsim/generated-src/Top.$CONFIG.v] \
 [file normalize $origin_dir/../../../vsrc/chip_top.sv] \
]
add_files -norecurse -fileset [get_filesets sources_1] $files

# add include path
set_property include_dirs [list \
                               $origin_dir/src \
                               $origin_dir/../../../fsim/generated-src \
                               ] [get_filesets sources_1]

# Set 'sources_1' fileset properties
set_property "top" "chip_top" [get_filesets sources_1]

#UART
create_ip -name axi_uart16550 -vendor xilinx.com -library ip -version 2.0 -module_name axi_uart16550_0
set_property -dict [list \
                        CONFIG.UART_BOARD_INTERFACE {Custom} \
                        CONFIG.C_S_AXI_ACLK_FREQ_HZ_d {200} \
                       ] [get_ips axi_uart16550_0]
generate_target {instantiation_template} \
    [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_uart16550_0/axi_uart16550_0.xci]

#BRAM Controller
create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -version 4.0 -module_name axi_bram_ctrl_0
set_property -dict [list \
                        CONFIG.DATA_WIDTH $mem_data_width \
                        CONFIG.ID_WIDTH $axi_id_width \
                        CONFIG.PROTOCOL {AXI4} \
                        CONFIG.BMG_INSTANCE {EXTERNAL} \
                        CONFIG.SINGLE_PORT_BRAM {1} \
                        CONFIG.SUPPORTS_NARROW_BURST {1} \
                        CONFIG.ECC_TYPE {0} \
                       ] [get_ips axi_bram_ctrl_0]
generate_target {instantiation_template} \
    [get_files $proj_dir/$project_name.srcs/sources_1/ip/axi_bram_ctrl_0/axi_bram_ctrl_0.xci]

#MMCM Clock Controller
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 5.1 -module_name clk_wiz_0
set_property -dict [list \
                        CONFIG.CLK_IN1_BOARD_INTERFACE {sys_diff_clock} \
                        CONFIG.RESET_BOARD_INTERFACE {Custom} \
                        CONFIG.USE_LOCKED {true} \
                        CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
                        CONFIG.PRIM_IN_FREQ {200} \
                        CONFIG.CLKIN1_JITTER_PS {50.0} \
                        CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
                        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} \
                        CONFIG.MMCM_CLKOUT0_DIVIDE_F {20.000} \
                        CONFIG.MMCM_CLKIN1_PERIOD {5.0} \
                        CONFIG.CLKOUT1_JITTER {129.198} \
                        CONFIG.CLKOUT1_PHASE_ERROR {89.971}] \
    [get_ips clk_wiz_0]
generate_target {instantiation_template} \
    [get_files $proj_dir/$project_name.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]

# Create 'constrs_1' fileset (if not found)
#if {[string equal [get_filesets -quiet constrs_1] ""]} {
#  create_fileset -constrset constrs_1
#}

# Set 'constrs_1' fileset object
#set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
#set file "[file normalize "$origin_dir/const/axi_uart_imp.xdc"]"
#set file_added [add_files -norecurse -fileset $obj $file]


# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
#set obj [get_filesets sim_1]
#set files [list \
# "[file normalize "$origin_dir/tb/tb.sv"]"\
#]
#add_files -norecurse -fileset $obj $files

# add include path
set_property include_dirs [list \
                               $origin_dir/src \
                               $origin_dir/../../../fsim/generated-src \
                               ] [get_filesets sim_1]

#set_property "tb" "tb" $obj
