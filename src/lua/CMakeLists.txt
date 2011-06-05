
PROJECT(lua)


INCLUDE_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/src
	${CMAKE_CURRENT_SOURCE_DIR}/include
	${ALL_INC}
)

LINK_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}
	${ALL_LIB}
)


SET(lua_exe_SRCS

src/lua.c
src/print.c
src/lopcodes.h
src/lopcodes.c
)

SET(luac_exe_SRCS

src/luac.c
src/print.c
src/lopcodes.h
src/lopcodes.c
)


SET(lua_src_SRCS


src/lapi.h
src/lcode.h
src/ldebug.h
src/ldo.h
src/lfunc.h
src/lgc.h
src/llex.h
src/lmem.h
src/lobject.h
src/lopcodes.h
src/lparser.h
src/lstate.h
src/lstring.h
src/ltable.h
src/ltm.h
src/lundump.h
src/lvm.h
src/lzio.h

src/lapi.c
src/lcode.c
src/ldebug.c
src/ldo.c
src/ldump.c
src/lfunc.c
src/lgc.c
src/llex.c
src/lmem.c
src/lobject.c
src/lopcodes.c
src/lparser.c
src/lstate.c
src/lstring.c
src/ltable.c
src/ltm.c
src/lundump.c
src/lvm.c
src/lzio.c

)

SET(lua_srclib_SRCS

src/lauxlib.c
src/lbaselib.c
src/ldblib.c
src/liolib.c
src/lmathlib.c
src/loslib.c
src/ltablib.c
src/lstrlib.c
src/loadlib.c
src/linit.c

)

SET(lua_inc_SRCS

src/lua.h
src/luaconf.h
src/lualib.h
src/lauxlib.h

)

SET(lua_SRCS ${lua_src_SRCS} ${lua_srclib_SRCS} ${lua_inc_SRCS} )

SOURCE_GROUP(code/src FILES ${lua_src_SRCS} )
SOURCE_GROUP(code/lib FILES ${lua_srclib_SRCS} )
SOURCE_GROUP(code/inc FILES ${lua_inc_SRCS} )


IF(WIN32)

	IF(BUILD_SHARED_LIBS)

		ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)

	ENDIF(BUILD_SHARED_LIBS)
	
ELSE(WIN32)

	IF(BUILD_SHARED_LIBS)

		ADD_DEFINITIONS(-DLUA_USE_POSIX)
		ADD_DEFINITIONS(-DLUA_USE_DLOPEN)

	ENDIF(BUILD_SHARED_LIBS)
	
ENDIF(WIN32)


IF(BUILD_SHARED_LIBS)

	ADD_LIBRARY(lua5.1 SHARED ${lua_SRCS})
	
ELSE(BUILD_SHARED_LIBS)

	ADD_LIBRARY(lua5.1 STATIC ${lua_SRCS})

ENDIF(BUILD_SHARED_LIBS)



ADD_EXECUTABLE(lua ${lua_exe_SRCS} )
TARGET_LINK_LIBRARIES(lua

	lua5.1
)

#ADD_EXECUTABLE(luac ${luac_exe_SRCS} )
#TARGET_LINK_LIBRARIES(luac
#	lua5.1
#	m
#	dl
#)


IF(WIN32)

	ADD_CUSTOM_COMMAND( TARGET lua5.1 POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lua5.1.dll
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/bin/lua5.1.dll
	)

	ADD_CUSTOM_COMMAND( TARGET lua5.1 POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lua5.1.pdb
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/bin/lua5.1.pdb
	)
	
ELSE(WIN32)

TARGET_LINK_LIBRARIES(lua

	m
	dl
)

	ADD_CUSTOM_COMMAND( TARGET lua5.1 POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/liblua5.1.so
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/bin/lua5.1.so
	)

	ADD_CUSTOM_COMMAND( TARGET lua POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lua
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/bin/lua
	)
	ADD_CUSTOM_COMMAND( TARGET luac POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/luac
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/bin/luac
	)
ENDIF(WIN32)
