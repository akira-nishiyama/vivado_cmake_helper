cmake_minimum_required(VERSION 3.1)
find_program(VIVADO_COMMAND
		NAME vivado
		HINTS ENV var)

find_file(HELPER_SCRIPT_IPX
		NAME create_ip.tcl
		HINTS $ENV{VIVADO_CMAKE_HELPER})

find_file(VIVADO_IPX_EXPORT_CMAKE
		NAME vivado_ipx_export.cmake
		HINTS $ENV{VIVADO_CMAKE_HELPER}
		REQUIRED)

#version fixed to 1.0 due to vivado 2019.2 restriction.
project(ics_if
	VERSION 1.0
	LANGUAGES NONE)

add_subdirectory(modules)

set(VENDOR "Akira_Nishiyama")
set(LIBRARY_NAME "user")
set(TARGET_DEVICE "xczu3eg-sbva484-1-e")

#description
set(DESCRIPTION "ICS_IF IP")
#string(REPLACE " " ":" DESCRIPTION "${DESCRIPTION}")

set(DISPLAY_IP_NAME "ICS_IF")

#source list
set(SRC_FILES "")
list(APPEND SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/interval_timer.v")
#string(REPLACE ";" ":" SRC_FILES "${SRC_FILES}")

#testbench list
set(TESTBENCH_FILES "")
list(APPEND TESTBENCH_FILES "${CMAKE_CURRENT_SOURCE_DIR}/test/src/tb_interval_timer.v")
#string(REPLACE ";" ":" TESTBENCH_FILES "${TESTBENCH_FILES}")

#create block design scripts
set(BLOCK_DESIGN_TCL "${CMAKE_CURRENT_SOURCE_DIR}/scripts/blockdesign.tcl")

include(${VIVADO_IPX_EXPORT_CMAKE})

add_dependencies( ${PROJECT_NAME} ics_if_main)
add_dependencies( ${PROJECT_NAME} ics_if_tx)
add_dependencies( ${PROJECT_NAME} ics_if_rx)

if(PRINT_VARIABLES)
	message(STATUS "*** dump start cmake variables ***")
	get_cmake_property(_variableNames VARIABLES)
	foreach(_variableName ${_variableNames})
	        message(STATUS "${_variableName}=${${_variableName}}")
	endforeach()
	message(STATUS "*** dump end ***")
endif()
