
local gtab=data.gametypes["zeegrind"] or {}


-----------------------------------------------------------------------------
-- 
-- book a wakeup call
-- 
-----------------------------------------------------------------------------
local function npc_wakeme(npc,t)

local zd=npc.zd

	if t then npc.wakeup=t end -- change if new time is given
	
	if zd.npc_wakeup > npc.wakeup then zd.npc_wakeup = npc.wakeup end -- remember earliest wakeup call

end

-----------------------------------------------------------------------------
-- 
-- request a statechange, booking a wakeupcall to make it happen
-- 
-----------------------------------------------------------------------------
local function npc_state_change(npc,state)

	if not npc then return end
	
	npc.state_next=state
	npc_wakeme(npc,gtab.now)

end

-----------------------------------------------------------------------------
-- 
-- get the current(t=gtab.now) position and area, this is cached
-- 
-----------------------------------------------------------------------------
local function npc_get_pos(npc)

	if npc.pos.t == gtab.now then return npc.pos end -- we have the answer cached

	local p = propdata_get_xyzt(npc.vuser,gtab.now)
	
	npc.pos=p
	
	for n,v in pairs(npc.vroom.zone) do
	
		if n~="size" then -- ignore the room size zone
		
			if p.x >= v.x_min and p.x <= v.x_max and p.z >= v.z_min and p.z <= v.z_max then
			
				p.zone=n
				
				return p
			
			end
		
		end
	
	end
	
	return p
	
end

-----------------------------------------------------------------------------
-- 
-- save a players new zone, if its different to the last saved one
-- 
-----------------------------------------------------------------------------
local function npc_savezone(npc)

local new_zone=npc.pos.zone
local old_zone=1

local zroom=gtab.rooms[npc.vroom.class]

	if new_zone=="entrance" or new_zone=="exit" then 
	
		if new_zone=="entrance" then new_zone=zroom.level end
		if new_zone=="exit" then new_zone=zroom.level + 1 end
		
		old_zone=tonumber( day_flag_get(npc.vuser.owner,"zeegrind.zone") or 1 )
		
		if old_zone ~= new_zone then -- zone change
		
			day_flag_set(npc.vuser.owner,"zeegrind.zone",new_zone)
			
			local vuser=npc.vuser
			local vroom=npc.vroom
			local room=vroom_get_room(vroom)
			
			local balloon_msg=""
			
			local weapon_name=day_flag_get(vuser.owner,"zeegrind.balloon")
			
			if npc.pos.zone=="exit" then
				local give=zroom.award -- give cookies for getting to the other side
				if give>0 then
					local msg,reward=game_name_award_cookies("zeegrind",npc.user,give,give)
					
					if reward and reward > 0 then
						if balloon_msg=="" then
							balloon_msg=" and now has "..reward.." cookies"
						else
							balloon_msg=balloon_msg.." and "..reward.." cookies"
						end
					end
				end
			end

			roomqueue(room,{cmd="note",note="act",arg1=npc.vuser.owner .. " has reached level " .. new_zone .. balloon_msg})

		end
		
		feats_signal_zeegrind(npc.vuser,"zone",{zone=npc.pos.zone,level=new_zone})
		
	elseif new_zone=="zeegrind" then -- mark as entering danger zone
	
		feats_signal_zeegrind(npc.vuser,"zone",{zone="zeegrind",level=zroom.level})

	end

end


-----------------------------------------------------------------------------
-- 
-- show reload effect
-- 
-----------------------------------------------------------------------------
local function npc_show_reload(npc)

local balloon
local aa

	if npc.bonk_reload then -- check for reloading timer
	
		if npc.bonk_reload > gtab.now then -- go back to sleep

			if npc.weapon then
			
				balloon=npc.weapon.balloon
				aa=str_split(":",balloon)
				aa[5]="10"
				balloon=table.concat(aa,":")
			
				if npc.vuser then
--dbg(balloon,"\n")
					vobj_set(npc.vuser,"balloon", balloon ) -- place it in hand
				end
			
			end
			
			return
		end
	
	end

	if npc.weapon then
	
		balloon=npc.weapon.balloon
				
		if npc.vuser then
		
--dbg(balloon,"\n")
			vobj_set(npc.vuser,"balloon", balloon ) -- place it in hand
	
		end
	
	end
	
