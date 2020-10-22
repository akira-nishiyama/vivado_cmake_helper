# vivado_generate_bitstream.tcl
#     This file implements the Tcl code for generation bitstream to vivdo default project "project_1" on default "impl_1" target.
#     This scripts assumes that Vivado project is already created.
#     Project name is fixed to "project_1". Simulation set name is fixed to "sim_1".
#     Implementation set name is fixed to "impl_1".
#     
# Copyright (c) 2020 Akira Nishiyama.
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#
# Arguments:
#       $argv  0:design name.
#       $argv  1:number of jobs.
#
# Usage:
#    vivado -mode batch -source ../scripts/vivado_generate_bitstream.tcl -tclargs ultra96v2_4z 4
#
set design_name     [lindex $argv  0]
set number_of_jobs  [lindex $argv  1]

set vivado_project_name "project_1"
set simulation_set_name "sim_1"
set synth_set_name "synth_1"
set impl_set_name "impl_1"

open_project $vivado_project_name.xpr
reset_run $synth_set_name
launch_runs $impl_set_name -to_step write_bitstream -jobs $number_of_jobs
wait_on_run $impl_set_name
#write_hw_platform -include_bit -include_emulation $design_name.xsa -force
write_hw_platform -include_bit $design_name.xsa -force
validate_hw_platform ./$design_name.xsa
