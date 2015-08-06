# on board differential clock, 200MHz
set_property PACKAGE_PIN AD12 [get_ports clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports clk_n]
set_property PACKAGE_PIN AD11 [get_ports clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports clk_n]
set_property BOARD_PART_PIN reset [get_ports rst_top]

# Reset active high SW7.1
set_property PACKAGE_PIN AB7 [get_ports rst_top]
set_property IOSTANDARD LVCMOS15 [get_ports rst_top]

# UART Pins
set_property PACKAGE_PIN M19 [get_ports rxd]
set_property IOSTANDARD LVCMOS25 [get_ports rxd]
set_property PACKAGE_PIN K24 [get_ports txd]
set_property IOSTANDARD LVCMOS25 [get_ports txd]

