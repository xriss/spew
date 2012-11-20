
-----------------------------------------------------------------------------
--
-- find a vuser by name, case is ignored
--
-----------------------------------------------------------------------------
function get_vuser(name)

	if not name then return nil end
	
	return data and data.ville and data.ville.users and data.ville.users[string.lower(name)]
	
end

-----------------------------------------------------------------------------
--
-- activate special balloon give effect, when you give someone a balloon
--
-----------------------------------------------------------------------------
function vuser_balloon_activate(vuser)

	local name=string.lower(vuser.owner)
	
	local user=get_user(name)
	if not user then return end

	local loc=name.."/balloon"
	
	local it=get_item_by_home(loc)
	if not it then return end
	
	local bnam=item_name_balloon(it.props)
	
	local form
	
-- change to form of balloon
    if bnam=="chav" then
		form="chav"
	elseif bnam=="zombie" then
		form="zom"
	elseif bnam=="human" then
		form=nil
	elseif bnam=="werewolf" then
		form="wolf"
	elseif bnam=="vampire" then
		form="vamp"
	else
		return
	end
	
	if not room_lock_form_test(user.room,form) then return end -- cant turn here

	if not is_admin(user.name) then -- doesnt work on us
	
		if user.form~=form then -- turn to form
			user.form=form
			roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has turned into a "..user_form(user).." "..user_rank_name(user)})
		end
		
	end
	
end

-----------------------------------------------------------------------------
--
-- get an avatar url for a given user name
--
-----------------------------------------------------------------------------

function vuser_avatar_url(name,url_name)

local default=cfg.base_data_url.."/game/s/ville/test/vtard/me.xml"


local user=get_user(name)
	if user and user.hostname and string.sub(user.hostname,1,20)=="http://cgi.4chan.org" then
	
		default=cfg.base_data_url.."/game/s/ville/test/vtard/default.failchan.xml"
		
	end


	name=string.lower(name or "me") -- make sure
	
	if url_name then -- setting a name
	
		url_name=string.gsub(url_name, "[ ]+", "_" )
		url_name=string.gsub(url_name, "[^0-9a-zA-Z%-_%.]+", "" )
		url_name=string.lower(url_name) -- make sure

		if url_name=="me" then -- reset
		
			data.ville.avatars[name]=nil
			
		else
	
			data.ville.avatars[name]=cfg.base_data_url.."/game/s/ville/test/vtard/default."..url_name..".xml"
			
--			data.ville.avatars[name]=cfg.base_data_url.."/game/s/ville/test/vtard/z.liz.xml"

		end		
	end

	if not data.ville.avatars[name] then -- try and build a new one
	
		if not data.ville.avatars[name] then -- check disk

			local fname = cfg.data_dir.."/game/s/ville/test/vtard/"..name..".xml"
			local fp=io.open(fname,"r")
			
			if fp then
				fp:close()
				data.ville.avatars[name]=cfg.base_data_url.."/game/s/ville/test/vtard/"..name..".xml"
			end
			
		end
	
		data.ville.avatars[name] = data.ville.avatars[name] or default
	
	end
	
--dbg("name:",name,"=",data.ville.avatars[name],"\n")

	return data.ville.avatars[name]

end


-----------------------------------------------------------------------------
--
-- create a bot in a room, or a global bot if no room given
--
-----------------------------------------------------------------------------
function vuser_create_bot(tab)

-- bot defaults
	tab.type="bot"
	tab.group=nil
	tab.url=tab.url or vuser_avatar_url(tab.owner)
	tab.props={ xyz="0:0:0" , anim="idle" , speed="100" , name=tab.name }

local vobj=vobj_create(tab)

	propdata_create(vobj)

	return vobj
		
end

-----------------------------------------------------------------------------
--
-- create a user vobj
--
-----------------------------------------------------------------------------
function vuser_create(tab)

local vobj=vobj_create(tab)

	propdata_create(vobj)

--dbg("VUSER:"..serialize(vobj))

	data.ville.users[tab.owner]=vobj -- save into users list
	
	return vobj
		
end

-----------------------------------------------------------------------------
--
-- destroy a user vobj
--
-----------------------------------------------------------------------------
function vuser_destroy(vobj)

	if not vobj then return end

	vobj_destroy(vobj)

end

-----------------------------------------------------------------------------
--
-- destroy a user vobj given a user
--
-----------------------------------------------------------------------------
function vuser_destroy_by_user(user)

	if not user then return end

