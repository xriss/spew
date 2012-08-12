PROJECT(lua_lanes)


INCLUDE_DIRECTORIES(

        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${lua_include_dir}
)


LINK_DIRECTORIES(

        ${CMAKE_CURRENT_SOURCE_DIR}
)


SET(lua_lanes_src_sources


src/lanes.c

src/tools.h
src/tools.c

src/threading.h
src/threading.c

src/keeper.h
src/keeper.c

)



SET(lua_lanes_sources ${lua_lanes_src_sources} )

IF(WIN32)

        IF(BUILD_SHARED_LIBS)

#               ADD_DEFINITIONS(-DLUA_BUILD_AS_DLL)

        ENDIF(BUILD_SHARED_LIBS)
        
ENDIF(WIN32)



SOURCE_GROUP(src FILES ${lua_lanes_src_sources} )




IF(BUILD_SHARED_LIBS)

        ADD_LIBRARY(lua_lanes SHARED ${lua_lanes_sources} )
        
ELSE(BUILD_SHARED_LIBS)

        ADD_LIBRARY(lua_lanes STATIC ${lua_lanes_sources} )

ENDIF(BUILD_SHARED_LIBS)





TARGET_LINK_LIBRARIES(lua_lanes

        lua5.1
)

IF(WIN32)

        ADD_CUSTOM_COMMAND( TARGET lua_lanes POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
                ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lua_lanes.dll
                ${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/lua51-lanes.dll
        )

        ADD_CUSTOM_COMMAND( TARGET lua_lanes POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
                ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/lua_lanes.pdb
                ${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/lua51-lanes.pdb
        )

ELSE(WIN32)

TARGET_LINK_LIBRARIES(lua_lanes

        pthread
)

        ADD_CUSTOM_COMMAND( TARGET lua_lanes POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy
                ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/liblua_lanes.so
                ${CMAKE_CURRENT_SOURCE_DIR}/../../nix/lib/lua51-lanes.so
        )

ENDIF(WIN32)
