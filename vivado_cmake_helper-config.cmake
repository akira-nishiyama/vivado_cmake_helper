
find_program(   VIVADO_COMMAND
                NAME vivado
                HINTS ENV var
                REQUIRED)
if(${VIVADO_COMMAND} STREQUAL "VIVADO_COMMAND-NOTFOUND")
    message(FATAL_ERROR "Vivado program not found.")
endif()
message("VIVADO_COMMAND found:${VIVADO_COMMAND}")

find_program(   SED
                NAME sed
                HINTS ENV var
                REQUIRED)
if(${SED} STREQUAL "SED-NOTFOUND")
    message(FATAL_ERROR "sed not found")
endif()
message("SED found:${SED}")

#tcl scripts
find_file(  HELPER_SCRIPT_EXPORT_IP
            NAME vivado_export_ip.tcl
            HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
            REQUIRED)
message("HELPER_SCRIPT_EXPORT_IP found:${HELPER_SCRIPT_EXPORT_IP}")

find_file(  HELPER_SCRIPT_PRJ_GEN
            NAME vivado_project_generation.tcl
            HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
            REQUIRED)
message("HELPER_SCRIPT_PRJ_GEN found:${HELPER_SCRIPT_PRJ_GEN}")

find_file(  HELPER_SCRIPT_EXPORT_SIM
            NAME vivado_export_sim.tcl
            HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
            REQUIRED)
message("HELPER_SCRIPT_EXPORT_SIM found:${HELPER_SCRIPT_EXPORT_SIM}")

find_file(  HELPER_SCRIPT_OPEN_WDB
            NAME vivado_open_wdb.tcl
            HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
            REQUIRED)
message("HELPER_SCRIPT_OPEN_WDB found:${HELPER_SCRIPT_OPEN_WDB}")

find_file(  HELPER_SCRIPT_ADD_BD
            NAME vivado_add_bd.tcl
            HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
            REQUIRED)
message("HELPER_SCRIPT_ADD_BD found:${HELPER_SCRIPT_ADD_BD}")

#functions
find_file(  VIVADO_IPX_EXPORT_CMAKE
            NAME vivado_ipx_export.cmake
            HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
            REQUIRED)
message("vivado ipx export related functions found:${VIVADO_IPX_EXPORT_CMAKE}")

find_file(  VIVADO_ADD_SIM_CMAKE
            NAME vivado_add_sim.cmake
            HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
            REQUIRED)
message("vivado simulation related functions found:${VIVADO_ADD_SIM_CMAKE}")

include(${VIVADO_IPX_EXPORT_CMAKE})
include(${VIVADO_ADD_SIM_CMAKE})




