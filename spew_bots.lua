

-----------------------------------------------------------------------------
--
-- process a possible brain command
--
-- return a msg to broadcast if it is a command we recognise
--
-- return nil if it is nothing we understand
--
-----------------------------------------------------------------------------
function generic_bot_cmds(brain,msg,user)

	if not brain then return end
	if not brain.user then return end
	if not brain.room then return end

	if user and user.room and is_room_admin(user,user.room) then return nil end -- room owner cant spam

-- no spam if super hush is enabled and the bot is hushed, cant get spammed out
--	if brain.room.hush_super and brain.room.hush_time and brain.room.hush_time>=os.time() then return nil end 
	
local newmsg

local name=brain.user.name

local len=string.len(msg.txt or "")

-- simple spam check

local function kicked(spam)

	local count=spam.kicks or 0

	count=count+1 -- one more kick

	spam.kicks=count
	
	join_room_str(user,"swearbox")
	set_status(nil,"ban",msg.frm,os.time()+(60*count*count)) -- ban for count squared minutes
	
	local s=""
	if count*count>1 then s="s" end
	return {cmd="act",frm=name,txt="shows "..msg.frm.." where the spambox is for "..(count*count).." minute"..(s).."."}

end


	if user and ( not user.brain ) and brain and ( brain.user ) then -- check for brain so we dont ban ourselves, duh :)
	
		local ipnum=user_ipnum(user)
		
		if ipnum~=0 then -- some sanity
			
			if not data.spam[ipnum] then
				data.spam[ipnum]={count=0,time=0}
			end
			
			local spam=data.spam[ipnum]

			
			spam.count=spam.count+force_floor(len/50) -- penalise for length
			
			if msg.txt and string.find(msg.txt,"http://") then -- post images / links
			
				spam.count=spam.count+4
			end
			
			if spam.time < os.time()-(2+(len/5)) then -- zero counter on more than 2 secs between talking, 
				spam.count=0
			end
			
			spam.count=spam.count+1
			spam.time=os.time()
					
			if spam.count>9 then
			-- say 10 things with a gap of less than 2 secs between each, get kicked
			
				return kicked(spam)
				
			end
			
			if ( user.status and ( user.status.active=="gag" or user.status.active=="dis" ) ) and spam.count>2 then
			-- say 3 things with a gap of less than 2 secs between each, get kicked if you have been gagged
			
				return kicked(spam)
				
			end
			
			if is_mud(user.name) and spam.count>2 then
			-- say 3 things with a gap of less than 2 secs between each, get kicked if your name is mud
			
				return kicked(spam)
				
			end
			
		end
		
	end

--[[
	if not brain.hush_time or brain.hush_time<os.time() then
		
		if msg.cmd=="say" then -- respond to talking or acts
		
			if ( msg.frm==name ) or ( msg.frm=="*" ) then return nil end -- ignore talking to self and notifications

			local txt=string.lower(msg.txt)
			
			if txt=="..." then
				user.spam.count=user.spam.count+5
				return {cmd="say",frm=name,txt="Automated Alice, a book by Jeff Noon is a trequel to Alice in Wonderland and is in many ways concerned with the proper use of the ellipses..."}
=--			elseif string.find(txt, "digg") then
--				return {cmd="lnk",frm=name,txt="If you like this game then please click here to digg us...",lnk="http://www.wetgenes.com/link/digg"}
			elseif string.find(txt, "facebook") then
				return {cmd="say",frm=name,txt="add me on facebook, visit http://facebook.wetgenes.com"}
			elseif string.find(txt, "myspace") then
				return {cmd="say",frm=name,txt="add me on myspace, visit http://myspace.wetgenes.com"}
			end
			
			local aa=str_split(" ",txt)
			
			if aa[1] == "time" then
			
					local time = os.date("it is now %H:%M:%S %a %d %b GMT")
					
					return {cmd="say",frm=name,txt=time}
			end
			
		end
		
	end
]]

	return nil
end





-----------------------------------------------------------------------------
--
-- remove all bots
--
-----------------------------------------------------------------------------
function remove_all_bots()

	for u,b in pairs(data.brains) do

		b:delete()
		data.brains[u]=nil

	end

end

