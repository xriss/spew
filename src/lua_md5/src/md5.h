/**
*  $Id: md5.h,v 1.2 2006/03/03 15:04:49 tomas Exp $
*  Cryptographic module for Lua.
*  @author  Roberto Ierusalimschy
*/


#ifndef md5_h
#define md5_h

#include <lua.h>

#ifndef LUAMD5_API
#define LUAMD5_API extern
#endif


#define HASHSIZE       16

void md5 (const char *message, long len, char *output);
LUAMD5_API int luaopen_md5_core (lua_State *L);


#endif
