--[[

What SPEW Programming Systems Mean To Users:

INCREASED PROGRAMMING EFFICIENCY

Programmers can concentrate on the application and results rather than on a multitude of "bookkeeping" functions, such as keeping track of storage locations.

FASTER TRANSLATION OF USERS REQUIREMENTS INTO USABLE RESULTS

Simplified programming routines allow programmers to write more instructions in less time.

SHORTER TRAINING PERIODS

Programmers use a language more familiar to them rather than having to learn detailed machine codes.

REDUCED PROGRAMMING COSTS

Many pre-written programs are supplied by WetGenes, eliminating necessity of customers' staffs writing their own.

MORE AVAILABLE SPEW TIME

Pre-written programs have already been tested by WetGenes, reducing tedious checking operations on the computer.

EASIER TO UNDERSTAND PROGRAMS

Programs are written in symbolic or application-oriented form instead of computer language. This enables users to communicate more easily with the programming staff.

FASTER REPORTS ON OPERATIONS

Routines such as those designed for report writing permit faster translation of users requirements into usable information.

]]


require ("config")
require("coxpcall")
require("lash")

-- always reload these files
dofile("global.lua")
global.__newindex_unlock()

dofile("spew_dbg.lua")
dofile("spew_log.lua")

-----------------------------------------------------------------------------
--
-- Flash friendly spew chat server for in game chat and multiplayer game comms.
--
-- derived from the lua socket simple server example
--
-- Flash friendly means null terminated text line communications
-- using web &a=1&b=2 style packets
-- this is just the default
--
-- I'll throw in a few different options on different ports :)
--
-- port 5223 for spew, with flashsockets OR websockets OR raw
-- port 5224 for telnet, text only, nothing out of band
-- port 5225 for irc, half working, you may only join one room at a time
--
-----------------------------------------------------------------------------


require("lanes")
require("socket")
require("socket.smtp")
require("socket.http")
require("luasql.mysql")
require("lash")
require("Json")
require("bit")



if cfg.os=="nix" then

dbg("setting up POSIX\n")
require("posix")

end





-----------------------------------------------------------------------------
--
-- simple set implementation
-- the select function doesn't care about what is passed to it as long as
-- it behaves like a table
-- creates a new set data structure
--
-----------------------------------------------------------------------------
function newset()
    local reverse = {}
    local set = {}
    return setmetatable(set, {__index = {
        insert = function(set, value)
            if not reverse[value] then
                table.insert(set, value)
                reverse[value] = table.getn(set)
            end
        end,
        remove = function(set, value)
            local index = reverse[value]
            if index then
                reverse[value] = nil
                local top = table.remove(set)
                if top ~= value then
                    reverse[top] = index
                    set[index] = top
                end
            end
        end
    }})
end






-----------------------------------------------------------------------------
--
-- handle a simple update queue
--
-----------------------------------------------------------------------------
function queue_update(tab)
	data.updates[tab]=true
	data.updates_kill[tab]=nil -- remove any removal, since we have just been added
end

function remove_update(tab)
	data.updates_kill[tab]=true
end

function do_updates()

local done_kill=false
local ret,_ret

	for i,v in pairs(data.updates) do -- call all updates
	
		ret,_ret = copcall(i.update,i)
	
		if ret~=true then

			print("\n",( _ret or "" ),"\n")
			
			remove_update(i)

		end
	
	end

	for i,v in pairs(data.updates_kill) do -- kill all flaged tasks
		data.updates[i]=nil
		done_kill=true
	end
	
	if done_kill then -- remove all kills
		data.updates_kill={}
	end

end






-----------------------------------------------------------------------------
--
-- safecall, ignore errors just dump to log on problems
--
-----------------------------------------------------------------------------
function safecall( func , ... )

local	ret,_ret=copcall(func,unpack(arg))

	if ret~=true then

		dbg("\n",( _ret or "" ),"\n")

	end
	
	return ret,_ret

end

-----------------------------------------------------------------------------
--
-- load a brainfile
--
-----------------------------------------------------------------------------
function load_brains( name , dest)

