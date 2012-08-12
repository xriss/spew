

-----------------------------------------------------------------------------
--
-- convert a url into a local file location
--
-- return nil if this is not possible 
--
-----------------------------------------------------------------------------
function url_to_local_file(url)

local aa

	aa=str_split(cfg.base_data_url,url)
	
	if not aa[2] then
	
		aa=str_split("http://data.wetgenes.com",url)
	
		if not aa[2] then return nil end
		
	end

	return cfg.data_dir..aa[2]

end




-----------------------------------------------------------------------------
--
-- some old simple xml parsing code, found here and fixed up a little :)
--
-- http://lua-users.org/lists/lua-l/2002-06/msg00040.html
--
-- i am creating the data being read here so this is all thats needed
--
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
--
-- auxiliar function to parse tag attributes
--
-----------------------------------------------------------------------------
function xml_parse_args(s,label)
  local arg = {}
  arg[0]=label or "?"
  string.gsub(s, "([%w_]+)%s*=%s*([\"'])(.-)%2", function (w, _, a)
    arg[string.lower(w)] = a
  end)
  return arg
end

-----------------------------------------------------------------------------
--
-- string "s" is a string with XML marks. This function parses the string
-- and returns the resulting tree.
--
-- simple but will parse small data xml files just fine and thats what im using it for
--
-- [0] == tag name
-- [1++] == contained strings or sub tags IE all numerical keys
-- [stringnames] == attributes IE all string keys
--
-----------------------------------------------------------------------------
function xml_parse(s)
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local i = 1
  local ni,j,c,label,args, empty = string.find(s, "<%?(%/?)([%w_:]+)(.-)(%/?)%?>")
  
  while ni do
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, xml_parse_args(args,label) )
    elseif c == "" then   -- start tag
      top = xml_parse_args(args,label)
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[#stack]
      if #stack < 1 then
        assert(false,"Tag <"..label.."> not matched ")
      end
      if toclose[0] ~= label then
	    assert(false,"Tag <"..(toclose[0] or "?").."> doesnt match <"..(label or "?")..">.")
      end
      table.insert(top, toclose)
    end 
    i = j+1
    ni,j,c,label,args, empty = string.find(s, "<(%/?)([%w_:]+)(.-)(%/?)>", j)
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  return stack[2]
end


--[[

local fname = cfg.data_dir.."/game/s/ville//test/room/bog_wide.xml"
local fp,fdat,ftab

	fp=io.open(fname,"r")
	if fp then
	
		fdat=fp:read("*all")
		fp:close()
	
	else
	
        assert(false,"Failed to read file "..fname)
	
	end

dbg(fdat)

ftab=xml_parse(fdat)

dbg("Dumping parsed data\n")

dbg(serialize(ftab))

assert(false,"Dumped parsed data\n")


]]

