
local spew_lanes_version=16 -- bump this version number to make sure threads are killed and restarted with code changes

local spew_lanes_disable=false -- do not use lanes, block the main thread for easier debuging


-----------------------------------------------------------------------------
--
-- create data.lanes table and threads if it isnt already setup
--
-----------------------------------------------------------------------------
function lanes_setup()

	if not data.lanes then data.lanes={} end
	
	if not data.lanes.msgid then data.lanes.msgid=1 end -- msg id, use and inc on each send
	
	if not data.lanes.rets then data.lanes.rets={} end -- table of return values, slot filed is msgid, just busy wait for results
	
	if not data.lanes.threads then data.lanes.threads={} end
	
	local need_new_workers=false
	
	if spew_lanes_disable then -- stop here, we are not using lanes
		data.lanes.state="working"
		return
	end

	
local function create_new_thread(i)

	data.lanes.threads[i]={}
	data.lanes.threads[i].linda=lanes.linda()
	data.lanes.threads[i].version=spew_lanes_version
	data.lanes.worker=lanes.gen("*",{["globals"]={master_cpath=package.cpath,master_path=package.path}},lanes_worker)
	data.lanes.threads[i].worker=data.lanes.worker(data.lanes.threads[i].linda,i)

end
	
	for i=1,3 do
	
		if not data.lanes.threads[i] then -- create new
		
			create_new_thread(i)
		
		else -- check old
				
			if	data.lanes.threads[i].worker.status~="done" and 
				data.lanes.threads[i].worker.status~="error" and 
				data.lanes.threads[i].worker.status~="cancelled" then
						
				if data.lanes.threads[i].version~=spew_lanes_version then -- this old running thread is a bad version
				
					need_new_workers=true
					
				end
			
			else -- replace dead thread
			
				create_new_thread(i)
			
			end
		end
		
	end
		
--	data.lanes.update=lanes_update
	
	if need_new_workers then -- kill all old threads and start new threads
	
		lanes_refresh()
			
	else
	
		data.lanes.state="working"
	
	end
end


-----------------------------------------------------------------------------
--
-- tell worker threads to shutdown and start again
--
-----------------------------------------------------------------------------
function lanes_refresh()

		lanes_clean()		
		data.lanes.state="refreshing"
end

-----------------------------------------------------------------------------
--
-- tell worker threads to shutdown
--
-----------------------------------------------------------------------------
function lanes_clean()

	data.lanes.state="cleaning"

	if not spew_lanes_disable then
	
		for i,v in ipairs(data.lanes.threads) do
		
			lanes_send({cmd="end"},i)
			
		end
	end
end

-----------------------------------------------------------------------------
--
-- get a uniqueish msg id for comms
--
-----------------------------------------------------------------------------
function lanes_get_new_msgid()

	data.lanes.msgid=data.lanes.msgid+1
	if data.lanes.msgid > 65535 then data.lanes.msgid=0 end -- do not let numbers spiral out of control
	data.lanes.rets[data.lanes.msgid]=nil -- maybe something got stuck
	
	return data.lanes.msgid
	
end

-----------------------------------------------------------------------------
--
-- send a msg to a worker
--
-----------------------------------------------------------------------------
function lanes_send(msg,idx)

	msg.id=lanes_get_new_msgid() -- where to store a reply, 
	
	if not spew_lanes_disable then

		data.lanes.threads[idx].linda:send(nil,idx,msg)
	
	end
	
end

-----------------------------------------------------------------------------
--
-- return a msg from a worker
--
-----------------------------------------------------------------------------
function lanes_return(linda,msg,ret)
	
	if spew_lanes_disable then
	
		return ret
	
	else

		linda:send(nil,0,{ cmd="ret" , id=msg.id , ret=ret })
	
	end
	
	return nil
	
end

-----------------------------------------------------------------------------
--
-- check the state of workers
--
-----------------------------------------------------------------------------
function lanes_update()

--dbg("searching for msg\n")
	if data.lanes.state=="working" then
		local msg
		
		if not spew_lanes_disable then

			for i,v in ipairs(data.lanes.threads) do -- we shouldnt share lindas amongst worker threads, it seems to confuse things, a bug no doubt
			
				repeat
--dbg(i)
					msg=data.lanes.threads[i].linda:receive( 0 , 0 ) -- check for returned msgs, but do not block
					
					if msg then
						data.lanes.rets[msg.id]=msg -- store msg in rets table, there are polling waits on these
					end
					
				until not msg
				
			end
		
		end
	
	elseif data.lanes.state=="cleaning" or data.lanes.state=="refreshing" then
	
