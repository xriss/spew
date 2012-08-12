
local vroom_urls={
	
	
	["kolumbo"]				="/game/s/ville/test/room/kolumbo.xml",
	["kolumbo_bob"]			="/game/s/ville/test/room/kolumbo.xml",
	
}

local vroom_base_urls={

	["vip"]				="/game/s/ville/test/room/vip_wide.xml",
	["zom"]				="/game/s/ville/test/room/zom_wide.xml",
	["wolf"]			="/game/s/ville/test/room/wolf_wide.xml",
	["vamp"]			="/game/s/ville/test/room/vamp_wide.xml",
		
	["tv"]				="/game/s/ville/test/room/tv_wide.xml",
	
	["corridor"]		="/game/s/ville/test/room/corridor.xml",
	
	
	["zeegrind"]		="/game/s/ville/test/room/zeegrind0.xml",
	["bigpong"]			="/game/s/ville/test/room/clock_wide.xml",
	["tv"]				="/game/s/ville/test/room/tv_wide.xml",
	["kickabout"]		="/game/s/ville/test/room/kickabout.xml",
	["4lfa"]			="/game/s/ville/test/room/comic_4lfa.xml",
	["pokr"]			="/game/s/ville/test/room/poker_title.xml",

}

-----------------------------------------------------------------------------
--
-- create a room vobj
--
-----------------------------------------------------------------------------
function vroom_create(tab)

local vobj=vobj_create(tab)

	vobj.uniques={} -- object idstr of unique objecs in the room, check the id is still valid before using it
	
	vobj.voyeurs={} -- names of users watching this vroom
	vobj.voyeurs_count=0

	vobj.contents={} -- object idstr=true of objects in this room
	
	vobj.rooms={} -- name -> idstr of sub rooms of this room, eg for broom_closet
	
	vobj.name=tab.name or tab.owner
	data.ville.rooms[vobj.name]=vobj -- save into rooms list
	
	return vobj
		
end

-----------------------------------------------------------------------------
--
-- destroy a room vobj
--
-----------------------------------------------------------------------------
function vroom_destroy(vobj)

local vroom=vobj

	for n,b in pairs(vroom.voyeurs) do
	
		local vuser=get_vuser(n)
		
		if vuser then

			vroom_leave(vuser)
			
		end
		
	
	end
	
	for i,b in pairs(vobj.contents) do
	
		local v=vobj_get_vobj_str(i)
		
			if v then
				vobj_destroy(v)
			end
			
			vobj.contents[i]=false
	end

	data.ville.rooms[vobj.name]=nil
	vobj_destroy(vobj)

end

-----------------------------------------------------------------------------
--
-- send all room information about objects in the vroom to this vuser
--
-----------------------------------------------------------------------------
function vroom_send_vobjs(vroom,vuser)

	vuser_cast(vuser,vobj_build_full_msg( vroom )) -- first send room, this tells the client to clear out old data
			
	for n,b in pairs(vroom.contents) do
	
		local vobj=data.ville.vobjs[ n ]
		
		if vobj then
		
			if vobj.type=="user" then -- this is an avatar
			
				if data.names[vobj.owner] and data.names[vobj.owner].vobj then -- whos user must be online, otherwise this is a ghost to ignore
				
					vuser_cast(vuser,vobj_build_full_msg( vobj )) -- then send this object
				
					local m=vobj_build_propdata_msg( vobj )
					if m then vuser_cast(vuser,m) end -- then send extra info about this object
				end
			
			else
			
--dbg("sending "..vobj.id.."\n")

				vuser_cast(vuser,vobj_build_full_msg( vobj )) -- then send this object
			
				local m=vobj_build_propdata_msg( vobj )
				if m then vuser_cast(vuser,m) end -- then send extra info about this object
				
			end
		end
		
	end

end

-----------------------------------------------------------------------------
--
-- send this vobj information to all watching vusers in the room
--
-----------------------------------------------------------------------------
function vroom_send_full(vroom,vobj)

	for n,b in pairs(vroom.voyeurs) do
	
		local vuser=data.ville.users[ n ]
		
		if vuser then
		
			vuser_cast(vuser,vobj_build_full_msg( vobj )) -- then send
			
			local m=vobj_build_propdata_msg( vobj )
			if m then vuser_cast(vuser,m) end -- then send extra info about this object
			
		end
		
	end

end

-----------------------------------------------------------------------------
--
-- tell this room that this object is gone
--
-----------------------------------------------------------------------------
function vroom_send_del(vroom,vobj)
			
	for n,b in pairs(vroom.voyeurs) do
	
		local vuser=data.ville.users[ n ]
		
		if vuser then
		
			vuser_cast(vuser,vobj_build_del_msg( vobj )) -- then send
			
		end
		
	end

