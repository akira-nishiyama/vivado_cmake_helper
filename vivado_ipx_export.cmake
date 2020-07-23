set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/ip_repo")

#output filename
set(IP_FILENAME "")
list(APPEND IP_FILENAME ${VENDOR})
list(APPEND IP_FILENAME ${LIBRARY_NAME})
list(APPEND IP_FILENAME ${PROJECT_NAME})
list(APPEND IP_FILENAME ${PROJECT_VERSION})
string( REPLACE ";" "_" IP_FILENAME "${IP_FILENAME}" )
#string( REPLACE "." "_" IP_FILENAME "${IP_FILENAME}" )
set(IP_FILENAME "${IP_FILENAME}.zip")

add_custom_command(
    OUTPUT ${OUT_DIR}/${IP_FILENAME}
    COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_IPX} -tclargs
        ${PROJECT_NAME}
        ${TARGET_DEVICE}
        "{${SRC_FILES}}"
        "{${TESTBENCH_FILES}}"
        ${VENDOR}
        ${PROJECT_VERSION}
        "{${IP_REPO_PATH}}"
        ${OUT_DIR}
        ${BLOCK_DESIGN_TCL}
        ${HELPER_SCRIPT_PRJ_GEN}
    )

add_custom_target( ${PROJECT_NAME} ALL
    DEPENDS ${OUT_DIR}/${IP_FILENAME}
    )

install(DIRECTORY ${OUT_DIR}
    DESTINATION ${PROJECT_NAME}
    PATTERN "*.zip" EXCLUDE
    PATTERN "*")