-- check threads for ending

	local finished=true

		if not spew_lanes_disable then
		
			for i,v in ipairs(data.lanes.threads) do
			
				if	v.worker.status~="done" and 
					v.worker.status~="error" and 
					v.worker.status~="cancelled" then
				
					finished=false
				
				end
			
			end
		
		end
		
		if finished then
		
			if data.lanes.state=="cleaning" then -- just shutting down
			
				data.lanes.state="cleaned"
				
			elseif data.lanes.state=="refreshing" then -- reloading
			
				data.lanes.state="cleaned"
				
				lanes_setup()
			end
			
		end
	
	end

end

-----------------------------------------------------------------------------
--
-- send a url request to a worker thread and return the result
-- use yield to wait and poll, this should probably be upgraded to use a wakeup signal
--
-----------------------------------------------------------------------------
function lanes_url(url)

local msg={}
local ret

	msg.cmd="url"
	msg.url=url
	
	if spew_lanes_disable then
	
		return lanes_url_worker(nil,msg)
	
	else	
	
		lanes_send(msg,2)
		
dbg("waiting for "..msg.id.."\n")
		repeat dbg("B") coroutine.yield() dbg("A") until data.lanes.rets[msg.id] -- poll wait for return value
dbg("got "..msg.id.."\n")

		ret=data.lanes.rets[msg.id]
		data.lanes.rets[msg.id]=nil
	
		return ret.ret
	end
	
	
end


-----------------------------------------------------------------------------
--
-- This is a user request on another thread, I dont want it to block my threads
-- but its ok if each user pisses each other off
--
-- send a url request to a worker thread and return the result
-- use yield to wait and poll, this should probably be upgraded to use a wakeup signal
--
-----------------------------------------------------------------------------
function lanes_url_user(url)

local msg={}
local ret

	msg.cmd="url"
	msg.url=url
	
	if spew_lanes_disable then
	
		return lanes_url_worker(nil,msg)
	
	else	
	
		lanes_send(msg,3)
		
--dbg("waiting for "..msg.id.."\n")
		repeat coroutine.yield() until data.lanes.rets[msg.id] -- poll wait for return value
--dbg("got "..msg.id.."\n")

		ret=data.lanes.rets[msg.id]
		data.lanes.rets[msg.id]=nil
	
		return ret.ret
	end
	
	
end

-----------------------------------------------------------------------------
--
-- send a sql queery to a worker thread and return the result
-- use yield to wait and poll, this should probably be upgraded to use a wakeup signal
--
-----------------------------------------------------------------------------
function lanes_sql(q,flags)
local d=debug.getinfo(2)
--dbg("SQL CALL "..(d.source or "?").." "..d.currentline.."\n")

local msg={}
local ret

	msg.cmd="sql"
	msg.q=q
	msg.flags=flags
	
	if spew_lanes_disable then
	
		return lanes_sql_worker(nil,msg)
	
	else	
		lanes_send(msg,1)
	
--dbg("waiting for "..msg.id.."\n")
		repeat coroutine.yield() until data.lanes.rets[msg.id] -- poll wait for return value	
--dbg("got "..msg.id.."\n")

		ret=data.lanes.rets[msg.id]
		data.lanes.rets[msg.id]=nil
		
		return ret.ret
	end
	
	
end

-----------------------------------------------------------------------------
--
-- send a sql queery to a worker thread and return the result
-- use yield to wait and poll, this should probably be upgraded to use a wakeup signal
--
-----------------------------------------------------------------------------
function lanes_sql_noblock(q)

local msg={}
local ret

	msg.cmd="sql"
	msg.q=q

	lanes_send(msg,1)
	
	
--dbg("waiting for "..msg.id.."\n")
--	repeat coroutine.yield() until data.lanes.rets[msg.id] -- poll wait for return value	
--dbg("got "..msg.id.."\n")

--	ret=data.lanes.rets[msg.id]
--	data.lanes.rets[msg.id]=nil
	
--	return ret.ret
	
end

-----------------------------------------------------------------------------
--
-- fill up a table with named results
--
-----------------------------------------------------------------------------
function sql_named_tab(tab,idx)

	if not tab then return nil end
	if not tab[idx] then return nil end

local ret={}

	for i,v in ipairs(tab.names) do
		ret[v]=tab[idx][i]
	end

	return ret
end


-----------------------------------------------------------------------------
--
-- get url content
--
-----------------------------------------------------------------------------
function lanes_url_worker(linda,msg)

dbg("URL WAIT "..msg.url.."\n")

local body, headers, code = socket.http.request(msg.url)

dbg("URL DONE "..msg.url.."\n")

local ret={}

	ret.body=body
	ret.headers=headers
	ret.code=code
	
	return lanes_return(linda,msg,ret)
