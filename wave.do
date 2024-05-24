onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group testbench /testbench/test_phase_step
add wave -noupdate -expand -group testbench -format Analog-Step -height 100 -max 32766.0 -min -31117.0 -radix decimal /testbench/test_output
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/clock
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/reset_n
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/data
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/enable
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/filtered_data
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/filtered_data_valid
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/i
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/j
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/k
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/x
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/_filtered_data
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/_filtered_data_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {32665000 ps} 0} {{Cursor 6} {417944959 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 245
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {63483553 ps}
