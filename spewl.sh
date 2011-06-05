cd /var/www/spew
nix/bin/lua -e "package.cpath='./nix/lib/?.so;'..package.cpath;package.path='./nix/share/?.lua;'..package.path;" spewl.lua