local vroom,vobj

	vobj=data.ville.users[string.lower(user.name)]

	if vobj and vobj.parent then
	
		vroom=data.ville.vobjs[ vobj.parent ]
		
		if vroom then

			vroom_send_del(vroom,vobj)
		
		end
		
	end
	
--	vuser_destroy( data.ville.users[string.lower(user.name)] )
	
--	data.ville.users[user.name] = nil
	
end

-----------------------------------------------------------------------------
--
-- sync the position of this users vuser if it exists
--
-----------------------------------------------------------------------------
function vuser_sync_room_by_user(user)

local vuser,vroom

	if not user then return end	
	if not data.ville.users then return end
	
	vuser=data.ville.users[string.lower(user.name)]

	if not vuser then return end
	
	local room=user.room
	
	vroom=vroom_obtain(room)
	
	if room and room.ville_game then -- talk to the ville game
		if room.ville_game.vroom_which then vroom=room.ville_game.vroom_which(room,user) end
	end
			
	vroom_join( vroom , vuser )
			
end

-----------------------------------------------------------------------------
--
-- get or create the player vobj for this user
--
-----------------------------------------------------------------------------
function vuser_obtain(user)

local name=string.lower(user.name)
local tab
local vuser

dbg("vuser_obtain ",name,"\n")

	vuser=data.ville.users[name]
	
	if not vuser then -- need to create

dbg("vuser_obtain01 ",name,"\n")

		if user_confirmed(user) then -- load from data base

			tab=vobj_data_load({owner=user.fud.id,type=data.ville.types.user}) -- grab player vobj, there should only be one
			
		end
		
dbg("vuser_obtain02 ",name,"\n")

		if tab then -- we loaded an old saved data in

		else -- need to make new
		
dbg("vuser_obtain1 ",name,"\n")

			if user_confirmed(user) then -- load from data base
			
				tab=vobj_data_create({owner=user.fud.id,type=data.ville.types.user})
			
			else
		
				tab=vobj_data_create({owner=0,type=data.ville.types.user})
				
			end
		end

dbg("vuser_obtain2 ",name,"\n")
		
		if tab then -- create the player data locally
		
dbg("vuser_obtain3 ",name,"\n")

			tab.type=data.ville.types[tab.type]
			tab.owner=name
			tab.group=nil
			
			tab.url=vuser_avatar_url(name) --vuser_urls[name] or cfg.base_data_url.."/game/s/ville/test/vtard/me.xml"
			
			tab.props={ xyz="0:0:0" , anim="idle" , speed="100" }
			
			vuser=vuser_create(tab)
			
dbg("new vuser ",tab.owner,"\n")

		end
	
	end
	
dbg("vuser,tab,owner==",tostring(vuser),tostring(tab),tab.owner,"\n")


	if vuser then -- force url update
	
		local ville_size=day_flag_get("*","ville_size")
		
		if ville_size then
			vuser.props.size=ville_size	
		end

		if is_god(vuser.owner) then -- godly size
			vuser.props.size=150
		end
	
		vuser.url=vuser_avatar_url(name) --vuser_urls[name] or cfg.base_data_url.."/game/s/ville/test/vtard/me.xml"
		
	end

dbg("vuser_obtain done \n")

	return vuser
		
end


-----------------------------------------------------------------------------
--
-- make sure we are holding the right balloon
--
-- and aply any special effects
--
-----------------------------------------------------------------------------
function vuser_check_balloon(vuser)

local item

	local vroom=vobj_get_vroom(vuser)
	local room=vroom_get_room(vroom)
	
	if room and room.ville_game then -- let the ville game handle this?
	
		if room.ville_game.check_balloon then
		
			if room.ville_game.check_balloon(vroom,vuser) then -- the game handled it
			
				return -- exit
			end
		end
	end
		
		
	if vuser.npc then -- check for an npc balloon
	
	elseif vuser.brain then -- check for a bot balloon
	
		if vroom then
			item=get_item_by_home(string.lower(vroom.name).."/room/balloon") -- are we holding a balloon?
		end
		
	else

		item=get_item_by_home(string.lower(vuser.owner).."/balloon") -- are we holding a balloon?
	
	end
	
	local default=true
	
	if item then
	
		vobj_set(vuser,"balloon", item_to_balloon_str(item) ) -- place it in hand
		
		local name=item_name_balloon(item.props)
		
		if name=="speed" then
		
			vobj_set(vuser,"speed", 100 + item.props.size )
			default=false
		end
		
	else
	
		vobj_set(vuser,"balloon", item_to_balloon_str(nil) ) -- place it in hand
		
	end
	
	if default then
	
		vobj_set(vuser,"speed", 100 )
		
	end

