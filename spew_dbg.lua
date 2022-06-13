
local dbg_filename=( cfg and cfg.dbg_filename ) or "./spew.dbg"
local dbg_stdio=not ( cfg and cfg.dbg_stdio_off )

-----------------------------------------------------------------------------
--
-- function to squirt out dump information
--
-----------------------------------------------------------------------------
function dbg(...)


local t={}

	for i,v in ipairs({...}) do -- force to strings
	
		t[i]=tostring(v or "")
	
	end

local fp=io.open(dbg_filename,"a")
	if fp then
		fp:write(table.concat(t))
		fp:close()
	end
	
	if dbg_stdio then -- output to console?

		io.write(table.concat(t))
		io.flush()
	
	end
	
	if data and data.rooms and data.rooms.panopticon then
		local s=table.concat(t)
		s=string.gsub(s,"^%s*(.-)%s*$","%1") -- trim whitespace from ends, eg a trailing /n
		roomqueue(data.rooms.panopticon,{cmd="note",note="notice",arg1=s})
	end
end


-----------------------------------------------------------------------------
--
-- turn a client into a debug string
--
-----------------------------------------------------------------------------
function dbg_client(client)

	if client then
		local n,p = client:getpeername()
		if n and p then	return n..":"..p
		else return "*" end
	else return "*" 
	end
	
end

-----------------------------------------------------------------------------
--
-- turn a msg into a debug string
--
-----------------------------------------------------------------------------
function dbg_msg(msg)
local s="\n"
	for i,v in pairs(msg) do
		s=s..i.."="..v.."\n"
	end
	s=s.."\n"
	
	return s
end

