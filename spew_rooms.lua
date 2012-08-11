

local imgbacks=
{

["xix"]=cfg.base_data_url.."/game/s/spew/backs/xix.png",
["shi"]=cfg.base_data_url.."/game/s/spew/backs/shi.png",

["swearbox"]=cfg.base_data_url.."/game/s/spew/backs/swearbox.png",

["public.tv"]=cfg.base_data_url.."/game/s/spew/backs/tv.png",
}
-----------------------------------------------------------------------------
--
-- return a new room
--
-----------------------------------------------------------------------------
function new_room(opt)

local room={}

	room.addlieza=opt.addlieza or nil
	room.addnoir=opt.addnoir or nil
	room.locked=opt.locked or nil
	room.imgback=opt.imgback or nil
	
	room.mux=opt.mux or nil
	room.state=opt.state or "open"
	room.name=opt.name or "limbo"
	room.welcome=opt.welcome or ("Welcome to "..room.name.."s room!")
	room.goodbye=opt.goodbye or ("Leaving "..room.name.."!")
	room.history={}
	room.history_max=32
	room.users={}
	room.user_count=0
	room.owners={} -- names of users who are local admins in this room, [1] is the main owner, rest are deputies
	
	room.allow={} -- names of people allowed in to an otherwise locked room, this is a name->true map for easy testing

	data.rooms[room.name]=room
		
	check_room(room)

	return room
end
-----------------------------------------------------------------------------
--
-- delete an old room
--
-----------------------------------------------------------------------------
function del_room(room)

-- cast any remaining users out into public rooms

	while next(room.users,nil) do
	
	local v=next(room.users,nil)
	
		if v then
		
--dbg("remove ",v.name,"\n")

			if v.client then -- move user
			
				join_room_pub(v)
				
			elseif v.brain then -- kill bott
			
				del_user(v)
				
			end
			
		end
		
	end
	
	clean_gameroom(room)
	
	data.rooms[room.name]=nil 			-- remove main reference
	
end

-----------------------------------------------------------------------------
--
-- check rooms
--
-----------------------------------------------------------------------------
function check_room(room)

local dot=str_split(".",room.name)
local name

	for i=5,1,-1 do
	
		if dot[i] then

			name=dot[1]
			for ii=2,i do name=name.."."..dot[ii] end
	
			if imgbacks[name] then
			
				room.imgback=imgbacks[name]
				
				
				break
			
			end
			
		end
		
	end
	
	
	if room.retain_noir and room.retain_noir>os.time() and room.retain_noir_name then -- paid bot, keep room
		
	elseif room.addnoir then -- forced bot, keep room
	
	elseif room.owners[1] then -- private room that is not retained, so we may delete it
	
		if (room.history.stamp or 0) + (60*60*24*7) < os.time() then -- over a week since last talk, kill the room...
		
			del_room(room)
		
		end

	end
	
end

function check_rooms()

local count=0

	for n,r in pairs(data.rooms) do
	
		count=count+1
	
		check_room(r)
		
	end
	
dbg("CHECKED ROOMS: ",count,"\n")
	
end



-----------------------------------------------------------------------------
--
-- check if name is a room owner
--
-----------------------------------------------------------------------------
function is_room_owner(room,name)

local n=string.lower(name)

	for i,v in ipairs(room.owners) do
		if v==n then return true end
	end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is allowed to enter an otherwise locked room
--
-----------------------------------------------------------------------------
function is_room_allowed(room,name)

	if room.allow and room.allow[string.lower(name)] then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is denied to enter an otherwise open room
--
-----------------------------------------------------------------------------
function is_room_denied(room,name)

	if room.deny and room.deny[string.lower(name)] then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- find a room by name
--
-----------------------------------------------------------------------------
function get_room(name)
	return data.rooms[string.lower(name)]
end

-----------------------------------------------------------------------------
--
-- create a room if it is one of the rooms that should magically apear on request
--
-----------------------------------------------------------------------------
function manifest_room(name,user,tab)

local room

	room=get_room(name) -- already exists
	
	if not room then -- create?
	
		if user and string.lower(user.name)==string.lower(name) then -- create a home room for this user
		
			room=new_room{	name=string.lower(user.name) , locked="nochav" } -- keep chavs out by default
			room.owners[1]=string.lower(user.name)

		elseif tab then -- create room with info from tab

