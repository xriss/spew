

local vobj_type = "hook"


-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
local function kolumbo_empty_hook()

	local b={}
	
	b.type="0"
	b.size=0
	b.string=0
	b.idx=0
	b.price=0

	return b
end

-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
local function kolumbo_fill_hook(k,i)

	local b={}
	
	math.random()
	
	if k.idx==2 then
	
		b.size=50+math.random(51)-1
		if b.size< 50 then b.size= 50 end
		if b.size>100 then b.size=100 end
		
		b.string=b.size
		b.price=b.size
		
		if i<=2 then -- always water cans items
		
			b.type="items1"
			b.idx=1
			b.size=100
		
			b.price=b.size * 10000
			
		elseif i<=6 then -- weapons
		
			b.type="zeegrind"
			b.idx=math.random(16)-1
		
			b.price=b.size * 1000
		
		elseif i<=10 then -- items
		
			b.type="items"..(math.random(1,2))
			
			if b.type=="items2" then -- only what is available
				b.idx=math.random(7)-1
			else
				b.idx=math.random(16)-1
			end
			
			b.price=b.size * 1000
		
		else
			b=kolumbo_empty_hook()
		
		end
	
	else
	
		b.size=20+math.random(31)-1
		b.string=b.size
		b.price=b.size
		
		if i==1 then -- always a watering can
		
			b.type="items1"
			b.idx=1
			
		elseif i<=6 then -- random specials
		
			b.type="items1"
			b.idx=math.random(4)+4-1
		
		else -- always letters
		
			b.type="abc"
			b.idx=math.random(26)-1
		
		end
		
	end
	
	
	return b

end

-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
local function kolumbo_fill_item(item)

	local b={}	

	b.type=item.props.type
	b.size=tonumber(item.props.size)
	b.string=tonumber(item.props.string)
	b.idx=tonumber(item.props.idx)
	b.price=b.size
	
	return b

end

-----------------------------------------------------------------------------
--
-- check and fix global kolumbo data
--
-----------------------------------------------------------------------------
local function kolumbo_check(vobj)

	data.ville.kolumbo = data.ville.kolumbo or {}
	
local idx=1 -- kolumbo type?

	local vroom=vobj_get_vroom(vobj)
	local room=vroom_get_room(vroom)
	
	if room.name=="kolumbo_bob" then -- different datas
		idx=2	
	end

local k=data.ville.kolumbo
	if not k[idx] then k[idx]={ idx=idx } end
	k=k[idx]

	if ( not k.list ) or ( not k.time ) or ( k.time+(60*60) < os.time() ) or ( not k.list[18] ) then
	
		k.time=force_floor(os.time()/(60*60))*(60*60) -- update on the hour
	
		k.list={}
		
		for i=1,18 do
		
			k.list[i]=kolumbo_fill_hook(k,i)
		
		end
	
	end

	return k
end


-----------------------------------------------------------------------------
--
-- get balloon infor for this hook
--
-----------------------------------------------------------------------------
local function kolumbo_get(vobj)

local k=kolumbo_check(vobj)
local id = force_floor(tonumber(vobj.props.id) or 0)
local b=k.list[id]

	return b
end

-----------------------------------------------------------------------------
--
-- set balloon infor for this hook
--
-----------------------------------------------------------------------------
local function kolumbo_set(vobj,b)

local k=kolumbo_check(vobj)
local id = force_floor(tonumber(vobj.props.id) or 0)

	k.list[id]=b
end

-----------------------------------------------------------------------------
--
-- return the menu prop string for this kolumbo hook
--
-----------------------------------------------------------------------------
local function kolumbo_menu(vobj)

local k=kolumbo_check(vobj)
local id = force_floor(tonumber(vobj.props.id) or 0)
local b=k.list[id]

	if not b then return "base/cancel" end

	if b.type=="0" then return "base/cancel/appraise/sell" end
	
	return "base/cancel/examine/buy:base buy/pay "..b.price.."c/cancel"
end

