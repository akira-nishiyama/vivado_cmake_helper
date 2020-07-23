function( add_sim SIM_TARGET SIMULATION_DIR DEPENDENCIES PREV_TARGET)
    set(WORK_DIR "${SIMULATION_DIR}/work/xsim")
    set(DESTINATION_DIR "${SIMULATION_DIR}/work/${SIM_TARGET}/xsim")
    if(PREV_TARGET)
        set(COMP_PREV_TARGET compile_${PREV_TARGET})
    else()
        set(COMP_PREV_TARGET "")
    endif()
    file(MAKE_DIRECTORY ${DESTINATION_DIR})
    file(WRITE ${DESTINATION_DIR}/vhdl.prj)
    file(WRITE ${DESTINATION_DIR}/vlog.prj)
    add_custom_command(
        OUTPUT ${WORK_DIR}/compile_${SIM_TARGET}.sh
               ${WORK_DIR}/elaborate_${SIM_TARGET}.sh
               ${WORK_DIR}/simulate_${SIM_TARGET}.sh
        COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_EXPORT_SIM} -tclargs
                ${SIM_TARGET}
                ${SIMULATION_DIR}
        COMMAND ${SED} -e 's/vhdl.prj/${SIM_TARGET}_vhdl.prj/' ${DESTINATION_DIR}/${SIM_TARGET}.sh              |
                ${SED} -e 's/vlog.prj/${SIM_TARGET}_vlog.prj/'                                                  |
                ${SED} -e 's/compile.log/${SIM_TARGET}_compile.log/'                                            |
                ${SED} -e 's/elaborate.log/${SIM_TARGET}_elaborate.log/'                                        |
                ${SED} -e 's/simulate.log/${SIM_TARGET}_simulate.log/'                                          |
                ${SED} -e 's/xvlog_opts=\"--relax/xvlog_opts=\"--relax -L uvm/'                                 |
                ${SED} -e 's/xelab --relax/xelab --relax -L uvm/'                                               >
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
        COMMAND ${MV} ${DESTINATION_DIR}/vhdl.prj ${DESTINATION_DIR}/${SIM_TARGET}_vhdl.prj
        COMMAND ${MV} ${DESTINATION_DIR}/vlog.prj ${DESTINATION_DIR}/${SIM_TARGET}_vlog.prj
        COMMAND ${CP} ${CP_OPTION} ${DESTINATION_DIR}/* ${WORK_DIR}
            )
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
        open_${SIM_TARGET}
        COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_OPEN_WDB} -tclargs ${WORK_DIR}/${SIM_TARGET}.wdb
        DEPENDS ${WORK_DIR}/${SIM_TARGET}.wdb
    )

endfunction()

function( add_bd BLOCK_DESIGN_TCL)
    add_custom_command(
        OUTPUT import_${BLOCK_DESIGN_TCL}.timestamp
        COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_IMPORT_BD} -tclargs ${BLOCK_DESIGN_TCL}
        COMMAND ${CMAKE_COMMAND} -E touch import_${BLOCK_DESIGN_TCL}.timestamp
        )
    add_custom_target( import_bd_sim_ics_if
        DEPENDS ${PROJECT_NAME} import_${BLOCK_DESIGN_TCL}.timestamp
        )
endfunction()
