


PROJECT(lua_posix)


INCLUDE_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}/src
	${lua_include_dir}
)


LINK_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}
)


SET(lua_posix_src_sources


lposix.c

)



SET(lua_posix_sources ${lua_posix_src_sources} )

IF(WIN32)

	IF(BUILD_SHARED_LIBS)

		ADD_DEFINITIONS("-DLUAPOSIX_API=__declspec(dllexport)")

	ENDIF(BUILD_SHARED_LIBS)
	
ENDIF(WIN32)



SOURCE_GROUP(src FILES ${lua_posix_src_sources} )




IF(BUILD_SHARED_LIBS)

	ADD_LIBRARY(posix_core SHARED ${lua_posix_sources} )
	
ELSE(BUILD_SHARED_LIBS)

	ADD_LIBRARY(posix_core STATIC ${lua_posix_sources} )

ENDIF(BUILD_SHARED_LIBS)





TARGET_LINK_LIBRARIES(posix_core

	lua5.1
	crypt
)

IF(WIN32)

	ADD_CUSTOM_COMMAND( TARGET posix_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/posix_core.dll
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/posix.dll
	)

	ADD_CUSTOM_COMMAND( TARGET posix_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/posix_core.pdb
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/posix.pdb
	)

ELSE(WIN32)

	ADD_CUSTOM_COMMAND( TARGET posix_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/libposix_core.so
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/posix.so
	)


ENDIF(WIN32)
