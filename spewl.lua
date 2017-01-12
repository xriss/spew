--[[

this lua script mails the old logs and gzips them

it doesnt touch todays log

should be run once a day
]]


require ("config")
require("coxpcall")

-- always reload these files
dofile("global.lua")
global.__newindex_unlock()



-- force dbg output to this file and stdio
cfg.dbg_filename = "./spewl.dbg"
cfg.dbg_stdio_off=false



dofile("spew_dbg.lua")



function dir(path)

local command
if cfg.os=="nix" then
   command = string.format('ls -1 %s', path)
else
   command = string.format('dir /b /ON "%s"', path:gsub('/', '\\') )
end
   local pipe = assert(io.popen(command, 'r'))
   return function()
      local entry = pipe:read('*line')
      if entry then return entry end
      pipe:close()
   end
end


-- if the log file has got large, break it into parts, return the number of parts
-- break files into .0 .1 .2 etc files at 500k ish marks
function split(path)

local c=0

local size=0

local fpin=io.open(path,"r")
local fpout


	for line in io.lines(path) do

		if not fpout then
			
			fpout=io.open(path.."."..c,"w")
			size=0
		
		end
		
		fpout:write(line.."\n")
		
		size=size+string.len(line)
		
		if size>(500*1024) then -- about 500k per logfile chunk
		
			fpout:close()
			fpout=nil
			
			c=c+1
		
		end

	end
	
	if fpout then
	
		fpout:close()
		fpout=nil
	
	else -- didint actualy open a new file so reduce the count by 1 for correct return value
	
		c=c-1
		
	end

	return c+1
end


-- remove the tempory split files
function split_clean(path,count)

	if count>0 then
	
		for i=0,count-1 do
		
			local fn=path.."."..i
		
			os.remove(fn)
		
		end
	
	end

end


local today=math.floor(os.time()/(24*60*60))


dbg("Today is "..today..".\n")

local logdir='./save/logs/'

for fname in dir(logdir) do

dbg("checking ",fname,"\n")

local fday=fname:gsub(".csv","")

	if fday==tostring(tonumber(fday or 0) or 0 ) then -- logfilename is always just a number, ignore otherfiles
	
		fday=tonumber(fday)

		if fday>=today then -- skip active log
		
			dbg("SKIPPING : ",fday,"\n")
			
		else

			local cmds={}
			local fn=logdir..fday..".csv"
			local count=split(fn)
			
			if count>1 then -- log file has been split
			
				for i=0,count-1 do
				
					table.insert(cmds,string.format('mail -s%d.%d %s <%s', fday,i, cfg.email_logs, logdir..fday..".csv."..i ))
				
				end
			
			else -- single
			
				table.insert(cmds,string.format('mail -s%d %s <%s', fday, cfg.email_logs, logdir..fday..".csv" ))
			
			end
			
			table.insert(cmds,string.format('gzip -f %s', logdir..fday..".csv" ))
			
			for i,v in ipairs(cmds) do
				dbg( v ,"\n")
				if cfg.os=="nix" then
					os.execute( v )
				end
			end
			
			split_clean(fn,count) -- remove tempory files
		
		end
		
	end
	
end

