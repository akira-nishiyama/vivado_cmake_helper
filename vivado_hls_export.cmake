#output directory
set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/solution1/impl/ip")

#output filename
set(IP_FILENAME "")
list(APPEND IP_FILENAME ${VENDOR})
list(APPEND IP_FILENAME ${LIBRARY_NAME})
list(APPEND IP_FILENAME ${PROJECT_NAME})
list(APPEND IP_FILENAME ${PROJECT_VERSION})
string(REPLACE ";" ":" CFLAGS_V "${CFLAGS}")
string(REPLACE ";" ":" CFLAGS_TB_V "${CFLAGS_TB}")
string(REPLACE " " ":" DESCRIPTION_V "${DESCRIPTION}")
string(REPLACE ";" ":" SRC_FILES_V "${SRC_FILES}")
string(REPLACE ";" ":" TESTBENCH_FILES_V "${TESTBENCH_FILES}")
string(REPLACE ";" ":" LDFLAGS_V "${LDFLAGS}")
string( REPLACE ";" "_" IP_FILENAME "${IP_FILENAME}" )
string( REPLACE "." "_" IP_FILENAME "${IP_FILENAME}" )
set(IP_FILENAME "${IP_FILENAME}.zip")

add_custom_command(
    OUTPUT ${OUT_DIR}/${IP_FILENAME}
    COMMAND ${HLS_COMMAND} ${HELPER_SCRIPT_EXEC_VIVADO_HLS}
        ${PROJECT_NAME}
        ${TARGET_DEVICE}
        ${CLOCK_PERIOD}
        "{${SRC_FILES_V}}"
        "{cflags=${CFLAGS_V}}"
        "{${TESTBENCH_FILES_V}}"
        "{cflags_tb=${CFLAGS_TB_V}}"
        "{${DESCRIPTION_V}}"
        ${DISPLAY_IP_NAME}
        ${VENDOR}
        ${PROJECT_VERSION}
        ${DIRECTIVES}
        "export"
    DEPENDS ${SRC_FILES}
    )

add_custom_target( ${PROJECT_NAME} ALL
    DEPENDS ${OUT_DIR}/${IP_FILENAME}
    )

add_custom_command(
    OUTPUT simulate_${PROJECT_NAME}.timestamp
    COMMAND ${HLS_COMMAND} ${HELPER_SCRIPT_EXEC_VIVADO_HLS}
        ${PROJECT_NAME}
        ${TARGET_DEVICE}
        ${CLOCK_PERIOD}
        "{${SRC_FILES_V}}"
        "{cflags=${CFLAGS_V}}"
        "{${TESTBENCH_FILES_V}}"
        "{cflags_tb=${CFLAGS_TB_V}}"
        "{${DESCRIPTION_V}}"
        ${DISPLAY_IP_NAME}
        ${VENDOR}
        ${PROJECT_VERSION}
        ${DIRECTIVES}
        "csim"
        "ldflags={${LDFLAGS_V}}"
    COMMAND ${CMAKE_COMMAND} -E touch simulate_${PROJECT_NAME}.timestamp
    DEPENDS ${SRC_FILES} ${TESTBENCH_FILES}
    )

add_custom_target( simulate_${PROJECT_NAME}
    DEPENDS simulate_${PROJECT_NAME}.timestamp
    )

add_test(
    NAME simulate_${PROJECT_NAME}.ctest
    COMMAND ${HLS_COMMAND} ${HELPER_SCRIPT_EXEC_VIVADO_HLS}
        ${PROJECT_NAME}
        ${TARGET_DEVICE}
        ${CLOCK_PERIOD}
        "{${SRC_FILES_V}}"
        "{cflags=${CFLAGS_V}}"
        "{${TESTBENCH_FILES_V}}"
        "{cflags_tb=${CFLAGS_TB_V}}"
        "{${DESCRIPTION_V}}"
        ${DISPLAY_IP_NAME}
        ${VENDOR}
        ${PROJECT_VERSION}
        ${DIRECTIVES}
        "csim"
        "ldflags={${LDFLAGS_V}}"
    )

set_tests_properties(
    simulate_${PROJECT_NAME}.ctest PROPERTIES
    FAIL_REGULAR_EXPRESSION "Failed"
)


install(DIRECTORY ${OUT_DIR}
        DESTINATION ${PROJECT_NAME}
        PATTERN "*.zip" EXCLUDE
        PATTERN "*")
