

-----------------------------------------------------------------------------
--
-- trime whitespace from ends of string
--
-----------------------------------------------------------------------------
function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
function trim_start(s)
  return (s:gsub("^%s*(.-)", "%1"))
end
function trim_end(s)
  return (s:gsub("(.-)%s*$", "%1"))
end




-----------------------------------------------------------------------------
--
-- split a string into a table
--
-----------------------------------------------------------------------------
function str_split(div,str,enable_special_chars)

  if (div=='') or not div then error("div expected", 2) end
  if (str=='') or not str then error("str expected", 2) end
  
  local pos,arr = 0,{}
  
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,not enable_special_chars) end do
	table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
	pos = sp + 1 -- Jump past current divider
  end
  
  if pos~=0 then
	table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  else
	table.insert(arr,str) -- return entire string
  end
  
  
  return arr
end



-----------------------------------------------------------------------------
--
-- serialize a simple table to a lua string that would hopefully recreate said table if executed
--
-- returns a string
--
-----------------------------------------------------------------------------
function serialize(o,fout)

	if not fout then -- call with a function to build and return a strin	
		local ret=""
		fout=function(s) ret=ret..s end
		serialize(o,fout)		
		return ret	
	end

	if type(o) == "number" then
	
		return fout(o)
		
	elseif type(o) == "boolean" then
	
		if o then return fout("true") else return fout("false") end
		
	elseif type(o) == "string" then
	
		return fout(string.format("%q", o))
		
	elseif type(o) == "table" then
	
		fout("{\n")
		
		for k,v in pairs(o) do
			fout("  [")
			serialize(k,fout)
			fout("] = ")
			serialize(v,fout)
			fout(",\n")
		end
		
		return fout("}\n")
	else
		error("cannot serialize a " .. type(o))
	end
	
end

-----------------------------------------------------------------------------
--
-- count table entries and table entries of sub tables upto maxdepth
--
-- hopefully this can give us some idea where lost vars and cyclic dependencies might be happening
--
-- returns a string
--
-----------------------------------------------------------------------------
function serialdbg(o,maxdepth)
local count=0

	if maxdepth==0 then return("MAXDEPTH") end

	if type(o) == "table" then
	
		local s=("{\n")
		
		for k,v in pairs(o) do
		
			count=count+1
			
			if type(v) == "table" then
			
				s=s..("  ["..tostring(k).."] = ")			
				s=s..serialdbg(v,maxdepth-1).."\n"
				
			end
			
		end
		
		return(s..count..("}\n"))
	end
	
end
	

-----------------------------------------------------------------------------
--
-- join a table of things into an english list with commas and an "and" at the end
-- returns nil if the table is empty
--
-----------------------------------------------------------------------------
function str_join_english_list(t)

local s

	for i,v in ipairs(t) do
	
		if not s then -- first
		
			s=v
			
		elseif t[i+1]==nil then -- last
		
			s=s.." and "..v
			
		else -- middle
		
			s=s..", "..v
			
		end
	
	end

	return s

end

-----------------------------------------------------------------------------
--
-- convert a string into a hex string
--
-----------------------------------------------------------------------------
function str_to_hex(s)
	return string.gsub(s, ".", function (c)
		return string.format("%02x", string.byte(c))
	end)
end

-----------------------------------------------------------------------------
--
-- escape a string for mysql
--
-----------------------------------------------------------------------------
function mysql_escape(s)
	return "0x"..str_to_hex(s)
end


