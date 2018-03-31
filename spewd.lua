--[[

this lua script uses the posix library to watch the server and make sure that it is operational

the server should be killed and then restarted if it goes screwy or missing

]]


require ("config")
require("coxpcall")

-- always reload these files
dofile("global.lua")
global.__newindex_unlock()


cfg.dbg_filename = "./spewd.dbg"

dofile("spew_dbg.lua")




require("posix")

--require("socket")
--require("socket.smtp")
--require("socket.http")



function check_spew(data)

	if data and data.pid then
	
		if posix.kill(tonumber(data.pid),0) == 0 then -- spew is running
		
			return true
		end
	end
	
	return false -- we dont think spew is running
end

function restart_spew(data)

	kill_spew(data)
	run_spew(data)
	
end

function kill_spew(data)

	dbg("Asking spew server to shut down nicely.\n")
	local s="kill -int "..data.pid
	dbg(s,"\n")
	os.execute(s)
	posix.sleep(1)
	dbg("Telling spew server to shut down immediately.\n")
	local s="kill "..data.pid
	dbg(s,"\n")
	os.execute(s)
	posix.sleep(1)

end


function run_spew(data)

	local pid=posix.getpid("pid")
	dbg("Starting spew server "..pid.." \n")

local tim=os.time()

os.execute([[mail -s"SPEW LOG ]]..tim..[[" krissd@gmail.com <spew.log]])

os.execute([[mv spew.dbg save/spew.]]..tim..[[.dbg]])
os.execute([[mv spew.log save/spew.]]..tim..[[.log]])
os.execute([[mv spew.err save/spew.]]..tim..[[.err]])


-- make sure we can log
os.execute([[echo "***" >spew.dbg]])
os.execute([[chmod 777 spew.dbg]])
os.execute([[echo "***" >spew.err]])
os.execute([[chmod 777 spew.err]])
os.execute([[echo "***" >spew.log]])
os.execute([[chmod 777 spew.log]])

	
--os.execute([[nix/bin/lua -e "package.cpath='./nix/lib/?.so;'..package.cpath;package.path='./nix/share/?.lua;'..package.path;" spew.lua >spew.log 2>spew.err]])
os.execute([[lua spew.lua >spew.log 2>spew.err]])

os.execute([[mail -s"SPEW BOOT ]]..tim..[[" krissd@gmail.com </dev/null]])

end

local pid=posix.getpid("pid")
dbg(posix.uname("Machine %n is a %m running %s %r : PID = "..pid.."\n"))

--run_spew()

local tab={}


while true do

local tim=os.date().." : "

local func=loadfile("spewd.dat")
	if func then
		setfenv(func,tab)
		pcall(func)
	end
	
	if tab.data then -- loaded info
	
--		dbg("PID=",tab.data.pid,"\n")
--		dbg("time=",tab.data.time,"\n")
		
		local delta=os.time()-tab.data.time
		
--		dbg(tim,"spewd delta=",delta,"\n")
		
		
		if not check_spew(tab.data) then -- spew has gone missing, maybe shutdown
		
			dbg(tim,"Missing spew server\n")
	
			run_spew(tab.data)
		
		else -- it's still there, so check for lock up
		
			if delta>300 then -- looks like the server has been dead for 5 minutes?
			
				dbg(tim,"Lost server pulse, attempting to shutdown and restart server\n")
			
				restart_spew(tab.data)
			end
		end
	
	else
	
		dbg(tim,"Missing spew server spewd.dat file\n")
		
		run_spew(tab.data) -- try and restart server but do not kill old one
	end


posix.sleep(60) -- check for missing server every 60secs

end