end

-----------------------------------------------------------------------------
--
-- give or remove god balloon
--
-----------------------------------------------------------------------------
function vuser_check_god_balloon(vuser)

local user=get_user(vuser.owner)

	if not user then return end
		
	if is_god(user.name) or is_room_owner(user.room,user.name) then -- give god balloons to room owners or gods

		local aa=str_split(":",vuser.props.balloon or "0:0:0:0:0")
		
		if aa[2]~="godloons" then -- check and update if not holding a god balloon
		
			vuser_check_balloon(vuser) -- give old balloon back
			
		end
		
	else -- remove when not available
	
		if vuser.props.balloon then
		
			local aa=str_split(":",vuser.props.balloon or "0:0:0:0:0")
			
			if aa[2]=="godloons" then -- remove god balloon
			
				vobj_set(vuser,"balloon","0:0:0:0:0")
			
			end
			
		end
		
		vuser_check_balloon(vuser) -- give old balloon back
	end
end

-----------------------------------------------------------------------------
--
-- walk to a location, escaping from whomever is carying us
--
-----------------------------------------------------------------------------
function vuser_walkto(vobj,p)

local t=lanes.now_secs() -- a fixed time to be used in this function

	if vobj.propdata.root>t then return end -- cant move when rooted
	
local speed=tonumber(vobj_get(vobj,  "speed"))/100 -- our speed multiplyer

	
	local held=vobj_get_vobj_str( vobj_get(vobj,"held") or "" ) -- we are held by something
		
	local hold=vobj_get_vobj_str( vobj_get(vobj,"hold") or "" ) -- we are holding onto something
	
-- check for mutual links, ie we are properly held or holding, else null links
	
	if hold then
		if vobj_get(hold,"held") ~= vobj.id then -- not mutual
			hold=nil
			vobj_set_vobj(hold,"held","*")
		end
	end
	if held then
		if vobj_get(held,"hold") ~= vobj.id then -- not mutual
			held=nil
			vobj_set_vobj(held,"hold","*")
		end
	end
	
	vobj_set_vobj(vobj,  "held","*") -- always mark as escaped
	
	
	
	if held then
		vobj_set_vobj(held,"hold","*")
	end
		
		
	if p then -- where to walk to
	
		propdata_set_xyzt(vobj,p,speed*75)
		propdata_send_xyzt(vobj)
		
		local sane=10
		while hold and sane>0 do -- walk what we are holding to the same location, cascade this up to everything thats held
		
			sane=sane-1
			
			propdata_set_xyzt(hold,p,speed*75)
			propdata_send_xyzt(hold)
		
			local last_hold_id=hold.id
			
			hold=vobj_get_vobj_str( vobj_get(hold,"hold") or "" )
			
			if hold then
				if vobj_get(hold,"held") ~= last_hold_id then -- not mutual
					hold=nil
				end
			end
		
		end
	
	end

end

-----------------------------------------------------------------------------
--
-- jump to a location, escaping from whomever is carying us and dropping what we are carrying
--
-----------------------------------------------------------------------------
function vuser_jumpto(vobj,p)

local t=lanes.now_secs() -- a fixed time to be used in this function

	if vobj.propdata.root>t then return end -- cant move when rooted
	
local speed=tonumber(vobj_get(vobj,  "speed"))/100 -- our speed multiplyer

	
	local held=vobj_get_vobj_str( vobj_get(vobj,"held") or "" ) -- we are held by something
		
	local hold=vobj_get_vobj_str( vobj_get(vobj,"hold") or "" ) -- we are holding by something
	
