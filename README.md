# vivado_cmake_helper Overview
Helper scripts for vivado and vivado_hls build with cmake.
This scripts contains below two cmake packages.
- vivado_cmake_helper:for vivado ip export.
- vivado_hls_cmake_helper:for vivado hls export.

# Tested Version
Ubuntu 18.04
Vivado 2019.2
Vivado_HLS 2019.2
CMake 3.10.2

# Example
See [ICS_IF](https://github.com/akira-nishiyama/ICS_IF).
CMakeLists.txt example is stored in example folder.

# Setup
export VIVADO_CMAKE_HELPER environt variable that contain repository path.
Just run below script.(or you can run cmake with -Dvivado_cmake_helper_DIR/-Dvivado_hls_cmake_helper_DIR=\<path_to_repository\> option)
```bash
source <path-to-repository>/setup.sh
```

# Usage
## vivado_hls
### Directory structure
Example assumes below directory structure.
```
project_top
├── CMakeLists.txt:See CMakeLists.txt.hls_example
├── directives.tcl
├── include:place headers
├── src:place sources
└── test:place test codes
    ├── include:place test headers
    └── src:place test sources
```

### Create CmakeLists.txt
see example/CMakeLists.txt.hls_example
Find vivado_hls_cmake_helper package via find_package() for build and simulation.
If you use ctest, call enable_testing().  
Project name is assumed top_function and the name is used for build_target.
Add header path to CFLAS and CFLAGS_TESTBENCH as a LIST.  
Add sources to SRC_FILES and TESTBENCH_FILES as a LIST.  
The LIST have to replace delimiter ";" to ":".(or tcl not works)
After that include vivado_hls_export.cmake.  
That add custom_command and custom_target for build.(build target name is same as project name)  
That add add_test for csimulation. Cosim is not supported.(test target is same as project name)
That also setup installation. Copy ip folder to CMAKE_INSTALL_PREFIX/${project_name} except archived zip.

### Install
Installation is done with the following commands.
```bash
source <path_to_vivado>/setup.sh
source <path_to_this_repository>/setup.sh
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=<path_to_user_ip_repository>
cmake --build .
make install
```

### Test
just run ctest in build directory.
```bash
ctest
```

## vivado ip packager(ipx)
### Directory structure
Example assumes below directory structure.
```
project_top
├── CMakeLists.txt
├── scripts
│   └── blockdesign.tcl
├── src
│   └── interval_timer.v
└── test
    └── src
        └── tb_interval_timer.v
```

### Create CmakeLists.txt
see example/CMakeLists.txt.ipx_example
Find vivado_cmake_helper package for build and simulation.
Create blockdesign.tcl through vivado command(write_bd_tcl).  
Be sure the design name(export target) is same as project_name  
(or modify blockdesign.tcl)  
Find vivado_cmake_helper package via find_package() for build and simulation.
If you use ctest, call enable_testing().  
Add rtl modules and testbenchs if necessary.  
To export ip do the following function.(defined in vivado_ipx_export.cmake)
+ project_generation(PROJECT_NAME VENDOR LIBRARY_NAME TARGET_DEVICE SRC_FILES TESTBENCH_FILES IP_REPO_PATH)
  this function add_custom_target prj_gen_\${PROJECT_NAME}.
  this target is used for vivado project generation(this helper script use vivado project to generate compile order, include libraries, export ip)
  + arg0:export ip name.(assume project name)
  + arg1:vendor name.
  + arg2:library name.(user might less problem)
  + arg3:target deivce.
  + arg4:source file list. Enclose with double quatation to pass list variable.
  + arg5:simulation file list. Enclose with double quatation to pass list variable.
  + arg6:ip repository path list. Enclose with double quatation to pass list variable.
+ project_add_bd(BLOCK_NAME BLOCK_DESIGN_TCL DEPENDENCIES)
  use this function if block design is necessary.
  this function add block design to the vivado project.(other tcl code might work.)
  add_custom_target add_bd_\${BLOCK_NAME}
  + arg0:\${BLOCK_NAME} is used for target name.
  + arg1:block design tcl path. this is created through vivado command(write_bd_tcl)
  + arg2:dependencies for add_bd_\${BLOCK_NAME} target.Enclose with double quatation to pass list variable.
+ export_ip(VENDOR LIBRARY_NAME RTL_PACKAGE_FLAG)
  add_custom_target \${PROJECT_NAME} and add it to ALL target for build.
  export target name(blockdesign name or rtl module name) should be same as project_name
  export_ip also setup installation. Copy ip folder to CMAKE_INSTALL_PREFIX/\${project_name} except archived zip.
  + arg0:vendor name.
  + arg1:library name.(user might less problem)
  + arg2:rtl package flag. 0 is for block design ip export, 1 is for rtl design ip export.  

To setup simulation, use add_sim function.
+ add_sim(SIM_TARGET SIMULATION_DIR DEPENDENCIES ADDITIONAL_VLOG_OPTS ADDITIONAL_ELAB_OPTS ADDITIONAL_XSIM_OPTS PREV_TARGET)
  add_custom_targets  [gen_\${SIM_TARGET},compile_\${SIM_TARGET},elaborate_\${SIM_TARGET},simulate_\${SIM_TARGET},open_wdb_\${SIM_TARGET}]
  the targets are add to compile_all, elaborate_all and simulate_all.
  This function also setup ctest.
  Add the test name with simulate_\${SIM_TARGET}.ctest.
  The test will fail if UVM_FATAL or UVM_ERROR message asserted.
  + arg0:simulation target module name.
  + arg1:simulation workspace.
  + arg2:dependencies for simulation.
  + arg3:additional verilog compilation options. Set user include directory here.
  + arg4:additional elaboration options.
  + arg5:additional xsim options. UVM_TESTNAME will be set here if needed.
  + arg6:used for define compilation order.(because vivado could compile only one process. Unset is also ok if you build project with single process,see below)

  ```bash
  make -j4 && make compile_all -j1 && make_elaborate_all -j4 && ctest
  ```  


### Install
Installation is done with the following commands.
```bash
source <path_to_vivado>/setup.sh
source <path_to_this_repository>/setup.sh
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=<path_to_user_ip_repository>
cmake --build .
make install
```

### Test
run elaborate_all before run ctest in build directory.
```bash
make elaborate_all
ctest
```

### OpenWDB
run open_wdb_\${SIM_TARGET} target in build directory.
```bash
make open_wdb_\${SIM_TARGET}
```
## nested project
nested project also works.
See [ICS_IF](https://github.com/akira-nishiyama/ICS_IF).
Add a cmake buildable project with add_subdirectory(modules).
Or use find_package() with xxx-config.cmake, findxxx.cmake.

# License
This software is released under the MIT License, see LICENSE.