dbg("creating room from tab ",name,"\n")		
			room=new_room{	name=string.lower(name) } -- create a blank room
			
			for i,v in pairs(tab) do -- copy these bits across from the tab
			
--dbg("setting ",i,"\n")

				room[i]=tab[i]
			
			end
		
		end
		
	end
	
end


-----------------------------------------------------------------------------
--
-- remove a user from their current room if they have one
--
-----------------------------------------------------------------------------
function leave_room(user)
local room=user.room

	if room then 
	
		if room.game then
			game_room_part(room.game,user)
		end
	
		del_player(user) -- remove any player data associated with this user, tell the games we have left etc
		
		if user.room then usercast(user,{cmd="say",frm="*",txt=room.goodbye}) end
		
		if user.room then roomcast(user.room,{cmd="note",note="part",arg1=user.name,arg2=user.room.name}) end
	
		if room.users[user] then
			room.users[user]=nil
			room.user_count=room.user_count-1
		end
		user.room=nil
		if user.brain then user.brain.room=nil end
		
	
	end
	
end

-----------------------------------------------------------------------------
--
-- move a user into a new public room, and creates one if the rest seem full
--
-----------------------------------------------------------------------------
function join_room_pub(user)

local pubnum=0
local pubstr=""

	if user.hash and string.lower(user.gamename)~=string.lower(user.hash) then -- passed in hash, try and join that room

--dbg("HASH="..user.hash.."\n")

		local n=user.hash -- deal with some retartedness?
		
		n=str_split(".swf",n)[1]
		n=str_split(" ",n)[1]
		n=str_split("%20",n)[1]
		n=str_split("+",n)[1]
	
--dbg("HASH="..n.."\n")

		local room_name=string.lower(string.gsub(n, "[^0-9a-zA-Z%-_%.]+", "" ))
		if string.sub(room_name,1,1)=="." then room_name="public"..room_name end

		manifest_room(room_name,user)

		local room=data.rooms[room_name]
		
--dbg("HASHROOM="..room_name.."\n")

		if room then -- only try and join if room now exists
		
			join_room_str(user,room_name) -- so this will probably work
			return
			
		end
		
	end
	
	if user.gamename and ( string.lower(user.gamename)=="wetv" ) then -- join a tv room
	
		join_room_pubtv(user)
		return
	end
	if user.gamename and ( string.lower(user.gamename)=="zeegrind" ) then -- join a zeegrind room
	
		join_room_zeegrind(user)
		return
	end
	if user.gamename and ( string.lower(user.gamename)=="wetpokr" ) then -- join a poker room
	
		join_room_pokr(user)
		return
	end

	if user_confirmed(user) then
	
		if user.form=="wolf" then
		
			join_room_str(user,"public.wolf")
			return
			
		elseif user.form=="vamp" then
		
			join_room_str(user,"public.vamp")
			return
			
		elseif user.form=="zom" then
		
			join_room_str(user,"public.zom")
			return
			
		elseif (user.form~="chav") then
		
			join_room_str(user,"public.vip")
			return

		end
	
	end

	while true do
	
		local room = get_room("public"..pubstr)
	
		if not room then -- create another public room
		
			room=new_room{
				name="public"..pubstr,
				welcome="Welcome to the public"..pubstr.." room, please to be behaving your self. That means do not simulate copulation and be careful not to share personal information.",
				addnoir="noir"
			}
			remove_bots()
			add_bots()
			
			join_room_str(user,room.name)
			return
		
		end
		
		if room.user_count<55 then
		
			join_room_str(user,room.name)
			return
			
		end
	
		pubnum=pubnum+1
		pubstr="."..pubnum
	
	end

end

-----------------------------------------------------------------------------
--
-- move a user into a new public tv room, and creates one if the rest seem full
--
-----------------------------------------------------------------------------
function join_room_pubtv(user)

--dbg("pubtv\n")

local pubnum=0
local pubstr=""

	user.done_tv_spread=true

	while true do
	
		local room = get_room("public.tv"..pubstr)
	
		if not room then -- create another public room
		
			room=new_room{
				name="public.tv"..pubstr,
				welcome="Welcome to the public.tv"..pubstr.." room, please to be behaving your self. That means do not simulate copulation and be careful not to share personal information.",
				addnoir="reg"
			}
			remove_bots()
			add_bots()
			
			build_and_check_environment()
			
			join_room_str(user,room.name)
			return
		
		end
		
		if room.user_count<55 then
		
			join_room_str(user,room.name)
			return
			
		end
	
		pubnum=pubnum+1
		pubstr="."..pubnum
	
	end