-- check for mutual links, ie we are properly held or holding, else null links
	
	if hold then
		if vobj_get(hold,"held") ~= vobj.id then -- not mutual
			hold=nil
			vobj_set_vobj(hold,"held","*")
		end
	end
	if held then
		if vobj_get(held,"hold") ~= vobj.id then -- not mutual
			held=nil
			vobj_set_vobj(held,"hold","*")
		end
	end
	
	vobj_set_vobj(vobj,  "held","*") -- always mark as escaped
	vobj_set_vobj(vobj,  "hold","*") -- always mark as droped
	
	
	
	if held then
		vobj_set_vobj(held,"hold","*")
	end
		
		
	if hold then -- drop what we are holding
	
		local pnow=propdata_get_xyzt(vobj,t)
		
		propdata_set_xyzt(hold,pnow,0)
		propdata_send_xyzt(hold,"force")
	
		vobj_set_vobj(hold,"held","*")
	end
		
	if p then -- where to walk to
	
		propdata_set_xyzt(vobj,p,speed*75*4)
		propdata_send_xyzt(vobj,"jump")
	
	end

end

-----------------------------------------------------------------------------
--
-- if we are holding someone, drop them
--
-----------------------------------------------------------------------------
function vuser_drop(vobj)

local t=lanes.now_secs() -- a fixed time to be used in this function

	local hold=vobj_get_vobj_str( vobj_get(vobj,"hold") or "" ) -- we are holding onto something
	
-- check for mutual links, ie we are properly held or holding, else null links
	
	if hold then
		if vobj_get(hold,"held") ~= vobj.id then -- not mutual
			hold=nil
			vobj_set_vobj(hold,"held","*")
		end
	end
	
	vobj_set_vobj(vobj,  "hold","*") -- always mark as droped
	
	if hold then -- drop what we are holding
	
		local pnow=propdata_get_xyzt(vobj,t)
		
		propdata_set_xyzt(hold,pnow,0)
		propdata_send_xyzt(hold,"force")
	
		vobj_set_vobj(hold,"held","*")
	end

end
-----------------------------------------------------------------------------
--
-- stop walking
--
-----------------------------------------------------------------------------
function vuser_stopwalking(vobj)

local t=lanes.now_secs() -- a fixed time to be used in this function


	local pnow=propdata_get_xyzt(vobj,t)
	
	propdata_set_xyzt(vobj,pnow,0)
	propdata_send_xyzt(vobj,"force")

end

-----------------------------------------------------------------------------
--
-- set a prop value and broadcast the change to anyone listening
--
-----------------------------------------------------------------------------
function vuser_set_vobj(vobj,prop,val,user)

local t=lanes.now_secs() -- a fixed time to be used in this function

local speed=tonumber(vobj_get(vobj,  "speed"))/100 -- our speed multiplyer

--dbg(prop.."\n")
	if not vobj or not prop or not val then return end
	
	if type(vobj.props[prop])~=type(val) or vobj.props[prop]~=val then -- setting a prop to the same value is ignored
	
		if prop=="use" then -- pass menu option onto brain?
		
			if not user then return end -- must be used by someone
			
			local vuser=get_vuser(user.name)
			local vroom=vobj_get_vroom(vobj)

			if val=="give balloon" then -- we wish to give them a balloon

--dbg(user.name," wants to give ",vobj.owner," a balloon ","\n")

				if not vroom or not vuser then return end -- need all these
				
				if vobj.npc then -- an npc may do anything, but not yet
				
				elseif vobj.brain then -- a bot can be used as a public balloon swapping post
				
					local loc1=string.lower(vroom.name).."/room/balloon"
					local loc2=string.lower(user.name).."/balloon"
				
					local it1=get_item_by_home(loc1)
					local it2=get_item_by_home(loc2)
					
					if not it2 then
						userqueue(user,{cmd="note",note="act",arg1="You have no balloon to give."})
						return
					end
					
					if it1 and it2 then
					
						item_home_swap(it1,it2)
						it1.owner=string.lower(user.name)
						it2.owner=string.lower(vobj.owner)
						item_save(it1)
						item_save(it2)
					
					else
					
						-- give balloon to them
						item_rehome(it2,loc1)
						it2.owner=string.lower(vobj.owner)
						item_save(it2)
					
					end
					
					-- change balloons displayed
					vobj_set(vuser,"balloon",item_to_balloon_str(it1))
					vobj_set(vobj ,"balloon",item_to_balloon_str(it2))
				
				else -- a user auto accepts any balloon you give them, need a way of turning this of later but for now it is good for noobs
				
					local loc1=string.lower(vobj.owner).."/balloon"
					local loc2=string.lower(user.name).."/balloon"
					
					local it1=get_item_by_home(loc1)
					local it2=get_item_by_home(loc2)
					
					if not it2 then
						userqueue(user,{cmd="note",note="act",arg1="You have no balloon to give."})
						return
					end
					
					if it1 then
						userqueue(user,{cmd="note",note="act",arg1="They already have a balloon."})
						return
					end
					
					-- give balloon to them
					item_rehome(it2,loc1)
					it2.owner=string.lower(vobj.owner)
					item_save(it2)
					
					-- change balloons displayed
					vobj_set(vuser,"balloon",item_to_balloon_str(it1))
					vobj_set(vobj ,"balloon",item_to_balloon_str(it2))
					
					-- ativate special balloon effect
