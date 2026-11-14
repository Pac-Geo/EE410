transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/blk_mem_gen_v8_4_13
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap blk_mem_gen_v8_4_13 activehdl/blk_mem_gen_v8_4_13
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../../../../../../Vivado2026/2026.1/Vivado/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_13 -l xil_defaultlib \
"C:/Vivado2026/2026.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"C:/Vivado2026/2026.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_13  -v2k5 "+incdir+../../../../../../../../../Vivado2026/2026.1/Vivado/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_13 -l xil_defaultlib \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../../../../../Vivado2026/2026.1/Vivado/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_13 -l xil_defaultlib \
"../../../../XDAC.gen/sources_1/ip/blk_mem_gen_0/sim/blk_mem_gen_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