-----------------------------------------------------------------------------
--
-- remove generic bots
--
-----------------------------------------------------------------------------
function remove_bots()
	remove_all_bots()
end


-----------------------------------------------------------------------------
--
-- find a random public room
--
-----------------------------------------------------------------------------
function get_random_public_room()

local tab={}

	for i,v in pairs(data.rooms) do
	
		if not v.owners[1] then -- this is a public room
		
			if not v.locked and not v.mux then -- and unlocked and not fiction
		
				table.insert(tab,v)
			
			end
		
		end
	
	end
	
	return tab[math.random(#tab)]

end

-----------------------------------------------------------------------------
--
-- find a bot by name, return its user tab
--
-----------------------------------------------------------------------------
function get_bot_by_name(name)

name=string.lower(name)

	for u,b in pairs(data.brains) do
	
		if string.lower(u.name)==name then
		
			if u.room then
				if u.room.brain~=u.brain then -- ignore bots that own rooms
					return u
				end
			end
		end
	
	end

	return nil
end

-----------------------------------------------------------------------------
--
-- put kolumbo in a random room
--
-----------------------------------------------------------------------------
function kolumbo_relocate()

local u=get_bot_by_name("kolumbo")

	if u then
	
		local r=get_random_public_room() -- put kolumbo in a random room
		
		if r then
			join_room(u,r)
			
dbg("Kolumbo is in "..(r.name).."\n")

-- make sure he really is in the right room
			local vuser=vuser_obtain(u)
			local vroom=vroom_obtain(u.room)
			vroom_join( vroom , vuser )
	
		end
	
	end

end

-----------------------------------------------------------------------------
--
-- add generic bots
--
-----------------------------------------------------------------------------
function add_bots()
local v,u
local vuser,vroom
local r


	v="kolumbo" -- special wandering bot
	
	u=get_bot_by_name(v)
	if not u then
		u=new_user{}
		data.brains[u]=new_brain[v]{ user=u }
		login_newname(u,v)
	end
	kolumbo_relocate() -- put kolumbo somewhere random
	
--	u.room.locked="kolumbo"
	
	vuser=vuser_obtain(u)
	u.vobj=vuser.id -- map the user to the id and use as flag to show we are logged into ville	
	vuser.brain=data.brains[u]
	
--	join_room_str(u,"noir.tv") -- kolumbo likes the black and white movies
	vroom=vroom_obtain(u.room)
	vroom_join( vroom , vuser )
	
	u.brain.update(u.brain)



	
	v="kolumbo_bob" -- special wandering bot
	
	u=get_bot_by_name(v)
	if not u then
		u=new_user{}
		data.brains[u]=new_brain[v]{ user=u }
		login_newname(u,v)
	end
	
	vuser=vuser_obtain(u)
	u.vobj=vuser.id -- map the user to the id and use as flag to show we are logged into ville	
	vuser.brain=data.brains[u]
	
	join_room_str(u,"public.zeegrind") -- kolumbo bob lives in the zeegrind
	
	vroom=vroom_obtain_name(u.room,string.lower(u.room.name).."/11")
	vroom_join( vroom , vuser )
				
	u.brain.update(u.brain)

--dbg("vroom:",vroom.name,"\n")
	
	
	
	v="lieza" -- limbo bot
	u=new_user{name=v}
	data.brains[u]=new_brain[v]{ user=u, room="limbo" }
	u.room.brain=u.brain


	
	
	for _,r in pairs(data.rooms) do
	
		if r.retain_noir and r.retain_noir>os.time() and r.retain_noir_name then -- this room still has paid for supervision, add noir back in when i reset
		
			u=new_user{name=r.retain_noir_name}
			data.brains[u]=new_brain["noir"]{ user=u , room=r.name }
			u.room.brain=u.brain
			
		elseif r.addnoir then
		
			u=new_user{name=r.addnoir}
			data.brains[u]=new_brain["noir"]{ user=u , room=r.name }
			u.room.brain=u.brain
			
		end
		
		vroom=data.ville and data.ville.rooms and data.ville.rooms[r.name] -- check the virtual bots
		if vroom then
			vroom_check_bots(vroom)
		end
		
	end
		
	
end