end

-----------------------------------------------------------------------------
--
-- move a user into a new public zeegrind room, and creates one if the rest seem full
--
-----------------------------------------------------------------------------
function join_room_zeegrind(user)

--dbg("pubtv\n")

local pubnum=0
local pubstr=""

	user.done_zeegrind_spread=true

	while true do
	
		local room = get_room("public.zeegrind"..pubstr)
	
		if not room then -- create another public room
		
			room=new_room{
	name="public.zeegrind"..pubstr,
	welcome="Welcome to zeegrind, where you may grind zee zombies.",
	addnoir="meatwad",
	locked="ville",
	novillebot=true,
			}
			remove_bots()
			add_bots()
			
			build_and_check_environment()
			
			join_room_str(user,room.name)
			return
		
		end
		
		if room.user_count<16 then
		
			join_room_str(user,room.name)
			return
			
		end
	
		pubnum=pubnum+1
		pubstr="."..pubnum
	
	end

end

-----------------------------------------------------------------------------
--
-- move a user into a new public pokr room, and creates one if the rest seem full
--
-----------------------------------------------------------------------------
function join_room_pokr(user)

local pubnum=0
local pubstr=""

	user.done_pokr_spread=true

	while true do
	
		local room = get_room("public.pokr"..pubstr)
	
		if not room then -- create another public room
		
			room=new_room{
	name="public.pokr"..pubstr,
	welcome="Welcome to Wet Pokr, where you may win many cookies then lose them all.",
	addnoir="ygor",
	locked="ville",
			}
			remove_bots()
			add_bots()
			
			build_and_check_environment()
			
			join_room_str(user,room.name)
			return
		
		end
		
		if room.user_count<16 then
		
			join_room_str(user,room.name)
			return
			
		end
	
		pubnum=pubnum+1
		pubstr="."..pubnum
	
	end

end

-----------------------------------------------------------------------------
--
-- send the user has joined msg, may get multiple joins per user
--
-----------------------------------------------------------------------------
function join_room_build_msg(name)

local user=get_user(name)

	if user and user.room then
		return {cmd="note",note="join",arg1=user.name,arg2=user.room.name,arg3=user.gamename,arg4=user.gameid,arg5=user.color or ""}
	else
		return {cmd="note",note="join",arg1=name,arg2="*",arg3="*",arg4="0",arg5=data.saved_color[ string.lower(name) ] or ""}
	end
end

-----------------------------------------------------------------------------
--
-- move a user into a new room
--
-----------------------------------------------------------------------------
function join_room(user,room)

	if (not user) or (not room) then return false end	-- null check
	
	if user.room==room then	return true end -- we are already here


	leave_room(user)
	
	room.user_count=room.user_count+1
			
	room.users[user]=true
	user.room=room
	
	if user.brain then
		user.brain.room=room
	else
		roomcast(user.room,join_room_build_msg(user.name))
	end

-- connect this user to mux if we need to
	if room.mux then
	
		usercast(user,{cmd="note",note="welcome",arg1=room.welcome})
		
		mux_connect(user)
		
		return true
	end
	
	
--	usercast(user,{cmd="say",frm="*",txt="Joining "..room.name})

	if user.client then -- do not recap the bots
	
		if room.name~="limbo" or data.admin_names[ string.lower(user.name) ] then -- do not recap in limbo except for admins
		
		local sent={}
		
			for i,v in ipairs(room.history) do
			
				if v.frm then
				
					if not sent[v.frm] then
					
						sent[v.frm]=true
						
						usercast(user,join_room_build_msg(v.frm)) -- send color / game etc of recent talkers 
						
					end
				end
				
				usercast(user,v)
			end
			
		end
		
		if user.gamename=="irc" then -- special welcome msg
		
			usercast(user,{cmd="topic"})
			usercast(user,list_users_msg(user))
			usercast(user,{cmd="note",note="welcome",arg1=room.welcome,back=room.imgback or "-"})
		
		elseif user.gamename=="telnet" and room.name=="limbo" and user.name=="me" then -- special welcome msg
		
			usercast(user,{cmd="note",note="notice",arg1="Welcome to the world of tomorrow!"})
			usercast(user,{cmd="note",note="notice",arg1="visit http://join.wetgenes.com/ to make an account."})
			usercast(user,{cmd="note",note="notice",arg1="/LOGIN NAME PASS will log you in and /LOGOUT will log you out."})
			usercast(user,{cmd="note",note="notice",arg1="Everything you type will normally just be said. Special commands begin with / for instance /ME FALLS OVER for acts or /ROOMS for a room list and /JOIN ROOMNAME to join a room, /USERS will give you a list of who is in this room."})