-----------------------------------------------------------------------------
--
-- return the balloon prop string for this kolumbo hook
--
-----------------------------------------------------------------------------
local function kolumbo_balloon(vobj)

local k=kolumbo_check(vobj)
local id = force_floor(tonumber(vobj.props.id) or 0)
local b=k.list[id]

	if not b then return "0:0:0:0:0" end
	
	if b.type=="0" then return "0:0:0:0:0" end

	return "0:"..b.type..":"..b.idx..":"..b.size..":"..b.string

end


-----------------------------------------------------------------------------
--
-- create a user vobj
--
-----------------------------------------------------------------------------
local function vobj_local_create(tab)

--dbg("creating ",vobj_type,"\n")
--dbg(tab.props.brain,"\n")

	tab.type=vobj_type

local vobj=vobj_create(tab)

--	propdata_create(vobj)
	
	if vobj.props.brain == "god" then -- a god balloon hook, only the rooms owner can use it to switch to their god balloon
	
		vobj.props.menu="base/cancel/use"
		vobj.props.balloon1="0:godloons:0:75:75"
		
	elseif vobj.props.brain == "event" then -- a special event balloon generator hook
	
		vobj.props.menu="base/cancel"
		vobj.props.balloon1="0:0:0:0:0"
		
	elseif vobj.props.brain == "kolumbo" then -- the shop keeper
	
		vobj.props.menu=kolumbo_menu(vobj)
		vobj.props.balloon1=kolumbo_balloon(vobj)
		
	elseif vobj.props.brain == "zeegrind" then -- zeegrind weapons
	
		vobj.props.menu=zeegrind_hook_menu(vobj)
		vobj.props.balloon1=zeegrind_hook_balloon(vobj)
		
	elseif vobj.props.brain == "closet" then
	
		vobj.props.menu="base/cancel/examine/use"
		
		local vroom=vobj_get_vroom(vobj)
		if vroom then
		
			local it=get_item_by_home(vroom.name.."/"..vobj.props.id.."/balloon")
			
			if it then
				vobj.props.balloon1=item_to_balloon_str(it)
			end
		
		end
		
	else
	
		vobj.props.menu="base/cancel/use:base use/sorry/this/isnt/working/yet"
	
	end
		
	return vobj
		
end

-----------------------------------------------------------------------------
--
-- check if we should change anything about this vobj, called when a player enters a room for all the rooms contents
--
-----------------------------------------------------------------------------
local function vobj_local_check(vobj)

local user=get_user(vobj.owner)
local vuser=get_vuser(vobj.owner)

	if vobj.props.brain == "god" then

		if user and vuser then
		
			if is_room_owner(user.room , user.name) then -- auto give god balloons to room owners or gods who are holding nothing
			
				local b1=vuser.props.balloon  or "0:0:0:0:0"
				local b2=vobj .props.balloon1 or "0:0:0:0:0"
				
				local s1=str_split(":",b1)[2]
				local s2=str_split(":",b2)[2]
				
				if s1=="" or s1=="0" then -- give a godballoon if we do not have one and it is not on hook
				
					if s2~="godloons" then -- give a godballoon if we do not have one and it is not on hook
					
						vobj_set(vuser,"balloon","godloons:0:75")
						
					end
				end
			end
		end
		
		if vuser then -- do nothing if the user is not logged in
		
			local b=vuser.props.balloon or "0:0:0:0:0"
			
			if str_split(":",b)[2]~="godloons" then -- force a godballoon onto the hook, unless we already have one
			
				vobj_set(vobj,"balloon1","0:godloons:0:75:75")
				
			else -- hide the god balloon from the hook?
			
				local b=vobj.props.balloon1 or "0:0:0:0:0"
				
				if str_split(":",b)[2]=="godloons" then -- hide any god ballloon on the hook
				
					vobj_set(vobj,"balloon1","0:0:0:0:0")
				
				end
				
			end
		
		end
	
	elseif vobj.props.brain == "closet" then -- a users balloon closet
	
		local vroom=vobj_get_vroom(vobj)
		if vroom then
		
			local it=get_item_by_home(vroom.name.."/"..vobj.props.id.."/balloon")
			
			if it then
				vobj_set(vobj,"balloon1" , item_to_balloon_str(it) )
			else
				vobj_set(vobj,"balloon1" , item_to_balloon_str(nil) )
			end
		
		end
		
	elseif vobj.props.brain == "kolumbo" then -- the shop keeper
	
		kolumbo_check(vobj)
		vobj_set(vobj,"menu" , kolumbo_menu(vobj) )
		vobj_set(vobj,"balloon1" , kolumbo_balloon(vobj) )
		
	elseif vobj.props.brain == "event" then
		
		local event=day_flag_get(vobj.owner,"event")
		
		if event=="birthday" then
		
		local props={}
		
			item_setname_balloon(props,"cake")
			props.size=50
			props.string=50
			props.title=vobj.owner
			
			vobj_set(vobj,"menu" , "base/cancel/take" )
			vobj_set(vobj,"balloon1" , "0:"..item_props_to_balloon_str(props) )
						
		else
		
			vobj_set(vobj,"menu" , "base/cancel" )
			vobj_set(vobj,"balloon1" , "0:0:0:0:0" )
			
		end

	end