end

	
	
-----------------------------------------------------------------------------
-- 
-- load a players saved zone, return the name of the zone we should start in
-- 
-----------------------------------------------------------------------------
local function npc_loadzone_name(npc)

	if not npc then return "entrance" end
	
local vuser=npc.vuser

	if not vuser then return "entrance" end

local name=npc.vuser.owner

	if not name then return "entrance" end
	

local zone_flag=day_flag_get(name,"zeegrind.zone")

	if not zone_flag then return "entrance" end
	
local zone

local n=force_floor(zone_flag or 0)

local zroom=gtab.rooms[npc.vroom.class]

	if n <= zroom.level then return "entrance" end
	if n > zroom.level then return "exit" end
	
	return "entrance"
	
end

-----------------------------------------------------------------------------
-- 
-- build bonk info from npc1 to npc2
-- 
-----------------------------------------------------------------------------
local function npc_bonk_info(npc1,npc2)

local bnk={}

	local p1=npc_get_pos(npc1)
	local p2=npc_get_pos(npc2)

	local dx=p1.x-p2.x
	local dz=p1.z-p2.z
	local dd=dx*dx + dz*dz
	
	local d=math.sqrt(dd)
	
	bnk.npc1=npc1
	bnk.npc2=npc2
	
	bnk.d=d
	
	bnk.hit=false
	bnk.nochance=false
	bnk.damage=0
	
	local damage=0
	local weapon=npc1.weapon
	local zom=npc2.zom
	
	if weapon and zom then -- sanity
	
		if d < (weapon.hit_dist-zom.evade) then -- must be this close to hit
		
			bnk.hit=true
		
		else
			
			bnk.nochance=true -- dont even bother trying
			
		end
		
		damage=weapon.damage * zom.armour
		if damage<0 then damage=0 end
		
		bnk.damage=damage
	
	end
	
	return bnk

end

-----------------------------------------------------------------------------
-- 
-- state function lookup tables
-- 
-----------------------------------------------------------------------------
local npc_enter={}
local npc_leave={}
local npc_update={}

-----------------------------------------------------------------------------
-- 
-- get or create the zd data for this vroom
-- 
-----------------------------------------------------------------------------
local function manifest_zd(room,vroom)

local zd=gtab.zds[vroom.name]

	if zd then return zd end
	
	zd={}

	gtab.zds[vroom.name]=zd
	
	zd.name=vroom.name -- name of vroom which can be used to find the zroom and room if all we have is a zd
	
	zd.pcs={} -- array of data for players characters, like npcs but linked by name and updated when people join/leave the room
	zd.npcs={} -- array of data for our in room only bots
	zd.npc_wakeup=0 -- the next server time that any npc needs to be processed.
	
	room.ville_game=gtab -- link room to us
	gtab.room_names[room.name]=true -- remember to update this room

	return zd
end

-----------------------------------------------------------------------------
-- 
-- destroy this zd data
-- 
-----------------------------------------------------------------------------
local function destroy_zd(zd)

	gtab.zds[zd.name]=nil

	for i,npc in ipairs(zd.npcs) do -- remove each npc
	
		local vuser=vobj_get_vobj_str(npc.id)
		
		if vuser then
		
			vroom_leave(vuser)
			vuser_destroy(vuser)

		end
	
	end
			
end



-----------------------------------------------------------------------------
-- 
-- create the npc side of a user
-- 
-----------------------------------------------------------------------------
local function npc_create_pc(zd,name,vroom,vuser)

local npc={}

	if not name then return end
	
	if not vuser then return end

	if not vroom then return end
	
	npc.zd=zd
	npc.vuser=vuser
	npc.vroom=vroom

	npc.user=get_user(name) -- there is also a user attached to this npc ( non player control )
	
	npc.name=name
	zd.pcs[npc.name]=npc


	npc.id=vuser.id
	
	npc.wakeup=0 
	
	-- setup no initial state
	npc.state=nil
	npc.state_next=nil
	npc.state_prev=nil

	npc.pos={}
	
	vuser.npc=npc

	gtab.check_balloon(vroom,vuser)
	
	return npc
end
-----------------------------------------------------------------------------
-- 
-- destroy the npc side of a user
-- 
-----------------------------------------------------------------------------
local function npc_remove_pc(zd,npc)

	if not npc then return end
	
