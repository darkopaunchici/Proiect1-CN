vlib work

vlog ALUtop.v
vlog control_unit.v
vlog add_sub.v
vlog radix4.v
vlog non_rest.v
vlog mux.v
vlog testbench.v

vsim work.alu_test

add wave *

run -all
