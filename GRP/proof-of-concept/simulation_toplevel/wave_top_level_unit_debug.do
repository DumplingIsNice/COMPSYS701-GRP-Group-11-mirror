onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /grp_testbench/clk
add wave -noupdate /grp_testbench/rst
add wave -noupdate -divider asp_adc
add wave -noupdate -radix hexadecimal /grp_testbench/asp_adc/send
add wave -noupdate -radix hexadecimal /grp_testbench/asp_adc/recv
add wave -noupdate -radix decimal /grp_testbench/asp_adc/channel_0
add wave -noupdate -radix decimal /grp_testbench/asp_adc/channel_1
add wave -noupdate -divider asp_dac
add wave -noupdate -radix hexadecimal /grp_testbench/asp_dac/send
add wave -noupdate -radix hexadecimal /grp_testbench/asp_dac/recv
add wave -noupdate -radix decimal /grp_testbench/asp_dac/channel_0
add wave -noupdate -radix decimal /grp_testbench/asp_dac/channel_1
add wave -noupdate -divider asp_dft
add wave -noupdate -radix decimal /grp_testbench/asp_dft/x_direct_ready
add wave -noupdate -radix decimal /grp_testbench/asp_dft/x_direct
add wave -noupdate -radix decimal /grp_testbench/asp_dft/magnitudes
add wave -noupdate -radix decimal /grp_testbench/asp_dft/magnitudes_updated
add wave -noupdate -radix hexadecimal /grp_testbench/asp_dft/noc_send
add wave -noupdate -radix hexadecimal /grp_testbench/asp_dft/noc_recv
add wave -noupdate -radix decimal /grp_testbench/asp_dft/enable
add wave -noupdate -radix decimal /grp_testbench/asp_dft/rst_sinusoid
add wave -noupdate -radix decimal /grp_testbench/asp_dft/update_output
add wave -noupdate -radix decimal /grp_testbench/asp_dft/output_updated
add wave -noupdate -radix decimal /grp_testbench/asp_dft/x
add wave -noupdate -divider asp_dft_datapath
add wave -noupdate /grp_testbench/asp_dft/DataPath/clk
add wave -noupdate /grp_testbench/asp_dft/DataPath/rst
add wave -noupdate /grp_testbench/asp_dft/DataPath/enable
add wave -noupdate /grp_testbench/asp_dft/DataPath/rst_sinusoid
add wave -noupdate /grp_testbench/asp_dft/DataPath/update_output
add wave -noupdate /grp_testbench/asp_dft/DataPath/x
add wave -noupdate /grp_testbench/asp_dft/DataPath/magnitudes
add wave -noupdate /grp_testbench/asp_dft/DataPath/output_updated
add wave -noupdate /grp_testbench/asp_dft/DataPath/working_magnitudes
add wave -noupdate /grp_testbench/asp_dft/DataPath/sinusoid_clk
add wave -noupdate -divider asp_dft_datapath_unit
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/clk
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/rst
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/restart
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/cos_w_LUT
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/yn1_LUT
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/yn2_LUT
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/x
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/c_sum
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/yn1_out
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/yn_out
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/yn1_src
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/yn2_src
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/c_sum_out
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/c_sum_src
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/prev_x
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/prev_rst
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ReCosUnit/prev_restart
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ApproximateMagnitude/clk
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ApproximateMagnitude/rst
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ApproximateMagnitude/a
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ApproximateMagnitude/b
add wave -noupdate -radix decimal /grp_testbench/asp_dft/DataPath/GEN_UNITS(5)/ApproximateMagnitude/magnitude
add wave -noupdate -divider asp_dft_init
add wave -noupdate /grp_testbench/INIT_DFT/port_delay_counter
add wave -noupdate /grp_testbench/INIT_DFT/state
add wave -noupdate /grp_testbench/INIT_DFT/edge3
add wave -noupdate /grp_testbench/INIT_DFT/dft_port
add wave -noupdate -divider disp
add wave -noupdate /grp_testbench/DispFrequency/clk
add wave -noupdate /grp_testbench/DispFrequency/rst
add wave -noupdate /grp_testbench/DispFrequency/start_run
add wave -noupdate -radix decimal /grp_testbench/DispFrequency/magnitudes
add wave -noupdate /grp_testbench/DispFrequency/seg0
add wave -noupdate /grp_testbench/DispFrequency/seg1
add wave -noupdate /grp_testbench/DispFrequency/seg2
add wave -noupdate /grp_testbench/DispFrequency/seg3
add wave -noupdate /grp_testbench/DispFrequency/seg4
add wave -noupdate /grp_testbench/DispFrequency/seg5
add wave -noupdate /grp_testbench/DispFrequency/hex0
add wave -noupdate /grp_testbench/DispFrequency/hex1
add wave -noupdate /grp_testbench/DispFrequency/hex2
add wave -noupdate /grp_testbench/DispFrequency/hex3
add wave -noupdate /grp_testbench/DispFrequency/hex4
add wave -noupdate /grp_testbench/DispFrequency/hex5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3797698 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 415
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 100
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {3782384 ps}
