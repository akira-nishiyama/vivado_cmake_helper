function(project_generation PROJECT_NAME VENDOR LIBRARY_NAME TARGET_DEVICE SRC_FILES TESTBENCH_FILES IP_REPO_PATH )

    set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/ip_repo")

    find_file(  HELPER_SCRIPT_PRJ_GEN
                NAME vivado_project_generation.tcl
                HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
                REQUIRED)
    string(REPLACE ";" ":" SRC_FILES_ "${SRC_FILES}")
    string(REPLACE ";" ":" TESTBENCH_FILES_ "${TESTBENCH_FILES}")
    string(REPLACE ";" ":" IP_REPO_PATH_ "${IP_REPO_PATH}")

    #output filename
    set(IP_FILENAME "")
    list(APPEND IP_FILENAME ${VENDOR})
    list(APPEND IP_FILENAME ${LIBRARY_NAME})
    list(APPEND IP_FILENAME ${PROJECT_NAME})
    #list(APPEND IP_FILENAME ${PROJECT_VERSION})
    list(APPEND IP_FILENAME "1.0")
    string( REPLACE ";" "_" IP_FILENAME "${IP_FILENAME}" )
    set(IP_FILENAME "${IP_FILENAME}.zip")

    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/project_1/project_1_gen.timestamp
        COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_PRJ_GEN} -tclargs
            ${PROJECT_NAME}
            ${TARGET_DEVICE}
            "{${SRC_FILES_}}"
            "{${TESTBENCH_FILES_}}"
            ${VENDOR}
            #${PROJECT_VERSION}
            "1.0"
            "{${IP_REPO_PATH_}}"
            ${OUT_DIR}
        COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/project_1/project_1_gen.timestamp
        )
    add_custom_target( prj_gen_${PROJECT_NAME} ALL
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/project_1/project_1_gen.timestamp
        )
    add_custom_target( open_prj_${PROJECT_NAME}
        COMMAND ${VIVADO_COMMAND} ${CMAKE_CURRENT_BINARY_DIR}/project_1/project_1.xpr
        )

endfunction()

function(project_add_constr PRJ_NAME CONSTR_FILES DEPENDENCIES)

    find_file(  HELPER_SCRIPT_ADD_CONSTR
                NAME vivado_add_constr.tcl
                HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
                REQUIRED)

    string(REPLACE ";" ":" CONSTR_FILES_ "${CONSTR_FILES}")

    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/project_1/add_constr_${PRJ_NAME}.timestamp
        COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_ADD_CONSTR} -tclargs "{${CONSTR_FILES_}}"
        COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/project_1/add_constr_${PRJ_NAME}.timestamp
        DEPENDS ${DEPENDENCIES}
    )
    add_custom_target( add_constr_${PRJ_NAME}
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/project_1/add_constr_${PRJ_NAME}.timestamp
    )

endfunction()

function(project_add_bd BLOCK_NAME BLOCK_DESIGN_TCL DEPENDENCIES)

    find_file(  HELPER_SCRIPT_ADD_BD
                NAME vivado_add_bd.tcl
                HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
                REQUIRED)

    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/project_1/add_bd_${BLOCK_NAME}.timestamp
        COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_ADD_BD} -tclargs ${BLOCK_DESIGN_TCL}
        COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/project_1/add_bd_${BLOCK_NAME}.timestamp
        DEPENDS ${DEPENDENCIES}
    )
    add_custom_target( add_bd_${BLOCK_NAME}
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/project_1/add_bd_${BLOCK_NAME}.timestamp
    )

endfunction()

function(export_ip VENDOR LIBRARY_NAME RTL_PACKAGE_FLAG )

    set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/ip_repo")

    find_file(  HELPER_SCRIPT_EXPORT_IP
                NAME vivado_export_ip.tcl
                HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
                REQUIRED)

    #output filename
    set(IP_FILENAME "")
    list(APPEND IP_FILENAME ${VENDOR})
    list(APPEND IP_FILENAME ${LIBRARY_NAME})
    list(APPEND IP_FILENAME ${PROJECT_NAME})
    #list(APPEND IP_FILENAME ${PROJECT_VERSION})
    list(APPEND IP_FILENAME "1.0")
    string( REPLACE ";" "_" IP_FILENAME "${IP_FILENAME}" )
    set(IP_FILENAME "${IP_FILENAME}.zip")

    add_custom_command(
        OUTPUT ${OUT_DIR}/${IP_FILENAME}
        COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_EXPORT_IP} -tclargs
            ${PROJECT_NAME}
            ${VENDOR}
            #${PROJECT_VERSION}
            "1.0"
            ${OUT_DIR}
            ${RTL_PACKAGE_FLAG}
        )

    add_custom_target( ${PROJECT_NAME} ALL
        DEPENDS ${OUT_DIR}/${IP_FILENAME}
        )

    install(DIRECTORY ${OUT_DIR}
        DESTINATION ${PROJECT_NAME}
        PATTERN "*.zip" EXCLUDE
        PATTERN "*")
endfunction()
