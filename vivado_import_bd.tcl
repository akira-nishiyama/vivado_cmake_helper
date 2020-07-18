# vivado_import_bd.tcl
# 	This file implements the Tcl code for add blockdesign to vivdo default project "project_1".
# 	This scripts assumes that Vivado project is already created.
# 	Project name is fixed to "project_1". Simulation set name is fixed to "sim_1".
# 	
# Copyright (c) 2020 Akira Nishiyama.
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#
# Arguments:
#       $argv  0:blockdesign import script written by vivado export_bd command.
#
# Usage:
#	vivado -mode batch -source ../scripts/vivado_import_bd.tcl -tclargs ../scripts/sim_ics_if.tcl
#
set import_bd_tcl   [lindex $argv  0]

set vivado_project_name "project_1"
set simulation_set_name "sim_1"

open_project $vivado_project_name/$vivado_project_name.xpr
source $import_bd_tcl
