transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../ipstatic" "+incdir+../../../../../../../../../Vivado2026/2026.1/Vivado/data/rsb/busdef" -l xpm -l xil_defaultlib \
"C:/Vivado2026/2026.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  -incr \
"C:/Vivado2026/2026.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../ipstatic" "+incdir+../../../../../../../../../Vivado2026/2026.1/Vivado/data/rsb/busdef" -l xpm -l xil_defaultlib \
"../../../../project_1.gen/sources_1/ip/clk_gen/clk_gen_clk_wiz.v" \
"../../../../project_1.gen/sources_1/ip/clk_gen/clk_gen.v" \

vlog -work xil_defaultlib \
"glbl.v"

