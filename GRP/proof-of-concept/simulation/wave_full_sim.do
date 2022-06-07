onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /dft_testbench/clk
add wave -noupdate -radix decimal /dft_testbench/rst
add wave -noupdate -radix decimal /dft_testbench/x_ready
add wave -noupdate -radix decimal /dft_testbench/new_window
add wave -noupdate -radix decimal /dft_testbench/enable
add wave -noupdate -radix decimal /dft_testbench/rst_sinusoid
add wave -noupdate -radix decimal /dft_testbench/update_output
add wave -noupdate -radix decimal /dft_testbench/output_updated
add wave -noupdate -radix decimal /dft_testbench/x
add wave -noupdate -radix decimal /dft_testbench/magnitudes
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix decimal /dft_testbench/DataPath/clk
add wave -noupdate -radix decimal /dft_testbench/DataPath/rst
add wave -noupdate -radix decimal /dft_testbench/DataPath/enable
add wave -noupdate -radix decimal /dft_testbench/DataPath/rst_sinusoid
add wave -noupdate -radix decimal /dft_testbench/DataPath/update_output
add wave -noupdate -radix decimal /dft_testbench/DataPath/x
add wave -noupdate -radix decimal /dft_testbench/DataPath/magnitudes
add wave -noupdate -radix decimal /dft_testbench/DataPath/working_magnitudes
add wave -noupdate -radix decimal /dft_testbench/DataPath/sinusoid_clk
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/c_sum_re
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/c_sum_im
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/magnitude
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/clk
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/rst
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/restart
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/cos_w_LUT
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/yn1_LUT
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/yn2_LUT
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/x
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/c_sum
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/yn1_out
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/yn_out
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/yn1_src
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/yn2_src
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/c_sum_out
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/c_sum_src
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/SumCorrelation/main/v_mult
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ReCosUnit/SumCorrelation/main/v_c_sum
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ApproximateMagnitude/word_length
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ApproximateMagnitude/clk
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ApproximateMagnitude/rst
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ApproximateMagnitude/a
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ApproximateMagnitude/b
add wave -noupdate -radix decimal /dft_testbench/DataPath/GEN_UNITS(8)/ApproximateMagnitude/magnitude
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4882341 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 432
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
WaveRestoreZoom {4741035 ps} {5038288 ps}
