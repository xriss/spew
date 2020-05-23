#! /bin/sh

export LUA_CPATH="./nix/lib/?.so;"
export LUA_PATH="./?.lua;./nix/share/?.lua;"

nix/bin/lua test.lua
