nix\bin\lua.exe -e "package.cpath='./nix/lib/?.dll;'..package.cpath; package.path='./src/lua_lanes/tests/?.lua;./nix/share/?.lua;'..package.path;" src/lua_lanes/tests/basic.lua 
