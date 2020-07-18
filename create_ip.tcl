# create_ip.tcl
# 	This file implements the Tcl code for ip generation for vivado with cmake.
# 	Source lists are separated with colon. The reason is that the vivado_hls scripts
# 	use colon delimiter due to its restriction, so I chose the same method for this scripts.
# 	
# Copyright (c) 2020 Akira Nishiyama.
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#
# Arguments:
# 	$argv  0:target ip name.
# 	$argv  1:target part name.
# 	$argv  2:file list to add project. Enclose with brace and separetes with colon.
# 	$argv  3:testbench file list to add project. Enclose with brace and separetes with colon.
# 	$argv  4:vendor_name.
# 	$argv  5:version. This argument is ignored because version is fixed to 1.0.
# 	         Reason:ip packager could not change the version fields through tcl code.
# 	$argv  6:ip repository path for create block design. Enclose with brace and separates with colon.
# 	$argv  7:ip export path.
# 	$argv  8:Tcl code path to create the target block design.
# 	         The design name should be $ip_name.
# 	         (The Modification required from vivado "export block design" output.
# 	          Or create block design with exactly same name as $ip_name in vivado.)
#	$argv  9:Path to project_generation.tcl
# Usage:
#	vivado -mode batch -source ../scripts/create_ip.tcl -tclargs "ICS_IF" "xczu3eg-sbva484-1-e" {../src/interval_timer.v:../src/empty.v} {../test/src/tb_interval_timer.v} Akira_Nishiyama 1.0 . ip_repo ../scripts/blockdesign.tcl ../scripts/project_generation.tcl

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
set blockdesign_path         [lindex $argv  8]
set project_generation_path  [lindex $argv  9]

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

set argv [list $ip_name $target_part_name $file_list $file_list_tb $vendor_name $version $ip_repo_path $blockdesign_path]
set argc 8
source $project_generation_path

ipx::package_project -root_dir /home/akira/work/hls/ICS_IF/build/ip_repo -vendor $vendor_name -library user -taxonomy /UserIP -module $ip_name -import_files
set_property core_revision 2 [ipx::find_open_core $vendor_name:user:$ip_name:$version]
ipx::create_xgui_files [ipx::find_open_core $vendor_name:user:$ip_name:$version]
ipx::update_checksums [ipx::find_open_core $vendor_name:user:$ip_name:$version]
ipx::save_core [ipx::find_open_core $vendor_name:user:$ip_name:$version]
ipx::check_integrity -quiet [ipx::find_open_core $vendor_name:user:$ip_name:$version]
ipx::archive_core $export_path [ipx::find_open_core $vendor_name:user:$ip_name:$version]