local brains_lua
local ret,_msg,_ret


	brains_lua,_msg=loadfile(name)

	if not brains_lua then
	
		print(debug.traceback().."\n"..( _msg or "" ).."\n") -- check load, which should always work
		
		assert(nil,"ASSERT")
		
	end
	
	if dest then
		setfenv(brains_lua, dest)    -- change this functions environment from the global one
	end
	
	ret,_ret=copcall(brains_lua)	-- running the file builds the functions etc

	if ret~=true then

		print("\n",( _ret or "" ),"\n")
		
		assert(nil,"ASSERT")

	end

	
end


-----------------------------------------------------------------------------
--
-- Reload everything, but try not to break anything...
--
-- Now loading everything into the global table so be aware of name clashes
--
-- try not to cache functions locally unless its in a function that gets reloaded here IYSWIM
--
-----------------------------------------------------------------------------
function reload_brains(flags)

dbg("reloading brains\n")
log(nil,"reload")

global.__newindex_unlock()

	load_brains("config.lua")
	load_brains("spew.lua")
	
	load_brains("spew_dbg.lua")
	load_brains("spew_log.lua")
	
	load_brains("spew_funcs.lua")
	load_brains("spew_xml.lua")
	load_brains("spew_setup.lua")
	load_brains("spew_vest.lua")
	
	load_brains("spew_rooms.lua")
	load_brains("spew_users.lua")
	load_brains("spew_feats.lua")
	load_brains("spew_games.lua")
	load_brains("spew_players.lua")
	
	load_brains("spew_bots.lua")
	load_brains("spew_bots_kolumbo.lua")
	
	load_brains("spew_admin.lua")
	
	load_brains("spew_clients.lua")
	load_brains("spew_mux.lua")
	load_brains("spew_lieza.lua")
	load_brains("spew_noir.lua")

	load_brains("spew_item.lua") -- permanent user owned items
	
	load_brains("spew_ville.lua") -- now in almost 3d chat
	load_brains("spew_vobj.lua")
	load_brains("spew_vobj_propdata.lua")
	load_brains("spew_vobj_ball.lua")
	load_brains("spew_vobj_pot.lua")
	load_brains("spew_vobj_hook.lua")
	load_brains("spew_vobj_comic.lua")
	load_brains("spew_vobj_door.lua")
	load_brains("spew_vroom.lua")
	load_brains("spew_vuser.lua")
	
	load_brains("spew_pulse.lua")
	
	load_brains("spew_lanes.lua")
	load_brains("spew_mysql.lua")
	
-- load in some sub brains

	load_brains("spew_games_itsacoop.lua")
	load_brains("spew_games_wetv.lua")
	load_brains("spew_games_zeegrind.lua")
	load_brains("spew_games_pokr.lua")
	load_brains("spew_games_ewarz.lua")
	load_brains("spew_games_elo.lua")
global.__newindex_lock()
	
	client_new_data(flags)
	
end

-----------------------------------------------------------------------------
--
-- wrap a brain reload in a lanes frendly coroutine
--
-----------------------------------------------------------------------------
function reload_brains_co(flags) -- run reload_brains in a co

	local co=coroutine.create(function() return reload_brains(flags) end)
	
	while coroutine.status(co)~="dead" do
	
--dbg(coroutine.status(co),"\n\n")

		local ret,_ret=coroutine.resume(co)	
		if ret~=true then
			print('\n'.._ret..'\n')
		end
		
		lanes_update()
	end

end

local policy_xml='<cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>'.."\0"

-----------------------------------------------------------------------------
--
-- the main loop, call this repeatedly to process socket input
--
-----------------------------------------------------------------------------
function spew_receive()

	local sa,sb,sc
	local ret,_ret
	
	local readable, _, error = socket.select(connections, nil, 0.01) -- a 100ms or less wait
	for _, input in ipairs(readable) do
	
		-- flash policy SNAFU
		
		if input == server2 then
		
			local client = input:accept()
			if client then
								
				connections:insert(client)
				client_connected(client)
								
			end
			
		-- is it a server socket?
		
		elseif input == server1 then
		
