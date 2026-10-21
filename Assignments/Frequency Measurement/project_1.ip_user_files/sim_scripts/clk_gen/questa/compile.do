vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../ipstatic" "+incdir+../../../../../../../../../Vivado2026/2026.1/Vivado/data/rsb/busdef" \
"C:/Vivado2026/2026.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm  -93  \
"C:/Vivado2026/2026.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../ipstatic" "+incdir+../../../../../../../../../Vivado2026/2026.1/Vivado/data/rsb/busdef" \
"../../../../project_1.gen/sources_1/ip/clk_gen/clk_gen_clk_wiz.v" \
"../../../../project_1.gen/sources_1/ip/clk_gen/clk_gen.v" \

vlog -work xil_defaultlib \
"glbl.v"

