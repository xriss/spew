
PROJECT(lua_sql)


INCLUDE_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}/src
	${lua_include_dir}
)


LINK_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}
)

IF(WIN32)

INCLUDE_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}/../mysql51/include
)
LINK_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}/../mysql51/lib
)
ELSE(WIN32)

INCLUDE_DIRECTORIES(

	/usr/include/mysql
)

ENDIF(WIN32)


SET(lua_sql_src_sources

src/luasql.c
src/luasql.h

src/ls_mysql.c

)


SET(lua_sql_sources ${lua_sql_src_sources} )



IF(WIN32)

	IF(BUILD_SHARED_LIBS)

		ADD_DEFINITIONS("-DLUASQL_API=__declspec(dllexport)")
		
	ENDIF(BUILD_SHARED_LIBS)
	
ENDIF(WIN32)




SOURCE_GROUP(src FILES ${lua_sql_src_sources} )




IF(BUILD_SHARED_LIBS)

	ADD_LIBRARY(luasql_mysql SHARED ${lua_sql_sources} )
	
ELSE(BUILD_SHARED_LIBS)

	ADD_LIBRARY(luasql_mysql STATIC ${lua_sql_sources} )

ENDIF(BUILD_SHARED_LIBS)





TARGET_LINK_LIBRARIES(luasql_mysql

	lua5.1
)

			
			
IF(WIN32)

TARGET_LINK_LIBRARIES(luasql_mysql

	libmySQL
)

	ADD_CUSTOM_COMMAND( TARGET luasql_mysql POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_SOURCE_DIR}/../mysql51/lib/libmysql.dll
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/bin/libmysql.dll
	)
	
	ADD_CUSTOM_COMMAND( TARGET luasql_mysql POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/luasql_mysql.dll
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/luasql/mysql.dll
	)

	ADD_CUSTOM_COMMAND( TARGET luasql_mysql POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/luasql_mysql.pdb
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/luasql/mysql.pdb
	)

ELSE(WIN32)

TARGET_LINK_LIBRARIES(luasql_mysql

	mysqlclient
)
	ADD_CUSTOM_COMMAND( TARGET luasql_mysql POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
		${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/libluasql_mysql.so
		${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/luasql/mysql.so
	)

ENDIF(WIN32)
