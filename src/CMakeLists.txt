
cmake_minimum_required(VERSION 2.6)

SET(BUILD_SHARED_LIBS true)


PROJECT(spew)


#INCLUDE_DIRECTORIES(
#
#	${CMAKE_CURRENT_SOURCE_DIR}
#	${CMAKE_CURRENT_SOURCE_DIR}/lua/src
#)


LINK_DIRECTORIES(

	${CMAKE_CURRENT_SOURCE_DIR}
)



SET(lua_include_dir ${CMAKE_CURRENT_SOURCE_DIR}/lua/src )

SET(serv_dir ${CMAKE_CURRENT_SOURCE_DIR}/.. )



SUBDIRS(

	lua
	lua_lanes
	lua_md5
	lua_lash
	lua_socket
	lua_sql
)


IF(WIN32)

ELSE(WIN32)
	
SUBDIRS(
	
	lua_posix

)

ENDIF(WIN32)
