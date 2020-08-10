# vivado_export_ip.tcl
#     This file implements the Tcl code for ip generation for vivado with cmake.
#     Source lists are separated with colon. The reason is that the vivado_hls scripts
#     use colon delimiter due to its restriction, so I chose the same method for this scripts.
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
#     $argv  7:ip export path.
#     $argv  8:RTL package flag, 0 is block_design export mode. 1 is rtl design export mode.
#              Each mode exports ip_name object.(0:export ip_name block_design, 1:export ip_name module,)
# Usage:
#    vivado -mode batch -source ../scripts/create_ip.tcl -tclargs "ICS_IF" "xczu3eg-sbva484-1-e" {../src/interval_timer.v:../src/empty.v} {../test/src/tb_interval_timer.v} Akira_Nishiyama 1.0 . ip_repo 0

set ip_name                  [lindex $argv  0]
set target_part_name         [lindex $argv  1]
#file list
set file_list_in             [lindex $argv  2]
regsub -all ":" $file_list_in " " file_list
#file list for simulation
set file_list_tb_in          [lindex $argv  3]
regsub -all ":" $file_list_tb_in " " file_list_tb
set vendor_name              [lindex $argv  4]
set version                  [lindex $argv  5]
set ip_repo_path_in          [lindex $argv  6]
regsub -all ":" $ip_repo_path_in " " ip_repo_path
set export_path_i            [lindex $argv  7]
set rtl_package_flag         [lindex $argv  8]

set vivado_project_name "project_1"
puts $vivado_project_name/$vivado_project_name.xpr

puts [lindex $argv  0]
puts [lindex $argv  1]
puts [lindex $argv  2]
puts [lindex $argv  3]
puts [lindex $argv  4]
puts [lindex $argv  5]
puts [lindex $argv  6]
puts [lindex $argv  7]
puts [lindex $argv  8]
puts [lindex $argv  9]

set export_path "$export_path_i/$vendor_name\_user\_$ip_name\_1.0.zip"
puts $export_path
puts $file_list
puts $file_list_tb

open_project $vivado_project_name/$vivado_project_name.xpr

if { $rtl_package_flag == "0" } {
    ipx::package_project -root_dir /home/akira/work/hls/ICS_IF/build/ip_repo -vendor $vendor_name -library user -taxonomy /UserIP -module $ip_name -import_files
} else {
    set_property top $ip_name [current_fileset]
    update_compile_order -fileset sources_1
    ipx::package_project -root_dir /home/akira/work/hls/ICS_IF/build/ip_repo -vendor $vendor_name -library user -taxonomy /UserIP -import_files
}
set_property core_revision 2 [ipx::find_open_core $vendor_name:user:$ip_name:$version]
ipx::create_xgui_files [ipx::find_open_core $vendor_name:user:$ip_name:$version]
ipx::update_checksums [ipx::find_open_core $vendor_name:user:$ip_name:$version]
ipx::save_core [ipx::find_open_core $vendor_name:user:$ip_name:$version]
ipx::check_integrity -quiet [ipx::find_open_core $vendor_name:user:$ip_name:$version]
ipx::archive_core $export_path [ipx::find_open_core $vendor_name:user:$ip_name:$version]


