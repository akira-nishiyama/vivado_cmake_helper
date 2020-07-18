
function( add_sim SIM_TARGET DEPENDENCIES)
	add_custom_command(
	        OUTPUT ${SIMULATION_DIR}/work/xsim/compile_${SIM_TARGET}.sh
	        COMMAND ${VIVADO_COMMAND} -mode batch -source ${HELPER_SCRIPT_EXPORT_SIM} -tclargs
	                ${SIM_TARGET}
	                ${SIMULATION_DIR}
	        COMMAND ${CP} ${CP_OPTION} ${vivado_prj_name}/${vivado_prj_name}.sim/${simset_name}/behav/xsim ${SIMULATION_DIR}/work
	        COMMAND ${MV} ${SIMULATION_DIR}/work/xsim/compile.sh ${SIMULATION_DIR}/work/xsim/compile_${SIM_TARGET}.sh
	        COMMAND ${MV} ${SIMULATION_DIR}/work/xsim/elaborate.sh ${SIMULATION_DIR}/work/xsim/elaborate_${SIM_TARGET}.sh
	        COMMAND ${MV} ${SIMULATION_DIR}/work/xsim/simulate.sh ${SIMULATION_DIR}/work/xsim/simulate_${SIM_TARGET}.sh
	        )

	add_custom_command(
	        OUTPUT ${SIMULATION_DIR}/work/xsim/${SIM_TARGET}.wdb
	        COMMAND ./compile_${SIM_TARGET}.sh
	        COMMAND ./elaborate_${SIM_TARGET}.sh
	        COMMAND ./simulate_${SIM_TARGET}.sh
	        WORKING_DIRECTORY ${SIMULATION_DIR}/work/xsim
	        DEPENDS ${SIMULATION_DIR}/work/xsim/compile_${SIM_TARGET}.sh
	)
	add_custom_target( sim_${SIM_TARGET}
	        DEPENDS ${PROJECT_NAME} ${SIMULATION_DIR}/work/xsim/${SIM_TARGET}.wdb ${DEPENDENCIES}
	        )
endfunction()
