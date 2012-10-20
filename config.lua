LUA_PATH="./"
--LUA_CPATH=

--require ("compat-5.1.lua")

cfg={}

cfg.os="nix"
cfg.posix_username="wet"

cfg.sql="mysql"
cfg.mysql_hostname="127.0.0.1"
cfg.mysql_database="forum"
cfg.mysql_username="wet"
cfg.mysql_password="wet1923"
cfg.mysql_prefix="wet_"

cfg.fud_prefix="fud26_"

cfg.email_logs="wetgenes.rowboatlogs@blogger.com"

cfg.temp_chat_file="/var/www/wetgenes/swf/beta.chat.txt"

cfg.mux_server="themudhost.net"
cfg.mux_port=9956

cfg.data_dir="/home/wet/hg/wetgenes/subs/data"
cfg.base_data_url="http://data.wetgenes.com"

--cfg.dbg_stdio_off=true

cfg.blocked={

        ["24.241.194.99"]=true,
        ["24.241."]=true,

--[[
        ["70.114.2.84"]=true,
]]

}

cfg.cockblocked={
	"24.241.",
	"71.12.",
	"75.137.",
	"24.196.",
}








