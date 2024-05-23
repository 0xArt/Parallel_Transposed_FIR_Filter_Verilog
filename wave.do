onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/clock
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/reset_n
add wave -noupdate -expand -group fir_filter -radix decimal -childformat {{{/testbench/fir_filter/data[15]} -radix decimal} {{/testbench/fir_filter/data[14]} -radix decimal} {{/testbench/fir_filter/data[13]} -radix decimal} {{/testbench/fir_filter/data[12]} -radix decimal} {{/testbench/fir_filter/data[11]} -radix decimal} {{/testbench/fir_filter/data[10]} -radix decimal} {{/testbench/fir_filter/data[9]} -radix decimal} {{/testbench/fir_filter/data[8]} -radix decimal} {{/testbench/fir_filter/data[7]} -radix decimal} {{/testbench/fir_filter/data[6]} -radix decimal} {{/testbench/fir_filter/data[5]} -radix decimal} {{/testbench/fir_filter/data[4]} -radix decimal} {{/testbench/fir_filter/data[3]} -radix decimal} {{/testbench/fir_filter/data[2]} -radix decimal} {{/testbench/fir_filter/data[1]} -radix decimal} {{/testbench/fir_filter/data[0]} -radix decimal}} -subitemconfig {{/testbench/fir_filter/data[15]} {-height 23 -radix decimal} {/testbench/fir_filter/data[14]} {-height 23 -radix decimal} {/testbench/fir_filter/data[13]} {-height 23 -radix decimal} {/testbench/fir_filter/data[12]} {-height 23 -radix decimal} {/testbench/fir_filter/data[11]} {-height 23 -radix decimal} {/testbench/fir_filter/data[10]} {-height 23 -radix decimal} {/testbench/fir_filter/data[9]} {-height 23 -radix decimal} {/testbench/fir_filter/data[8]} {-height 23 -radix decimal} {/testbench/fir_filter/data[7]} {-height 23 -radix decimal} {/testbench/fir_filter/data[6]} {-height 23 -radix decimal} {/testbench/fir_filter/data[5]} {-height 23 -radix decimal} {/testbench/fir_filter/data[4]} {-height 23 -radix decimal} {/testbench/fir_filter/data[3]} {-height 23 -radix decimal} {/testbench/fir_filter/data[2]} {-height 23 -radix decimal} {/testbench/fir_filter/data[1]} {-height 23 -radix decimal} {/testbench/fir_filter/data[0]} {-height 23 -radix decimal}} /testbench/fir_filter/data
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/filtered_data
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/i
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/j
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/k
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/x
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/_filtered_data
add wave -noupdate -expand -group fir_filter /testbench/fir_filter/fir_coefficients
add wave -noupdate -expand -group testbench /testbench/test_phase_step
add wave -noupdate -expand -group testbench -format Analog-Step -height 100 -max 32766.0 -min -31117.0 -radix decimal /testbench/test_output
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {417675000 ps} 0} {{Cursor 6} {417944959 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
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
WaveRestoreZoom {417468288 ps} {418501824 ps}
