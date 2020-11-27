# vivado_source_tcl.tcl
#     This file implements the Tcl code for do user tcl.
#     This scripts assumes that Vivado project is already created.
#     The main usage are to set project parameters.
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
#    vivado -mode batch -source ../scripts/vivado_source_tcl.tcl -tclargs set_property.tcl
#
set tcl_file        [lindex $argv  0]

set vivado_project_name "project_1"
set simulation_set_name "sim_1"
set synth_set_name "synth_1"
set impl_set_name "impl_1"

open_project $vivado_project_name.xpr
source $tcl_file

