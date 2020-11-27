# vivado_add_constr.tcl
#     This file implements the Tcl code for add constraints to vivdo default project "project_1".
#     This scripts assumes that Vivado project is already created.
#     Project name is fixed to "project_1". Simulation set name is fixed to "sim_1".
#     Constraint set name is fixed to "constr_1".
#     
# Copyright (c) 2020 Akira Nishiyama.
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#
# Arguments:
#       $argv  0:constraint files.
#
# Usage:
#    vivado -mode batch -source ../scripts/vivado_add_bd.tcl -tclargs {../src/constr_1/constr.xdc}
#
set file_list_const_in   [lindex $argv  0]
regsub -all ":" $file_list_const_in " " file_list_const

set vivado_project_name "project_1"
set simulation_set_name "sim_1"
set constraint_set_name "constrs_1"

open_project $vivado_project_name/$vivado_project_name.xpr

import_files -fileset $constraint_set_name -norecurse $file_list_const

