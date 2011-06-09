
PROJECT(lua_socket)


INCLUDE_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}/src
	${lua_include_dir}
)


LINK_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}
)


SET(lua_mime_src_sources

src/mime.c
src/mime.h

)

SET(lua_socket_src_sources

src/auxiliar.c
src/auxiliar.h

src/buffer.c
src/buffer.h

src/except.c
src/except.h

src/inet.c
src/inet.h

src/io.c
src/io.h

src/luasocket.c
src/luasocket.h

src/options.c
src/options.h

src/select.c
src/select.h

src/tcp.c
src/tcp.h

src/timeout.c
src/timeout.h

src/udp.c
src/udp.h

)

IF(WIN32)

SET(lua_socket_src_sources

${lua_socket_src_sources}

src/wsocket.c
src/wsocket.h

)

ELSE(WIN32)

SET(lua_socket_src_sources

${lua_socket_src_sources}

src/usocket.c
src/usocket.h

)

ENDIF(WIN32)



SET(lua_mime_sources ${lua_mime_src_sources} )

SET(lua_socket_sources ${lua_socket_src_sources} )



IF(WIN32)

	IF(BUILD_SHARED_LIBS)

		ADD_DEFINITIONS("-DMIME_EXPORTS")
		ADD_DEFINITIONS("-DMIME_API=__declspec(dllexport)")

		ADD_DEFINITIONS("-DLUASOCKET_EXPORTS")
		ADD_DEFINITIONS("-DLUASOCKET_API=__declspec(dllexport)")
		
	ENDIF(BUILD_SHARED_LIBS)
	
ENDIF(WIN32)




SOURCE_GROUP(src FILES ${lua_mime_src_sources} )

SOURCE_GROUP(src FILES ${lua_socket_src_sources} )




IF(BUILD_SHARED_LIBS)

	ADD_LIBRARY(mime_core SHARED ${lua_mime_sources} )
	ADD_LIBRARY(socket_core SHARED ${lua_socket_sources} )
	
ELSE(BUILD_SHARED_LIBS)

	ADD_LIBRARY(mime_core STATIC ${lua_mime_sources} )
	ADD_LIBRARY(socket_core STATIC ${lua_socket_sources} )

ENDIF(BUILD_SHARED_LIBS)





TARGET_LINK_LIBRARIES(mime_core

	lua5.1
)

TARGET_LINK_LIBRARIES(socket_core
	
	lua5.1
)

IF(WIN32)

TARGET_LINK_LIBRARIES(socket_core

	ws2_32
)


	ADD_CUSTOM_COMMAND( TARGET mime_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/mime_core.dll
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/mime/core.dll
	)

	ADD_CUSTOM_COMMAND( TARGET mime_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/mime_core.pdb
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/mime/core.pdb
	)
	
	ADD_CUSTOM_COMMAND( TARGET socket_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/socket_core.dll
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/socket/core.dll
	)

	ADD_CUSTOM_COMMAND( TARGET socket_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/socket_core.pdb
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/socket/core.pdb
	)

ELSE(WIN32)

	ADD_CUSTOM_COMMAND( TARGET mime_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/libmime_core.so
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/mime/core.so
	)
	
	ADD_CUSTOM_COMMAND( TARGET socket_core POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/libsocket_core.so
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/socket/core.so
	)

ENDIF(WIN32)
