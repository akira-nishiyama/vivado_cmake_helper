# exec_vhls.tcl
#     This file is helper scripts that creating and managing ip under the vivado_hls.
#     Due to vivado_hls and cmake restriction, scripts arguments could not use space and could not start with "-".
# Copyright (c) 2020 Akira Nishiyama.
# Released under the MIT license
# https://opensource.org/licenses/mit-license.php
#
# Arguments:
#     $argv  0:target function name for HLS
#     $argv  1:target part name.
#     $argv  2:clock preiod in nano seconds
#     $argv  3:file list to add project. enclose with brace and separetes with colon.
#     $argv  4:cflags to pass add_files command. enclose with brace, start with cflags= and separates with colon.
#     $argv  5:testbench file list to add project
#     $argv  6:cflags to pass add_files -tb command. enclose with brace, start with cflags_tb= and separates with colon.
#     $argv  7:description of export IP. enclose with brace and use colon instead of space.
#     $argv  8:display name of export IP
#     $argv  9:vendor name
#     $argv 10:version of export IP
#     $argv 11:directives.tcl path
#    $argv 12:flow control flag
#        export - run csynth_design and export_design
#        csim   - run csim_design
#        cosim  - run csynth_design and cosim_design
#
# Usage:
#    vivado_hls exec_vhls.tcl ics_if_rx xczu3eg-sbva484-1-e 10 {src/ics_if_rx.cpp:src/empty.cpp} {cflags="-Iinclude"} {test/src/tb_ics_if_rx.cpp} {cflags_tb="-Iinclude"} {description:of:ip} ICS_IF_RX Akira_Nishiyama 0.1 directives.tcl export {ldflags={-L/home/akira/local/lib:-lgtest_main:-lgtest}

# puts $argv0
set top_function_name   [lindex $argv  0]
set target_part_name    [lindex $argv  1]
set clock_period        [lindex $argv  2]
#file list
set file_list_in        [lindex $argv  3]
regsub -all ":" $file_list_in " " file_list
#cflags list
scan [lindex $argv 4] "cflags=%s" cflags_in
regsub -all ":" $cflags_in    " " cflags
#file list for testbench
set file_list_tb_in     [lindex $argv  5]
regsub -all ":" $file_list_tb_in " " file_list_tb
#cflags for testbench
scan [lindex $argv 6] "cflags_tb=%s" cflags_tb_in
regsub -all ":" $cflags_tb_in " " cflags_tb
#description
set description_in      [lindex $argv  7]
regsub -all ":" $description_in " " description
set display_ip_name     [lindex $argv  8]
set vendor_name         [lindex $argv  9]
set version             [lindex $argv 10]
set directives_tcl_path [lindex $argv 11]
set flow_control        [lindex $argv 12]
#ldflags
scan [lindex $argv 13] "ldflags=%s" ldflags_in
regsub -all ":" $ldflags_in " " ldflags

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
puts [lindex $argv 10]
puts [lindex $argv 11]
puts [lindex $argv 12]
puts [lindex $argv 13]

puts $file_list

puts $cflags
puts $cflags_tb
puts $ldflags

open_project $top_function_name
set_top $top_function_name
open_solution "solution1"
set_part $target_part_name
create_clock -period $clock_period -name default
add_files $file_list -cflags $cflags
add_files -tb $file_list_tb -cflags $cflags_tb
config_export    -description $description \
        -display_name $display_ip_name \
        -format ip_catalog \
        -ipname $top_function_name \
        -rtl verilog \
        -vendor $vendor_name \
        -version $version

source $directives_tcl_path

if {$flow_control == "export" } {
  csynth_design
  export_design -format ip_catalog
} elseif {$flow_control == "csim" } {
  csim_design -ldflags $ldflags
} elseif {$flow_control == "cosim" } {
  csynth_design
  cosim_design -ldflags $ldflags
} else {
  throw {UNDEFINED_FLOW} "undefined flow detected."
}