--			usercast(user,{cmd="note",note="notice",arg1="type CONNECT NAME PASS or GUEST NAME to login."})
		
		else
			if string.sub(room.welcome,1,7)=="http://" then -- image welcome
				local frm="*welcome*"
				if room.brain and room.brain.user then frm=room.brain.user.name end
				usercast(user,{cmd="lnk",frm=frm,txt=room.welcome,lnk=room.welcome})
			else
				usercast(user,{cmd="note",note="welcome",arg1=room.welcome,back=room.imgback or "-"})
			end
		end
	end
	
	if room.game then -- this user needs a player in this room
	
		new_player( room.game , user , {status="idle"} )
	
	end
	

	update_and_check_user_status( user , nil )
	
	if room.game then
		game_room_join(room.game,user)
	end

-- check for room effects on entering room

	local farted=day_flag_get(room.name,"zombie_fart")
	
	if farted then
	
		userqueue(user,{cmd="note",note="act",arg1="The funk of forty thousand years fills this room!"})
			
		if user.name~="me" and not is_admin(user.name) and not is_bot(user.name) then
		
			if user.form~="zom" then
			
				roomqueue(room,{cmd="note",note="act",arg1=user.name.." smells "..farted.."s funk and turns into a zombie."})
				user.form="zom"
				
			end
		
		end
		
	end
				
--dbg(user.gamename.."\n")

	if user.gametype~="WetVille" then -- user is not playing vill
	
		local vroom=data.ville and data.ville.rooms and data.ville.rooms[room.name]
		
--dbg(((vroom and vroom.voyeurs_count) or "*") .."\n")

		if vroom and vroom.voyeurs_count and vroom.voyeurs_count>1 then -- other people may be playing ville?
		
			userqueue(user,{cmd="lnk",frm="cthulhu",
			txt=vroom.voyeurs_count.." people are playing Ville in this room. Click here to quit "..user.gamename.." and play Ville with them instead.",
			lnk="http://ville.wetgenes.com/#"..room.name})
		
		end
		
	else
		
-- relocate the ville into this room if we must

		if not user.skip_auto_ville_join then -- this is set if ville is changing room and will handle this later		
		
			vuser_sync_room_by_user(user)
		end
	
	end
	
	return true
end


-----------------------------------------------------------------------------
--
-- is this form allowed in this room? return trus if they are
--
-----------------------------------------------------------------------------
function room_lock_form_test(room,form)

local lock=room.locked

local badform={
	chav={nochav=true,wolf=true,vamp=true,man=true,zom=true},
	wolf={chav=true,vamp=true,man=true,zom=true},
	zom={chav=true,vamp=true,man=true,wolf=true},
	vamp={chav=true,zom=true,man=true,wolf=true},
}

local bad=badform[form or "man"]

	if not bad then return true end -- no deny
	
	if room.locked and bad[room.locked] then return false end -- these locks keep the form out
	
	return true -- otherwise ok
end

-----------------------------------------------------------------------------
--
-- move a user into a new room, by name, create the room if it should
--
-----------------------------------------------------------------------------
function join_room_str(user,room_name)

--dbg("join\n"..user.room.name.."\n"..room_name.."\n")

-- expand names that begin with . into public.
	if string.sub(room_name,1,1)=="." then room_name="public"..room_name end


	if room_name=="public.tv" and not user.done_tv_spread then -- special first join check, spread the noobs out
		return join_room_pubtv(user)
	end
	if room_name=="public.zeegrind" and not user.done_zeegrind_spread then -- special first join check, spread the noobs out
		return join_room_zeegrind(user)
	end

	room_name=string.lower(room_name)

	manifest_room(room_name,user)

local room=data.rooms[room_name]

