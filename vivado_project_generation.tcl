# vivado_project_generation.tcl
#     This file implements the Tcl code for project generation for vivado with cmake.
#     Source lists are separated with colon. The reason is that the vivado_hls scripts
#     use colon delimiter due to its restriction, so I chose the same method for this scripts.
#     Project name is fixed to "project_1". Simulation set name is fixed to "sim_1".
#     
# Copyright (c) 2020 Akira Nishiyama.
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#
# Arguments:
#     $argv  0:target ip name.
#     $argv  1:target part name.
#     $argv  2:file list to add project. Enclose with brace and separetes with colon.
#     $argv  3:testbench file list to add project. Enclose with brace and separetes with colon.
#     $argv  4:vendor_name.
#     $argv  5:version. This argument is ignored because version is fixed to 1.0.
#              Reason:ip packager could not change the version fields through tcl code.
#     $argv  6:ip repository path for create block design. Enclose with brace and separates with colon.
#
# Usage:
#    vivado -mode batch -source ../scripts/create_ip.tcl -tclargs "ICS_IF" "xczu3eg-sbva484-1-e" {../src/interval_timer.v:../src/empty.v} {../test/src/tb_interval_timer.v} Akira_Nishiyama 1.0 . ../scripts/blockdesign.tcl

set ip_name           [lindex $argv  0]
set target_part_name  [lindex $argv  1]
#file list
set file_list_in      [lindex $argv  2]
regsub -all ":" $file_list_in " " file_list
#file list for simulation
set file_list_tb_in   [lindex $argv  3]
regsub -all ":" $file_list_tb_in " " file_list_tb
set vendor_name       [lindex $argv  4]
set version           [lindex $argv  5]
set ip_repo_path_in   [lindex $argv  6]
regsub -all ":" $ip_repo_path_in " " ip_repo_path
set blockdesign_path  [lindex $argv  7]
set vivado_project_name "project_1"
set simulation_set_name "sim_1"

puts [lindex $argv  0]
puts [lindex $argv  1]
puts [lindex $argv  2]
puts [lindex $argv  3]
puts [lindex $argv  4]
puts [lindex $argv  5]
puts [lindex $argv  6]
puts [lindex $argv  7]

#set export_path "$export_path_i/$vendor_name\_user\_$ip_name\_1.0.zip"
#puts $export_path
puts $file_list
puts $file_list_tb

create_project $vivado_project_name ./$vivado_project_name -part $target_part_name -force
if { $file_list != "\ " && $file_list != "" } {
    import_files -norecurse $file_list
}
if { $file_list_tb != "\ " && $file_list_tb != "" } {
    add_files -fileset $simulation_set_name -norecurse $file_list_tb
}
update_compile_order -fileset sources_1
set_property  ip_repo_paths  $ip_repo_path [current_project]
update_ip_catalog

