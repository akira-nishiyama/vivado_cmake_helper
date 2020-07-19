# vivado_open_wdb.tcl
# 	This file implements the Tcl code for open wdb file.
# 	
# Copyright (c) 2020 Akira Nishiyama.
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#
# Arguments:
#       $argv  0:wdb file name
#
# Usage:
#	vivado -mode batch -source ../scripts/vivado_open_wdb.tcl -tclargs sim/work/xsim/tb_ics_if.wdb
#
set wdbfile_name   [lindex $argv  0]

start_gui

load_feature simulator
open_wave_database $wdbfile_name

add_wave /

