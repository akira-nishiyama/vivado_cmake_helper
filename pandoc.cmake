
if(DEFINED DOC_GEN)

    message("document generation enabled")
    add_custom_target(docs)

    find_program(   PANDOC_COMMAND
                    NAME pandoc
                    HINTS ENV var
                    REQUIRED)

    find_program(   PYTHON3
                    NAME python3
                    HINTS ENV var
                    )

    find_program(   INKSCAPE
                    NAME inkscake
                    HINTS ENV var
                    )

    find_file(  PLANTUML
                NAME plantuml.jar
                HINTS ENV var $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_SOURCE_DIR}
                REQUIRED)

    find_file(  PLANTUML_FILTER
                NAME plantuml.py
                HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
                REQUIRED)

    find_file(  WAVEDROM_FILTER
                NAME wavedrom.py
                HINTS $ENV{VIVADO_CMAKE_HELPER} ${CMAKE_CURRENT_LIST_DIR}
                REQUIRED)

    function (add_pandoc targetname SRC)

        set(OUTDIR "${CMAKE_CURRENT_BINARY_DIR}/docs")

        add_custom_command(
            OUTPUT ${OUTDIR}/${targetname}.html
            COMMAND ${PANDOC_COMMAND} ${SRC} -t json |
                    ${PYTHON3} ${PLANTUML_FILTER} ${PLANTUML} |
                    ${PYTHON3} ${WAVEDROM_FILTER} |
                    ${PANDOC_COMMAND} -f json -t html -o ${OUTDIR}/${targetname}.html
            WORKING_DIRECTORY ${OUTDIR}
            DEPENDS ${SRC}
        )

        add_custom_target( pandoc_${targetname}
            DEPENDS ${OUTDIR}/${targetname}.html
        )

        add_dependencies(docs
            pandoc_${targetname}
        )
    endfunction()

else()
    message("document generation disabled")

    function(add_pandoc targetname SRC)
    endfunction()

endif()
