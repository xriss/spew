
local log_dirname=( cfg and cfg.log_filename ) or "./save/logs/"

local tlog_filename=( cfg and cfg.tlog_filename ) or "./save/tlog.json"

local json=require("Json")
-- replace with my json encoder decoder
--local wjson=require("wjson")
--local json={}
--json.Decode=wjson.decode
--json.Encode=wjson.encode

-----------------------------------------------------------------------------
--
-- function to squirt out log information
--
-- log username,"act",victims or nil,actdat1,actdat2,...
--
-----------------------------------------------------------------------------
function log(...)

local t={}

local tim=os.time()
local day=math.floor(tim/(60*60*24))
local log_filename=log_dirname..day..".csv"

local user_name=string.lower( arg[1] or "" )

local act=string.lower( arg[2] or "" )

	if act=="" then return end -- bad act

local victims=arg[3]
local victim=nil

	if type(victims)=="table" and victims[1] then --many victims
	
		victim=string.lower(victims[1])
	
	elseif victims then -- one victim
	
		victim=string.lower(victims)
		victims=nil
	
	else -- no victim
	
		victims=nil
		victim=""
	
	end

local l={tim,user_name,act,victim}

	local i=4
		while arg[i] do
			l[i+1]=arg[i]
			i=i+1
		end
	table.insert(t,table.concat(l,",").."\n")
	
	if victims then -- repeat
	
		for i,v in ipairs(victims) do
		
			if i>1 then -- skip first
			
				table.insert(t,",,,"..string.lower(v).."\n")
			
			end
		
		end
	
	end


local fp=io.open(log_filename,"a")
	if fp then
		fp:write(unpack(t))
		fp:close()
	end	
	
end
-----------------------------------------------------------------------------
--
-- append extra info to yesterdays logs
--
-----------------------------------------------------------------------------
function loglast(...)

local t={}

local tim=os.time()
local day=math.floor(tim/(60*60*24))-1 -- yesterday
local log_filename=log_dirname..day..".csv"


local l={0} -- time is not important

	local i=1
		while arg[i] do
			l[i+1]=arg[i]
			i=i+1
		end
	table.insert(t,table.concat(l,",").."\n")
	

local fp=io.open(log_filename,"a")
	if fp then
		fp:write(unpack(t))
		fp:close()
	end	
	
end

-----------------------------------------------------------------------------
--
-- twitter like logging
--
-- tlog is a shortening of the term wetlog
--
-- a public last n entries is kept available in json format
-- and this is also saved into the normal logs which are posted once a day
--
-- tlog username,str
--
-- username can be nil
--
-- names is an optional list of user names used in the str
-- games is an optional list of game names used in the str
--
-- these can be used to generate useful links for the same word used in the str
--
-----------------------------------------------------------------------------
function tlog(name,str,names,games)

-- we need to escape any commas in str, for logging

local function url_encode(str)
    return string.gsub(str, "([,])", function(c)
        return string.format("%%%02x", string.byte(c))
    end)
end


-- send to normal logfile

	log(name,"tlog",nil, (url_encode(str)) )
	
-- check our tlog cache

	if not data then return end -- no data table? no logging
	
	local cache=data.tlog or {}
	data.tlog=cache
	
	local tab={}
	
	tab.names={ name } -- list of participents names that can be found in str, first is the main active user
	tab.str=str
	tab.time=os.time()
	
	table.insert(cache,1,tab)
	
	if #cache > 50 then -- keep only last so many
		table.remove(cache,50)
	end
	
-- serv these tlogs from a file

	local j=json.Encode(cache)

	local fp=io.open(tlog_filename,"w")
	if fp then
		fp:write(j)
		fp:close()
	end	

end

-----------------------------------------------------------------------------
--
-- perform a randomly sampled tlog
--
-- chance is a number 0-1 which is the odds that this act should be broadcast
-- usd to semi filter out the less important actions
--
-- this chance is modified by the number of times that this user has already had an
-- act broadcast today.
--
-- using a 2^times scale, so chance would be /2 if one other chance tlog has succeeded
-- /4 if 2 and so on
--
-----------------------------------------------------------------------------
function tlog_chance(chance,name,...)

-- adjust chance

	local done=day_flag_get_num(name,"tlogs") or 0
	chance=chance / math.pow(2,done)
	
	if math.random() <= chance then -- perform tlog
	
		day_flag_set(name,"tlogs",done+1) -- remember that we tlogged for this user today
	
		tlog(name,...)
	end

end