-----------------------------------------------------------------------------
--
-- replace any %xx with the intended char, eg "%20" becomes a " "
--
-----------------------------------------------------------------------------
function url_decode(str)
    return string.gsub(str, "%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

-----------------------------------------------------------------------------
--
-- replace % , & and = chars with %xx codes
--
-----------------------------------------------------------------------------
function url_encode(str)
    return string.gsub(str, "([&=%%])", function(c)
        return string.format("%%%02x", string.byte(c))
    end)
--  return str
end


-----------------------------------------------------------------------------
--
-- harsh url encode of all non letters
--
-----------------------------------------------------------------------------
function url_encode_harsh(str)
    return string.gsub(str, "([^%w])", function(c)
        return string.format("%%%02x", string.byte(c))
    end)
--  return str
end

-----------------------------------------------------------------------------
--
-- decode a string into a msg
-- if last is passed in then this table is adjusted rather than a new table being created
--
-----------------------------------------------------------------------------
function str_to_msg(str,last)
local msg=last or {}
local arr
local set

	arr=str_split("&",str)
	
	for i,v in ipairs(arr) do
	
		if v~="" then
		
			set=str_split("=",v)
			
			if set[1] and set[2] then
			
				msg[ set[1] ]=url_decode(set[2])
			end
			
		end
	end

--dbg(dbg_msg(msg))

	return msg
end


-----------------------------------------------------------------------------
--
-- encode a msg into a string
-- if last is available then only *changes* from msg to last are encoded, last is also updated with these changes
-- this gives a very simple delta compression
--
-----------------------------------------------------------------------------
function msg_to_str(msg,last)
local str
local line="&"

	for i,v in pairs(msg) do
	
		if (not last) or (last[i]~=v) then -- only store changes in string
		
			line=line.. i .."=".. url_encode(v) .."&"
			
			if last then last[i]=v end
			
		end
		
	end
	
	return line
end


-----------------------------------------------------------------------------
--
-- convert a table to a unique id *number*, using the internal 32bit address so its in the range 0 - 2^32 
--
-- possible future 64bit issues?
-- well this is the future but I was promised 128bit addresses and jetpacks and flying cars so we will see
--
-- provided the table is not copied and replaced this will remain constant whilst this code runs
-- much like table comparisons
--
-----------------------------------------------------------------------------
function tab_to_uid(tab)

	return tonumber(string.sub(tostring(tab),-8),16)

end



-----------------------------------------------------------------------------
--
-- convert an ipstr "a.b.c.d" to a number
--
-----------------------------------------------------------------------------
function ipstr_to_number(str)

local num=0

	for word in string.gmatch(str, "[^.]+") do num=num*256+tonumber(word) end
	
	return num

end
-----------------------------------------------------------------------------
--
-- convert a number to an ipstr "a.b.c.d"
--
-----------------------------------------------------------------------------
function number_to_ipstr(num)

local h,s

	h=string.format("%08x",num)

	s=tonumber( string.sub(h,1,2) , 16 ) .. "." ..
	  tonumber( string.sub(h,3,4) , 16 ) .. "." ..
	  tonumber( string.sub(h,5,6) , 16 ) .. "." ..
	  tonumber( string.sub(h,7,8) , 16 ) 

	return s
end


-----------------------------------------------------------------------------
--
-- get today as a number of days since the unix epoch
--
-----------------------------------------------------------------------------
function get_today()

	return force_floor(os.time()/(60*60*24))
end


-----------------------------------------------------------------------------
--
-- call a function inside a coroutine so it may yield, handling lanes msgs but not doing anything else
--
-----------------------------------------------------------------------------
function co_wrap_and_wait(func)

	local co=coroutine.create(func)
		
	while coroutine.status(co)~="dead" do -- wait for death
	
		local ret,_ret=coroutine.resume(co)
		if ret~=true then
			print('\n'.._ret..'\n')
		end
		
		lanes_update() -- check mysql communications
		save_posix_data() -- let spewd know we are not dead yet
	end

end


-----------------------------------------------------------------------------
--
-- make sure a value is an integer like math.floor but also catches nans...
-- returns 0 if the number is garbage
-- 
-----------------------------------------------------------------------------
function force_floor(n)

-- nan is not a number, lets make sure we dont think any numbers are nans

	n=tonumber(n or 0) or 0
	n=math.floor(n) or 0
	if n~=n then n=0 end -- catch nans

	return n
end

-----------------------------------------------------------------------------
--
-- make sure the string is utf8 clean, remove any bad char sequences
-- 
-----------------------------------------------------------------------------
function clean_utf8(s)
	if type(s)~="string" then return "" end -- need a string
	
-- first check for possible utf8, 7bit clean will have nothing done to it
	if string.find(s,"[\128-\255]") then
	
		local t={}
		local state=nil
		local utf8_len=nil
		local utf8_start=nil
		local buff={}
		local buff_len=0
		local sb=string.byte
		local mf=math.floor
		local ut=0
		s:gsub(".", function(c)
		
			local n=sb(c)
			
			if utf8_len then
			
				if mf(n/64)==2 then -- a valid continue byte
					ut=(ut*64)+(n%64)
					t[#t+1]=c
					utf8_len=utf8_len-1
					if utf8_len==1 then -- this was the last one we where looking for
						if ut>=0xd800 and ut<=0xdfff then -- unicode fuckup, kill it
							for i=#t,utf8_start,-1 do
								t[i]=nil
							end
						end
						utf8_len=nil
					end
				else -- invalid, roll back
					for i=#t,utf8_start,-1 do
						t[i]=nil
					end
					utf8_len=nil -- cancel utf8 mode
				end	
				
			else -- default state
			
				if n>127 then -- control code
				
					utf8_len=nil
					if mf(n/32)==6 then -- 2 bytes
						utf8_len=2
						ut=n%32
					elseif mf(n/16)==14 then -- 3 bytes
						utf8_len=3
						ut=n%16
					elseif mf(n/8)==30 then -- 4 bytes
						utf8_len=4
						ut=n%8
					elseif mf(n/4)==62 then -- 5 bytes
						utf8_len=5
						ut=n%4
					elseif mf(n/2)==126 then -- 6 bytes
						utf8_len=6
						ut=n%2
					end
					
					if utf8_len then -- valid code, otherwise we ignore it
						utf8_start=#t+1
						t[#t+1]=c
					end
				end
				
			end
			
			if n<128 then -- always save all 7bit chars, these chars should slip through the above
				t[#t+1]=c
			end
			
		end)

		s=table.concat(t) -- put back into a string
	end

	return s or ""
end

-----------------------------------------------------------------------------
--
-- turn a number of seconds into a rough duration
--
-----------------------------------------------------------------------------
function rough_english_duration(t)
	t=math.floor(t)
	if t>=2*365*24*60*60 then
		return math.floor(t/(365*24*60*60)).." years"
	elseif t>=2*30*24*60*60 then
		return math.floor(t/(30*24*60*60)).." months" -- approximate months
	elseif t>=2*7*24*60*60 then
		return math.floor(t/(7*24*60*60)).." weeks"
	elseif t>=2*24*60*60 then
		return math.floor(t/(24*60*60)).." days"
	elseif t>=2*60*60 then
		return math.floor(t/(60*60)).." hours"
	elseif t>=2*60 then
		return math.floor(t/(60)).." minutes"
	elseif t>=2 then
		return t.." seconds"
	elseif t==1 then
		return "1 second"
	else
		return "0 seconds"
	end	
end
