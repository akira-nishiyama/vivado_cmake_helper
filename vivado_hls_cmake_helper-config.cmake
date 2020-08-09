find_program(HLS_COMMAND
        NAME vivado_hls
        HINTS ENV var
        REQUIRED)

if(${HLS_COMMAND} STREQUAL "HLS_COMMAND-NOTFOUND")
    message(FATAL_ERROR "Vivado HLS program not found.")
endif()
#message("Vivado HLS found:${HLS_COMMAND}")

find_file(HELPER_SCRIPT_EXEC_VIVADO_HLS
        NAME exec_vhls.tcl
        HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
        REQUIRED)
#message("HELPER_SCRIPT_EXEC_VIVADO_HLS found:${HELPER_SCRIPT_EXEC_VIVADO_HLS}")

find_file(VIVADO_HLS_EXPORT_CMAKE
        NAME vivado_hls_export.cmake
        HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURENT_LIST_DIR}
        REQUIRED)
#message("VIVADO_HLS_EXPORT_CMAKE found:${VIVADO_HLS_EXPORT_CMAKE}")