local dizzy=day_flag_get(user.name,"dizzy")

	local du=is_dramaip(user_ipnum(user))
	if du then -- possible drama
		local dr=is_dramaroom(room)
		if dr and dr>0 and du>0 and dr~=du then -- actual drama, just refuse entry
			userqueue(user,{cmd="note",note="act",arg1="You are not allowed in that room("..dr..") due to possibilities of drama!"})
			return
		end
	end
	
	if dizzy and dizzy>os.time() and not is_admin(user.name) and room_name~="swearbox" then -- too dizzy to move, can always move into the swearbox
	
		usercast(user,{cmd="note",note="warning",arg1="you are too dizzy to move rooms! ("..(dizzy-os.time())..")"})
	
		return
		
	end
			
	if user.name=="me" and room_name~="swearbox" then
	
		usercast(user,{cmd="note",note="warning",arg1="you can not join that room as you are not logged in. Type /login name_you_want_to_have if you need to login."})
	
		return
		
	end

-- advance check of status of new room without actually joining it yet
	
	update_and_check_user_status( user , room )
		
	if user.status and user.status.active == "ban" then

		usercast(user,{cmd="note",note="warning",arg1="you can not join that room as you have been banned"})
	
		update_and_check_user_status( user , nil )
		
		return
		
	end

-- reset status in case the join fails

	update_and_check_user_status( user , nil )
			
	
	if room then
	
		if get_user(data.tagged_name)==user then -- tagged user is not allowed to move into private rooms
		
			if room.owners[1] or room.mux then -- owned rooms, or mux rooms
				usercast(user,{cmd="note",note="warning",arg1="sorry but your huge tag does not fit into that room."})
				return
			end
		
		end
	
	local room_allow=is_room_allowed(room,user.name) or is_admin(user.name) or is_bot(user.name) or is_room_owner(room,user.name)
	local room_deny=(not room_allow ) and is_room_denied(room,user.name) -- allow overrides denylist, so cant deny room owners
	
	
--if is_admin(user.name) then room_allow=false end -- for testing locks

	
		if room_deny then
			usercast(user,{cmd="note",note="warning",arg1="sorry but you have been denied entrance to that room by its owners."})
			return
		end
	
		if room.max_users and room.user_count>=room.max_users then
		
				usercast(user,{cmd="note",note="warning",arg1="sorry but that room is full of "..(room.max_users).." people"})
				return
				
		elseif room.locked=="man" then
		
			if not user_confirmed(user) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry only registered users with confirmed emails can enter that room"})
				return

			elseif user.form~=nil and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but only humans can enter that room"})
				return
				
			end
		
		elseif room.locked=="vamp" then
		
			if not user_confirmed(user) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry only registered users with confirmed emails can enter that room"})
				return

			elseif user.form~="vamp" and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but only vampires can enter that room."})
				return

			end
		
		elseif room.locked=="chav" then
		
			if not user_confirmed(user) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry only registered users with confirmed emails can enter that room"})
				return

			elseif user.form~="chav" and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but only chavs can enter that room."})
				return

			end
		
		elseif room.locked=="wolf" then
		
			if not user_confirmed(user) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry only registered users with confirmed emails can enter that room"})
				return

			elseif user.form~="wolf" and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but only werewolfs can enter that room."})
				return

			end
		
		elseif room.locked=="zom" then
		
			if not user_confirmed(user) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry only registered users with confirmed emails can enter that room"})
				return

			elseif user.form~="zom" and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but only zombies can enter that room."})
				return

			end
		
		elseif room.locked=="all" then
		
			if not room_allow then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but that room is locked"})
				return

			end
		
		elseif room.locked=="guests" then
		
			if user_rank(user)>0 and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but only guests can enter that room, to become a guest say /login guestnameyouwouldliketousebutnotthis"})
				return

			end
					
		elseif room.locked=="vip" then
		
			if user_rank(user)<1 and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but guests can not enter that room"})
				return

			end
					
		elseif room.locked=="rank5" then
		
			if user_rank(user)<5  and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but only ranks 5 and above can enter that room"})
				return

			end
					
		elseif room.locked=="rank10" then
		
			if user_rank(user)<10  and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but only ranks 10 and above can enter that room"})
				return

			end
					
		elseif room.locked=="nochav" then
		
			if user_confirmed(user) and user.form=="chav" and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="sorry but registered chavs can not enter that room."})
				return

			end
		
		elseif room.locked=="kolumbo" then
		
