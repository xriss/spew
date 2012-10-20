


PROJECT(lua_lash)


INCLUDE_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}/src
	${lua_include_dir}
)


LINK_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}
)


SET(lua_lash_src_sources

src/crc32.c

src/md5.c

src/sha1.c

src/main.c

)



SET(lua_lash_sources ${lua_lash_src_sources} )

IF(WIN32)

	IF(BUILD_SHARED_LIBS)

#windows always builds a dll
#		ADD_DEFINITIONS("-DLUAMD5_API=__declspec(dllexport)")

	ENDIF(BUILD_SHARED_LIBS)
	
ENDIF(WIN32)



SOURCE_GROUP(src FILES ${lua_lash_src_sources} )




IF(BUILD_SHARED_LIBS)

	ADD_LIBRARY(lash SHARED ${lua_lash_sources} )
	
ELSE(BUILD_SHARED_LIBS)

	ADD_LIBRARY(lash STATIC ${lua_lash_sources} )

ENDIF(BUILD_SHARED_LIBS)





TARGET_LINK_LIBRARIES(lash

	lua5.1
)

IF(WIN32)

	ADD_CUSTOM_COMMAND( TARGET lash POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lash.dll
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/lash.dll
	)

	ADD_CUSTOM_COMMAND( TARGET lash POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lash.pdb
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/lash.pdb
	)

ELSE(WIN32)

	ADD_CUSTOM_COMMAND( TARGET lash POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/liblash.so
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/lash.so
	)


ENDIF(WIN32)
