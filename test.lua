
require ("config")


-- load the http module
local io = require("io")
local http = require("socket.http")
local ltn12 = require("ltn12")


--require("ssl")


require("luasql.mysql")


require("md5")

require("lanes")

require 'posix'


if true then

ox=posix

io.flush()
pid=assert(ox.fork())
io.write("---- ",pid,"\n")
if pid==0 then
	pid=ox.getpid"pid"
	ppid=ox.getpid"ppid"
	io.write("in child process ",pid," from ",ppid,".\nnow executing date... ")
	io.flush()
--	assert(ox.exec("date","+[%c]"))
	return
	print"should not get here"
else
	io.write("process ",ox.getpid"pid"," forked child process ",pid,". waiting...\n")
	ox.wait(pid)
	io.write("child process ",pid," done\n")
end

end


if false then

local sql=luasql.mysql()

local con=assert(sql:connect(cfg.mysql_database,cfg.mysql_username,cfg.mysql_password,cfg.mysql_hostname))

local tab
local ret

	ret=con:execute("select * from spew_feats")
	
	tab={}
	while ret:fetch(tab,"a") do
		for i,v in pairs(tab) do
			print(i," = ",v)
		end
	end

end



if false then

local tab={}

print( tab , "\n" )
print( tostring(tab) , "\n" )
print( tonumber(string.sub(tostring(tab),-8),16) , "\n" )


end



if false then


	print(
		string.gsub("po)ooop to01 l:P", "[^0-9a-zA-Z%-_]", "" )
	)
	
end



if false then


http.request{
				url = "http://swf.wetgenes.com/crossdomain.xml",
				sink = ltn12.sink.file(io.stdout)
		}

end


if false then

--
-- Same without upvalue, and with 'require' only at the main level 
-- ('lanes' is passed onto others as upvalue table)
--
do
    local lanes= require "lanes"
    assert(lanes)

    local function f( depth )
        print("depth = " .. depth)
        if depth > 100 then
            return "done!"
        end
    
        local lgen= lanes.gen("*", debug.getinfo(1,"f").func)
        local lane= lgen( depth+1 )
        return lane[1]
    end
    
    local v= f(0)
    print(v)    -- "done!"
    
    assert(v=="done!")
end

end