end


-----------------------------------------------------------------------------
--
-- set a prop value and broadcast the change to anyone listening
--
-----------------------------------------------------------------------------
local function vobj_local_set_vobj(vobj,prop,val,user)

	if not vobj or not prop or not val then return end
	
--dbg(vobj.id," hook test ",prop," : ",val,"\n")

	if type(vobj.props[prop])~=type(val) or vobj.props[prop]~=val then -- setting a prop to the same value does nothing
	
		local vuser
		if user then vuser=data.ville.users[string.lower(user.name)] end -- get vuser if a user is operating this
		
		if prop=="use" and val=="try" then -- switch try value to a previously cached use string
			if vuser and vuser.try then val=vuser.try end
		end
		local vals=str_split(":",val)

		if prop=="use" then -- custom menu act

--dbg(vobj.id," hook use ",val,"\n")

		
			if vobj.props.brain == "god" then -- a god hook, so we can switch to a god balloon, old balloon gets placed on your god hook
			
				if vals[1]=="base use" then
					if user and vuser then
					
					
						if vobj_edit_lock(vobj,user.name) then -- we are allowed to get or drop the god balloon
						
							local b1=vuser.props.balloon  or "0:0:0:0:0"
							local b2=vobj .props.balloon1 or "0:0:0:0:0"
															
							if str_split(":",b1)[2]~="godloons" then -- force hook to give out a god balloon unless we already have one
							
								b2="0:godloons:0:75"
							
							end
			
							vobj_set(vobj,"balloon1",b1)
							vobj_set(vuser,"balloon",b2)
					
						else
					
							userqueue(user,{cmd="note",note="act",arg1="***ACCESS***DENIED***"})
							
						end					
					end
				end
				
			elseif vobj.props.brain == "event" then -- give out a special ballon, maybe
			
				local event=day_flag_get(vobj.owner,"event")
				
				vobj_local_check(vobj)

				if event=="birthday" then
									
					if vals[1]=="base take" then -- give out balloon
					
						if get_item_by_home(string.lower(user.name).."/balloon") then -- can not be holding a balloon
						
							userqueue(user,{cmd="note",note="act",arg1="Sorry but you are already carrying a balloon."})
						
						else
					
							local item=item_create_balloon( user, vobj.props.balloon1 ) -- create temporary balloon									
							item_save(item) -- make it real, if this is a real user
							vobj_set(vuser,"balloon", item_to_balloon_str(item) ) -- place it in hand
							
						
						end
					end
					
				else
				
				end
				
				
				
			elseif vobj.props.brain == "zeegrind" then -- a weapon hook
			
				if vals[1]=="base examine" then
				
					zeegrind_hook_examine(user,vobj)
				
				elseif vals[1]=="base compare" then
				
					zeegrind_hook_compare(user,vobj)
				
				elseif vals[1]=="base about" then
				
					zeegrind_hook_about(user,vobj)
				
				elseif vals[1]=="base take" then
					
					local t=lanes.now_secs()
					local p1=propdata_get_xyzt(vuser,t)
					local p2=propdata_get_xyzt(vobj,t)
					local dd=xyzt_get_distance2(p1,p2)
					
					if dd < 80*80 then -- close enough
					
						zeegrind_hook_take(user,vobj)
					
						vobj_trigger(vobj,"jiggle", 0.25) -- jiggle balloon
					
					else -- walk towards
					
						if vals[2] ~= "only" and vuser.propdata.root<=t then -- walk towards, if not rooted
						
							vuser.try=vals[1]..":only" -- remember to try again, but dont walk next time
							
							vobj_trigger_user(vuser,"try", vobj.id, user) -- tell the client to get back to us later
						
							vuser_walkto(vuser,p2) -- head to object
							
						end
					end
				end
			
			elseif vobj.props.brain == "closet" then -- a keeper hook
			
				if vals[1]=="base examine" then
				
					local vroom=vobj_get_vroom(vobj)
					local s=item_info_balloon(nil)
					
					if vroom then
					
						local it=get_item_by_home(vroom.name.."/"..vobj.props.id.."/balloon")
						
						if it then
							s=item_info_balloon(it.props)
						end
					end
					
					userqueue(user,{cmd="note",note="act",arg1=s  }) -- about this balloon
					
				elseif vals[1]=="base use" then
				
					local vroom=vobj_get_vroom(vobj)
					
					if user and vuser and vroom then
					
						if vobj_edit_lock(vobj,user.name) then -- we are allowed to swap with this balloon
						
						
							local hook=get_item_by_home(vroom.name.."/"..vobj.props.id.."/balloon")
							local hand=get_item_by_home(string.lower(user.name).."/balloon")
							
							if hook and hand then -- swap
							
								item_home_swap(hook,hand)
								item_save(hook)
								item_save(hand)
									
							else 
									
								if hand then -- update home to hook and save
								
									item_rehome(hand, vroom.name.."/"..vobj.props.id.."/balloon" )
									item_save(hand)
								
								end
								
								if hook then -- update home to hand and save
								
									item_rehome(hook, string.lower(user.name).."/balloon" )
									item_save(hook)
								end
							end
							
							vobj_local_check(vobj)
							vuser_check_balloon(vuser)
							