--					vuser_balloon_activate(vuser)
					vuser_balloon_activate(vobj)
				
				end
			
				return
			end
		
			if vobj.npc and vobj.npc.set_prop_use then
			
				vobj.npc.set_prop_use(vobj, prop , val ,vuser)
				
			elseif vobj.brain and vobj.brain.set_prop_use then
			
				vobj.brain.set_prop_use(vobj.brain, prop , val ,user)
				
			end
			
			return -- use doesnt get set, its always just an action
		
		elseif prop=="xyz" then
		
			if vobj.propdata.root>t then return end -- cant move when rooted
		
			local aa=str_split(":",val)
			aa[1]=tonumber(aa[1]) or 0
			aa[2]=tonumber(aa[2]) or 0
			aa[3]=tonumber(aa[3]) or 0
			
			local p={x=aa[1],y=aa[2],z=aa[3]}
			
			vuser_walkto(vobj,p)
			
			return -- dont actually set it here
			
		elseif prop=="avatar" then
		
			vuser_avatar_url(vobj.owner,val)
			ville_msg_setup( get_user(vobj.owner) ,{}) -- reload room with new avatar
			return -- dont actually set it now

			
		elseif prop=="pickup" then -- not a real prop, its a pickup request
		
		if vobj.propdata.root>t then return end -- cant pickup/drop when rooted
		
		local aa=str_split(":",val)
			
		local target=vobj_get_vobj_str(aa[1])
		
		
		local held=vobj_get_vobj_str( vobj_get(vobj,"held") or "" ) -- we are held by something
			
		local hold=vobj_get_vobj_str( vobj_get(vobj,"hold") or "" ) -- we are holding by something
		
			if target and target.parent ~= vobj.parent then return end -- cant pickup unless in same vroom
			
			-- check for mutual links, ie we are properly held or holding, else null links
		
			if hold then
				if vobj_get(hold,"held") ~= vobj.id then -- not mutual
					hold=nil
					vobj_set_vobj(hold,"held","*")
				end
			end
			if held then
				if vobj_get(held,"hold") ~= vobj.id then -- not mutual
					held=nil
					vobj_set_vobj(held,"hold","*")
				end
			end
		
			-- start by escaping/dropping
			
			vobj_set_vobj(vobj,  "held","*") -- always mark as escaped
			vobj_set_vobj(vobj,  "hold","*") -- always mark as dropped			
			
			if held then
				local pnow=propdata_get_xyzt(held,t)
				propdata_set_xyzt(vobj,pnow,0)
				propdata_send_xyzt(vobj,"force")
				vobj_set_vobj(held,"hold","*")
			end
			if hold then
				local pnow=propdata_get_xyzt(vobj,t)
				propdata_set_xyzt(hold,pnow,0)
				propdata_send_xyzt(hold,"force")
				vobj_set_vobj(hold,"held","*")
			end

			if target then -- pickup / jump to target
			
			local p1=propdata_get_xyzt(target,t)
			local p2=propdata_get_xyzt(vobj,t)
			
				
--dbg("pos ",p2.x," : ",p2.y," : ",p2.z, " : ", t ,"\n")

				if xyzt_check_distance(p1,p2,80*80) then -- pickup when close

					vobj_set_vobj(vobj,  "hold",target.id)
					vobj_set_vobj(target,"held",vobj.id)
				
				else -- jump to it
				
					if aa[2] ~= "only" then -- check dont jump flag
					
--dbg("pos ",pos.x," : ",pos.y," : ",pos.z,"\n")

						vuser_jumpto(vobj,p1)