dbg("kolumbo "..room.name.." attempted by "..user.name.." from "..user.room.name.."\n")

			if user.gametype~="WetVille" and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="Sorry but you must be playing in WetVille to enter that room."})
				return

			end
			
			local k=get_bot_by_name(room.name)
			local kvu,kvr
			local vu,vr
		
			if k then
			
				kvu=vuser_obtain(k)
				
				if kvu then
					
					kvr=vobj_get_vroom(kvu)
				
dbg("kolumbo vcheck "..kvr.name.."\n")
				end
			
dbg("kolumbo check "..k.room.name.."\n")
			
			end
			
			if user.gametype~="WetVille" and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="Sorry but you must be playing in WetVille to enter that room."})
				return

			end
			
			vu=vuser_obtain(user)
			if vu then
				vr=vobj_get_vroom(vu)
			end

			if ( (not k) or (k.room~=user.room) or (vr~=kvr) ) and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="You must be in the same room as "..room.name.."."})
				return

			end
		
		elseif room.locked=="ville" then -- must be playing ville to enter
		
			if user.gametype~="WetVille" and (not room_allow) then
			
				usercast(user,{cmd="note",note="warning",arg1="Sorry but you must be playing in WetVille to enter that room."})
				return

			end
		
		end
		
		join_room(user,room)
	
	else
	
		usercast(user,{cmd="note",note="warning",arg1="you can not join that room"})
	
	end
	
end

-----------------------------------------------------------------------------
--
-- return a msg containing a list of users
--
-----------------------------------------------------------------------------
function list_rooms_msg(user,msgin)

local s
local msg

	msg={cmd="note",note="rooms"}

	s=""

	local openrooms={swearbox=true,fiction=true}
	openrooms[string.lower(user.name)]=true -- own room
	
	for i,v in pairs(data.rooms) do
	
		if ( v.user_count > 0 ) or (openrooms[v.name]) or (v.brain) then -- ignore rooms with zero members unless it is a special room or has a bot
		
			openrooms[v.name]=nil -- forget from list
			
			local d=nil
			
			for _,swear in pairs(data.badwords) do
			
				d=string.find(v.name,swear)
				
				if d then break end
				
			end
			
			if not d then -- skip dodgy word room names
		
				if s~="" then s=s.."," end
				
				s=s .. v.name .. ":" .. (v.user_count)
				
				if v.game then
				
					s=s .. ":" .. v.game.name.. ":" .. v.game.state
				
				end
			end
		end
	end

-- always add these rooms even when they do not exist yet...

	for name,bb in pairs(openrooms) do

		if s~="" then s=s.."," end
		
		s=s .. name .. ":" .. 0
		
	end
	
	msg.list=s

	return msg
	
end


-----------------------------------------------------------------------------
--
-- remove say / act msgs with "" text parts from the history
--
-----------------------------------------------------------------------------
function compact_history(room)

	if room.mux then return end
	
local tab={}

	for i,v in ipairs(room.history) do
	
		if v.cmd=="say" or v.cmd=="act" then -- filter
		
			if v.txt ~= "" then
			
				table.insert(tab,v)
			
			end
		
		end
		
	end
	
	room.history=tab
end

-----------------------------------------------------------------------------
--
-- send a msg to everyone in a given room
--
-----------------------------------------------------------------------------
function roomcast(room,msg,user)
--dbg("roomcast ",room.name," ",msg_to_str(msg),"\n")

	if not room then return end
	if not msg then return end
	if type(user)=="nil" and msg.frm then user=get_user(msg.frm) end -- make sure someone gets blamed
	
	if room.mux then return end

	fix_msg_rgb(user,msg)


	

--[[
	if room.name=="limbo" then -- special to filter some msgs from limbo

		if msg.cmd=="note" then -- ignore some notes
			
			if msg.note=="join" or msg.note=="part" or msg.note=="rename" then
				if user and user.client then -- send to user anyway
--					usercast(user,msg)
				end
print(serialize(msg))
--				return
			end
			
		end
		
	end
]]

-- do not pass in the blame, just use it so bots can pick up on users spaming with bot help
local blame=msg.blame
	msg.blame=nil

	
local form_filter=nil
local form_alt="..."
local form_msg="..."

	if msg.form_filter then
	
		form_filter=msg.form_filter
		msg.form_filter=nil
		
	end
	
	if msg.form_alt then
	
		form_alt=msg.form_alt
		msg.form_alt=nil
		
	end
	
	if msg.form_msg then
	
		form_msg=msg.form_msg
		msg.form_msg=nil
		
	end
	
	if room.locked=="news" and ( ( not is_room_admin(user,room) ) or user.brain ) then -- only room admins can speak in news rooms, even the bots hush
	
		if msg.cmd=="say" then -- since only says are recorded only they are banned
		
			return
			
		end
	
	end

	
