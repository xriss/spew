
local vobj_type = "pot"

local grow_pulse=60 -- grow in 100 mins
--grow_pulse=1

-----------------------------------------------------------------------------
--
-- return the menu prop string for this hook
--
-----------------------------------------------------------------------------
local function grow_menu(vobj)

	local vroom=vobj_get_vroom(vobj)
	if not vroom then return "base/cancel" end  -- must have a vroom
	local it=get_item_by_home(vroom.name.."/"..(vobj.props.id or 0).."/balloon")
	
	if it then -- we are growing something
	
		if (not it.props.grow) or (tonumber(it.props.grow)==100) then -- finished growing
		
			return "base/cancel/examine/harvest"
		
		end
	
		return "base/cancel/examine/plant/water:base plant/balloon/cancel"

	else -- we may start planting something
	
		return "base/cancel/plant:base plant/balloon/cancel"
		
	end
end

-----------------------------------------------------------------------------
--
-- return the balloon prop string for this hook
--
-----------------------------------------------------------------------------
local function grow_balloon(vobj)

	local vroom=vobj_get_vroom(vobj)
	local it
	if vroom then it=get_item_by_home(vroom.name.."/"..(vobj.props.id or 0).."/balloon") end
	
--dbg(item_to_balloon_str(it),"\n")

	return item_to_balloon_str(it)

end

-----------------------------------------------------------------------------
--
-- object should do some growing
--
-----------------------------------------------------------------------------
local function grow_check(vobj)

	local vroom=vobj_get_vroom(vobj)
	local it
	if vroom then it=get_item_by_home(vroom.name.."/"..(vobj.props.id or 0).."/balloon") end

	if not it then return end -- the item grows, but we do not have one so just return
	
	local props=it.props
	
	if (not props.grow_time) or (tonumber(props.grow_time)==100) then return end -- finshed growing
	
	props.size=tonumber(props.size or 0) -- make sure
	local pa=str_split(":",props.grow_soil)
	for i,v in ipairs(pa) do pa[i]=tonumber(v) end -- keep soil state as numbers
	
	
	local t=os.time() - tonumber(props.grow_time)
	
	local tage=tonumber(props.grow)
	
	local tnow=force_floor(t/tonumber(props.grow_pulse or 1))
	
	local updated=false
	
	while ( tnow > tage ) and ( tage < 100 ) do -- age 1 tick at a time till we hit 100
	
		local name=item_name_balloon(props)
		
		if (tage==50) and ( (name=="sprout") or (name=="none") ) then -- sprout or unknown should flower at this point
		
			item_setname_balloon( props , props.grow_spell )
			name=item_name_balloon(props)
				
			if (name~="sprout") and (name~="none") then -- the spell kicked in, so just randomize size as well
			
				props.size=props.size+math.random(20)
				props.string=props.size
				
			else
			
				-- just grow a letter
				local ns=string.lower(props.grow_spell or "") -- makesure it is lower
				local nl=string.len(ns)
				local n=1 -- seed with 1 so by default a becomes b , b becomes c etc
				
				if nl>0 then -- we have a spell
				
					for i=1,nl do -- add the value of each letter, a=1 b=2 c=3 etc
						n=n+1+string.byte(ns,i)-string.byte("a")
					end
					n=(n-1)%26 -- wrap the letters so z+1 becomes a
					
				else -- just a random letter
				
					n=math.random(26)-1
					
				end
				
				props.type="abc"
				props.idx=n
				props.size=props.size+math.random(20)
				props.string=props.size
				
			end
		
		end
		
		if ( props.size<50 ) and ( props.size<tage ) then -- can try to grow, using up water
		
			if pa[4] > props.size then
			
				props.size=props.size+1
				
				pa[4]=pa[4]-5
				if pa[4]<0 then pa[4]=0 end
				
			end
		
		end
	
		tage=tage+1		
		props.grow=tage
		updated=true
	end
	
	if updated then -- save the items and change display
	
		props.grow_soil=pa[1]..":"..pa[2]..":"..pa[3]..":"..pa[4]..":"..pa[5] -- remember removed water
	
		item_save(it)
	
		vobj_set(vobj,"menu" ,     grow_menu(vobj)    )
		vobj_set(vobj,"balloon1" , grow_balloon(vobj) )
	end
	
	
	
end


-----------------------------------------------------------------------------
--
-- add a letter to the word of power
--
-----------------------------------------------------------------------------
local function grow_spell(props,letter)

local abc_lookup={
		"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
	}
	
	props.grow_spell=props.grow_spell .. abc_lookup[tonumber(letter.idx)+1]
	props.grow_power=props.grow_power .. ":" .. letter.size
		
end

-----------------------------------------------------------------------------
--
-- water this plant
--
-----------------------------------------------------------------------------
local function grow_water(props,water)

