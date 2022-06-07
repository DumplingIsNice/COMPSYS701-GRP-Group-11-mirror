onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider ControlUnit
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/ControlUnit/clk
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/ControlUnit/rst
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/ControlUnit/x_ready
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/ControlUnit/enable
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/ControlUnit/rst_sinusoid
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/ControlUnit/update_output
add wave -noupdate -divider DataPath
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/clk
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/rst
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/enable
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/rst_sinusoid
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/update_output
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/x
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/magnitudes
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/working_magnitudes
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/sinusoid_clk
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/sinusoid_rst
add wave -noupdate -divider Unit0
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/c_sum_re
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/c_sum_im
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/magnitude
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/cos_w_LUT
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/yn1_LUT
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/yn2_LUT
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/x
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/c_sum
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/yn1_out
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/yn_out
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/yn1_src
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/yn2_src
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/c_sum_out
add wave -noupdate -divider {ReCos GenRef}
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/c_sum_src
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/GenerateReference/clk
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/GenerateReference/rst
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/GenerateReference/cos_w
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/GenerateReference/yn1
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/GenerateReference/yn2
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/GenerateReference/cos_w_out
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/GenerateReference/yn1_out
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/GenerateReference/yn
add wave -noupdate -radix decimal /toplevel_testbench/DFTTest/DataPath/GEN_UNITS(0)/ReCosUnit/GenerateReference/main/v_yn_mult
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {76320 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 595
configure wave -valuecolwidth 222
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {4013 ps} {105052 ps}
