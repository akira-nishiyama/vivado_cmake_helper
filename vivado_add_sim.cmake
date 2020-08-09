function( add_sim SIM_TARGET SIMULATION_DIR DEPENDENCIES ADDITIONAL_VLOG_OPTS ADDITIONAL_ELAB_OPTS ADDITIONAL_XSIM_OPTS PREV_TARGET)
    set(WORK_DIR "${SIMULATION_DIR}/work/xsim")
    set(DESTINATION_DIR "${SIMULATION_DIR}/work/${SIM_TARGET}/xsim")
    if(PREV_TARGET)
        set(GEN_PREV_TARGET gen_${PREV_TARGET})
        set(COMP_PREV_TARGET compile_${PREV_TARGET})
    else()
        set(GEN_PRE_TARGET "")
        set(COMP_PREV_TARGET "")
    endif()
    string(REPLACE "/" "\\/" ADDITIONAL_VLOG_OPTS_ "${ADDITIONAL_VLOG_OPTS}")
    string(REPLACE "/" "\\/" ADDITIONAL_ELAB_OPTS_ "${ADDITIONAL_ELAB_OPTS}")
    string(REPLACE "/" "\\/" ADDITIONAL_XSIM_OPTS_ "${ADDITIONAL_XSIM_OPTS}")

    find_file(  HELPER_SCRIPT_EXPORT_SIM
                NAME vivado_export_sim.tcl
                HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
                REQUIRED)

    find_file(  HELPER_SCRIPT_OPEN_WDB
                NAME vivado_open_wdb.tcl
                HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
                REQUIRED)

    add_custom_command(
        OUTPUT ${WORK_DIR}/compile_${SIM_TARGET}.sh
               ${WORK_DIR}/elaborate_${SIM_TARGET}.sh
               ${WORK_DIR}/simulate_${SIM_TARGET}.sh
        COMMAND ${CMAKE_COMMAND} -E make_directory ${DESTINATION_DIR}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${WORK_DIR}
        COMMAND ${CMAKE_COMMAND} -E touch ${DESTINATION_DIR}/vhdl.prj
        COMMAND ${CMAKE_COMMAND} -E touch ${DESTINATION_DIR}/vlog.prj
        COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_EXPORT_SIM} -tclargs
                ${SIM_TARGET}
                ${SIMULATION_DIR}
        COMMAND ${SED} -e 's/vhdl.prj/${SIM_TARGET}_vhdl.prj/' ${DESTINATION_DIR}/${SIM_TARGET}.sh              |
                ${SED} -e 's/vlog.prj/${SIM_TARGET}_vlog.prj/'                                                  |
                ${SED} -e 's/compile.log/${SIM_TARGET}_compile.log/'                                            |
                ${SED} -e 's/elaborate.log/${SIM_TARGET}_elaborate.log/'                                        |
                ${SED} -e 's/simulate.log/${SIM_TARGET}_simulate.log/'                                          |
                ${SED} -e 's/xvlog_opts=\"--relax/xvlog_opts=\"--relax ${ADDITIONAL_VLOG_OPTS_}/'                |
                ${SED} -e 's/xelab --relax/xelab --relax ${ADDITIONAL_ELAB_OPTS_}/'                              |
                ${SED} -e 's/xsim ${SIM_TARGET}/xsim ${SIM_TARGET} ${ADDITIONAL_XSIM_OPTS_}/'                    >
                ${DESTINATION_DIR}/${SIM_TARGET}.sh.tmp
        COMMAND ${SED} -i -e '10alog_wave -r /' ${DESTINATION_DIR}/cmd.tcl
        COMMAND ${SED} -e '0,/elaborate/ s/elaborate/\#elaborate/'   ${DESTINATION_DIR}/${SIM_TARGET}.sh.tmp | 
                ${SED} -e '0,/simulate/  s/simulate/\#simulate/'   >
                ${DESTINATION_DIR}/compile_${SIM_TARGET}.sh
        COMMAND ${SED} -e '0,/compile/  s/compile/\#compile/'       ${DESTINATION_DIR}/${SIM_TARGET}.sh.tmp  | 
                ${SED} -e '0,/simulate/  s/simulate/\#simulate/'   >
                ${DESTINATION_DIR}/elaborate_${SIM_TARGET}.sh
        COMMAND ${SED} -e '0,/compile/   s/compile/\#compile/'       ${DESTINATION_DIR}/${SIM_TARGET}.sh.tmp | 
                ${SED} -e '0,/elaborate/ s/elaborate/\#elaborate/' >
                ${DESTINATION_DIR}/simulate_${SIM_TARGET}.sh
        COMMAND chmod +x ${DESTINATION_DIR}/compile_${SIM_TARGET}.sh
        COMMAND chmod +x ${DESTINATION_DIR}/elaborate_${SIM_TARGET}.sh
        COMMAND chmod +x ${DESTINATION_DIR}/simulate_${SIM_TARGET}.sh
        COMMAND ${CMAKE_COMMAND} -E copy ${DESTINATION_DIR}/vhdl.prj ${DESTINATION_DIR}/${SIM_TARGET}_vhdl.prj #rename is bad for make with multiprocess
        COMMAND ${CMAKE_COMMAND} -E copy ${DESTINATION_DIR}/vlog.prj ${DESTINATION_DIR}/${SIM_TARGET}_vlog.prj #rename is bad for make with multiprocess
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${DESTINATION_DIR} ${WORK_DIR}
        DEPENDS ${PROJECT_NAME} ${DEPENDENCIES} ${GEN_PREV_TARGET}
            )
    add_custom_target( gen_${SIM_TARGET}
        DEPENDS ${WORK_DIR}/compile_${SIM_TARGET}.sh ${WORK_DIR}/elaborate_${SIM_TARGET}.sh ${WORK_DIR}/simulate_${SIM_TARGET}.sh
    )
    add_dependencies( gen_all gen_${SIM_TARGET})
    add_custom_command(
        OUTPUT ${WORK_DIR}/compile_${SIM_TARGET}.timestamp
        COMMAND source ./compile_${SIM_TARGET}.sh -noclean_files
        COMMAND ${CMAKE_COMMAND} -E touch compile_${SIM_TARGET}.timestamp
        WORKING_DIRECTORY ${WORK_DIR}
        DEPENDS ${PROJECT_NAME} ${WORK_DIR}/compile_${SIM_TARGET}.sh ${DEPENDENCIES} ${COMP_PREV_TARGET}
    )
    add_custom_target( compile_${SIM_TARGET}
        DEPENDS ${PROJECT_NAME} ${WORK_DIR}/compile_${SIM_TARGET}.timestamp
    )
    add_dependencies(compile_all compile_${SIM_TARGET})
    add_custom_command(
        OUTPUT ${WORK_DIR}/elaborate_${SIM_TARGET}.timestamp
        COMMAND source ./elaborate_${SIM_TARGET}.sh -noclean_files
        COMMAND ${CMAKE_COMMAND} -E touch elaborate_${SIM_TARGET}.timestamp
        WORKING_DIRECTORY ${WORK_DIR}
        DEPENDS ${PROJECT_NAME} ${WORK_DIR}/compile_${SIM_TARGET}.sh ${WORK_DIR}/compile_${SIM_TARGET}.timestamp ${DEPENDENCIES}
    )
    add_custom_target( elaborate_${SIM_TARGET}
        DEPENDS ${PROJECT_NAME} ${WORK_DIR}/elaborate_${SIM_TARGET}.timestamp
    )
    add_dependencies(elaborate_all elaborate_${SIM_TARGET})
    add_custom_command(
        OUTPUT ${WORK_DIR}/${SIM_TARGET}.wdb
        COMMAND source ./simulate_${SIM_TARGET}.sh -noclean_files
        WORKING_DIRECTORY ${WORK_DIR}
        DEPENDS ${PROJECT_NAME} ${WORK_DIR}/compile_${SIM_TARGET}.sh ${WORK_DIR}/elaborate_${SIM_TARGET}.timestamp ${DEPENDENCIES}
    )
    add_custom_target( simulate_${SIM_TARGET}
        DEPENDS ${PROJECT_NAME} ${WORK_DIR}/${SIM_TARGET}.wdb
    )
    add_dependencies(sim_all simulate_${SIM_TARGET})
    add_custom_target(
        open_wdb_${SIM_TARGET}
        COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_OPEN_WDB} -tclargs ${WORK_DIR}/${SIM_TARGET}.wdb
        DEPENDS ${WORK_DIR}/${SIM_TARGET}.wdb
    )
    add_test(
        NAME simulate_${SIM_TARGET}.sh
        COMMAND "simulate_${SIM_TARGET}.sh" "-noclean_files"
        WORKING_DIRECTORY ${WORK_DIR}
    )
    set_tests_properties(
        simulate_${SIM_TARGET}.sh PROPERTIES 
        DEPENDS ${PROJECT_NAME} ${WORK_DIR}/compile_${SIM_TARGET}.sh ${WORK_DIR}/elaborate_${SIM_TARGET}.timestamp
        FAIL_REGULAR_EXPRESSION "UVM_FATAL : *[1-9];UVM_ERROR : *[1-9]"
    )
endfunction()

