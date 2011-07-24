LUA_PATH="./"
--LUA_CPATH=

--require ("compat-5.1.lua")

cfg={}

cfg.os="nix"
cfg.posix_username="wet"

cfg.mysql_hostname="127.0.0.1"
cfg.mysql_database="forum"
cfg.mysql_username="wet"
cfg.mysql_password="wet1923"
cfg.mysql_prefix="wet_"

cfg.fud_prefix="fud26_"

cfg.email_logs="wetgenes.rowboatlogs@blogger.com"

cfg.temp_chat_file="/var/www/wetgenes/swf/beta.chat.txt"

cfg.mux_server="vermaxhosting.com"
cfg.mux_port=9956

cfg.data_dir="/home/wet/wet/www/wetgenes/subs/data"

cfg.base_data_url="http://data2.wetgenes.com"

--cfg.dbg_stdio_off=true

cfg.blocked={

--[[
        ["70.114.2.84"]=true,
]]

}