end


-----------------------------------------------------------------------------
--
-- get or create the base vroom for the given room
--
-----------------------------------------------------------------------------
function vroom_obtain_url(name)


local name=string.lower(name)
local url=vroom_urls[name]

local name_parts=str_split("/",name)

local room=get_room(name_parts[1])

local aa=str_split(".",name_parts[1])


	if aa[2] then
		if vroom_base_urls[ aa[2] ] then 
		
			url=vroom_base_urls[ aa[2] ]
		end
	end
	
	if not url and room and room.owners[1] then -- this is a users home room
	
		url="/game/s/ville/test/room/home.xml"
		
	end
	
	if not url then -- default room
	
		url="/game/s/ville/test/room/bog_wide.xml"
	
	end
	
--dbg("url: ",name," : ",url,"\n")

	return url

end

function vroom_obtain(room)

local name=string.lower(room.name)
	
	return vroom_obtain_name(room,name,vroom_obtain_url(name))

end


-----------------------------------------------------------------------------
--
-- get or create the vroom for the given room and room name
--
-- url_in is without the leading "http://data.wetgenes.com/" if it is passed in
--
-----------------------------------------------------------------------------
function vroom_obtain_name(room,name,url_in)

local tab
local vroom
local url_loc

local name_parts=str_split("/",name)


	vroom=data.ville.rooms[ name_parts[1] ]

--dbg("obtain ",name,"\n")

	if name_parts[2] then -- a sub room, so try and grab it
	
		if not vroom then -- create base room first
		
			vroom=vroom_obtain_name(room,name_parts[1])
			
		end

		if vroom then -- from its master room

			vroom = vroom.rooms[ name_parts[2] ]

			if vroom then vroom=data.ville.vobjs[vroom] end -- convert id to room

		end
	
	end
	
			
	if not vroom then -- need to create a new vroom

	url_loc=url_in or vroom_obtain_url(name)
	
--dbg("obtain ",url_loc,"\n")

		tab=vobj_data_create({owner=0,type=data.ville.types.room})

		if tab then -- create the room data locally
		
			tab.type=data.ville.types[tab.type]
			tab.owner=name_parts[1]
			tab.name=name
			tab.group=nil
			
			tab.url=cfg.base_data_url..url_loc
			
			tab.props={ xyz="0:0:0" }
		
			vroom=vroom_create(tab)
			vroom.data={} -- a place to keep extra information
			vroom.zone={} -- zones of interest in this zone, probably related to the ackground gfx so you know where you are
		
			if vroom then -- also populate the room with any objects we can find in the xml so they exist serverside
			
				local fname,fdat,xml
				
				fname=cfg.data_dir..url_loc
				
				local fp=io.open(fname,"r")
				if fp then
				
					fdat=fp:read("*all")
					fp:close()
					
					xml=xml_parse(fdat)
								
					local parse
					local parse_vobj
					local parse_back
										
					parse_back=function(x) -- we need to know the size of the room
					
--dbg("loading back ",x.src,"\n")
					
						local fname=url_to_local_file(x.src) -- read this back file
						if not fname then return end
						
						local fp=io.open(fname,"r")
						
						if fp then
						
							local fdat=fp:read("*all")
							fp:close()
							
							local xml=xml_parse(fdat) -- grab xml data
							
							local parse
							parse=function(x,p) -- and lets parse the xml insode the back file
							
								if x[0]=="xyz" then
								
									local xyz={}
									
									xyz.x_min = force_floor(tonumber(x.x_min or 0))
									xyz.y_min = force_floor(tonumber(x.y_min or 0))
									xyz.z_min = force_floor(tonumber(x.z_min or 0))
									xyz.x_max = force_floor(tonumber(x.x_max or 0))
									xyz.y_max = force_floor(tonumber(x.y_max or 0))
									xyz.z_max = force_floor(tonumber(x.z_max or 0))
								
									vroom.zone[p]=xyz
									
								end
								
								if x[0]=="area" then p=x.name end
								
								for i,v in ipairs(x) do
									if type(v)=="table" then
										parse(v,p)
									end
								end
							end
							
							parse(xml,"size")
							
						end

					end
					
					parse_vobj=function(x,vobj) -- server needs to keep hold of a reference to all objects
					
						if not vobj then -- allocate a new vobj
						
							local props={}
							for i,v in ipairs{"title","game","dest","brain","id"} do -- pass on these props
							
								if x[v] then -- add a prop
								
									props[v]=x[v]
								
								end
							end
							
							local lc=string.lower(x.class or "")
							
							if data.ville.create and data.ville.create[lc] then -- check types of objects we might want to create
							
								vobj=data.ville.create[lc]({ mid=vroom.mid , owner=vroom.owner , parent=vroom.id , url=x.src , props=props })
							
							elseif string.lower(x.class or "")=="ball" then
							
								vobj=vobj_ball_create({ mid=vroom.mid , owner=vroom.owner , parent=vroom.id , url=x.src , props=props })
								
							elseif string.lower(x.class or "")=="pot" then
							
								vobj=vobj_pot_create({ mid=vroom.mid , owner=vroom.owner , parent=vroom.id , url=x.src , props=props })
								
