#! /bin/sh

export LUA_CPATH="./nix/lib/?.so;"
export LUA_PATH="./?.lua;./src/lua_lanes/tests/?.lua;./nix/share/?.lua;"



nix/bin/lua src/lua_lanes/tests/irayo_recursive.lua

#nix/bin/lua src/lua_lanes/tests/basic.lua 

nix/bin/lua src/lua_lanes/tests/fifo.lua 

nix/bin/lua src/lua_lanes/tests/keeper.lua 

nix/bin/lua src/lua_lanes/tests/timer.lua 

nix/bin/lua src/lua_lanes/tests/atomic.lua 

nix/bin/lua src/lua_lanes/tests/cyclic.lua 

nix/bin/lua src/lua_lanes/tests/objects.lua 

nix/bin/lua src/lua_lanes/tests/fibonacci.lua 

nix/bin/lua src/lua_lanes/tests/recursive.lua 