--			dbg("Client atempting to connect\n")
			
			local client = input:accept()
			if client then
								
				connections:insert(client)
				client_connected(client)
			end
			
		elseif input == server_irc then
		
dbg("Client atempting to irc connect\n")
			
			local client = input:accept()
			if client then
								
				connections:insert(client)
				client_connected(client,"irc")
			end
			
		elseif input == server_telnet then
		
--			dbg("Client atempting to telnet connect\n")
			
			local client = input:accept()
			if client then
								
				connections:insert(client)
				client_connected(client,"telnet")
			end
			
		-- it is a mux socket
		
		elseif data.muxouts[input] then
		
			input:settimeout(0.00001) -- this is a hack fix?
			local line, error = input:receive("*l")
			
			if error then
			
				if error=="timeout" then -- ignore timeouts

					mux_timedout(input)
					
				else -- disconect client on all other errors
				
					ret,_ret=copcall(mux_disconnected,input,error)
					if ret~=true then
						print('\n'.._ret..'\n')
					end
											
				end
				
			else -- received a packet so process it, catch silly errors so main server should stay up...
			
				ret,_ret=copcall(mux_received,input,line)
				if ret~=true then
					print('\n'.._ret..'\n')
				end
				
			end
			
			
		-- it is a user socket
		elseif data.clients[input] then
		
			input:settimeout(0.00001) -- this is a hack fix?
			local part, error , part2= input:receive("*a")
			
			part=part or part2 -- we can get an error AND data, possibly even in part2...
			
			if part and (part~="") then

				local ignore_handshake=false
				
				if not client_handshake_done(input) then
			
					
					local websock_path = string.match(part, 'GET (/[^ ]*) HTTP/1.1')
					local policy = ((string.find(part,"<policy-file-request/>",1,true))==1)
					
					if policy then
					
--dbg("sending policy file\n"..part)

						ignore_handshake=true
						input:send(policy_xml)
						
						client_handshake_set(input,"policy")

					elseif websock_path then
					
						local websock_version=string.match(part, 'Sec%-WebSocket%-Version:%s*([^\r]*)') or ""
						
						websock_version=tonumber(websock_version or 0) or 0
						
						if websock_version==13 then -- the all new codes
						