--							elseif string.lower(x.class or "")=="hook" then
--								vobj=vobj_hook_create({ mid=vroom.mid , owner=vroom.owner , parent=vroom.id , url=x.src , props=props })
								
							else
						
								vobj=vobj_create({ mid=vroom.mid , owner=vroom.owner , parent=vroom.id , url=x.src , props=props })

								if x.class then -- mark as a class
--dbg("vobj ",x.class," ",vobj.id,"\n")								
									vobj.type=string.lower(x.class)
								end
							end
							
							vroom.contents[vobj.id]=vobj -- place a hard link in the room
							
							if x.id then
								vroom.uniques[x.id]=vobj.id -- make it easy to find a special object of a given name
							end
							
--dbg(vobj.id.." : "..vobj.owner.."\n")
--dbg(vobj.url.."\n")

						end
						
						if x[0]=="xyz" then
						
							vobj.props.xyz=(x.x_pos or 0)..":"..(x.y_pos or 0)..":"..(x.z_pos or 0)
							vobj.props.rot=(x.x_rot or 0)..":"..(x.y_rot or 0)..":"..(x.z_rot or 0)
							propdata_create(vobj) -- make sure it is uptodate
						
--dbg(vobj.props.xyz.."\n")
						end
					
						for i,v in ipairs(x) do
						
							if type(v)=="table" then
							
								parse_vobj(v,vobj)
								
							end
							
						end
						
					end
					
					parse=function(x)
					
--dbg((x[0]or"*").."\n")

						if x[0]=="room" then
							vroom.class=x.class
						end
						
						if x[0]=="vobj" then
							return parse_vobj(x,nil)
						end
						
						if x[0]=="back" then
							return parse_back(x)
						end
						
						if x[0]=="vroom" and not name_parts[2] then -- create a sub room, but only if this is not already a sub room
						
							local sub_name=x.name
							local sub_url=str_split("http://data.wetgenes.com",x.src or ".")[2]
							
--dbg("subroom ",sub_name," = ",sub_url,"\n")
							
							if sub_name and sub_url then -- load sub room
								
								local sub_vroom=vroom_obtain_name( room , name_parts[1].."/"..sub_name , sub_url )
								
								if sub_vroom then -- remember it as a sub room of this master room			
--dbg("subroom loaded\n")
--dbg(sub_vroom.url,"\n")
									vroom.rooms[sub_name] = sub_vroom.id
								
								end
							end
						end
						
						for i,v in ipairs(x) do
							if type(v)=="table" then
								parse(v)
							end
						end
--[[
					
dbg(t..(x[0]or"*").."\n")
						for n,v in pairs(x) do
						
							if type(n)~="number" then
dbg(t..n.."="..v.."\n")
							end
							
						end
						
						for i,v in ipairs(x) do
						
dbg(t..i.." "..tostring(v).."\n")
							if type(v)=="table" then
							
								parse(v,t.." ")
								
							end
						
						end
]]					
					end
					
					parse(xml)
					
					
--					dbg(serialize(xml))
				
				end
			
			end
	
		end
		
--dbg(vroom.owner.."=="..serialize(vroom.data).."\n")


		vroom_check_bots(vroom)

	end
	
	if vroom then -- force url update
	
--		vroom.url=cfg.base_data_url..url_loc
		
	end
	
	return vroom
		
end

-----------------------------------------------------------------------------
--
-- get a random point on the floor
-- in one of the zones for an object to be positioned at
--
-----------------------------------------------------------------------------
function vroom_random_xyzt(vroom,zone,area)

local x,y,z

local xr
local zr

	if area then
	
		xr=area[1] + ((area[2]-area[1])*math.random())
		zr=area[3] + ((area[4]-area[3])*math.random())
		
	else
	
		xr=math.random()
		zr=math.random()
	
	end

