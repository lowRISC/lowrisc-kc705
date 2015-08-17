open_vcd lowrisc-chip.vcd
log_vcd -level 7 DUT
start_vcd
run 200 us
stop_vcd
quit
