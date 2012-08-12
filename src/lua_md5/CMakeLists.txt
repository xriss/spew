


PROJECT(lua_md5)


INCLUDE_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}/src
	${lua_include_dir}
)


LINK_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}
)


SET(lua_md5_src_sources


src/md5.c
src/md5.h

src/md5lib.c

)



SET(lua_md5_sources ${lua_md5_src_sources} )

IF(WIN32)

	IF(BUILD_SHARED_LIBS)

		ADD_DEFINITIONS("-DLUAMD5_API=__declspec(dllexport)")

	ENDIF(BUILD_SHARED_LIBS)
	
ENDIF(WIN32)



SOURCE_GROUP(src FILES ${lua_md5_src_sources} )




IF(BUILD_SHARED_LIBS)

	ADD_LIBRARY(md5_core SHARED ${lua_md5_sources} )
	
ELSE(BUILD_SHARED_LIBS)

	ADD_LIBRARY(md5_core STATIC ${lua_md5_sources} )

ENDIF(BUILD_SHARED_LIBS)





TARGET_LINK_LIBRARIES(md5_core

	lua5.1
)

IF(WIN32)

	ADD_CUSTOM_COMMAND( TARGET md5_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/md5_core.dll
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/md5/core.dll
	)

	ADD_CUSTOM_COMMAND( TARGET md5_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/md5_core.pdb
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/md5/core.pdb
	)

ELSE(WIN32)

	ADD_CUSTOM_COMMAND( TARGET md5_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/libmd5_core.so
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/md5/core.so
	)


ENDIF(WIN32)