zone=zone or "size"
local xyz=vroom.zone[zone] or vroom.zone["size"]

	if not xyz or not xyz.x_min or not xyz.x_max then return {x=0,y=0,z=0} end

	x=xyz.x_min +20+  xr*(xyz.x_max-xyz.x_min-40)
	y=0 -- xyz.y_min +20+  math.random()*(xyz.y_max-xyz.y_min-40)
	z=xyz.z_min +20+  zr*(xyz.z_max-xyz.z_min-40)
	
	x=force_floor(x/10)*10
	y=force_floor(y/10)*10
	z=force_floor(z/10)*10

--dbg(x..":"..y..":"..z,"\n")

	return {x=x,y=y,z=z}

end
-----------------------------------------------------------------------------
--
-- get a random point on the floor
-- in one of the zones for an object to be positioned at
--
-----------------------------------------------------------------------------
function vroom_random_xyz(vroom,zone,area)

local p=vroom_random_xyzt(vroom,zone,area)

	return p.x..":"..p.y..":"..p.z

end

-----------------------------------------------------------------------------
--
-- clip a point to this area
--
-----------------------------------------------------------------------------
function vroom_clip_xyzt(vroom,p,zone,edge)

edge=edge or 20

zone=zone or "size"
local xyz=vroom.zone[zone] or vroom.zone["size"]

	if not xyz or not xyz.x_min or not xyz.x_max then return p end

	if p.x < xyz.x_min + edge then p.x = xyz.x_min + edge end
	if p.x > xyz.x_max - edge then p.x = xyz.x_max - edge end
	
	if p.z < xyz.z_min + edge then p.z = xyz.z_min + edge end
	if p.z > xyz.z_max - edge then p.z = xyz.z_max - edge end

	return p

end
-----------------------------------------------------------------------------
--
-- get an appropriate entrance location in a vroom for a vuser
--
-----------------------------------------------------------------------------
function vroom_door_xyzt(vroom,vuser)

local p={x=0,y=0,z=0}

	for n,b in pairs(vroom.contents) do
	
		local vobj=data.ville.vobjs[ n ]
		
		if vobj and vobj.type=="door" then
		
			local po=propdata_get_xyzt(vobj,lanes.now_secs())
			p.x=po.x
			p.y=po.y
			p.z=po.z
			
			vroom_clip_xyzt(vroom,p,nil,edge)
			
			return p
		end
		
	end


	return p

end

-----------------------------------------------------------------------------
--
-- convert a room name into a vroom, or nil if there is no vroom
--
-----------------------------------------------------------------------------
function get_vroom(name)

local name_parts=str_split("/", string.lower(name) )

--dbg(name_parts[1],"\n")

local vroom=data.ville.rooms[ name_parts[1] ]

	if vroom and name_parts[2] then
	
		local vroom_id=vroom.rooms[ name_parts[2] ]
		
		if vroom_id then
			local vroom_sub=data.ville.vobjs[ vroom_id ]
			
			if vroom_sub then
				vroom=vroom_sub
			end
		end
	end
	
	return vroom

end
-----------------------------------------------------------------------------
--
-- get the room this vroom is in
--
-----------------------------------------------------------------------------
function vroom_get_room(vroom)

	if not vroom then return nil end

	return get_room(vroom.owner)
end

-----------------------------------------------------------------------------
--
-- add or remove bots that should or shouldnt be in this room...
--
-----------------------------------------------------------------------------
function vroom_check_bots(vroom)

if not vroom then return end

local room=get_room(vroom.owner)
local vid
local act
local vuser

	if room.brain then -- we need a bot, check first then try and add it
	
--dbg("checking for vbots to add or remove\n")

		vid=room.brain.vid
		act="add_bot"
		
		if room.novillebot then -- do not add this bot to ville (the bot may still speak in ville from a special room object)
		
			act=nil
		
		end
		
		for v,b in pairs(vroom.contents) do
		
			local vobj=data.ville.vobjs[v]
			if vobj then

				if vid and ( vobj.id == vid ) then -- found us
				
					act=nil
					
				else
				
					if vobj.type=="bot" then -- kill all other bots in this room
				
--dbg("killing vbot "..vobj.owner.."\n")

						vroom_leave(vobj)
						vuser_destroy(vobj)
					
					end
					
				end
			end
		
		end
		
		if act=="add_bot" then -- add one in
		
--dbg("adding vbot\n")

			local tab={}
		
		 	if room.brain.user then -- this was null?
			
				tab.owner=room.brain.user.name
				tab.mid=vroom.mid -- this object belongs to the room
			
				vuser=vuser_create_bot(tab)
				
				room.brain.vid=vuser.id -- remember whom we are
				
				vuser.brain=room.brain -- a bot needs a brain

				vroom_join(vroom,vuser)
				
				vuser_check_balloon(vuser)

				vroom.uniques["room_bot"]=vuser.id -- make the rooms bot easy to find
			end
		end
	
	else -- remove a bot if we can find it
	

		for v,b in pairs(vroom.contents) do
		
			local vobj=data.ville.vobjs[v]
			if vobj then
			
				if vobj.type=="bot" then -- kill all bots in this room
			