local vuser=vobj_get_vobj_str(npc.id)

	zd.pcs[npc.name]=nil

	if vuser then
	
		vuser.npc=nil
	end
	
end

-----------------------------------------------------------------------------
-- 
-- update a single npc
-- 
-----------------------------------------------------------------------------
local function npc_thunk(npc)

local f

	if npc.state_next then
	
		if npc.state then f=npc_leave[npc.state] else f=nil end
		if f then f(npc) end
		
		npc.state_prev=npc.state
		npc.state=npc.state_next
		npc.state_next=nil
		
		if npc.state then f=npc_enter[npc.state] else f=nil end
		if f then f(npc) end
		
	end

	if npc.state then f=npc_update[npc.state] else f=nil end
	if f then f(npc) end

end

-----------------------------------------------------------------------------
-- 
-- update a single npc
-- 
-----------------------------------------------------------------------------
local function set_prop_use(vobj, prop , val ,vuser)

local s=string.lower(val)

--dbg("attack ",npc.id,"\n")


	if s=="base bonk" then -- attack


		vuser.npc.state_next="bonk"
		npc_wakeme(vuser.npc,gtab.now)
		
		vuser.npc.target=vobj.id
		vuser_stopwalking(vuser)
--		vobj_trigger(vuser ,"bonk",vobj.id)

	end

end

-----------------------------------------------------------------------------
-- 
-- check the npcs in this vroom
-- 
-----------------------------------------------------------------------------
local function zd_thunk_npcs(zd,room,vroom)

local npc
local vuser

local zroom=gtab.rooms[vroom.class]
if not zroom then zroom=gtab.rooms[0] end


	for i,znam in ipairs(zroom.zombies) do -- check and create each bot if we need to
	
		local zom=gtab.zombies[znam]
	
		npc=zd.npcs[i]
		
		if not npc then -- create
		
			npc={}
			zd.npcs[i]=npc
		
		end
		
		npc.zd=zd
		npc.zom=zom -- makesure we have latest loaded zom data
		
		vuser=vobj_get_vobj_str(npc.id)
		
		if not vuser then -- bot went missing, create again
		
			local tab={}
		
			tab.mid=vroom.mid -- this object belongs to the room
			tab.name="zee."..zom.name
			tab.url=zom.avatar --"http://data.wetgenes.com/game/s/ville/test/vtard/z."..gtab.avatar_names[i]..".xml"
		
			vuser=vuser_create_bot(tab)
			
			vobj_set(vuser,"menu","base/bonk")
			npc.set_prop_use = set_prop_use -- menu use call back
			
			vuser.npc=npc -- link back to us, this should be very persistant data
			
			vobj_set(vuser,"speed", zom.walkspeed )
			vobj_set(vuser,"size", zom.size )

			
			vroom_join(vroom,vuser)
			vuser_check_balloon(vuser)
			
			npc.id=vuser.id
			
			npc.wakeup=0 
			
			-- setup initial state as "new"
			npc.state=nil
			npc.state_next="new"
			npc.state_prev=nil
			
			npc.pos={}
		end
		
-- cache pointers so we can just use npc in functions, and know these are all set / checked

		npc.vuser=vuser
		npc.room=room
		npc.vroom=vroom
	
	end

	for name,npc in pairs(zd.pcs) do -- update each pc (need a better name than npc but whatever)
	
		if npc.wakeup <= gtab.now then -- thunk npcs
		
			npc_thunk(npc)
		
		else -- just re-book a wakeup call when it is time
		
			npc_wakeme(npc)
		end
		
		if npc.pos and npc.pos.zone then -- check players safe zone saves
			
			if npc.pos.zone ~= npc.last_zone then
			
				npc_savezone(npc)
				npc.last_zone=npc.pos.zone
			end
		end
	end
	
	for i,npc in ipairs(zd.npcs) do -- update each npc
	
		if npc.wakeup <= gtab.now then -- thunk npcs
		
			npc_thunk(npc)
		
		else -- just re-book a wakeup call when it is time
		
			npc_wakeme(npc)
		end
	
	end
	
end

-----------------------------------------------------------------------------
-- 
-- "new" state npc functions
-- 
-----------------------------------------------------------------------------
npc_enter.new=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom

