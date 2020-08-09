#output directory
set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/solution1/impl/ip")

#output filename
set(IP_FILENAME "")
list(APPEND IP_FILENAME ${VENDOR})
list(APPEND IP_FILENAME ${LIBRARY_NAME})
list(APPEND IP_FILENAME ${PROJECT_NAME})
list(APPEND IP_FILENAME ${PROJECT_VERSION})
string( REPLACE ";" "_" IP_FILENAME "${IP_FILENAME}" )
string( REPLACE "." "_" IP_FILENAME "${IP_FILENAME}" )
set(IP_FILENAME "${IP_FILENAME}.zip")

add_custom_command(
    OUTPUT ${OUT_DIR}/${IP_FILENAME}
    COMMAND ${HLS_COMMAND} ${HELPER_SCRIPT_EXEC_VIVADO_HLS}
        ${PROJECT_NAME}
        ${TARGET_DEVICE}
        ${CLOCK_PERIOD}
        "{${SRC_FILES}}"
        "{cflags=${CFLAGS}}"
        "{${TESTBENCH_FILES}}"
        "{cflags_tb=${CFLAGS_TB}}"
        "{${DESCRIPTION}}"
        ${DISPLAY_IP_NAME}
        ${VENDOR}
        ${PROJECT_VERSION}
        ${DIRECTIVES}
        "export"
    )

add_custom_target( ${PROJECT_NAME} ALL
    DEPENDS ${OUT_DIR}/${IP_FILENAME}
    )

add_test(
    NAME ${PROJECT_NAME}
    COMMAND ${HLS_COMMAND} ${HELPER_SCRIPT_EXEC_VIVADO_HLS}
        ${PROJECT_NAME}
        ${TARGET_DEVICE}
        ${CLOCK_PERIOD}
        "{${SRC_FILES}}"
        "{cflags=${CFLAGS}}"
        "{${TESTBENCH_FILES}}"
        "{cflags_tb=${CFLAGS_TB}}"
        "{${DESCRIPTION}}"
        ${DISPLAY_IP_NAME}
        ${VENDOR}
        ${PROJECT_VERSION}
        ${DIRECTIVES}
        "csim"
    )


install(DIRECTORY ${OUT_DIR}
        DESTINATION ${PROJECT_NAME}
        PATTERN "*.zip" EXCLUDE
        PATTERN "*")
