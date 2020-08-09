# vivado_export_sim.tcl
#     This file implements the Tcl code for export simulation scripts for vivado with cmake.
#     This scripts assumes that Vivado project is already created.
#     Project name is fixed to "project_1". Simulation set name is fixed to "sim_1".
#     
# Copyright (c) 2020 Akira Nishiyama.
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#
# Arguments:
#     $argv  0:testbench name
#     $argv  1:simulation export destination.
#
# Usage:
#    vivado -mode batch -source ../scripts/vivado_export_sim.tcl -tclargs tb_ics_if ./sim
#
set testbench_name   [lindex $argv  0]
set sim_dir          [lindex $argv  1]

set vivado_project_name "project_1"
set simulation_set_name "sim_1"
set destination_dir "$sim_dir/work/$testbench_name"

file mkdir $destination_dir

open_project $vivado_project_name/$vivado_project_name.xpr

set_property top $testbench_name [get_filesets $simulation_set_name]
set_property top_lib xil_defaultlib [get_filesets $simulation_set_name]

set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets $simulation_set_name]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets $simulation_set_name]

generate_target Simulation [get_files -filter {FILE_TYPE=="Block Designs"}]
generate_target Simulation [get_ips -filter {SCOPE==""}]

export_ip_user_files -no_script -sync -force -ip_user_files_dir $sim_dir/ip_user_files -ipstatic_source_dir $sim_dir/ip_user_files/ipstatic

set_property -name {xsim.simulate.runtime} -value {-all} -objects [get_filesets $simulation_set_name]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets $simulation_set_name]
set_property -name {xsim.simulate.wdb} -value $destination_dir/$testbench_name.wdb -objects [get_filesets sim_1]
#launch_simulation -scripts_only -absolute_path
export_simulation -directory $destination_dir -ip_user_files_dir $sim_dir/ip_user_files -ipstatic_source_dir $sim_dir/ip_user_files/ipstatic -simulator xsim -use_ip_compiled_libs -absolute_path -force

exec touch $destination_dir/xsim/vhdl.prj
exec touch $destination_dir/xsim/vlog.prj


