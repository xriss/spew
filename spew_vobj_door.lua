

local vobj_type = "door"

-----------------------------------------------------------------------------
--
-- create a user vobj
--
-----------------------------------------------------------------------------
local function vobj_local_create(tab)

	tab.type=vobj_type

local vobj=vobj_create(tab)

--	propdata_create(vobj)
	
--	vobj.props.menu="base/cancel/use"
	
	local vroom=vobj_get_vroom(vobj)
	local room=vroom_get_room(vroom)
			
			
	if room.ville_game and room.ville_game.door_menu then
	
		local menu=room.ville_game.door_menu(vobj)
		
		if menu then vobj.props.menu=menu end
	
	end
	
	
	return vobj
		
end

-----------------------------------------------------------------------------
--
-- check if we should change anything about this vobj, called when a player enters a room for all the rooms contents
--
-----------------------------------------------------------------------------
local function vobj_local_check(vobj)

	
	if vobj.props.brain == "vback" then -- the users room background panel thingy
	
	end

end

-----------------------------------------------------------------------------
--
-- set a prop value and broadcast the change to anyone listening
--
-----------------------------------------------------------------------------
local function vobj_local_set_vobj(vobj,prop,val,user)

	if not vobj or not prop or not val then return end
	
	if prop=="use" then
	
--dbg("use",prop,"=",val,"\n")

		if user then -- must be used by a user, since it is the user who actually moves
			
			local vuser=data.ville.users[string.lower(user.name)]
			if prop=="use" and val=="try" then -- switch try value to a previously cached use string
				if vuser and vuser.try then val=vuser.try end
			end
			local vals=str_split(":",val)
		
			local vroom=vobj_get_vroom(vobj)
			local room=vroom_get_room(vroom)
			
			local t=lanes.now_secs()
			local p1=propdata_get_xyzt(vuser,t)
			local p2=propdata_get_xyzt(vobj,t)
			local dd=xyzt_get_distance2(p1,p2)
			
			local dest
			
			if room.ville_game and room.ville_game.door_use then
			
				local done
				
				dest,done=room.ville_game.door_use(vobj,dd,prop,val,user)
				
				if done then return end
			
			end
	
			if dd > 80*80 then -- walk towards
			
--				vuser_cast(vuser, vobj_build_say_msg(vuser,"The door is AJAR!") )
			
				if vals[2] ~= "only" and vuser.propdata.root<=t then -- walk towards, if not rooted
				
					vuser.try=vals[1]..":only" -- remember to try again, but dont walk next time
					
					vobj_trigger_user(vuser,"try", vobj.id, user) -- tell the client to get back to us later
				
					vroom_clip_xyzt(vroom,p2)
					vuser_walkto(vuser,p2) -- head to object
					
				end
				
				return
			end
			
			dest=dest or vobj.props.dest
			
			if dest=="follow" then -- use last location
			
				dest=vobj.props.dest_last or "public"
				
			end

			if val=="home" or dest=="home" then -- try our home room
			
				dest=string.lower(user.name)
				
			elseif val=="corridor" or dest=="corridor" then
			
				dest="public.corridor"
						
			elseif val=="clan" or dest=="clan" then
				
				if user_confirmed(user) then
				
					dest="public"
						
					if user.form=="wolf" then
					
						dest="public.wolf"
						
					elseif user.form=="vamp" then
					
						dest="public.vamp"
						
					elseif user.form=="zom" then
					
						dest="public.zom"
						
					elseif (user.form~="chav") then
					
						dest="public.vip"

					end
				
				end
				
			elseif val=="public" or dest=="public" then
			
				dest="public"
			
			end

			if dest then
			
				local vuser,vroom
				local hold,hold_user
					
				vuser=data.ville.users[string.lower(user.name)]
				hold=vobj_get_vobj_str( vobj_get(vuser,"hold") or "" ) -- we are holding onto something?
				if hold then
					hold_user=data.names[hold.owner]
					if hold_user then
						if data.ville.users[string.lower(hold.owner)] == hold then
						else
							hold_user=nil -- sanity
						end
					end
				end
				if not hold_user then hold=nil end --sanity

				if hold_user and user then -- check we can carry them out
					if user_rank(user) < user_rank(hold_user) then -- too heavy, cant carry out
						hold=nil
						hold_user=nil
					end
				end

					
				vobj_set(vuser,"roomfrom",user.room.name) -- remember where we came from
				if hold then vobj_set(hold,"roomfrom",user.room.name) end -- carry

				local dest_parts=str_split("/",dest)
				
				if dest_parts[1] == "." then -- replace with current room
				
					dest_parts[1]=user.room.name
					
					dest=dest_parts[1].."/"..(dest_parts[2] or "")
				end
			
				if user.room.name~=dest_parts[1] then -- goto this room
						
					user.skip_auto_ville_join=true
					join_room_str(user,dest_parts[1])
					user.skip_auto_ville_join=nil
					if hold_user then -- carry
						hold_user.skip_auto_ville_join=true
						join_room_str(hold_user,dest_parts[1])
						hold_user.skip_auto_ville_join=nil
					end
				end
				
				if user.room.name == dest_parts[1] then -- join success, or we where already there
				
					vobj_set_vobj(vobj,"dest_last",dest) -- remember last destination
					
					if vobj.props.dest=="follow" then -- change title of door
					
						vobj_set_vobj(vobj,"title", string.gsub(dest, "[%.]+", " " ) ) -- remember last destination
					
					end
					
				end
				
				if dest_parts[2] and (dest_parts[2]~="") then -- join the sub room
				
					vroom=vroom_obtain_name(user.room , dest )
					
				else -- join the main vroom for this room, this function will make sure we get the right one
				
					vroom=vroom_obtain(user.room)
					
				end

				if vuser and vroom then
					
					vroom_join( vroom , vuser )
					if hold_user and hold_user.room.name == dest_parts[1] then -- room join sanity check
						if hold then vroom_join( vroom , hold ) end --carry
					end
				end
			
			end
	
		end
	
	else
	
		vobj_set_vobj(vobj,prop,val,user)
		
	end

end

-- store pointers to these functions in data tabs, creating them if we need to, so a reload updates the pointers

data.ville 						= data.ville or {}

data.ville.create 				= data.ville.create or {}
data.ville.create[vobj_type]	= vobj_local_create

data.ville.check 				= data.ville.check or {}
data.ville.check[vobj_type]		= vobj_local_check

data.ville.set 					= data.ville.set or {}
data.ville.set[vobj_type]		= vobj_local_set_vobj
