# vivado_cmake_helper Overview
Helper scripts for vivado and vivado_hls build with cmake.

# Tested Version
Vivado 2019.2
Vivado_HLS 2019.2
CMake 3.10.2

# Example
See [ICS_IF](https://github.com/akira-nishiyama/ICS_IF).
CMakeLists.txt example is stored in example folder.

# Setup
export VIVADO_CMAKE_HELPER environt variable that contain repository path.
Just run below script.
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
Add header path to CFLAS and CFLAGS_TESTBENCH as a LIST.  
Add sources to SRC_FILES and TESTBENCH_FILES as a LIST.  
LIST have to replace delimiter ";" to ":".(or tcl not works)
After that include vivado_hls_export.cmake.  
That add custom_command and custom_target for build.  
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
Create blockdesign.tcl through vivado command(write_bd_tcl).  
Be sure the design name is same as project_name  
(or modify blockdesign.tcl)  
Add rtl modules and testbenchs if necessary.  
After that include vivado_ipx_export.cmake.  
That add custom_command and custom_target for build.  
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

## nested project
nested project also works.
See [ICS_IF](https://github.com/akira-nishiyama/ICS_IF).
Add a cmake buildable project with add_subdirectory(modules).

# License
This software is released under the MIT License, see LICENSE.