--dbg("killing vbot "..vobj.owner.."\n")

					vroom_leave(vobj)
					vuser_destroy(vobj)
				
				end
			end
		
		end
		
	end

end

-----------------------------------------------------------------------------
--
-- check and fix status of all vobjs in this room
--
-----------------------------------------------------------------------------
function vroom_check_vobjs(vroom)

	for n,b in pairs(vroom.contents) do
	
		local vobj=data.ville.vobjs[ n ]
		
		if vobj and data.ville and data.ville.check then
		
			local f=data.ville.check[vobj.type]
			
			if f then f(vobj) end -- check and update this vobj
		end
		
	end
	
	
end


-----------------------------------------------------------------------------
--
-- remove avatar from its room and stop watching this room
--
-----------------------------------------------------------------------------
function vroom_leave(vuser)

	vuser_drop(vuser)

	if vuser.parent then -- stop watching old room
	
		local old_vroom = data.ville.vobjs[vuser.parent]
		
		if old_vroom then
		
			local room=vroom_get_room(old_vroom)

			if room and room.ville_game then -- talk to the ville game
				if room.ville_game.vroom_part then room.ville_game.vroom_part(old_vroom,vuser) end
			end
		
			vroom_send_del(old_vroom,vuser)

			old_vroom.voyeurs_count=old_vroom.voyeurs_count-1
			if vuser.owner then old_vroom.voyeurs[vuser.owner]=nil end
			old_vroom.contents[vuser.id]=nil
		
		end
		
		vuser.parent=nil
	
	end
	
end

-----------------------------------------------------------------------------
--
-- add our name to the peple who want to watch this room
-- and stop watching any old room
--
-----------------------------------------------------------------------------
function vroom_join(vroom,vuser)

local room=vroom_get_room(vroom)

-- make sure the client knows who it is
local msg={}
	msg.cmd="ville"
	msg.vcmd="vid"
	msg.vid=0
	msg.vobj=vobj_ids_to_str(vuser.mid,vuser.cid)
	vuser_cast(vuser,msg)

-- leave any old room first

	vroom_leave(vuser)
	
-- place randomly

local joininfo

	if room and room.ville_game and room.ville_game.vroom_join then -- talk to the ville game

		joininfo=room.ville_game.vroom_join(vroom,vuser)
		
	else
	
		propdata_set_xyzt(vuser,vroom_door_xyzt(vroom,vuser),0)
		propdata_send_xyzt(vuser,"force")

--		vobj_set(vuser,"xyz",vroom_random_xyz(vroom))
	
	end
	

-- tell everyone about us joining befrore we get added to list of watchers

	vuser.parent=vroom.id
	
	vroom_send_full(vroom,vuser)

-- then send all objects to us

	vroom.voyeurs_count=vroom.voyeurs_count+1
	if vuser.owner then vroom.voyeurs[vuser.owner]=true end
	vroom.contents[vuser.id]=true
	
	vroom_send_vobjs(vroom,vuser)

	vuser_check_god_balloon(vuser) -- if we have admin we get a god balloon
			
	vroom_check_vobjs(vroom) -- keep room uptodate
	
--	if room and room.ville_game then -- talk to the ville game
--		if room.ville_game.vroom_join then room.ville_game.vroom_join(vroom,vuser) end
--	end


-- finally walk to a random location in the entrance after we enter the room

	if joininfo and joininfo.walkto then
	
		vuser_walkto(vuser, joininfo.walkto )
		
	else
	
		vuser_walkto(vuser,vroom_random_xyzt(vroom))
		
	end
	
end


-----------------------------------------------------------------------------
--
-- send a msg to everyone watching this room
--
-----------------------------------------------------------------------------
function vroom_cast(vroom,msg,user)

local u

--dbg(dbg_msg(msg))

	vroom.voyeurs_count=0

	for n,b in pairs(vroom.voyeurs) do
	
		u=data.names[n]
		
		if u and u.client then
		
			usercast(u,msg)
--			client_send(u.client , msg_to_str(msg,u.msg) .. "\n\0")  -- every client gets a custom built string			
			
			vroom.voyeurs_count=vroom.voyeurs_count+1
		
		else -- remove this dead user from voyeurs list
		
			vroom.voyeurs[n]=nil

		end
	
	end

end
