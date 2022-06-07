onerror {resume}
quietly WaveActivateNextPane {} 0
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
WaveRestoreCursors {{Cursor 1} {879608 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 325
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
WaveRestoreZoom {0 ps} {1734229 ps}
