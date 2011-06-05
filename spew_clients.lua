
--
-- data.* should be used for persistant vars as the plan is for this file to reload on command
--


-----------------------------------------------------------------------------
--
-- fill in basic data if it does not already exist
--
-----------------------------------------------------------------------------
function client_new_data(flags)

	spew_setup(flags)
	
--	dbg(serialdbg(data.brains,1))

end

-----------------------------------------------------------------------------
--
-- client connect
--
-----------------------------------------------------------------------------
function client_connected(client,flavour)
--dbg("connected"," ",dbg_client(client),"\n")

	if flavour=="telnet" then
		data.clients_telnet[client]={} -- extra telnet data
	elseif flavour=="irc" then
		data.clients_irc[client]={} -- extra irc data
	end
	
	client:settimeout(0.00001) -- this is a hack fix?

local user=new_user{name="me",client=client}
	

end
				
-----------------------------------------------------------------------------
--
-- client disconnect
--
-----------------------------------------------------------------------------
function client_disconnected(client,error)
--dbg("disconnected ",error," ",dbg_client(client),"\n")

local user=data.clients[client]

	data.clients_irc[client]=nil
	data.clients_telnet[client]=nil
	data.clients_websocket[client]=nil
		
	del_user(user)

end

-----------------------------------------------------------------------------
--
-- has this client performed a handshake?
--
-----------------------------------------------------------------------------
function client_handshake_done(client)

local user=data.clients[client]

	if user and user.spew_ok_to_send then return true end
	
	return false

end

-----------------------------------------------------------------------------
--
-- has this client performed a handshake?
--
-----------------------------------------------------------------------------
function client_handshake_set(client,flavour)

local user=data.clients[client]

--	if user then
		user.spew_ok_to_send=true
--	end
	
	if flavour=="websocket" then
		data.clients_websocket[client]={}
	end
	
end

-----------------------------------------------------------------------------
--
-- send a line to a client
--
-----------------------------------------------------------------------------
function client_send(client,line)

--dbg("send:"..line.."\n")

local user=data.clients[client]

	if ( not client ) or ( not line ) or ( not user ) then return end
	
	client:settimeout(0.00001) -- this is a hack fix?
	
	if user.spew_ok_to_send then
	
		if user.spew_send_cache then
		
			line=user.spew_send_cache .. line
			user.spew_send_cache=nil
		
		end
		
		if line~="" then
		
			client:send(line)
			
		end
			
	else -- delay sending until after connection has been confirmed
	
		user.spew_send_cache = ( user.spew_send_cache or "" ) .. line
		
	end

end

	
-----------------------------------------------------------------------------
--
-- receive some data from a client
--
-----------------------------------------------------------------------------
function client_received(client,line)
--dbg("received ",line," ",dbg_client(client),"\n")

local user=data.clients[client]

local line_term="\0"

	if data.clients_telnet[client] then -- break on \n not \0
		line_term="\n"
	elseif data.clients_irc[client] then -- break on \n not \0
		line_term="\n"
	elseif data.clients_websocket[client] then -- break on \255 not \0
		line_term="\255"
	end

--dbg("received ",line," ",user_ip(user),"\n")
	
	if not user.spew_ok_to_send then
	
		user.spew_ok_to_send=true -- flag as real connection, ok to start sending
		client_send(client,"")
		
	end

	client:settimeout(0.00001) -- this is a hack fix?
	
	if user.lineparts then -- continue our cache
	
		user.lineparts=user.lineparts..line			
		
	else -- start new cache
	
		user.lineparts=line
		
	end
	
	if string.len(user.lineparts)>4096 then user.lineparts=nil return end -- ignore large packets (we never need to send this much data?)
	
	local zero,linepart
	
	zero=string.find(user.lineparts,line_term)
	
	while zero do -- we have a command or more to split up
	
		if zero>1 then
		
			linepart=string.sub(user.lineparts,1,zero-1) -- command
			user.lineparts=string.sub(user.lineparts,zero+1) -- remainder
		
			table.insert(user.linein,linepart) -- do this line in the users coroutine
		else
			user.lineparts=string.sub(user.lineparts,zero+1) -- remainder
		end
		
		zero=string.find(user.lineparts,line_term)
	end
	
	if linepart then queue_update(user) end -- flag the users coroutine to update later as we sent it data

end

-----------------------------------------------------------------------------
--
-- remove this client from active clients
--
-----------------------------------------------------------------------------
function client_remove(client)

	data.clients_irc[client]=nil
	data.clients_telnet[client]=nil
	
	client:close()
	connections:remove(client)

end

