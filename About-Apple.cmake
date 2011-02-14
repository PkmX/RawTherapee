# this will generate a target that will never exist, so it will (should) be executed on each build
#WARNING: Actually, only Gcc is supported

string (TOUPPER ${CMAKE_BUILD_TYPE} UPPER_CMAKE_BUILD_TYPE)

# wee look for the hg command in this paths by order of preference
find_file(HG_CMD hg PATHS "/opt/local/bin" "/usr/local/bin" "/usr/bin")
find_file(HG_CMD hg)

if (HG_CMD STREQUAL HG_CMD-NOTFOUND)
	message(FATAL_ERROR "hg command not found!")
else (HG_CMD STREQUAL HG_CMD-NOTFOUND)
	message(STATUS "hg command found: ${HG_CMD}")
endif (HG_CMD STREQUAL HG_CMD-NOTFOUND)

set (OUT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/AboutThisBuild.txt")
set (VERSION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/rtgui/version.h")
set (SHELL "/bin/bash")

# if AboutThisBuild.txt has to be deleted, i guess that it's also the case for version.txt...
add_custom_target (AboutFile ALL
	COMMAND rm -f ${OUT_FILE}
	COMMAND rm -f ${VERSION_FILE}
	COMMAND for i in \$\( ${HG_CMD} -R \"${CMAKE_CURRENT_SOURCE_DIR}\" branch \)\; do echo Branch: $i >${OUT_FILE}\; done
	COMMAND ${HG_CMD} -R \"${CMAKE_CURRENT_SOURCE_DIR}\" parents --template=\"Version: {latesttag}.{latesttagdistance}\\nChangset: {node|short}\\n\" >>${OUT_FILE}
	COMMAND for i in \$\( gcc -dumpversion \) \;do echo Compiler: GCC $i >>${OUT_FILE} \; done
	COMMAND echo Processor: ${PROC_LABEL} >>${OUT_FILE}
	COMMAND echo Bit depth: ${PROC_BIT_DEPTH} >>${OUT_FILE}
	COMMAND echo Gtkmm: V${GTKMM_VERSION} >>${OUT_FILE}
	COMMAND echo Build type: ${CMAKE_BUILD_TYPE} >>${OUT_FILE}
	COMMAND echo Build flags: ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${UPPER_CMAKE_BUILD_TYPE}} >>${OUT_FILE}
	COMMAND echo Link flags: ${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_${UPPER_CMAKE_BUILD_TYPE}}  >>${OUT_FILE}
	COMMAND if [ \"${OPTION_OMP}\" = \"ON\" ] \; then echo OpenMP support: Yes >>${OUT_FILE} \;else echo OpenMP support: No >>${OUT_FILE} \;fi
	COMMAND if [ \"${WITH_MYFILE_MMAP}\" = \"ON\" ] \; then echo MMAP support: Yes >>${OUT_FILE} \; else echo MMAP support: No >>${OUT_FILE} \;fi
	COMMAND if [ \"${WITH_RAWZOR}\" = \"ON\" ] \; then echo Rawzor support: Yes >>${OUT_FILE} \;else  echo Rawzor support: No >>${OUT_FILE} \;fi
	COMMAND ${HG_CMD} -R \"${CMAKE_CURRENT_SOURCE_DIR}\" parents --template=\"// This file is automatically generated by the Makefile \; DO NOT EDIT!\\n// You can \(should\) also tell mercurial to ignore it.\\n\\n\#ifndef _VERSION_\\n\#define _VERSION_\\n\\n\#define VERSION \\"{latesttag}.{latesttagdistance}\\"\\n\#define TAGDISTANCE {latesttagdistance}\\n\\n\#endif\\n\" >${VERSION_FILE}
	COMMENT "Creating the about file"
)