--dbg("sending websock13\n"..part)

	local websock_key=string.match(part, 'Sec%-WebSocket%-Key:%s*([^\r]*)') or ""
	local websock_host=string.match(part, 'Host:%s*([^%s]*)') or ""
	local websock_origin=string.match(part, 'Origin:%s*([^%s]*)') or ""


	local websock_location = 'ws://' .. websock_host .. websock_path

	local key_base=trim(websock_key)
	local key_add="258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
	local key=key_base..key_add
	local key_sha1_hex=lash.SHA1.string2hex(key)
	
	local aa={}
	for i=1,#key_sha1_hex,2 do
		local t=key_sha1_hex:sub(i,i+1)
		aa[#aa+1]=string.char(tonumber(t,16))
	end
	local key_sha1_raw=table.concat(aa)
	
	

-- encoding
local function enc64(data)
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
	local key_sha1_b64=enc64(key_sha1_raw)


	local shake=("HTTP/1.1 101 Switching Protocols" .. "\r\n"
	.. "Upgrade: WebSocket" .. "\r\n"
	.. "Connection: Upgrade" .. "\r\n"
	.. "Sec-WebSocket-Accept: " .. key_sha1_b64 .. "\r\n\r\n"
	)

--print(shake)

	input:send(shake)
	ignore_handshake=true
	client_handshake_set(input,"websocket")

						else -- old junks

--[[part="GET / HTTP/1.1" .. "\r\n"..
"Connection: Upgrade" .. "\r\n"..
"Host: example.com" .. "\r\n"..
"Upgrade: WebSocket" .. "\r\n"..
"Sec-WebSocket-Key1: 3e6b263  4 17 80" .. "\r\n"..
"Origin: http://example.com" .. "\r\n"..
"Sec-WebSocket-Key2: 17  9 G`ZD9   2 2b 7X 3 /r90" .. "\r\n"..
"" .. "\r\n"..
"WjN}|M(6"]]
              
	local websock_host=string.match(part, 'Host:%s*([^%s]*)') or ""
	local websock_origin=string.match(part, 'Origin:%s*([^%s]*)') or ""
	local websock_key1=string.match(part, 'Sec%-WebSocket%-Key1:%s*([^\r]*)') or ""
	local websock_key2=string.match(part, 'Sec%-WebSocket%-Key2:%s*([^\r]*)') or ""

	local keys={}
	local kk={}
	for i,v in ipairs{websock_key1,websock_key2} do
		local spaces=0
		local digits={}
		for ci=1,#v do
			local c=v:sub(ci,ci)
			if c==" " then spaces=spaces+1 else
				if c:match("(%d)") then -- it is a didgit
					digits[#digits+1]=c
				end
			end
		end
		local num=tonumber( table.concat(digits) or "" )
		
		if num and spaces>0 then 
			keys[i]=num/spaces
			kk[#kk+1]=string.char(math.floor(keys[i]/(256*256*256))%256 )
			kk[#kk+1]=string.char(math.floor(keys[i]/(256*256))    %256 )
			kk[#kk+1]=string.char(math.floor(keys[i]/(256))        %256 )
			kk[#kk+1]=string.char(math.floor(keys[i])              %256 )
		end
		
	end
	for i=-8,-1 do
		kk[#kk+1]=part:sub(i,i)
	end
	local key_md5_sum_hex=lash.MD5.string2hex(table.concat(kk))



	local aa={}
	for i=1,#key_md5_sum_hex,2 do
		local t=key_md5_sum_hex:sub(i,i+1)
		aa[#aa+1]=string.char(tonumber(t,16))
	end
	local key_md5=table.concat(aa)
	

	
	local websock_location = 'ws://' .. websock_host .. websock_path
--[[
print("PART:",part)
print("HOST:",websock_host)
print("ORIG:",websock_origin)
print("KEY1:",websock_key1)
print("KEY2:",websock_key2)
print("#KK:",#kk)
print("KK:",table.concat(kk))
print("MD5:",key_md5_sum_hex)
]]					
	ignore_handshake=true
	
	local shake=("HTTP/1.1 101 WebSocket Protocol Handshake" .. "\r\n"
	.. "Upgrade: WebSocket" .. "\r\n"
	.. "Connection: Upgrade" .. "\r\n"
	.. "Sec-WebSocket-Origin: " .. websock_origin .. "\r\n"
	.. "Sec-WebSocket-Location: " .. websock_location .. "\r\n"
--						.. "Sec-WebSocket-Protocol: sample" .. "\r\n"
	.. "\r\n"..key_md5.."\0")
--print(shake)
	input:send(shake)

	client_handshake_set(input,"websocket_old")
	
						end -- websocket_old end
					end
				end
			
				if not ignore_handshake then
				
					ret,_ret=copcall(client_received,input,part)					
					if ret~=true then
						print('\n'.._ret..'\n')
					end
					
				end
					
			end

--dbg("part *"..part.."*\n");

			if error or part=="" then -- problem
			
--dbg("error *"..error.."*\n");
			
				if error=="timeout" then -- ignore timeouts

				else -- disconect client on all other errors
				
					ret,_ret=copcall(client_disconnected,input,error or "nullclosed")
					if ret~=true then
						print('\n'.._ret..'\n')
					end
					
					input:close()
					connections:remove(input)
					
				end
			
			end
			
			
		else -- unknown client
		
			input:settimeout(0.00001) -- this is a hack fix?
			local line, error = input:receive("*a")
			
			if error then
			
				if error=="timeout" then -- ignore timeouts
					
				else -- disconect client on all other errors
				
					input:close()
					connections:remove(input)
					
				end
			
			else
			
				input:settimeout(0.00001) -- this is a hack fix?
			
			end
			
		end
		
	end
	
-- recieve any msgs from worker tasks

 	lanes_update()
	
-- perform local thread updates 

	do_updates()

-- send any queued msgs last (which may cause more queued msgs)

	local tab=data.msg_send_queue
	local tab_count=0

	data.user_thread_available=false -- let noir know that we are not in a user thread
	while tab[1] do
	
		data.msg_send_queue={} -- clear msg list as we are about to send them all
	
		for i,v in ipairs(tab) do
		
			if v[1]=="user" then
			
				usercast(v[2],v[3])
			
			elseif v[1]=="room" then
			
				roomcast(v[2],v[3],v[4])
			
			end
		
		end
		
		tab=data.msg_send_queue -- now check if we queued some more
		
		tab_count=tab_count+1
		if tab_count > 10 then break end -- recursion sanity
	end
	data.user_thread_available=true

-- send any updated ville msgs

	ville_broadcast_changes()
	
-- handle a full garbage collect, we have very little memory so try not to waste it... ?
--	collectgarbage("step")

--	save_posix_data()

end



-- global.__newindex_lock()



-----------------------------------------------------------------------------
--
-- This is the main spew setup and sever loop
--
-- it should only be run once but this file may be loaded multiple times
--
-----------------------------------------------------------------------------

if not data then -- only do this if this is the first time this file has been loaded, that way we can reload the other functions in this file


	global.sql=luasql.mysql()

	global.host = host or "*"
	global.port1 = port1 or 5223
	
	global.port_telnet = port2 or 5224
	
	global.port_irc = port3 or 5225

	if arg then
	    host = arg[1] or host
	    port1 = tonumber(arg[2]) or port1
	end
	
	global.connections = newset()

dbg("Booting "..os.date().."\n")
copcall(function() error("Booting "..os.date().."\n") end ) -- also log a boot up msg with time into the error stream

	global.server_telnet = assert(socket.bind(host, port_telnet))
	server_telnet:settimeout(0.001) -- make sure we don't block in accept	
dbg("Servers bound telnet "..host.." "..port_telnet.."\n")
	connections:insert(server_telnet)

	
	global.server_irc = assert(socket.bind(host, port_irc))
	server_irc:settimeout(0.001) -- make sure we don't block in accept	
dbg("Servers bound irc "..host.." "..port_irc.."\n")
	connections:insert(server_irc)

	
	global.server1 = assert(socket.bind(host, port1))
	server1:settimeout(0.001) -- make sure we don't block in accept
	
dbg("Servers bound spew "..host.." "..port1.."\n")


	--dbg("Inserting servers in set\n")
	connections:insert(server1)
	
-- do policy sever as well? Need root, or privilages to access this port, thanks flash

	global.server2 = assert(socket.bind(host, 843))
	server2:settimeout(0.001) -- make sure we don't block in accept
	connections:insert(server2)

	if cfg.os=="nix" and cfg.posix_username then -- stop being root please
		posix.setpid("u",cfg.posix_username)
		posix.setpid("U",cfg.posix_username)
		posix.setpid("g",cfg.posix_username)
		posix.setpid("G",cfg.posix_username)
	end

	

	global.data={}
	global.new_brain={}
	
--build part of a unique string, use boot time
	data.idstr = "" -- put a unique hex id in here if we need more uniqueness, for now we just have one server so it is not necesary.	
	data.idstr = data.idstr .. string.format("%08X", math.floor(os.time()) )
dbg("Base game idstr ="..data.idstr.."\n")

log(nil,"boot")

	reload_brains_co({nocrowns=true})
	load_data() -- restore any saved data from last shutdown and clear the files ( its OK to lose this data ocassionally )
	reload_brains_co({nocrowns=true}) -- makesure everything is uptodate after the load_data
	
	-- do server loop for ever and ever
	-- the actual message handling brains may be updated while this loop is running
	-- so hopefully we can make updates without always breaking chats or even games in progress
	-- maybe :)

	-- make sure we now know the PID
	save_posix_data()
	
	while true do

		local ret,_ret=copcall(spew_receive)
		if ret~=true then
			print('\nERROR IN MAIN LOOP\n'.._ret..'\n')
			
			local ret,_ret=copcall( reload_brains )
			
		end
	end

end





	
