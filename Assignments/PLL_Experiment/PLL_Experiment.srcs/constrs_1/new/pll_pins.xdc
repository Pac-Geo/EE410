
## PYNQ-Z2 onboard 125 MHz clock
set_property PACKAGE_PIN H16 [get_ports clk_in]
set_property IOSTANDARD LVCMOS33 [get_ports clk_in]
create_clock -period 8.000 -name sys_clk [get_ports clk_in]

## SW0 - reset (active-high in our PLL design)
set_property PACKAGE_PIN M20 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## PLL generated clock output - Raspberry Pi header pin 37
set_property PACKAGE_PIN W9 [get_ports clk_out]
set_property IOSTANDARD LVCMOS33 [get_ports clk_out]

## LED0 - PLL lock indicator
set_property PACKAGE_PIN R14 [get_ports locked]
set_property IOSTANDARD LVCMOS33 [get_ports locked]