--						propdata_set_xyzt(vobj,p1,speed*75*4) -- speed of 75 a sec? thats 3 a frame at 25fps
--						propdata_send_xyzt(vobj,"jump")
					
					end
				
				end
			
			end
			
		
			return -- never set prop
		
		elseif prop=="kick" then -- not a real prop, its a hit test request
			
			local t=lanes.now_secs()
			
			if vobj.propdata.kicktime and vobj.propdata.kicktime + 1 > t then return end -- can only kick once per sec
			
			local vr=data.ville.vobjs[vobj.parent]
			if not vr then return end
			
			local vb=data.ville.vobjs[vr.uniques.ball]
			if not vb then return end
						
			if vb.data and vb.data.kickof then
				if vb.data.kickoff > t then -- cant kick yet, resetting ball
					return
				end
			end
			
			local p1,p2 -- get the current location of us and the ball
			
				p1=propdata_get_xyzt(vobj,t)
				p2=propdata_get_xyzt_bounce(vb,t)
				
--dbg( "P1 ".. p1.x .. " : " .. p1.y .." : ".. p1.z )
--dbg( "P2 ".. p2.x .. " : " .. p2.y .." : ".. p2.z )


				-- check if we are close enough to kick the ball
				
				
				
				if xyzt_check_distance(p1,p2,50*50) then
				
					vobj.propdata.kicktime=t -- say it this user has just kicked a ball
	
					vobj_ball_kick(vb,vobj,vr,p1,p2)
									
				end
		
			return -- never set prop
			
		elseif prop=="held" or prop=="hold" then -- these props may not be set by this function, so ignore
		
			return
		end

		vobj.props[prop]=val

		vobj.changes[prop]=val	-- changed flags
		data.ville.changes[vobj.id]=true
		
	end

end

-----------------------------------------------------------------------------
--
-- this user is doing something complicated so check their state all the time
--
-----------------------------------------------------------------------------
function vuser_check_and_set_god_act(user,victim)

	if not user then return end

	if is_god(user.name) or is_room_owner(user.room,user.name) then -- admin check
	
		local vuser=data.ville.users[string.lower(user.name)] -- get the vuser for this user
		if not vuser then return end
		
		local t=lanes.now_secs()
		
		vuser.propdata=vuser.propdata or {}
		vuser.propdata.god_anim_time=t
		
		vuser.update=function(vuser) vuser_update(vuser) end
		queue_update(vuser) -- check back till we are finished	
		
		if victim then
			vobj_set(vuser,"victim",victim,user)
			local vv=data.ville.users[string.lower(victim)]
			if vv then
				vobj_set(vv,"idle","scared",user)
			end
		end
	end
end

-----------------------------------------------------------------------------
--
-- this user is doing something complicated so check their state all the time
--
-----------------------------------------------------------------------------
function vuser_update(vuser)

-- some basic checks to make sure the world has not been deleted around us

	if not data.ville.vobjs[vuser.id] then return remove_update(vuser) end -- check we still exist
	
	local user=get_user(vuser.owner)
	
	if not user then return remove_update(vuser) end -- check we are still logged in
	
	
	if is_god(user.name) or is_room_owner(user.room,user.name) then -- admin check
	
		local aa=str_split(":",vuser.props.balloon or "0:0:0:0:0")
		
		if aa[2]~="godloons" then -- must be holding a god balloon
			return remove_update(vuser)
		end
			
		local t=lanes.now_secs()
		
		local anim=0
		
		if not vuser.propdata.god_anim_time then -- something strange

			anim=0
			
		else
		
			local td = t-vuser.propdata.god_anim_time

			anim = 2 - force_floor(td/2)
			
			if anim < 0 then anim=0 end
			if anim > 2 then anim=2 end
			
		end
		

		local balloon = "0:godloons:"..anim..":75"
		
		if vuser.props.balloon ~= balloon then -- change it
		
			vobj_set(vuser,"balloon",balloon,user)
		
		end
		
		if anim==0 then
		
			return remove_update(vuser)
	
		end
	
	else
	
		return remove_update(vuser)
	
	end
	
end

-----------------------------------------------------------------------------
--
-- send a msg to this user
--
-----------------------------------------------------------------------------
function vuser_cast(vuser,msg)

	if not vuser then return end -- no vuser

local u

--dbg("VOUT:"..dbg_msg(msg))

	u=data.names[vuser.owner]
	
	if u and u.client then
	
		usercast(u,msg)
--		client_send(u.client , msg_to_str(msg,u.msg) .. "\n\0")  -- every client gets a custom built string			
	
	end

end
