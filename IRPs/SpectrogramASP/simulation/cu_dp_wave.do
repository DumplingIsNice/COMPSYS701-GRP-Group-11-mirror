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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3007 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 365
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
WaveRestoreZoom {0 ps} {10500 ps}
