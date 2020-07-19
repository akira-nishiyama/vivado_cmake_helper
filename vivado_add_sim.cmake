#add_custom_target(compile_all)
#add_custom_target(elaborate_all)
#add_custom_target(sim_all)

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
		COMMAND ${SED} -e '0,/elaborate/ s/elaborate/\#elaborate/'   ${DESTINATION_DIR}/${SIM_TARGET}.sh | 
			${SED} -e '0,/simulate/  s/simulate/\#simulate/'   |
			${SED} -e 's/vhdl.prj/${SIM_TARGET}_vhdl.prj/'     |
			${SED} -e 's/vlog.prj/${SIM_TARGET}_vlog.prj/'     >
			${DESTINATION_DIR}/compile_${SIM_TARGET}.sh
		COMMAND ${SED} -e '0,/compile/  s/compile/\#compile/'       ${DESTINATION_DIR}/${SIM_TARGET}.sh | 
			${SED} -e '0,/simulate/  s/simulate/\#simulate/'   |
			${SED} -e 's/vhdl.prj/${SIM_TARGET}_vhdl.prj/'     |
			${SED} -e 's/vlog.prj/${SIM_TARGET}_vlog.prj/'     >
			${DESTINATION_DIR}/elaborate_${SIM_TARGET}.sh
		COMMAND ${SED} -e '0,/compile/   s/compile/\#compile/'       ${DESTINATION_DIR}/${SIM_TARGET}.sh | 
			${SED} -e '0,/elaborate/ s/elaborate/\#elaborate/' |
			${SED} -e 's/vhdl.prj/${SIM_TARGET}_vhdl.prj/'     |
			${SED} -e 's/vlog.prj/${SIM_TARGET}_vlog.prj/'     >
			${DESTINATION_DIR}/simulate_${SIM_TARGET}.sh
		COMMAND ${MV} ${DESTINATION_DIR}/vhdl.prj ${DESTINATION_DIR}/${SIM_TARGET}_vhdl.prj
		COMMAND ${MV} ${DESTINATION_DIR}/vlog.prj ${DESTINATION_DIR}/${SIM_TARGET}_vlog.prj
		COMMAND ${CP} ${CP_OPTION} ${DESTINATION_DIR}/* ${WORK_DIR}
	        )
	add_custom_target( compile_${SIM_TARGET}
		COMMAND source ./compile_${SIM_TARGET}.sh -noclean_files
		WORKING_DIRECTORY ${WORK_DIR}
		DEPENDS ${PROJECT_NAME} ${WORK_DIR}/compile_${SIM_TARGET}.sh ${DEPENDENCIES} ${COMP_PREV_TARGET}
	)
	add_dependencies(compile_all compile_${SIM_TARGET})
	add_custom_target( elaborate_${SIM_TARGET}
		COMMAND source ./elaborate_${SIM_TARGET}.sh -noclean_files
		WORKING_DIRECTORY ${WORK_DIR}
		DEPENDS ${PROJECT_NAME} ${WORK_DIR}/compile_${SIM_TARGET}.sh compile_${SIM_TARGET} ${DEPENDENCIES}
	)
	add_dependencies(elaborate_all elaborate_${SIM_TARGET})
	add_custom_command(
		OUTPUT ${WORK_DIR}/${SIM_TARGET}.wdb
		COMMAND source ./simulate_${SIM_TARGET}.sh -noclean_files
		WORKING_DIRECTORY ${WORK_DIR}
		DEPENDS ${PROJECT_NAME} ${WORK_DIR}/compile_${SIM_TARGET}.sh elaborate_${SIM_TARGET} ${DEPENDENCIES}
	)
	add_custom_target( simulate_${SIM_TARGET}
		DEPENDS ${PROJECT_NAME} ${WORK_DIR}/${SIM_TARGET}.wdb
	)
	add_dependencies(sim_all simulate_${SIM_TARGET})

endfunction()