local wa=str_split(":",water)
local pa=str_split(":",props.grow_soil)

	for i,v in ipairs(wa) do

		local w=tonumber(wa[i])
		local p=tonumber(pa[i])
		
		if w>p then pa[i]=w end
	end
	
	props.grow_soil=pa[1]..":"..pa[2]..":"..pa[3]..":"..pa[4]..":"..pa[5]

end
	
-----------------------------------------------------------------------------
--
-- setup initial growing conditions for this items props
--
-----------------------------------------------------------------------------
local function grow_prepare(props)


	props.grow=0	-- when we hit 100 we are ripe, grow by 1 every pulse
	
	props.grow_time=math.ceil(os.time()/grow_pulse)*grow_pulse -- the time stamp we where planted, rounded up to the pulse interval
	
	props.grow_spell=""	-- the word of power starts off blank
	props.grow_power=""
	props.grow_soil="0:0:0:0:0"
	props.grow_pulse=grow_pulse
		
	if props.type=="abc" then -- if we started with a letter then the letter also starts the spell
	
		grow_spell(props,props)
		
	-- and this letter turns into a sprout which will later turn back into something else
	
		props.type="items1"
		props.idx=0
		props.size=20
		props.string=props.size
		
	end

end

-----------------------------------------------------------------------------
--
-- remove growing props on harvest
--
-----------------------------------------------------------------------------
local function grow_harvest(props)

	props.grow=nil
	props.grow_time=nil
	props.grow_spell=nil
	props.grow_power=nil
	props.grow_soil=nil
	props.grow_pulse=nil
	
end

-----------------------------------------------------------------------------
--
-- create coroutine (if necesary) then call it
--
-----------------------------------------------------------------------------
function vobj_update(vobj)

	if type(vobj.co)~="thread" then vobj.co=nil end -- no co yet
	if vobj.co and coroutine.status(vobj.co)=="dead" then vobj.co=nil end -- the co died
	
	if not vobj.co then -- need to create a new co
	
		vobj.co=coroutine.create(grow_check)
	
	end

	local ret,_ret=coroutine.resume(vobj.co,vobj)
	if ret~=true then
		print('\n'.._ret..'\n')
	end

end

-----------------------------------------------------------------------------
--
-- create a user vobj
--
-----------------------------------------------------------------------------
local function vobj_local_create(tab)

	tab.type="pot"

local vobj=vobj_create(tab)

	propdata_create(vobj)
	
--	vobj.update=function(vobj) vobj_update(vobj) end  -- set update hook to fetch a global test growing function
--	queue_update(vobj)


	local d={} -- keep some object dependent state information in this table
	vobj.data=d
	
	d.start=lanes.now_secs()
	d.pulse=d.start
	
	vobj.props.pulse=grow_pulse -- client should check for updates to this object every pulse seconds
	
	vobj.props.menu=grow_menu(vobj)
	vobj.props.balloon1=grow_balloon(vobj)
	
	return vobj
		
end

-----------------------------------------------------------------------------
--
-- check if we should change anything about this vobj, called when a player enters a room for all the rooms contents
--
-- check if plan should grow and change acording to the current time and if so adjust the properties
--
-----------------------------------------------------------------------------
local function vobj_local_check(vobj)

	grow_check(vobj)

end

-----------------------------------------------------------------------------
--
-- set a prop value and broadcast the change to anyone listening
--
-----------------------------------------------------------------------------
local function vobj_local_set(vobj,prop,val,user)

local vuser

	if not vobj or not prop or not val then return end
	
	if type(vobj.props[prop])~=type(val) or vobj.props[prop]~=val then -- setting a prop to the same value does nothing

		if user then vuser=data.ville.users[string.lower(user.name)] end -- get vuser if a user is operating this
		
		if prop=="use" then -- custom menu act
		
			vobj_local_check(vobj) -- make plant grow if it should
			
			local vroom=vobj_get_vroom(vobj)
	
			if not vroom or not user or not vuser then return end -- must have a room and a user to use :)
			
			local plant_name=vroom.name.."/"..vobj.props.id.."/balloon" 	-- where the balloon lives
			local plant=get_item_by_home(plant_name) 						-- the planted balloon or nil
			local it=get_item_by_home(string.lower(user.name).."/balloon") 	-- the ballon we are holding or nil
			
