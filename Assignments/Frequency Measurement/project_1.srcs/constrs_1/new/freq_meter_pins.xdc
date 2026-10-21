
## PYNQ-Z2 Frequency Meter Constraints

## 125 MHz onboard system clock
set_property PACKAGE_PIN H16 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
create_clock -period 8.000 -name sys_clk [get_ports sys_clk]

## Active-low reset using SW0
## SW0 DOWN = Reset, UP = Run
set_property PACKAGE_PIN M20 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]

## Test clock input - Raspberry Pi header pin 38
set_property PACKAGE_PIN A20 [get_ports clk_test]
set_property IOSTANDARD LVCMOS33 [get_ports clk_test]

## Test clock output - Raspberry Pi header pin 37
set_property PACKAGE_PIN W9 [get_ports clk_out]
set_property IOSTANDARD LVCMOS33 [get_ports clk_out]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_test_IBUF]
set_false_path -to [get_pins -hier -filter {NAME =~ *cnt_clk_test_meta_reg*/D}]
set_false_path -to [get_pins -hier -filter {NAME =~ *cnt_clk_stand_meta_reg*/D}]
set_false_path -to [get_pins -hier -filter {NAME =~ *capture_toggle_meta_reg/D}]
set_false_path -to [get_pins -hier -filter {NAME =~ *gate_a_meta_reg/D}]
create_clock -name clk_test_input -period 77.000 [get_ports clk_test]
set_clock_groups -asynchronous \
    -group [get_clocks clk_test_input] \
    -group [get_clocks -filter {NAME != clk_test_input}]