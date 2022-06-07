onerror {resume}
quietly WaveActivateNextPane {} 0
quietly WaveActivateNextPane
add wave -noupdate /dft_unittestbench/GenerateReferenceTestBench/placeholder
add wave -noupdate /dft_unittestbench/GenerateReferenceTestBench/clk
add wave -noupdate /dft_unittestbench/GenerateReferenceTestBench/rst
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/cos_w
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/yn1
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/yn2
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/cos_w_out
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/yn1_out
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/yn
add wave -noupdate /dft_unittestbench/GenerateReferenceTestBench/CLK_PERIOD
add wave -noupdate /dft_unittestbench/GenerateReferenceTestBench/AMPLITUDE
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/UNIT_TEST/k
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/UNIT_TEST/n
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/UNIT_TEST/wk
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/UNIT_TEST/answer_cos
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/UNIT_TEST/answer_sin
add wave -noupdate -divider Vars
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/GenerateReferenceBlock/main/v_yn_mult
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/GenerateReferenceBlock/main/v_yn_sub
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/GenerateReferenceBlock/main/v_yn
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/UNIT_TEST/prev_cos_w
add wave -noupdate -radix decimal /dft_unittestbench/GenerateReferenceTestBench/UNIT_TEST/prev_yn1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {330046000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 514
configure wave -valuecolwidth 100
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
WaveRestoreZoom {329997991 ps} {330094009 ps}