dbg("pot use ",val,"\n")		

			if val=="base examine" then -- print info about the plant
				
				local s=item_info_balloon(nil)
				local it=get_item_by_home(vroom.name.."/"..vobj.props.id.."/balloon")
					
				if it then
					s=item_info_balloon(it.props)
				end
				
				userqueue(user,{cmd="note",note="act",arg1=s  }) -- about this balloon
				
			elseif val=="base plant balloon" then -- plant a balloon in this pot
		
				if not vobj_edit_lock(vobj,user.name) then -- we are allowed to use this pot
				
					userqueue(user,{cmd="note",note="act",arg1="***ACCESS***DENIED***"})
					
				else
				
					if not it then -- must have balloon
					
						userqueue(user,{cmd="note",note="act",arg1="You have no balloon to plant."})
						return
					end
					
					if not plant then -- can plant any balloon at the start, this ballon keeps its stats
					
						item_rehome(it, plant_name ) -- place in pot
						
						grow_prepare(it.props) -- get ready to grow
						
						item_save(it) -- save the act of planting to the DB
						vobj_set(vuser,"balloon","0:0:0:0:0")
										
					else -- but after the first balloon, only letters can be planted, these can adjust what grows
					
						if it.props.type~="abc" then -- must have letter balloon
						
							userqueue(user,{cmd="note",note="act",arg1="You may only add more letter balloons to the pot."})
							return
						end
						
						grow_spell( plant.props , it.props )
						item_save(plant) -- save the act of planting to the DB
						
						
						it.owner=nil -- no longer belongs to anyone
						item_rehome(it,".")  -- no longer lives anywhere
						item_save(it) -- save the act of planting to the DB
						
						vobj_set(vuser,"balloon","0:0:0:0:0") -- remove balloon from hand
						
					end
				end
						
			elseif val=="base water" then -- water this plant if we are holding a watering can

				if  plant then -- need a plant		
				
					local fail=true
					
					if it then -- check carried balloon
					
						local name=item_name_balloon(it.props)
						
						if name=="bluewater" then -- we got a watering can, so water this plant
						
							grow_water(plant.props,"0:0:0:"..(it.props.size)..":0") -- fire:earth:air:water:meta
							item_save(plant)
							
							fail=false
						end
						
						if not fail then
							userqueue(user,{cmd="note",note="act",arg1="pot has been watered"  }) -- about this balloon
							userqueue(user,{cmd="note",note="act",arg1=item_info_balloon(plant.props)  }) -- about this balloon
						end
				
					end

					if fail then
						userqueue(user,{cmd="note",note="act",arg1="Sorry but you need a water balloon to be able to water this plant."})
					end
					
				end
					
			elseif val=="base harvest" then -- take the balloon out
			
				if vobj_edit_lock(vobj,user.name) then -- we are allowed to take this balloon
				
					
					if it then -- cant take as we already have a balloon
					
						userqueue(user,{cmd="note",note="act",arg1="Sorry but you are already carrying a balloon."})
						return
					end
					
					if plant then -- update plant to hand and save
					
						grow_harvest(plant.props) -- remove growing data
						item_rehome(plant, string.lower(user.name).."/balloon" )
						item_save(plant)
						vobj_set(vuser,"balloon", item_to_balloon_str(plant) ) -- place it in hand
					end
			
				else
			
					userqueue(user,{cmd="note",note="act",arg1="***ACCESS***DENIED***"})
					
				end
			end
		
			vobj_set(vobj,"menu" , grow_menu(vobj) )
			vobj_set(vobj,"balloon1" , grow_balloon(vobj) )
	
		else
	
			vobj.props[prop]=val

			vobj.changes[prop]=val	-- changed flags
			data.ville.changes[vobj.id]=true
		
		end
		
	end

end



--[[
-----------------------------------------------------------------------------
--
-- update check
--
-----------------------------------------------------------------------------
function vobj_pot_update(vobj)

--	if not vobj then return remove_update(vobj) end -- passed in sanity

local d=vobj.data
local t=lanes.now_secs()
local pulse=1

	if t < d.pulse + pulse then return end -- check every pulse secs
	d.pulse=d.pulse+pulse -- wait for next check
	
	if not data.ville.vobjs[vobj.id] then return remove_update(vobj) end -- check we still exist
	
local g= (t - d.start)/pulse
local siz=0
local len=0

	for i=1,3 do

		if g<20 then
		
			siz=g*4;
			len=g*2;
		
			vobj_set(vobj,"balloon"..i,"0:items1:16:"..siz..":"..len)

		else
			local g=40-g
			if g<0 then g=0 end
			
			siz=g*4;
			len=g*2;
			
			vobj_set(vobj,"balloon"..i,"0:items1:19:"..siz..":"..len)
		
		end
		
	end

end
]]

-- store pointers to these functions in data tabs, creating them if we need to, so a reload updates the pointers to these functions

data.ville 						= data.ville or {}

data.ville.create 				= data.ville.create or {}
data.ville.create[vobj_type]	= vobj_local_create

data.ville.check 				= data.ville.check or {}
data.ville.check[vobj_type]		= vobj_local_check

data.ville.set 					= data.ville.set or {}
data.ville.set[vobj_type]		= vobj_local_set

