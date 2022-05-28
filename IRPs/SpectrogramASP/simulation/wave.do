onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider ref
add wave -noupdate /toplevel_testbench/ModuleTest/RefStage/clk
add wave -noupdate -radix decimal /toplevel_testbench/ModuleTest/RefStage/cos_w
add wave -noupdate -radix decimal /toplevel_testbench/ModuleTest/RefStage/yn1
add wave -noupdate -radix decimal /toplevel_testbench/ModuleTest/RefStage/yn2
add wave -noupdate -radix decimal /toplevel_testbench/ModuleTest/RefStage/cos_w_out
add wave -noupdate -radix decimal /toplevel_testbench/ModuleTest/RefStage/yn
add wave -noupdate -divider sum
add wave -noupdate -radix decimal /toplevel_testbench/ModuleTest/SumStage/clk
add wave -noupdate -radix decimal /toplevel_testbench/ModuleTest/SumStage/x
add wave -noupdate -radix decimal /toplevel_testbench/ModuleTest/SumStage/yn
add wave -noupdate -radix decimal /toplevel_testbench/ModuleTest/SumStage/c_sum_in
add wave -noupdate -radix decimal /toplevel_testbench/ModuleTest/SumStage/c_sum_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21847 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 373
configure wave -valuecolwidth 110
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
WaveRestoreZoom {0 ps} {105 ns}
