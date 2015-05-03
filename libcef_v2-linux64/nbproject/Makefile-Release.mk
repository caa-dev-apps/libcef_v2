#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Environment
MKDIR=mkdir
CP=cp
GREP=grep
NM=nm
CCADMIN=CCadmin
RANLIB=ranlib
CC=gcc
CCC=g++
CXX=g++
FC=
AS=as

# Macros
CND_PLATFORM=GNU-Linux-x86
CND_CONF=Release
CND_DISTDIR=dist

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=build/${CND_CONF}/${CND_PLATFORM}

# Object Files
OBJECTFILES= \
	${OBJECTDIR}/_ext/812168374/CIterData.o \
	${OBJECTDIR}/_ext/812168374/CCaaTransform.o \
	${OBJECTDIR}/_ext/812168374/CUtils.o \
	${OBJECTDIR}/_ext/812168374/CCefInterpolator.o \
	${OBJECTDIR}/_ext/812168374/main.o \
	${OBJECTDIR}/_ext/812168374/CLog.o \
	${OBJECTDIR}/_ext/812168374/CIsoTime.o \
	${OBJECTDIR}/_ext/812168374/lua_c_utils.o \
	${OBJECTDIR}/_ext/812168374/lua_c_tests.o \
	${OBJECTDIR}/_ext/812168374/CCefRecordReader.o \
	${OBJECTDIR}/_ext/812168374/CInitData.o \
	${OBJECTDIR}/_ext/812168374/lua_c_funcs.o


# C Compiler Flags
CFLAGS=

# CC Compiler Flags
CCFLAGS=
CXXFLAGS=

# Fortran Compiler Flags
FFLAGS=

# Assembler Flags
ASFLAGS=

# Link Libraries and Options
LDLIBSOPTIONS=-dynamic ../../LuaJIT-2.0.0-beta8/dist-linux64/lib/libluajit.so

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-Release.mk dist/../../app/bin/libcef_v2.so

dist/../../app/bin/libcef_v2.so: ../../LuaJIT-2.0.0-beta8/dist-linux64/lib/libluajit.so

dist/../../app/bin/libcef_v2.so: ${OBJECTFILES}
	${MKDIR} -p dist/../../app/bin
	${LINK.cc} -shared -o ${CND_DISTDIR}/../../app/bin/libcef_v2.so -fPIC ${OBJECTFILES} ${LDLIBSOPTIONS} 

${OBJECTDIR}/_ext/812168374/CIterData.o: ../source/CIterData.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/CIterData.o ../source/CIterData.cpp

${OBJECTDIR}/_ext/812168374/CCaaTransform.o: ../source/CCaaTransform.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/CCaaTransform.o ../source/CCaaTransform.cpp

${OBJECTDIR}/_ext/812168374/CUtils.o: ../source/CUtils.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/CUtils.o ../source/CUtils.cpp

${OBJECTDIR}/_ext/812168374/CCefInterpolator.o: ../source/CCefInterpolator.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/CCefInterpolator.o ../source/CCefInterpolator.cpp

${OBJECTDIR}/_ext/812168374/main.o: ../source/main.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/main.o ../source/main.cpp

${OBJECTDIR}/_ext/812168374/CLog.o: ../source/CLog.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/CLog.o ../source/CLog.cpp

${OBJECTDIR}/_ext/812168374/CIsoTime.o: ../source/CIsoTime.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/CIsoTime.o ../source/CIsoTime.cpp

${OBJECTDIR}/_ext/812168374/lua_c_utils.o: ../source/lua_c_utils.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/lua_c_utils.o ../source/lua_c_utils.cpp

${OBJECTDIR}/_ext/812168374/lua_c_tests.o: ../source/lua_c_tests.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/lua_c_tests.o ../source/lua_c_tests.cpp

${OBJECTDIR}/_ext/812168374/CCefRecordReader.o: ../source/CCefRecordReader.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/CCefRecordReader.o ../source/CCefRecordReader.cpp

${OBJECTDIR}/_ext/812168374/CInitData.o: ../source/CInitData.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/CInitData.o ../source/CInitData.cpp

${OBJECTDIR}/_ext/812168374/lua_c_funcs.o: ../source/lua_c_funcs.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/812168374
	${RM} $@.d
	$(COMPILE.cc) -O2 -I../../LuaJIT-2.0.0-beta8/dist-linux64/include/luajit-2.0 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/812168374/lua_c_funcs.o ../source/lua_c_funcs.cpp

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/Release
	${RM} dist/../../app/bin/libcef_v2.so

# Subprojects
.clean-subprojects:

# Enable dependency checking
.dep.inc: .depcheck-impl

include .dep.inc