--	linda:send(nil,0,{ cmd="ret" , id=msg.id , ret=ret })

end


-----------------------------------------------------------------------------
--
-- perform the sql queery in the worker
--
-----------------------------------------------------------------------------
function lanes_sql_worker(linda,msg)

local con,cur,ret,err
local lastid,lastcur

--dbg("performing sql1 "..msg.id.."\n",msg.q,"\n")

	con,err=sql:connect(cfg.mysql_database,cfg.mysql_username,cfg.mysql_password,cfg.mysql_hostname)
	
--dbg("performing sql2 "..msg.id.."\n")
	
	if not con then
	
		dbg("\n".."Failed to connect to mysql"..(err or "unknown").."\n") -- print error
		
		return lanes_return(linda,msg,false)
--		linda:send(nil,0,{ cmd="ret" , id=msg.id , ret=false })
--		return
		
	end
	
	cur,err=con:execute(msg.q)
	
	if not cur and err then -- indicate failure
	
		local d=debug.getinfo(1,"Sl")
		dbg("\n"..msg.q.."\n"..err.."\n"..d.source.."\n"..d.currentline.."\n")		
		
		if con then con:close() end
		return lanes_return(linda,msg,false)
--		linda:send(nil,0,{ cmd="ret" , id=msg.id , ret=false })
--		return
	end
	
	if type(cur)=="number" then -- a single number return value
	
		if msg.flags=="lastid" and (cur~=0) then -- get last id
		
			lastcur,err=con:execute("SELECT LAST_INSERT_ID()")
			
			if not lastcur and err then -- indicate failure
			
				local d=debug.getinfo(1,"Sl")
				dbg("\n"..msg.q.."\n"..err.."\n"..d.source.."\n"..d.currentline.."\n")		
				
				lastid=0
				
			else
			
				lastid=lastcur:fetch({})[1]
				
				lastid=tonumber(lastid)
				
				if lastcur then lastcur:close() end
				
--				dbg("\n LASTID = "..lastid.."\n") -- print error
			end
			
			if con then con:close() end
			return lanes_return(linda,msg,lastid)
--			linda:send(nil,0,{ cmd="ret" , id=msg.id , ret=lastid })
--			return
		end
	
		if con then con:close() end
		return lanes_return(linda,msg,cur)
--		linda:send(nil,0,{ cmd="ret" , id=msg.id , ret=cur })
--		return
	end
	
	ret={}
	
	ret.names=cur:getcolnames()
	ret.types=cur:getcoltypes()
	
	local i=1
	local r
	
	repeat
	
		r=cur:fetch({})
		ret[i]=r
		i=i+1
	
	until not r
		
	if cur then cur:close() end
	if con then con:close() end
	return lanes_return(linda,msg,ret)
--	linda:send(nil,0,{ cmd="ret" , id=msg.id , ret=ret })
	
end

-----------------------------------------------------------------------------
--
-- perform the end in the worker
--
-----------------------------------------------------------------------------
function lanes_end_worker(linda,msg)

local kay=math.floor(collectgarbage("count"))
	dbg("lua thread was using "..kay.."k\n")
					
	linda:send(nil,0,{ cmd="end" , id=msg.id })

end

-----------------------------------------------------------------------------
--
-- the generic worker thread function
--
-- used to create new worker threads
--
-- pass in a linda and an id to use on that linda for coms
--
-- this function needs to require and setup the things it neads as otherwise it has nothing
--
-----------------------------------------------------------------------------
function lanes_worker(linda,idx)

-- require libs

-- copy path from master
package.cpath=master_cpath or package.cpath
package.path=master_path or package.path

dofile("spew_dbg.lua")
require("coxpcall")


require("socket")
require("socket.http")


require("luasql.mysql")
sql=luasql.mysql()


require("md5")

--require("spew_lanes")
--require("spew_lanes_mysql")

dofile("config.lua")
dofile("spew_funcs.lua")
dofile("spew_lanes.lua")
dofile("spew_mysql.lua")

local loop=true

	while loop do

	local msg= linda:receive( nil, idx )

	
		if msg then
--dbg(idx," : ",msg.cmd," : ",msg.url or "?","\n")
		
			if msg.cmd=="end" then

				lanes_end_worker(linda,msg)
				
				return -- finish since we where told to
					
			elseif msg.cmd=="sql" then
			
				lanes_sql_worker(linda,msg)
			
			elseif msg.cmd=="url" then
			
				lanes_url_worker(linda,msg)
			
			end
			
-- handle a full garbage collect, we have very little memory so try not to waste it...
			collectgarbage("collect")
			
		end
	end
	
end
