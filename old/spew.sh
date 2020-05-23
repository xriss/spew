cd /devcake/spew
#nix/bin/lua -e "package.cpath='./nix/lib/?.so;'..package.cpath;package.path='./nix/share/?.lua;'..package.path;" spewd.lua 1>>spewd.log 2>>spewd.err </dev/null &

lua spewd.lua 1>>spew.log 2>>spew.err </dev/null &