--[[						
							local b1=vuser.props.balloon  or "0:0:0:0:0"
							local b2=vobj .props.balloon1 or "0:0:0:0:0"
							
							local a1=str_split(":",b1)
							local a2=str_split(":",b2)
							
							if a1[2]=="godloons" then -- cant put god balloon here				
								b1="0:0:0:0:0"
								a1=str_split(":",b1)
							end
							
							a1[1]=tonumber(a1[1]) or 0
							a2[1]=tonumber(a2[1]) or 0
							
							vobj_set(vobj,"balloon1",b1)
							vobj_set(vuser,"balloon",b2)
							
							local it1=get_item_by_id(a1[1])
							local it2=get_item_by_id(a2[1])
							
							if it1 and it2 then -- swap
							
								item_home_swap(it1,it2)
								item_save(it1)
								item_save(it2)
									
							else 
									
								if it1 then -- update home to hook and save
								
									item_rehome(it1, vroom.name.."/"..vobj.props.id.."/balloon" )
									item_save(it1)
								
								end
								
								if it2 then -- update home to hand and save
								
									item_rehome(it2, string.lower(user.name).."/balloon" )
									item_save(it2)
								end
							end
]]					
						else
					
							userqueue(user,{cmd="note",note="act",arg1="***ACCESS***DENIED***"})
							
						end
						
					end
				end
			
			elseif vobj.props.brain == "kolumbo" then -- the shop keeper
			
			
				if vals[1]=="base examine" then
				
					userqueue(user,{cmd="note",note="act",arg1= item_info_balloon(kolumbo_get(vobj)) }) -- about this balloon
					
						
				elseif vals[1]=="base appraise" then
				
					local b = kolumbo_get(vobj)
										
					if user and vuser and b then
					
						local it=get_item_by_home(string.lower(user.name).."/balloon")
						
						if not it then -- must have balloon
						
							userqueue(user,{cmd="note",note="act",arg1="You have no balloon to sell."})
							return
						end
						
						local price= force_floor( ( tonumber(it.props.size) or 0 ) / 2 )
						
						userqueue(user,{cmd="note",note="act",arg1="Your balloon is worth "..price.." cookies."})
					
					end
				
				elseif vals[1]=="base sell" then
				
					local b = kolumbo_get(vobj)
					
					if user and vuser and b then
					
						if b.type~="0" then -- cant sell to this hook
						
							userqueue(user,{cmd="note",note="act",arg1="Sorry but that hook has been taken."})
							return
						end
					
						local it=get_item_by_home(string.lower(user.name).."/balloon")
						
						if not it then -- must have balloon
						
							userqueue(user,{cmd="note",note="act",arg1="You have no balloon to sell."})
							return
						end
						
						local price= force_floor( ( tonumber(it.props.size) or 0 ) / 2 )
						
						userqueue(user,{cmd="note",note="act",arg1="Kolumbo has paid you "..price.." cookies."})
						user.cookies=user.cookies+price
						
						kolumbo_set(vobj, kolumbo_fill_item(it) )
						
						it.owner=nil -- no longer belongs to anyone
						item_rehome(it,".")  -- no longer lives anywhere
						item_save(it) -- save this item
					
						vobj_set(vuser,"balloon","0:0:0:0:0")
						vobj_set(vobj,"menu" , kolumbo_menu(vobj) )
						vobj_set(vobj,"balloon1" , kolumbo_balloon(vobj) )
						
						
					end
					
				elseif string.sub(vals[1],1,12)=="base buy pay" then
				
					if user and vuser then
					
						local b = kolumbo_get(vobj)
						
						if b then
						
							if get_item_by_home(string.lower(user.name).."/balloon") then -- can not be holding a balloon
							
								userqueue(user,{cmd="note",note="act",arg1="Sorry but you are already carrying a balloon."})
							
							elseif b.type=="0" then -- no balloon
							
								userqueue(user,{cmd="note",note="act",arg1="Sorry but we are sold out."})
									
							else
						
								if user.cookies >= b.price then -- pay and get balloon
								
									user.cookies = user.cookies - b.price
									
									local item=item_create_balloon( user, vobj.props.balloon1 ) -- create temporary balloon									
									item_save(item) -- make it real, if this is a real user
									vobj_set(vuser,"balloon", item_to_balloon_str(item) ) -- place it in hand
									
									kolumbo_set(vobj,kolumbo_empty_hook()) --remove from stock
									
									vobj_set(vobj,"menu" , kolumbo_menu(vobj) )
									vobj_set(vobj,"balloon1" , kolumbo_balloon(vobj) )
		
--									dbg(item_to_balloon_str(item),"\n")
								
									userqueue(user,{cmd="note",note="act",arg1="You have paid "..b.price.." cookies for a shiny new balloon."})
								else
									
									userqueue(user,{cmd="note",note="act",arg1="Sorry but you do not have "..b.price.." cookies."})
								
								end
							
							end
							
						end
						
					end
				
				end
				
			end
		
		else
	
			vobj.props[prop]=val

			vobj.changes[prop]=val	-- changed flags
			data.ville.changes[vobj.id]=true
		
		end
		
	end

end

-- store pointers to these functions in data tabs, creating them if we need to, so a reload updates the pointers to these functions

data.ville 						= data.ville or {}

data.ville.create 				= data.ville.create or {}
data.ville.create[vobj_type]	= vobj_local_create

data.ville.check 				= data.ville.check or {}
data.ville.check[vobj_type]		= vobj_local_check

data.ville.set 					= data.ville.set or {}
data.ville.set[vobj_type]		= vobj_local_set_vobj