local oldtxt=nil
local newtxt=nil

-- last minute translation	
	if user and msg.cmd=="say" and day_flag_get(user.name,"zom_bork") then -- this user has had their brain adjusted by a zombie

		oldtxt=msg.txt
		newtxt=string_chef_filter(msg.txt)
	
	end
	
	local star_tag=day_flag_get("*","tag") -- the stars align for a special tag effect today
	
	if star_tag and user then
	
		if string.lower(user.name)==string.lower(data.tagged_name or "") then -- only the tagged user
		
			if msg.cmd=="say" and star_tag=="strong" then -- the tagged user has a special case
				oldtxt=msg.txt
				newtxt="Cirno am the strongest!"
			end
			
		end
		
		if star_tag=="redacted" then -- everyone not just the tag victim
			if (msg.cmd=="say" or msg.cmd=="act") then -- redact all forms of communication
				oldtxt=msg.txt
				newtxt="[REDACTED]"
			end
		end
		
	end
	
	if room.game then -- send chat into the game, this may kill the ,msg
	
		if game_room_chat(room.game,msg,user) then
		
			return
		
		end
	
	end
	
	room.user_count=0 -- recalculate

	for v,b in pairs(room.users) do
	
		if v.client then
		
			if ( v.room~=room ) or ( not data.users[v] ) then
			
				room.users[v]=nil -- bug? ghost users? who knows?
				del_user(v)
			
			else
		
				room.user_count=room.user_count+1
			
				if form_filter then
				
					if	v.form==form_filter or is_admin(v.name) then
					
						msg.txt=form_msg -- we talk to our own kind
					else
						msg.txt=form_alt -- and everyone else just sees this
					end
					
					usercast(v,msg)
--					client_send(v.client , msg_to_str(msg,v.msg) .. "\n\0")  -- every client gets a custom built string
					
				else
				
					if newtxt then msg.txt=newtxt end
					
					usercast(v,msg)
--					client_send(v.client , msg_to_str(msg,v.msg) .. "\n\0")  -- every client gets a custom built string
					
				end
				
			end
			
		elseif v.brain then
		
			local frm
			local old_user
		
			if blame then -- swap out who said this when passing it to the bots
			
				old_user=user
				frm=msg.frm
				msg.frm=blame
				user=get_user(blame)
			
			end
		
			if form_filter then -- the brain still sees everything
			
				msg.txt=form_msg
				
				safecall( v.brain.msg , v.brain , msg ,user)
				
			else
			
				if oldtxt then msg.txt=oldtxt end
			
				safecall( v.brain.msg , v.brain , msg ,user)
				
			end
			
			if blame then -- swap back who said this after passing it to the bots
			
				user=old_user
				msg.frm=frm
			
			end
			
		else --ghost?
		
			if ( v.room~=room ) or ( not data.users[v] ) then
			
				room.users[v]=nil -- bug? ghost users? who knows?
				del_user(v)
			
			end
			
--			room.users[v]=nil -- bug? ghost users? who knows?
--			del_user(v)

		end
	end
	
	if msg.cmd=="say" then -- save in history
	
		table.insert(room.history,msg)
		room.history.stamp=os.time()
		
		while room.history[room.history_max] do
			table.remove(room.history,1)
		end
	end
	
-- finally if this is a public room and not the panopticon, also resend it into the panopticon
-- ignore all botthings
-- say or act only
	if	user and
		(not user.brain) and 
		(not room.owners[1]) and 
		( (msg.cmd=="say") or (msg.cmd=="act") ) and
		(room.name~="limbo") and
		(room.name~="swearbox") and
		(room.name~="panopticon") then
	
		local proom=get_room("panopticon")
		if proom then roomcast(proom,msg,user) end
	
	end
	
end

-----------------------------------------------------------------------------
--
-- queue a msg to everyone in a given room
--
-----------------------------------------------------------------------------
function roomqueue(room,msg,user)

	if not room then return end
	if not msg then return end
--	if not user then return end

	fix_msg_rgb(user,msg)
	
	table.insert(data.msg_send_queue,{"room",room,msg,user})
	
end