local p=vroom_random_xyzt(vroom,"zeegrind",npc.zom.roam_area)

	
	propdata_set_xyzt(vuser,p,0)
	propdata_send_xyzt(vuser,"force")
	
end
---
npc_leave.new=function(npc)

end
---
npc_update.new=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom

	npc_state_change(npc, npc.zom.start_state or "roam")
	
end

-----------------------------------------------------------------------------
-- 
-- "roam" state npc functions
-- 
-----------------------------------------------------------------------------
npc_enter.roam=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom
	
end
---
npc_leave.roam=function(npc)

end
---
npc_update.roam=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom

local zd=npc.zd

local p1
local p2
local nearest
local nearest_dd
local nearest_p


	nearest_dd=65536*65536
	p1=npc_get_pos(npc)
	
	for name,pc in pairs(zd.pcs) do -- find closest player
	
		p2=npc_get_pos(pc)
		
		if p2.zone=="zeegrind" then -- must be in active area
		
			local held=vobj_get_vobj_str( vobj_get(pc.vuser,"held") or "" ) -- pc is held by something
			
			if not held then -- ignore things being carried

				local dx=p1.x-p2.x
				local dz=p1.z-p2.z
				local dd=dx*dx + dz*dz
				
				if dd < npc.zom.sniff2 then -- close enough to smell spicy brains

					if dd < nearest_dd then -- closer than any other
					
						nearest_dd=dd
						nearest=pc
						nearest_p=p2
					
					end
				end
			end
		end
	
	end

	if nearest then -- head to player
	
		if nearest_dd < npc.zom.bite2 then -- pick em up
		
			propdata_set_xyzt(vuser,p1,0) -- stop moving
			propdata_send_xyzt(vuser,"force")
			
			propdata_set_xyzt(nearest.vuser,p1,0) -- force target to stop moving
			propdata_send_xyzt(nearest.vuser,"force")
				
			vobj_set_vobj(npc.vuser,  		"hold",nearest.vuser.id) -- pickup
			vobj_set_vobj(nearest.vuser,	"held",npc.vuser.id)
		
			nearest.vuser.propdata.root=gtab.now+5 -- hold em still
			
			npc.target=nearest.vuser.id
			npc_state_change(npc,"hold")
			return npc_thunk(npc) -- switch state right now
			
		elseif nearest_dd < npc.zom.jump2 then -- leap at them
		
			local sfx={
				'argh:1:100',
				'arghhigh:1:100',
				'arse:1:100',
				'balloonshigh:1:100',
				'balloonslow:1:100',
				'brains:1:100',
				'urh:1:100',
			}
			sfx=sfx[ math.random(#sfx) ]
		
			vobj_trigger(npc.vuser,"playsfx", sfx ) -- attack noise
			
			vuser_jumpto(vuser,nearest_p)
			
			local t=vuser.propdata.xyzt_vel.t -- time to destination
--			if t>2 then t=2 end -- maximum time till next thunk
			
			npc_wakeme(npc,gtab.now+t)
			
		else
		
			vuser_walkto(vuser,nearest_p)
			
			local t=vuser.propdata.xyzt_vel.t -- time to destination
			if t>1 then t=1 end -- maximum time till next thunk
			
			npc_wakeme(npc,gtab.now+t)
			
		end
		
	else -- wander
	
		local p=vroom_random_xyzt(vroom,"zeegrind",npc.zom.roam_area)
		
		vuser_walkto(vuser,p)
		
		local t=vuser.propdata.xyzt_vel.t -- time to destination
		if t>2 then t=2 end -- maximum time till next thunk
		
		npc_wakeme(npc,gtab.now+t)
	end
end

-----------------------------------------------------------------------------
-- 
-- "none" state npc functions
-- 
-----------------------------------------------------------------------------
npc_enter.none=function(npc)

end
---
npc_leave.none=function(npc)

end
---
npc_update.none=function(npc)

	npc_wakeme(npc,gtab.now+(60*60)) -- sleep for long time
end


-----------------------------------------------------------------------------
-- 
-- "hold" state npc functions
-- holding onto a user
-- 
-----------------------------------------------------------------------------
npc_enter.hold=function(npc)

	npc.hold_start=gtab.now -- when we started holding

local target=vobj_get_vobj_str(npc.target)

	if target then
	
		day_flag_set(target.owner,"zeegrind.balloon","none") -- flag weapon as gone in saved state, but do not update yet
		
		vuser_drop(target) -- drop what we are holding
		
	end
	
end
---
npc_leave.hold=function(npc)

local target=vobj_get_vobj_str(npc.target)

	if target then
	
		if target.npc and target.npc.weapon then
			
			if target.npc.weapon.item then -- this is a very real item
			
--			local props=target.npc.weapon.item.props
			
--				props.size = target.npc.weapon.item_size or props.size -- restore size
				
--				item_save(target.npc.weapon.item) -- update item
--				item_undiscard(target.npc.weapon.item,target) -- we rescued the item
				
			else
			
				day_flag_set(target.owner,"zeegrind.balloon",target.npc.weapon.fullname) -- return weapon (this stops user from dropping connection to cheat)
			end

		end
		
		target.propdata.root=gtab.now -- stop holding them still
		
		vobj_set_vobj(target,"held","*") -- droped
	end
	
	vobj_set_vobj(npc.vuser,"hold","*") -- drop
	
end
---
npc_update.hold=function(npc)

local target=vobj_get_vobj_str(npc.target)

	if target and target.npc then
	
		if npc.hold_start+5 < gtab.now then -- finished with them
		
			if target.npc and target.npc.weapon and (not target.npc.weapon.item) then -- this is a game item
				
				local aa=str_split(":",target.npc.weapon.fullname)
				
				aa[2]=tonumber(aa[2] or 1) -1
				if aa[2]>0 then -- weapon still lives, hand it back to them but less powerful
			
					vroom_cast(target.npc.vroom, vobj_build_act_msg(target.npc.vuser,"POWER DOWN!") )
								
					day_flag_set(target.owner,"zeegrind.balloon", table.concat(aa,":") )
				end
				
			elseif target.npc and target.npc.weapon and target.npc.weapon.item then -- this is a very real item
				
				local props=target.npc.weapon.item.props
				
				props.size=tonumber(props.size)
				
				target.npc.weapon.item_size=props.size
				
				if props.size>=15 then -- shrink on capture
					props.size=props.size-5
					vroom_cast(target.npc.vroom, vobj_build_act_msg(target.npc.vuser,"POWER DOWN!") )
				else
					props.size=10 -- minimum shrink to on death
				end
				
						
				item_save(target.npc.weapon.item) -- update item
	--			item_discard(target.npc.weapon.item) -- really kill the item
				
			end
			
			gtab.check_balloon(target.npc.vroom,target.npc.vuser) -- removed displayed weapon
	
			target.propdata.root=0 -- let us move them
			
			local p=vroom_random_xyzt(npc.vroom, npc_loadzone_name(target.npc) )
			
			vobj_set_vobj(target,"held","*") -- droped
			vobj_set_vobj(npc.vuser,"hold","*") -- drop
			
			propdata_set_xyzt(target,p,0)
			propdata_send_xyzt(target,"force")
			
			target.propdata.root=gtab.now+5 -- lock them again
			
			npc.target=nil
			
			npc_state_change(npc,"roam")
			
			npc_state_change(target.npc,"rooted")
			
			vobj_trigger(target.npc.vuser,"playsfx", "wilhelm:2:50" ) -- scream
			
			feats_signal_zeegrind(target,"dead",{zom=npc}) -- we where killed by this zombie
		else
	
			target.propdata.root=gtab.now+5 -- hold em still
			
			npc_wakeme(npc,gtab.now+1)
			
		end
	else
	
		npc_state_change(npc,"roam")
	end
end


-----------------------------------------------------------------------------
-- 
-- "bonk" state npc functions
-- 
-----------------------------------------------------------------------------
npc_enter.bonk=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom

npc.bonk_p=propdata_get_xyzt(vuser,gtab.now) -- remember starting position


end
---
npc_leave.bonk=function(npc)

end
---
npc_update.bonk=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom

	npc_show_reload(npc)

	if vuser.propdata.root > gtab.now then -- cant bonk whilst rooted
	
		npc_wakeme(npc,gtab.now+2)
		return
	end


local p1=npc.bonk_p
local p2=npc_get_pos(npc) -- check for movement

	if (not npc.weapon) or (not p1) or p1.x~=p2.x or p1.y~=p2.y or p1.z~=p2.z then -- exit this state if we move (includes being carried)
	
		npc.state_next="reload"
		npc_wakeme(npc,gtab.now) -- call again soon to switch state
		return
	end
	
	if p2.zone~="zeegrind" then -- cant bonk from safe zones
	
		npc_wakeme(npc,gtab.now+2)
		return
	end
	
	if npc.bonk_reload then -- check for reloading timer
	
		if npc.bonk_reload > gtab.now then -- go back to sleep

			npc_wakeme(npc,npc.bonk_reload)
			return
		end
	
	end
	
local vtarg=vobj_get_vobj_str(npc.target)

	if vtarg then
	
		if vtarg.npc then
	
			if vtarg.npc.state=="bonked" then -- dont bonk the bonked
			
				npc_wakeme(npc,gtab.now+1) -- just check again in a little while
				return
	
			else
			
				local bnk=npc_bonk_info(npc , vtarg.npc )
				
				if bnk.nochance then -- dont even bother trying
				
					npc_wakeme(npc,gtab.now+1) -- just check again in a little while
					return
				
				end
				
				vobj_trigger(vuser ,"bonk",npc.target) -- show balloon bonking animation
				
				if bnk.hit and bnk.damage>0 then -- success

					vtarg.npc.bonked_by=npc.id
					vtarg.npc.bonked_for=bnk.damage
					npc_state_change(vtarg.npc,"bonked")
				
					feats_signal_zeegrind(vuser,"bonk",{zom=vtarg.npc}) -- we bonked a zombie
					
					vuser.zeegrind_bonks=(vuser.zeegrind_bonks or 0) + 1 -- weapon level up counter, moved to vuser
					if vuser.zeegrind_bonks >= 5 then -- level up
						vuser.zeegrind_bonks=0 -- reset
						
						local weapon_name=day_flag_get(vuser.owner,"zeegrind.balloon")
						
						if weapon_name and npc.weapon then -- upgrade weapons?
						
							local aa=str_split(":",weapon_name)
							
							aa[2]=tonumber(aa[2] or 1)
							aa[2]=aa[2]+1
							if aa[2] > 5 then aa[2]=5 end -- max level is 5
							
							if npc.weapon.item then -- real item level up
							
								local props=npc.weapon.item.props
								props.size=tonumber(props.size)
								if props.size<=30 then -- grow but not too big
									props.size=props.size+5
								end
								item_save(npc.weapon.item) -- update item
			
							else
							
								weapon_name=table.concat(aa,":")
								day_flag_set(vuser.owner,"zeegrind.balloon",weapon_name)
								
							end
							
							
							local old_weapon_level=npc.weapon.level
							
							gtab.check_balloon(vroom,vuser) -- upgrade weapon
							
							if npc.weapon and npc.weapon.level ~= old_weapon_level then -- only say if weapon was upgraded
								vroom_cast(vroom, vobj_build_act_msg(vuser,"POWER UP!") )
								
								vobj_trigger(npc.vuser,"playsfx", "wikwikwik:2:100" ) -- power up noise
							end
						
						end
					end
				end
				
			end
			
		end
		
	end
	
	npc.bonk_reload=gtab.now+npc.weapon.reload
	
	npc_show_reload(npc)

	npc_wakeme(npc,gtab.now+npc.weapon.reload)
end

-----------------------------------------------------------------------------
-- 
-- "reload" state npc functions
-- 
-----------------------------------------------------------------------------
npc_enter.reload=function(npc)


end
---
npc_leave.reload=function(npc)

end
---
npc_update.reload=function(npc)

	npc_show_reload(npc)

	if npc.bonk_reload then -- check for reloading timer
	
		if npc.bonk_reload > gtab.now then -- go back to sleep

			npc_wakeme(npc,npc.bonk_reload)
			return
		end
	
	end
	
	npc.state_next="none"
	npc_wakeme(npc,gtab.now) -- reload done
	
end

-----------------------------------------------------------------------------
-- 
-- "bonked" state npc functions
-- 
-----------------------------------------------------------------------------
npc_enter.bonked=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom

	vuser_stopwalking(vuser)
	vobj_trigger(vuser ,"bonked", npc.bonked_for )

end
---
npc_leave.bonked=function(npc)

local vuser=npc.vuser

	vobj_trigger(vuser ,"bonked", 0 )
	
end
---
npc_update.bonked=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom

	npc.state_next="roam" -- go back to roaming on next wakeup
	npc_wakeme(npc,gtab.now+npc.bonked_for)
end

-----------------------------------------------------------------------------
-- 
-- "rooted" state npc functions
-- this is when the player has been frozen and cant move
-- 
-----------------------------------------------------------------------------
npc_enter.rooted=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom

	vobj_trigger(vuser ,"bonked", 5 )
	
end
---
npc_leave.rooted=function(npc)

local vuser=npc.vuser

	vobj_trigger(vuser ,"bonked", 0 )
	
end
---
npc_update.rooted=function(npc)

local vuser=npc.vuser

	if vuser.propdata.root < gtab.now then -- root has worn off
	
		npc_state_change(npc,"none")
		
	end

end

-----------------------------------------------------------------------------
-- 
-- "help" state npc functions
-- 
-----------------------------------------------------------------------------
npc_enter.help=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom

	vobj_set(vuser,"menu","base/help/balloon/avatar/objective/zombies/bonk/safezone")
	vobj_set(vuser,"balloon","0:items1:12:100:50") -- welcome to wetgenes, I love you.
	npc.set_prop_use =function(vobj, prop , val ,vuser)

local s=string.lower(val)

	if s=="base help" then -- basic help

		vuser_cast(vuser, vobj_build_say_msg(npc.vuser,"Click and hold on me then move the mouse to an option and release the button to select a help topic.") )
				
	elseif s=="base balloon" then -- basic help
	
		vuser_cast(vuser, vobj_build_say_msg(npc.vuser,"You need balloons to bonk zombies. Click and hold on a balloons hook then move the mouse left to select the option to take it.") )
		
	elseif s=="base avatar" then -- basic help
	
		vuser_cast(vuser, vobj_build_say_msg(npc.vuser,"Click and hold on yourself then select Choose Avatar for basic avatar selection.") )
		
	elseif s=="base zombies" then -- basic help
	
		vuser_cast(vuser, vobj_build_say_msg(npc.vuser,"Zombies? ZOMBIES? Yes but dont worry just click on them to bonk them with your balloon and stun them for a few seconds.") )
		
	elseif s=="base bonk" then -- basic help
	
		vuser_cast(vuser, vobj_build_say_msg(npc.vuser,"Diferent balloons have different ranges and some bonk zombies for longer. Carry a balloon past the zombies to the next safe zone and it will level up.") )
		
	elseif s=="base objective" then -- basic help
	
		vuser_cast(vuser, vobj_build_say_msg(npc.vuser,"Try and get as far to the right as you can. There are ten levels in total each one more zombie infested than the last.") )
		
	elseif s=="base safezone" then -- basic help
	
		vuser_cast(vuser, vobj_build_say_msg(npc.vuser,"To the left and right of each level is a safe zone, the zombies wont bother you there but you can't bonk them either.") )
		
	end

end


end
---
npc_leave.help=function(npc)

end
---
npc_update.help=function(npc)

local vuser=npc.vuser
local vroom=npc.vroom

local zd=npc.zd

	local p=vroom_random_xyzt(vroom,"entrance",npc.zom.roam_area)
	
	vuser_walkto(vuser,p)
	
	local t=vuser.propdata.xyzt_vel.t -- time to destination
--	if t>2 then t=2 end -- maximum time till next thunk
	
	
	for name,pc in pairs(zd.pcs) do -- look for players to greet
	
		if not pc.greeted then
	
			vuser_cast(pc.vuser, vobj_build_say_msg(npc.vuser,"Welcome to ZeeGrind, I love you. Please click me for more help.") )
			
			pc.greeted=true
			
			npc_wakeme(npc,gtab.now+2)
			return
		end
	end
	

	
	npc_wakeme(npc,gtab.now+(t*4))
	
	
end



-- expose some of these locals in the gtab

gtab.manifest_zd		=	manifest_zd
gtab.destroy_zd			=	destroy_zd

gtab.zd_thunk_npcs		=	zd_thunk_npcs

gtab.npc_create_pc		=	npc_create_pc
gtab.npc_remove_pc		=	npc_remove_pc

gtab.npc_loadzone_name	=	npc_loadzone_name



