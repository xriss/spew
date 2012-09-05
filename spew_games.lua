
-- a unique ID, simple inc on each use

local game_id=1


-----------------------------------------------------------------------------
--
-- str to tab and tab to str local funcs to handle ups array
--
-----------------------------------------------------------------------------
function ups_str_to_tab(game,str)
local tab
local aa

	if str then
		aa=str_split(";",str)
	elseif game then
		if game.styles.ups then
			aa=str_split(";", game.styles.ups )
		else
			return null
		end
	end
	
	
	tab={}
	for i,v in ipairs(aa) do
	
		tab[i]=str_split("/",v)
	end
	
	if game and game.room and game.room.users then
	
		game.ups={} -- about to build newups
		game.upsids={}
		
		for u,b in pairs(game.room.users) do
		
			for i,p in ipairs(tab) do
			
				if p[1]==u.name then
				
					game.ups[i]=u
					game.ups[u]=i
					game.ups[u.name]=i
					
					game.upsids[i]=u.name
					game.upsids[u.name]=i
				end
				
			end
			
		end
		
	end
			
	return tab
end

-----------------------------------------------------------------------------
--
-- str to tab and tab to str local funcs to handle ups
--
-----------------------------------------------------------------------------
function ups_tab_to_str(game)

local str=""

	for i=1,game.max_up do
	
		if str~="" then str=str..";" end
		
		if game.upsids[i] then
		
			str=str..game.upsids[i].."/ready"
		else
		
			str=str.."me/waiting"
		end
	end
	
	game.styles.ups=str
	
	return str
end


-----------------------------------------------------------------------------
--
-- return a new game
--
-----------------------------------------------------------------------------
function new_game(opt)

local game={}

	game_id=game_id+1
	
	game.id=game_id
	game.idstr = data.idstr .. string.format("%08X", force_floor(game.id) )
	
	game.name=opt.name or "chat"
	game.basename=str_split(".",game.name)[1]
	game.state="lobby"

	game.player_id=1
	game.players={}		-- all the players that have been in the room while the game is active, this is more than just the players playing the game
	game.player_count=0

	game.email_turn=0	-- last turn we emailed
	game.turn=1			-- every time any player sends an act msg this is inced by one
	game.next_up=1		-- the player who is expected to move next (start with player 1)
	game.max_up=2		-- number of players in the game
	
	game.voyeurs={}		-- the users who are watching the game
	
	game.styles={}		-- public game style string pairs eg seed=1234
	
	game.objects={}		-- serverside game objects, some public some private
	
	game.ups={}			-- the users playing the game : [1] is 1up player , [2] is 2up player , etc 
	game.upsids={}		-- link names to player ups number and upsnumber to names (this remains valid even if users are not in room)
	
	game.actions={}		-- the captured action streams, [1] is 1ups stream , [2] is 2ups stream etc, this can be used to recap the players
	game.results={}		-- what people claim the results are
	
	if opt.pbem then	-- unserailize an in progress pbem game
	
		game.pbem_info=opt.pbem
		exp_game(game)
		
	end
			
	game.styles.seed=math.random(65535)
		
	if opt.arena then	-- prepare an arena game, arena games have players joining adhoc and reset themselves every x minutes
	
		game.arena={}
		
		game.arena.duration=opt.arena.duration
		game.arena.start=os.time()
		
		game.max_up=0
		
		game.state="arena"
	end
	
	data.games[game.id]=game
	
	return game
	
end


-----------------------------------------------------------------------------
--
-- delete an old game
--
-----------------------------------------------------------------------------
function del_game(game)

	if game.pbem_info then
	
		pak_game(game)
		
	end

	game.room=nil
	
	for i,v in pairs(game.players) do -- cleanup players
	
		del_player(v.user)
	
	end

	data.games[game.id]=nil 			-- remove main reference
	
end


-----------------------------------------------------------------------------
--
-- serialise game data into pbem_info
--
-----------------------------------------------------------------------------
function pak_game(game)

	if not game.pbem_info then return end -- this will have been filled in if we where expected to update it
	
	game.pbem_info.data=game.styles.ups		-- remember current ups
	
local s
	
	for j=1,game.max_up do
	
		s=""
		
		for i,v in ipairs(game.actions[j]) do
		
			if s~="" then s=s.."," end
			
			s=s..v[1]..":"..v[2]
		end
		
		game.pbem_data["act"..j]=s
	
	end
	
	game.pbem_info.turn=game.turn
	game.pbem_data.next_up=game.next_up	
	game.pbem_data.ups=game.styles.ups
	
	game.pbem_info.data=msg_to_str(game.pbem_data)


-- save back into mysql
	
local con,num

	con=sql:connect(cfg.mysql_database,cfg.mysql_username,cfg.mysql_password)
	
	if con then
	
		num=con:execute(
		
		"UPDATE wet_beta_pbem SET "
		.." data=\"".. game.pbem_info.data .."\" , "
		.." turn=".. game.pbem_info.turn .." , "
		.." updated=".. os.time()
		.." WHERE id=".. game.pbem_info.id )

	end
	
	if con then con:close() end
	
	
end

-----------------------------------------------------------------------------
--
-- unserialise game data from pbem_info
--
-----------------------------------------------------------------------------
function exp_game(game)

local aa,aaa
	
	game.pbem_data=str_to_msg(game.pbem_info.data) -- expand data
	
	game.styles.seed=force_floor(game.pbem_info.seed)
	
	if game.pbem_data.ups then
	
		game.styles.ups=game.pbem_data.ups
			
	end
	
	for i=1,game.max_up do
	
		game.actions[i]={}
		
		if game.pbem_data["act"..i] then -- a msg is tim:data,
		
			local aas=game.pbem_data["act"..i]
			
			if aas and aas~="" then
			
				aa=str_split(",",aas)
				
				for j,v in ipairs(aa) do
				
					aaa=str_split(":",v)
					game.actions[i][j]={ force_floor(aaa[1]) , aaa[2] }
				
				end
				
			end
		
		end
	
	end
	
-- override some basic info if available

	game.turn		= game.pbem_info.turn		or game.turn
	game.next_up	= game.pbem_data.next_up	or game.next_up
	
	game.turn		=force_floor(game.turn)
	game.next_up	=force_floor(game.next_up)
		
end


-----------------------------------------------------------------------------
--
-- start a game in a given room
--
-----------------------------------------------------------------------------
function setup_gameroom(room,opt)

	if room.game then clean_gameroom(room) end
	
	room.game=new_game(opt)
	room.game.room=room

	ups_str_to_tab(room.game)
	ups_tab_to_str(room.game)
		
	game_setup(room.game)

	return room.game

end


-----------------------------------------------------------------------------
--
-- end the game in a given room
--
-----------------------------------------------------------------------------
function clean_gameroom(room)

	if room.game then
			
		game_clean(room.game)
	
		del_game(room.game)
		room.game=nil
	end

end




-----------------------------------------------------------------------------
--
-- list available game rooms, 
--
-----------------------------------------------------------------------------
function game_rooms_msg(user,msg)

local s
local ret

--dbg("OK:"..msg.gnam)

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="No gamerooms available right now, why don't you host your own and invite some friends?"}

	s=""

	for i,v in pairs(data.rooms) do
	
		if 	( ( v.user_count > 0 ) or (v.name==user.name) ) -- ignore rooms with zero members unless its our homeroom
			and (v.game) and (v.game.name==msg.gnam) then 
		
			if s~="" then s=s.."," end
			
			s=s .. v.name .. ":" .. (v.user_count)
			
			if v.game then
			
				s=s .. ":" .. v.game.name.. ":" .. v.game.state
			
			end
		
		end

	end
	
	if s~="" then
	
--dbg("recap:",s,"\n")
	
		ret.gret="OK,"..s
		
	end
	
	return ret
end



-----------------------------------------------------------------------------
--
-- list users in current room, 
--
-----------------------------------------------------------------------------
function game_users_msg(user,msg)

local s
local ret

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="No other people here right now, why dont you invite your friends?"}

	if not user.room.game or user.room.game.name~=msg.gnam then --there needs to be a game to join
	
		ret.gret="There is no game available here, so there are no users, try joining another room or hosting your own."
		
		return ret
	end
	
	s=""
	
	for v,b in pairs(user.room.users) do
	
		if v.player then
		
			if s~="" then s=s.."," end
			s=s .. v.name .. ":" .. v.player.status
			
		end
		
	end
	
	if s~="" then
	
		ret.gret="OK,"..s
		
		s=user.name
		for i,v in ipairs(user.room.owners) do -- also returns your user name and list of this rooms owners (so we can check if we are one of them)
		
			if s~="" then s=s.."," end
			s=s .. v
			
		end
		ret.gret2=s
		
	end
	
		
	
	return ret
end



-----------------------------------------------------------------------------
--
-- host a game (will only work if you are in your chatroom) so it also moves you there
--
-----------------------------------------------------------------------------
function game_host_msg(user,msg)

local s
local ret

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="Command failed."}

	
	if user.room.owners[1]~=string.lower(user.name) then --have no power to host a game in your current room, so we go to our game room if we can
	
		join_room_str(user,user.name)
	
		if user.room.owners[1]~=string.lower(user.name) then --have no power to host a game in your current room, so we go to our game room if we can
		
			ret.gret="Sorry but only signed up users with a confirmed email address can host games, maybe you just need to login?"
			return ret
			
		end
		
	end
	
	if msg.gvar=="multi" and msg.gset=="arena" then -- setup using arena mode 15 minute default
	
		setup_gameroom(user.room,{ name=msg.gnam , arena={duration=60*15} })
	
	else
	
		setup_gameroom(user.room,{name=msg.gnam})
	
	end
	
	for v,b in pairs(user.room.users) do -- make sure everyone in this room has a player tab asociated with the game
	
		new_player( user.room.game , v , {status="idle"} )
		
	end
	
	user.player.status="owner"
	
	ret.gret="OK,"..user.room.game.idstr
	return ret
end



-----------------------------------------------------------------------------
--
-- register a change in status of this user
--
-- eg a request to be picked to play
--
-----------------------------------------------------------------------------
function game_set_msg(user,msg)

local s,b
local ret

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="Command failed."}
	
	if ( not user.room.game ) or user.room.game.name~=msg.gnam then --there needs to be a game to join
	
		ret.gret="There is no game available in this room."		
		return ret
	end

--[[
	if msg.gvar=="imgurl" then -- simple avatar link (need to upgrade to proper ones sometime)
		
		user.player.imgurl = msg.gset
		
		-- tell the room about this status change
		roomcast( user.room , {cmd="game",gcmd="set",gid=0,guser=user.name,gvar=msg.gvar,gset=msg.gset} )

	else
]]
	
	if msg.gvar=="status" then -- set status

		user.player.status = msg.gset
		
		-- tell the room about this status change
		roomcast( user.room , {cmd="game",gcmd="set",gid=0,guser=user.name,gvar="status",gset=msg.gset} )

	end
	
	ret.gret="OK"
	return ret
end


-----------------------------------------------------------------------------
--
-- register a change in style of this game, only the room owner can set such things
--
-- or request the current style settings
--
-----------------------------------------------------------------------------
function game_styles_msg(user,msg)
local ret

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="Command failed.",gyou=user.name}
	
	if ( not user.room.game ) or user.room.game.name~=msg.gnam then --there needs to be a game to modify
	
		ret.gret="There is no game available in this room."		
		return ret
	end
	

local game=user.room.game

	if game.arena and game.state=="finished" then -- reset the arena

		game=setup_gameroom(user.room,{ name=msg.gnam , arena={duration=60*15} })
	
	end



	if msg.gcmd=="styles" then -- anyone can request a list of styles
	
		local s="state:"..user.room.game.state
		for i,v in pairs(user.room.game.styles) do -- return all style pairs
		
			if s~="" then s=s.."," end
			s=s .. i..":"..v
			
--dbg("styles=",s,"\n")

		end
		ret.gret="OK,"..s	
	
	elseif msg.gcmd=="style" then -- owner is setting a style

local ups_idx=game.upsids[user.name] or 0 -- the ups idx of user sending this msg

-- dbg( msg.gvar , " : ", (ups_idx.."up") , "\n")

		if ups_idx~=0 and msg.gvar==(ups_idx.."up") then 

-- "1up" "2up" etc style vars can always be set by the respective player

		elseif user.room.owners[1]~=string.lower(user.name) then -- only owner can set every thing else
			ret.gret="Only the room owner can adjust the game styles."
			return ret
		end
		
		game.styles[msg.gvar]=msg.gset;

		roomcast( user.room , {cmd="game",gcmd="style",gid=0,gvar=msg.gvar,gset=msg.gset} ) -- broadcast the change
		
		ret.gret="OK"
		
	end
	
	return ret
end

-----------------------------------------------------------------------------
--
-- broadcast the current ups array to all the players as people join the arena game
--
-----------------------------------------------------------------------------
function game_styles_send_upsids(game)

local s=""

	for i,v in ipairs(game.upsids) do
	
		if s~="" then s=s..";" end
		
		s=s..v;
	end
	if s=="" then s="-" end

	gamecast( game , {cmd="game",gcmd="style",gid=0,gvar="ups",gset=s} ) -- broadcast the change
	
end


-----------------------------------------------------------------------------
--
-- begin a game?
--
-----------------------------------------------------------------------------
function game_start_msg(user,msg)

local s,b
local ret

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="Command failed."}
	
	if ( not user.room.game ) or user.room.game.name~=msg.gnam then --there needs to be a game to play
	
		ret.gret="There is no game available in this room."
		return ret
		
	end
	
local game=user.room.game
		
	if msg.gtyp=="ready" then -- still need to wait for everyone to be ready

		if user.room.owners[1]~=string.lower(user.name) then --only owner can select players to play
			ret.gret="Only the room owner can select the players."
			return ret
		end
	
		if game.state=="lobby" or game.state=="finished" then
		
			game.voyeurs={}
			game.actions={}
			game.results={}
			
			
			ups_str_to_tab(game,msg.garg) -- builds game.ups
			ups_tab_to_str(game)
			
			for i,v in ipairs(game.ups) do
			
				usercast( v , {cmd="game",gcmd="start",gid=0,garg=game.styles.ups} )
			
			end
		
			game.state="starting" -- flag game as starting
			roomcast( user.room , {cmd="game",gcmd="style",gid=0,gvar="state",gset=game.state} ) -- broadcast the change
			
			for i=1,game.max_up do
			
				game.actions[i]={}
				game.results[i]={}
			end
				
			ret.gret="OK"
			return ret
			
		end
		
	elseif msg.gtyp=="go" then --really start the game

		if user.room.owners[1]~=string.lower(user.name) then --only owner can select players to play
			ret.gret="Only the room owner can start the game."
			return ret
		end
		
		if game.state=="starting" then
		
			game.state="playing" -- flag game as started
			roomcast( user.room , {cmd="game",gcmd="style",gid=0,gvar="state",gset=game.state} ) -- broadcast the change
			
		end
		
	elseif msg.gtyp=="finish" then --ending the game

local ups_idx=game.upsids[user.name] or 0 -- the ups idx of user sending this msg

		if game.state=="playing" or game.state=="finished" then
		
		local scores=str_split(",",msg.garg)
		
			game.state="finished" -- flag game as finished
			roomcast( user.room , {cmd="game",gcmd="style",gid=0,gvar="state",gset=game.state} ) -- broadcast the change
					
			game.results[ups_idx].scores=scores
			
--			roomcast( user.room , {cmd="note",note="notice",arg1="checking"} ) -- broadcast the results
				
			if		game.results[1].scores and
					game.results[2].scores and
					game.results[1].scores[1] == game.results[2].scores[1] and
					game.results[1].scores[2] == game.results[2].scores[2] then -- everyone say it is so

				game.state="done" -- flag game as really really finished so no multiple reports
				
-- update  elo rankings
				
				local scores={}
				scores[1]=tonumber(game.results[1].scores[1])
				scores[2]=tonumber(game.results[1].scores[2])
			
				local n1=game.upsids[1]
				local n2=game.upsids[2]
				
				local u1=get_user_forum_id(n1)
				local u2=get_user_forum_id(n2)
				
				if u1 and u1>0 and u2 and u2>1 then
				
					local aa=str_split(".",game.name) -- get a simple game name from the version string
					local game_name=aa[1]
				
					local change=elo_do(game_name, u1,u2, scores[1], scores[2] )
					
					if change>0 then
					
						roomcast( user.room , {cmd="note",note="notice",arg1=n1.." has gained "..change.." ranking points!"} )
						roomcast( user.room , {cmd="note",note="notice",arg1=n2.." has lost "..change.." ranking points!"} )
					elseif change<0 then
					
						roomcast( user.room , {cmd="note",note="notice",arg1=n1.." has lost "..(0-change).." ranking points!"} )
						roomcast( user.room , {cmd="note",note="notice",arg1=n2.." has gained "..(0-change).." ranking points!"} )
					end
				
				end

				
				local s
				
				if     scores[1] == scores[2] then
				
					s= n1 .." Draws ".. n2 .." scoring ".. scores[1] .." to ".. scores[2]
					
				elseif scores[1] > scores[2] then
				
					s= n1 .." Wins ".. n2 .." scoring ".. scores[1] .." to ".. scores[2]
					
				else
				
					s= n2 .." Wins ".. n1 .." scoring ".. scores[2] .." to ".. scores[1]
					
				end
				
				roomcast( user.room , {cmd="note",note="notice",arg1=s} ) -- broadcast the results
					
			
			end
			
		
		end
		
	end
	
	return ret
end


-----------------------------------------------------------------------------
--
-- a user is telling us the game is done, this is an arena msg and we should really check it isnt faked
--
-----------------------------------------------------------------------------
function game_done_msg(user,msg)

local s,b
local ret

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="Command failed."}
	
	if ( not user.room.game ) or user.room.game.name~=msg.gnam then --there needs to be a game to play here
	
		ret.gret="There is no game available in this room."
		return ret
		
	end

local game=user.room.game

local ups_idx=game.upsids[user.name] or 0 -- the ups idx of user sending this msg

local atim=0

-- return serverside arena time with each arena msg
	if game then
		if game.arena then
			atim=os.time()-game.arena.start
		end
	end
	ret.atim=atim
	

	if msg.gtyp=="done" then -- player says the game is done
	
		if game.state~="finished" then

			game.state="finished"
		
			gamecast( game , {cmd="game",gcmd="done",gid=0,gnam=game.name,atim=atim} )
		
		end
		
		ret.gret="OK"
		return ret
	
	
	elseif msg.gtyp=="time" then -- player says the game ran out of time
	
		if game.state~="finished" then
		
			game.state="finished"
		
			gamecast( game , {cmd="game",gcmd="done",gid=0,gnam=game.name,atim=atim} )
		
		end
	
		ret.gret="OK"
		return ret
		
	end
	
	return ret
end



-----------------------------------------------------------------------------
--
-- send or request game actions
--
-----------------------------------------------------------------------------
function game_actions_msg(user,msg)

local s,b,sn
local ret

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="Command failed."}
	
	if ( not user.room.game ) or user.room.game.name~=msg.gnam then --there needs to be a game to play
	
		ret.gret="There is no game available in this room."
		return ret
		
	end
	
local game=user.room.game	

local ups_idx=game.upsids[user.name] or 0 -- the ups idx of user sending this msg

local atim=0

-- return serverside arena time with each arena msg
	if game then
		if game.arena then
			atim=os.time()-game.arena.start
		end
	end
	ret.atim=atim

		
-- requesting a recap
-- either a watcher
-- or a player has rejoined

	if msg.gcmd=="acts" then -- anyone can request a dump of the public moves so far for this game
	
		if not game.arena then -- no need in arena games, they are special
			ups_str_to_tab(game) -- someone is requesting a recap of game data, make sure our ups array is up to date
		end
			
local gtim=force_floor(msg.gtim)

		s=""
		sn=""

		for ip=1,game.max_up do
			if s~="" then s=s..";" end				-- ; seperates each batch of ups
			if sn~="" then sn=sn..";" end			-- ; seperates each batch of ups
			
			sn=sn..game.upsids[ip] -- just the name
		
			if game.actions[ip] then
			
				for i,v in ipairs(game.actions[ip]) do
					if v[1]>=gtim then					-- pass in gtim=0 for all msgs higher numbers skips what we already know
						s=s..v[1]..":"..v[2]..","		-- a msg is tim:data
					end
				end
				
			end
		end
		if sn=="" then sn="-" end
		
--dbg("acts="..s.."\n")
	
		ret.gret="OK,"..s
		ret.gvar="ups"
		ret.gset=sn
		
		game.voyeurs[user.name]=user

--
-- player is submiting a turn
--
	elseif msg.gcmd=="act" then -- we are submiting a new action chunk
	
		if ups_idx==0 then -- this is not a playing player
		
			if game.arena then  -- just add this user to upsids
			
				game.max_up=game.max_up+1
				game.upsids[user.name]=game.max_up
				game.upsids[game.max_up]=user.name
				
				ups_idx=game.max_up
				
				game.actions[ups_idx]={}
				
				game_styles_send_upsids(game)
				
			else
				ret.gret="Sorry but you are not an active player in this game."
				return ret
			end

		end
		
		local new_action
		
		if force_floor(msg.gtim)<0 then -- assign turn
		
			new_action={game.turn , (msg.gdat or "+") }
		
		else
		
			new_action={force_floor(msg.gtim),(msg.gdat or "+")}
		
		end
		
		table.insert( game.actions[ups_idx] , new_action )

-- for i=1,8000000 do local j=math.sqrt(i) end	
		
		gamecast( game , {cmd="game",gcmd="act",gid=0,gnam=game.name,gups=ups_idx,gtim=new_action[1],gdat=new_action[2],atim=atim} )
		
-- simple step to next player, clients could break this logic since I'm not currently checking that game.next_up=ups_idx

		game.turn=game.turn+1
		
		if not game.arena then 
			game.next_up=game.next_up+1
			if game.next_up > game.max_up then game.next_up=1 end
			game_pbem_check(game)	-- check if this player needs an email reminder
		end
		
		ret.gret="OK"
	end
	
	return ret
end

-----------------------------------------------------------------------------
--
-- join a pbem game
-- an apropriate room will be created to play in
-- you can only join if you provide the right hash keys
--
-----------------------------------------------------------------------------
function game_pbem_start_msg(user,msg)

local s
local ret

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="Command failed."}
	
dbg(dbg_msg(msg))
	

local id	=string.gsub(msg.gpid,		"[^0-9]+", "" )
local hash0	=string.gsub(msg.gphash0,	"[^0-9a-zA-Z]+", "" )
local hash1	=string.gsub(msg.gphash1,	"[^0-9a-zA-Z]+", "" )

local con,cur,tab

local room

	room=get_room(".pbem"..id) -- we may have data saved, IE other player is still in the room
	if room and room.game then tab=room.game.pbem_info end

	if not tab then
	
		con=sql:connect(cfg.mysql_database,cfg.mysql_username,cfg.mysql_password)
		
		if con then
		
			cur=con:execute([[SELECT * FROM wet_beta_pbem WHERE id=]]..id)

			tab=cur:fetch({},"a")
			
		end
		
		if cur then cur:close() end
		if con then con:close() end
		
	end
	
	if tab then -- game exists
	
dbg(dbg_msg(tab))

		if tab.hash ~= hash0 then -- bad authentication			
			ret.gret="Bad authentication for this game!"
			return ret
		end

-- create or join the given pbem room
		
		if not room then -- create the room
		
			room=new_room{
				name=".pbem"..id,
				state="pbem",
				welcome="Please note that this is a tempory room and it will only exist whilst you are playing this game."
			}
			
			setup_gameroom(room,{name=msg.gnam,pbem=tab})
	
		end
		
dbg(dbg_msg(room.game.pbem_data))

	end
	
	if room then
	
		local game=room.game
		
		join_room(user,room) -- wont join if you are already there
		
		if user.room~=room then
		
			ret.gret="Failed to join room!"
			return ret
		end
		
		local new_ups=false
		for i=1,game.max_up do
			if hash1 == game.pbem_data["id"..i] then -- we got us a player
			
				new_ups=true
				game.ups[i]=user
				game.ups[user]=i
				game.ups[user.name]=i
				
				game.upsids[user.name]=i
				game.upsids[i]=user.name
			end
		end
		if new_ups then
			ups_tab_to_str(game)
			roomcast( user.room , {cmd="game",gcmd="style",gid=0,gvar="ups",gset=game.styles.ups} ) -- broadcast the change of ups
		end

		ret.gret="OK"
		
	end

	return ret
end


-----------------------------------------------------------------------------
--
-- check if we need to send any emails
--
-- or possibly shut down the room if everyone has left
--
-----------------------------------------------------------------------------
function game_pbem_check(game)

	if not game.pbem_info then return end
	
	
	if game.email_turn<game.turn and not game.ups[game.next_up] then -- send email only if we are not in room and it has not been sent before

	local t=game.next_up-1
		if t<1 then t=game.max_up end
		
		
	local email1=game.pbem_data["em"..game.next_up]
	local email2=game.pbem_data["em"..t]


	local nam1=game.pbem_data["em"..game.next_up]
	local nam2=game.pbem_data["em"..t]

		nam1=str_split("@",nam1)
		nam1=nam1[1]
		nam2=str_split("@",nam2)
		nam2=nam2[1]

	local from="<pbem@wetgenes.com>"
	local rcpt={"<"..email1..">","<pbem@wetgenes.com>"}
	local headers={}
	local body

		headers.to = email1
		headers.subject = "PBEM "..game.pbem_info.id.."."..game.turn.." : "..nam2.." is waiting for you to make your move."
		
	local msg_extra=""
	
		if game.turn==2 then -- add extra info as this is the first time 2up is getting an email
msg_extra=[[

]]..email2..[[ has challenged you <]]..email1..[[> to a game of WetDiamonds at http://www.WetGenes.com

]]
		end
		
		body=
[[Hello ]]..nam1..[[!
]]..msg_extra..[[
]]..nam2..[[ has just taken their turn and is now waiting for you.

Visit the following link to make your move.

http://www.wetgenes.com/link/WetDiamonds.swf?pbem_id=]]..game.pbem_info.id
..[[&pbem_hash0=]]..game.pbem_info.hash
..[[&pbem_hash1=]]..game.pbem_data["id"..game.next_up]
..[[/-=-//index.php/Main/WetDiamonds

Please keep the above link a secret. If you give it to someone else they will be able to play in your game as you.

-- 

Kriss

http://XIXs.com -><- http://www.WetGenes.com
]]

		local r, e = socket.smtp.send{
		  from = from,
		  rcpt = rcpt, 
		  source = socket.smtp.message( {  headers = headers,  body = body } )
		}
		
		if r then -- success, remember the last person we bothered

			game.email_turn=game.turn 
			
dbg("EMAIL SENT OK!\n")

		else
		
dbg("EMAIL FAILED!\n")

		end
		
dbg(body)


	end
	
	
	
	if game.player_count==0 then -- remove pbem room when its empty
	
dbg("REMOVE ROOM\n")
	
		del_room(game.room)	
	
	end
	
end

-----------------------------------------------------------------------------
--
-- send a message to everyone who is interested in a game, the players and the voyeurs
--
-----------------------------------------------------------------------------
function gamecast(game,msg)
	
	for i,v in pairs(game.voyeurs) do
		usercast(v,msg)
	end

end


-----------------------------------------------------------------------------
--
-- a custom game msg, handled by custom game code
--
-----------------------------------------------------------------------------
function game_do_msg(user,msg)

local ret

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="Command failed."}
	
	if ( not user.room.game ) or user.room.game.name~=msg.gnam then --there needs to be a game to play
	
		ret.gret="There is no game available in this room."
		return ret
		
	end
	
local game=user.room.game	

local gtab=data.gametypes[game.basename]

	if gtab and gtab.game_do_msg then
	
		return gtab.game_do_msg(game,msg,user)
	
	end
	
	return ret
end

-----------------------------------------------------------------------------
--
-- a custom wetv msg, handled by custom wetv code
--
-----------------------------------------------------------------------------
function game_wetv_msg(user,msg)

local ret

	ret={cmd="game",gcmd="ret",gid=msg.gid,gret="Command failed."}
	
	if not user.room then return ret end
		
local game=user.room.game

local gtab=data.gametypes["wetv"]

	if gtab and gtab.game_wetv_msg then
	
		return gtab.game_wetv_msg(game,msg,user)
	
	end
	
	return ret
end

-----------------------------------------------------------------------------
--
-- run any room chats through here ( best not to trigger room msgs that may trigger more msgs )
--
-----------------------------------------------------------------------------
function game_room_chat(game,msg,user)

local gtab=data.gametypes[game.basename]

	if gtab and gtab.game_room_chat then
	
		return gtab.game_room_chat(game,msg,user)
	
	end

end

function game_room_brain_update(game,brain)
local gtab=data.gametypes[game.basename]

	if gtab and gtab.brain_update and game.brain_updateready then
		gtab.brain_update(game,brain)
	end
end


-----------------------------------------------------------------------------
--
-- anyone joins
--
-----------------------------------------------------------------------------
function game_room_join(game,user)

local gtab=data.gametypes[game.basename]

	if gtab and gtab.game_room_join then
	
		return gtab.game_room_join(game,user)
	
	end

end

-----------------------------------------------------------------------------
--
-- anyone leaves
--
-----------------------------------------------------------------------------
function game_room_part(game,user)

local gtab=data.gametypes[game.basename]

	if gtab and gtab.game_room_part then
	
		return gtab.game_room_part(game,user)
	
	end

end

-----------------------------------------------------------------------------
--
-- save the created game data for this game
--
-----------------------------------------------------------------------------
function game_save(game)

local gtab=data.gametypes[game.basename]

	if gtab and gtab.game_save then
	
		gtab.game_save(game)
	
	end

end

-----------------------------------------------------------------------------
--
-- setup
--
-----------------------------------------------------------------------------
function game_setup(game)

local gtab=data.gametypes[game.basename]

	if gtab and gtab.setup then
	
		gtab.setup(game)
	
	end

end

-----------------------------------------------------------------------------
--
-- clean
--
-----------------------------------------------------------------------------
function game_clean(game)

local gtab=data.gametypes[game.basename]

	if gtab and gtab.clean then
	
		gtab.clean(game)
	
	end

end

-----------------------------------------------------------------------------
--
-- tell user they need to signup before we can award the cookies
--
-----------------------------------------------------------------------------
function game_signal_request_signup(user,award)

	usercast(user,{cmd="lnk",frm="cthulhu",
	txt="Sorry but I can not give you any cookies. If you were a registered user with a confirmed email (a VIP) then you would have just been rewarded with "..award.." cookies. Click here to register.",
	lnk="http://www.wetgenes.com/forum/index.php?t=register"})
	
end


-----------------------------------------------------------------------------
--
-- record who is playing what
--
-----------------------------------------------------------------------------
function record_arena_activity(game,user)

if not data.arena_activity then data.arena_activity={} end

local t=data.arena_activity

if not t[game] then t[game]={} end



local tg=t[game]

	table.insert(tg,user)

end


-----------------------------------------------------------------------------
--
-- a pet has earned cookies, give award to owner
--
-----------------------------------------------------------------------------
function game_award_pet_owner(user,award)

	if (not user) or (not user.fud) or (not user.fud.referer_id) then return end  -- we must be a registered user to have an owner

local owner_id=tonumber(user.fud.referer_id)

	if owner_id==0 or user.fud.referer_id==user.fud.id then return end -- no owner, or owned by self

local num=data.saved_pet_cookies[owner_id] or 0

	num=num+(award/10)

	data.saved_pet_cookies[owner_id]=num
	
--dbg("pet "..owner_id.." = "..num.."\n")
	
end

-----------------------------------------------------------------------------
--
-- our games are sending in a score / signal , maybe we will convert that into some cookies...
--
-- award limited by ip
--
-----------------------------------------------------------------------------
function game_award_cookies(game,user,award,award_max)

local given=0
	
	if not award or award==0 then return end
	
	if not user_confirmed(user) then return game_signal_request_signup(user,award) end
	
	given=day_flag_get_num(user.ip,game.name..".part") or 0
	
	if given<award_max and award>0 then
	
		record_arena_activity(game.basename,user.name)
	
		if given+award > award_max then award=award_max-given end -- cap award
		
		day_flag_addcheck(user.ip,game.name..".part",nil,award)
		
		user.cookies= user.cookies + award
		
		game_award_pet_owner(user,award)
		
log(user.name,"award",nil,game.basename,award)

		return {cmd="note",note="act",
		arg1="For playing "..game.basename.." "..user.name.." has been given a daily reward of "..award.." cookies!! "},award
		

	end
	
	return nil

end

-----------------------------------------------------------------------------
--
-- our games are sending in a score / signal , maybe we will convert that into some cookies...
--
-- award limited by user not ip
--
-----------------------------------------------------------------------------
function game_name_award_cookies(game_name,user,award,award_max)

local given=0
	
	if not award or award==0 then return end
	
	if not user_confirmed(user) then return game_signal_request_signup(user,award) end
	

	given=day_flag_get_num(user.name,game_name..".part") or 0
	
	if given<award_max and award>0 then
	
		record_arena_activity(game_name,user.name)
	
		if given+award > award_max then award=award_max-given end -- cap award
		
		day_flag_addcheck(user.name,game_name..".part",nil,award)
		
		user.cookies= user.cookies + award
		
		game_award_pet_owner(user,award)
		
log(user.name,"award",nil,game_name,award)

		return {cmd="note",note="act",
		arg1="For playing "..game_name.." "..user.name.." has been given a daily reward of "..award.." cookies!! "},award
		

	end
	
	return nil

end

-----------------------------------------------------------------------------
--
-- turn a game name into available reward data
--
-----------------------------------------------------------------------------

game_awards=
{

	{
		name="zeegrind",
		max={{0,5500}},
		snam="best",
		game_name="ZeeGrind",
		link="http://ville.wetgenes.com/#.zeegrind",
		shout=true,
	},
	
	{
		name="itsacoop.0",
		max={{0,16000}},
		snam="final",
		game_name="ItsaCoop",
		link="http://itsacoop.wetgenes.com/",
		shout=true,
	},
	
	{
		name="pixlcoop",
		div=1,
		max={{0,32000}},
		snam="final",
		game_name="PixlCoop",
		link="http://pixlcoop.wetgenes.com/",
		shout=true,
	},
	
	{
		name="gojirama",
		div=1,
		max={{0,8000}},
		snam="final",
		game_name="Gojirama",
		link="http://gojirama.wetgenes.com/",
		shout=true,
	},
	
	{
		name="basement.2",
		div=0.5,
		max={{0,8000}},
		snam="Race",
		game_name="WetBasement",
		link="http://basement.wetgenes.com/",
		only="today",
		shout=true,
	},
	
	{
		name="basement.4",
		div=0.25,
		max={{0,16000}},
		snam="Race",
		game_name="HARD WetBasement",
		link="http://basement.wetgenes.com/",
		only="today",
		shout=true,
	},
	
	{
		name="diamonds.puz.3",
		div=0.5,
		max={{0,16000}},
		snam="Puzzle",
		game_name="Diamonds Puzzle",
		link="http://diamonds.wetgenes.com/",
		only="today",
		shout=true,
	},
	
	{
		name="diamonds.end.3",
		div=50,
		max={{0,8000}},
		snam="Endurance",
		game_name="Diamonds Endurance",
		link="http://diamonds.wetgenes.com/",
		shout=true,
	},

	{
		name="bowwow",
		div=0.3,
		max={{0,16000}},
		snam="BowWow",
		game_name="BowWow",
		link="http://bowwow.wetgenes.com/",
		only="today",
		shout=true,
	},

	{
		name="batwsball",
		div=1,
		max={{0,16000}},
		snam="Endurance",
		game_name="BatWsBall",
		link="http://batwsball.wetgenes.com/",
		shout=true,
	},
	
	{
		name="wetdike",
		div=0.5,
		max={{0,16000}},
		snam="Puzzle",
		game_name="WetDike",
		link="http://wetdike.wetgenes.com/",
		only="today",
		shout=true,
	},

	{
		name="wetcell",
		div=0.5,
		max={{0,16000}},
		snam="Puzzle",
		game_name="WetCell",
		link="http://wetcell.wetgenes.com/",
		only="today",
		shout=true,
	},

	{
		name="estension",
		div=10,
		max={{0,32000}},
		snam="EsTension",
		game_name="EsTension",
		link="http://estension.wetgenes.com/",
		shout=true,
	},

	{
		name="mute",
		div=2,
		max={{0,32000}},
		snam="Smash",
		game_name="MUTE",
		link="http://mute.wetgenes.com/",
		shout=true,
	},
	
	{
		name="take1",
		div=1000,
		max={{0,2000}},
		snam="take1",
		game_name="Take1",
		link="http://take1.wetgenes.com/",
		shout=true,
	},
	
	{
		name="manicminer",
		div=1,
		max={{0,16000}},
		snam="score",
		game_name="Manic Miner",
		link="http://games.wetgenes.com/games/Manic_Miner.php",
		shout=true,
	},
	
	{
		name="kickabout",
		div=1,
		max={{0,16000}},
		snam="score",
		game_name="KickAbout",
		link="http://ville.wetgenes.com/#public.kickabout",
		shout=true,
	},
	
	{
		name="rgbtd0",
		div=0.05,
		max={{0,16000}},
		snam="rgbtd0",
		game_name="rgbTD0",
		link="http://rgbtd0.wetgenes.com/",
		only="today",
		shout=true,
	},
	
	{
		name="fruit_mania",
		div=10,
		max={{0,2000}},
		snam="final",
		game_name="Fruit Mania",
		link="http://like.wetgenes.com/-/game/4889/Fruit Mania",
	},
	
	{
		name="pief",
		div=0.1,
		max={{0,1000}},
		snam="final",
		game_name="pief",
		link="http://like.wetgenes.com/-/game/26758/pief",
	},
}

for i,v in ipairs(game_awards) do -- so i don't have to repeat myself above...
	game_awards[v.name]=v
end

-- map default games when game has many modes

game_awards[ "itsacoop" ] = game_awards[ "itsacoop.0" ]
game_awards[ "diamonds" ] = game_awards[ "diamonds.puz.3" ]
game_awards[ "basement" ] = game_awards[ "basement.2" ]
game_awards[ "manic miner" ] = game_awards[ "manicminer" ]
game_awards[ "fruit mania" ] = game_awards[ "fruitmania" ]


-----------------------------------------------------------------------------
--
-- our games are sending in a score / signal , maybe we will convert that into some cookies...
--
-----------------------------------------------------------------------------
function game_signal(user,msg)

	if msg.stype=="feat" then -- game says we owe the user a feat
		return game_signal_feat(user,msg)
	end
	
--dbg(dbg_msg(msg))

local seed=0
local num=0

local award=0
local score=0

local given=0
local award_max=0
local award_div=1

local this_game_award=0

local awards=game_awards[string.lower(msg.sgame)]


--	dbg("AWARD : ",user.name," : ",msg.sgame or ""," : ",msg.stype or ""," : ",msg.snum or "","\n")


	if not awards then
		return
	end -- need datas before we can do anything :)
	
	user.this_game_name=msg.sgame -- remember last game played

local function do_award()

	if not user.this_game_award then user.this_game_award=0 end -- just in case we miss a start game msg

	award_div=awards.div
	award_max=0
	for _,v in ipairs(awards.max) do	-- list is high to low
		if num>=v[1] then				-- so break on first find
			award_max=v[2]
			break
		end

	end

	if num==0 or awards.snam=="final" then -- start of a new game reset award so far
		user.this_game_award=0
	end
	this_game_award=user.this_game_award or 0
	
	given=day_flag_get_num( user.ip , awards.name..".part" ) or 0 -- how much awarded so far
		
	if award_div and (not awards.max[2]) then -- max score is max
	
		award=force_floor((num/award_div)-given)
		if award<0 then award=0 end
	
	elseif award_div then -- can gain partial score in an accumalitive fasion
	
		award=force_floor((num-this_game_award)/award_div)
	
	else -- award max score always, this gets capped later if we have already partialy given this award
		
		award=award_max
		
	end
		
	if award>0 then
				
		if not user_confirmed(user) then return game_signal_request_signup(user,award) end -- we do not award guests
		
		if given<award_max and award>0 then
						
			if given+award > award_max then award=award_max-given end -- cap award to this amount
			
			day_flag_addcheck( user.ip , awards.name..".part" , nil , award ) -- remember what we are giving
			
			if award_div then -- also save to award given for this play session, user can reset this just by starting a new game
			
				user.this_game_award=user.this_game_award+(award*award_div)
				
			end
			
			user.cookies= user.cookies + award -- give the award
			
log(user.name,"award",nil,awards.game_name,award)

			roomcast(user.room,{cmd="note",note="act",
			arg1="For playing "..awards.game_name.." "..user.name.." has been given a daily reward of "..award.." cookies!! "},user)
			
			game_award_pet_owner(user,award)
		end
	
	end
	
end
	

	if msg.snum then
	
		num=force_floor(tonumber(msg.snum) or 0)
	
	end
	
	if msg.sseed then
	
		seed=force_floor(tonumber(msg.sseed) or 0)
	
	end
	
	if awards.only=="today" then -- must have todays seed to get award
	
		if seed ~= force_floor(os.time()/(60*60*24)) then
		
			return
			
		end
	
	end
	
	if msg.stype=="final" then -- a final score
	
		if awards.snam=="final" then -- give here
		
			do_award()
		
		end
	
	elseif msg.stype=="score" then -- an ongoing score

		if awards.snam==msg.snam then -- give here
		
			do_award()
			
			if awards.name=="manicminer" then
				if num>9000 then -- hand out a feat
					feats_award(user,"manicminer_keymaster")
				end
			end
		
		end
		
	end


end

-----------------------------------------------------------------------------
--
-- the game says we deserve a feat, filter them a little so obviously only 
-- these non secure feats can be gained this way
--
-----------------------------------------------------------------------------
function game_signal_feat(user,msg)

--dbg(msg.sgame.."\n")
--dbg(msg.snam.."\n")

	if msg.sgame=="only1" then
	
		local feat=msg.snam or "none"
		
		if string.sub(feat,1,5)=="tool_" then
		
			feat=string.sub(feat,6)
			
		elseif string.sub(feat,1,5)=="join_" then
		
			feat=string.sub(feat,6)
			
		end
		
		feat="only1_"..feat

		local safe={
			"only1_toast",
			"only1_cheese_on_toast",
			"only1_boiled_eggs",
			"only1_eggy_soldiers",
			"only1_french_toast",
			"only1_omelette",
			"only1_cheese_omelette",
			"only1_sashimi",
			"only1_sashimi_fresh",
			"only1_radish_full",
			"only1_top_world",
			"only1_cat_stuck",
			"only1_portrait",
		}
		for i,v in ipairs(safe) do safe[v]=i end
		
		if safe[feat] then -- safe to award
		
--dbg("award "..feat.."\n")
			feats_award(user,feat)
		
		end
		
	end
	
	

end





local gid_names=
{
"diamonds",
"diamonds.endurance",
"adventisland",
"batwsball",
"gojirama",
"wetdike",
"romzom",
"ASUE1",
"estension",
"bowwow",
"basement.hard",
"basement",
"mute",
"diamonds.ws",
"ASUE2",
"take1",
"pixlcoop",
"rgbtd0",
"pief",
"wetcell",
"only1",
}

local gid_active_crowns={1,2,4,5,6,9,10,11,12,13,18,20,21}


-----------------------------------------------------------------------------
--
-- say why this person deserves a crown
--
-----------------------------------------------------------------------------
local function crown_why(nam,txt,num)

	if (not num) or (num==0) then return end -- no more zeros anymore

local user=get_user(nam)

	data.crowns[nam]=( data.crowns[nam] or 0) + num
	
	if data.crowns[nam]==0 then -- crowns just added up to 0, try not to award a +0
		data.crowns[nam]=nil
	end
	
	if num>=0 then txt=txt.."+"..num end
	if num<0 then txt=txt..num end

	if data.crowns_why[nam] then -- explain why
	
		data.crowns_why[nam]=data.crowns_why[nam]..","..txt
		
	else
	
		data.crowns_why[nam]=txt
		
	end

	if user and user.room then -- tell the room they have a crown
		roomcast(user.room,{cmd="note",note="act", arg1=user.name.." has a crown "..txt},user)
	end
	
dbg("crown: "..nam.." "..txt.."\n")
			
-- make sure crowns are capped

end

	
-----------------------------------------------------------------------------
--
-- check if the named individual should have their crowns adjusted
--
-----------------------------------------------------------------------------
function build_crowns_for(name)

local v

	name=string.lower(name)
	
	if not data.crowns then data.crowns={} end
	if not data.crowns_why then data.crowns_why={} end
	
	data.crowns[name]=nil -- clear old crowns
	data.crowns_why[name]=nil -- string explaining why someone has a crown seperated by ,


	for gid,n in pairs(data.crowns_games_score_high or {} ) do

		if n==name then

			crown_why(name,gid_names[gid],1)
			
		end
	end

	if data.thorns_mud and data.thorns_mud[name] then
	
		v=data.thorns_mud[name]
		if v<0 then
			crown_why(name,"mud" , v )
		end
	end
	
	if data.thorns and data.thorns[name] then
	
		v=data.thorns[name]
		if v<0 then
			crown_why(name,"cheats" , v)
		end
	end
	
	if data.hoe and data.hoe.crowns  and data.hoe.crowns.score then
		if data.hoe.crowns.score[name] and data.hoe.crowns.score[name]>0 then
			crown_why(name,"hoe", data.hoe.crowns.score[name] )
		end
	end

	if data.elo and data.elo.crowns and data.elo.crowns[name] then
	
		for n,c in pairs(data.elo.crowns[name]) do
			crown_why(name,"elo_"..n,c)
		end
	end
	
	if data.shadow and data.shadow.crowns and data.shadow.crowns[name] then
	
		v=data.shadow.crowns[name]
		crown_why(name,"shadow",v)
	end
	
	v=day_flag_get(name,"zeegrind.zone")
	if tonumber( v or 0 ) == 11 then -- got to end of zeegrind
	
		crown_why(name,"zeegrind",1)
			
	end
	
-- tag crowns, +1 or +2
	if data.tag_crowns and data.tag_crowns[name] then
		v=data.tag_crowns[name]
		crown_why(name,"tag",v)
	end
	

	if data.crowns_birthdays and data.crowns_birthdays[name] then --check
		crown_why(name,"birthday",10)
	end
	if data.crowns_furry_birthdays and data.crowns_furry_birthdays[name] then --check
		crown_why(name,"furry.birthday",3)
	end
	
-- very extra special awarded crowns

	if data.crowns_special and data.crowns_special[name] then
		for w,n in pairs(data.crowns_special[name]) do
			crown_why(name,w,n)
		end
	end
	
-- cap only at the end because we are nice and 20 + crowns can cancel out -10 crowns

	local mincap=10
	local maxcap=1
	local user=get_user(name)
	if user and user.fud and user.fud.join_date then --need to know your age
		local t=math.floor(os.time()/(60*60*24)) -- days now
		local d=(tonumber(user.fud.join_date or 0) or 0) -- time when regged

		local days=math.floor((d/(60*60*24))) -- convert registration to days
		if days>0 then days=t-days end -- convert to days to age if it looks valid
		local months=math.floor(days/28) -- get age of account in luna months (4 weeks)

		if months<1 then months=1 end -- max crowns starts at 1
		if months>10 then months=10 end -- max crowns reaches 10 after 10 months
		maxcap=months      -- your crown cap increases by+1 for every month old you are to a maximum of 10
		
	end
	
	if data.crowns[name] then
		if data.crowns[name]> maxcap then data.crowns[name]= maxcap end
		if data.crowns[name]<-mincap then data.crowns[name]=-mincap end
	end
	
end

-----------------------------------------------------------------------------
--
-- find and crown winners with level bonuses
--
-- if we catch cheaters, we will install perminant crowns of thorns upon them :)
--
-----------------------------------------------------------------------------
function game_crowns()

local names={} -- build active names here for update at end of function

	data.crowns={} -- clear old crowns
	data.crowns_why={} -- string explaining why someone has a crown seperated by ,
	
	data.crowns_games_score_high={}

	co_wrap_and_wait(function() -- so spewd doesnt think we are dead
	
		local today=force_floor(os.time()/(60*60*24)) -- unix day
		
		for _,gid in ipairs(gid_active_crowns) do -- game ids that get crowns
		
			local ret=lanes_sql("SELECT forum_id FROM wet_beta_scores WHERE forum_id>0 AND game="..gid.." AND seed="..today.." AND audit>=0 ORDER BY score DESC, created DESC LIMIT 1")
			
			if ret[1] then -- got a score

				local dat=sql_named_tab(ret,1)
				
				local uid=tonumber(dat.forum_id)
				
				if uid>0 then
					local name=get_user_name_from_forum_id(uid)
					
					if name then -- give this user a +1 crown
					
						name=string.lower(name)
						
						data.crowns_games_score_high[gid]=name
						
						names[name]=true
						
					end
			
				end
			end
		
		end
		
		game_shadow_update(names) -- shadow
	
		game_elo_update(names) -- elo updates
		
		game_hoe_update(names) -- hoe updates
	end)

	if data.thorns_mud then
	
		for n,v in pairs(data.thorns_mud or {} ) do
		
			names[n]=true
			
		end
	
	end

	if data.thorns then
	
		for n,v in pairs(data.thorns) do
		
			names[n]=true
			
		end
	
	end
	
	for n,v in pairs(data.day_flags) do
	
		if type(n)=="string" then -- ignore ips?
		
			if tonumber( v["zeegrind.zone"] or 0 ) == 11 then -- got to end of zeegrind
			
				names[n]=true
			
			end
		end	
	end

-- tag crowns, +1 or +2
	if data.tag_crowns then
		for n,v in pairs(data.tag_crowns) do
		
			names[n]=true
			
		end
	end

-- birthday crowns?

	if data.crowns_birthdays then
		for n,b in pairs(data.crowns_birthdays) do
			names[n]=true
		end
	end
	if data.crowns_furry_birthdays then
		for n,b in pairs(data.crowns_furry_birthdays) do
			names[n]=true
		end
	end

	if data.crowns_special then
	
		for n,b in pairs(data.crowns_special) do

			names[n]=true
		end
	end
	
	for n,b in pairs(names) do
		build_crowns_for(n)
	end
	
end


-----------------------------------------------------------------------------
--
-- find and anti crown cheaters with level punishment
--
-----------------------------------------------------------------------------
function game_thorns()
dbg("checking thorns\n")
local tlen=os.time()-(60*60*24*10) -- 10 days of thorns?

	data.thorns={} -- clear old thorns
	data.thorns_mud={} -- clear old thorns

	co_wrap_and_wait(function() -- so spewd doesnt think we are dead
		
		for _,gid in ipairs(gid_active_crowns) do -- game ids that get crowns
		
			local ret=lanes_sql("SELECT forum_id FROM wet_beta_scores WHERE forum_id>0 AND forum_id!=2 AND forum_id!=14 AND game="..gid.." AND audit<0 AND created>"..tlen)
			
			if ret then
				for i=1,#ret do -- every fake score costs you -1
				
					if ret[i] then -- got a score

						local dat=sql_named_tab(ret,i)
						
						local uid=tonumber(dat.forum_id)
						
						if uid>0 then
							local name=get_user_name_from_forum_id(uid)
							
							if name then -- give this user a -5 crown
							
								local tab=get_shared_names_by_ip(name) -- more pain
								if not tab then tab={name} end -- make sure we get at least 1 person
								
								for i,v in ipairs(tab) do
									name=string.lower(v)
									
--dbg("giving "..gid.." thorns to "..name.." \n")

									data.thorns[name]=( data.thorns[name] or 0) - 5
									
								end
								
							end
					
						end
					end
				end
			end
		end

-- copy hardmud to mud
	for n,b in pairs(data.hardmud_names) do	
		data.mud_names[n]=10
	end

-- reduce muddyness once a day	
	local cleanmud = day_flag_get("cthulhu","cleanmud")
	
	
	
-- give muds a nice crown
		for n,b in pairs(data.mud_names) do
		
			if type(data.mud_names[n])~="number" then
				data.mud_names[n]=10
			end

-- slowly clean off the muds, 1 level a day

			if not data.hardmud_names[n] then -- hard muds never clean
				if not cleanmud then -- once a day only
					data.mud_names[n]=data.mud_names[n]-1 -- reduce slowly, may change this number to .1
				end
			end

-- after 10 days, you are clean			
			if data.mud_names[n]<1 then
							
				local ipnum=data.ipmap[n]
				local tab=data.ipwho[ipnum]
				
				if tab then
					for n,b in pairs(tab) do
						if is_mud(n) then -- remove linked muds so they stand a chance
							tab[n]=nil
						end
					end
				end
				
				data.mud_names[n]=nil -- and mark them as no longer mudded, this probably works
				
			else

--				data.thorns[string.lower(n)]=-force_floor(data.mud_names[n])
				data.thorns_mud[string.lower(n)]=-force_floor(data.mud_names[n])
				
--dbg("giving mud "..data.mud_names[n].." thorns to "..n.." \n")

			end

		end
		
		
		day_flag_set("cthulhu","cleanmud")
	
	end)


end



-----------------------------------------------------------------------------
--
-- update shadow data, awarding crowns and so on
--
-----------------------------------------------------------------------------
function game_shadow_update(names)

	data.shadow={}
	data.shadow.crowns={}

	local ret=lanes_sql("SELECT * FROM shadow_games WHERE 1 ORDER BY game DESC LIMIT 0,2")
	
	if ret then
		if ret[1] then -- got an active game
--dbg("checking shadow games ret 1\n")
			local t=sql_named_tab(ret,1)
			data.shadow.active=Json.Decode(t.data)
			data.shadow.active.game=tonumber(t.game)
		end
		if ret[2] then -- got an active game
--dbg("checking shadow games ret 2\n")
			local t=sql_named_tab(ret,2)
			data.shadow.result=Json.Decode(t.data)
			data.shadow.result.game=tonumber(t.game)
		end
	end
	
--dbg("checking shadow games \n"..data.shadow.result.state)

	if data.shadow.result and data.shadow.result.state=="finished" then -- got a previous game
	
		local game=data.shadow.result.game -- game number which is start game time in days
		
		local tim=game*24*60*60 -- convert days into secs
		
		local done_elo=elo_check_stamp("shadow",tim)
	
		local ret
		
-- get all people in the game
		
		ret=lanes_sql("SELECT r.*,f.login AS name FROM shadow_results r JOIN fud26_users f ON f.id=r.user WHERE game="..game)
		
dbg("checking shadow crowns "..game.."\n")

		if ret then 

			if not done_elo then
			
--dbg("doing elo check\n")
				for i=1,#ret do -- grab elo for everyone
				
					if ret[i] then
						local dat=sql_named_tab(ret,i)
						
						ret[i].dat=dat
						ret[i].elo=elo_get("shadow",tonumber(dat.user))
						
--dbg("\nelo ",i)
					end
				end
				
				-- build an average elo rating for each side
				
				local elo_human=0
				local elo_humans={}
				
				local elo_occult=0
				local elo_occults={}
				
				for i=1,#ret do -- grab elo for everyone
				
					if ret[i] then
						local dat=ret[i].dat -- already got it
						
						local form=tonumber(dat.form)%2
						
						if form==0 then -- human
							elo_human=elo_human+ret[i].elo.score
							table.insert(elo_humans,tonumber(dat.user))
						else
							elo_occult=elo_occult+ret[i].elo.score
							table.insert(elo_occults,tonumber(dat.user))
						end
--dbg("\nform ",form)
					end
				end
				
				if #elo_humans>0 and #elo_occults>0 then -- sanity

--dbg("elo ws ",elo_occult," ",elo_human)

					elo_human=math.floor(elo_human/#elo_humans)
					elo_occult=math.floor(elo_occult/#elo_occults)
					
--dbg("elo ws ",elo_occult," ",elo_human)
					
					if data.shadow.result.won=="humans" then -- dead or alive, you score the same elo
					
						elo_do_groups("shadow",elo_occults,elo_humans,elo_occult,elo_human,0,tim)
						
					else
					
						elo_do_groups("shadow",elo_occults,elo_humans,elo_occult,elo_human,1,tim)
						
					end
					
					
				end
				
			end
		
			for i=1,#ret do
			
				if ret[i] then

					local dat=sql_named_tab(ret,i)
					local c=0
					local form=tonumber(dat.form)%2
					
					if dat.state=="0" then -- living
					
						if data.shadow.result.won=="humans" then
						
							if form==0 then
								c=2
							end
							
						else -- occult win
						
							if form==1 then
								c=3
							end
							
						end
						
					else
					
						if data.shadow.result.won=="humans" then
						
							if form==0 then
								c=1
							end
							
						else -- occult win
						
							if form==1 then
								c=2
							end
							
						end
						
					end
						
					local name=string.lower(dat.name)
						
--dbg("giving shadow crown+"..c.." to "..name.." \n")

					data.shadow.crowns[name]=c
					names[name]=true
				end
			end				
		end
	end
	
end




-----------------------------------------------------------------------------
--
-- update elo data, awarding crowns and so on
--
-----------------------------------------------------------------------------
function game_elo_update(names)

-- clear old
	data.elo={}
	data.elo.crowns={}

local games={"shadow","diamonds"}

	for _,n in ipairs(games) do
	
		local r=elo_get_ranks(n,5)
		
		for i=1,3 do
		
			if r[i] then
			
				local name=string.lower(r[i].name)
				
				data.elo.crowns[name]=data.elo.crowns[name] or {} -- make sure we have a table
				
				data.elo.crowns[name][n]=4-i	-- 3 crowns for first
				
				names[name]=true
			end
		end
	end
	
end

-----------------------------------------------------------------------------
--
-- update hoe data, awarding crowns and so on
--
-----------------------------------------------------------------------------
function game_hoe_update(names)

local ending="@id.wetgenes.com"
local endlen=string.len(ending)

	data.hoe={}
	data.hoe.crowns={}
	data.hoe.crowns.score={}
	
	local ret=lanes_url("http://hoe.4lfa.com/hoe/api/tops")
	if ret.body then
		
		local dat=Json.Decode(ret.body)
		
		if dat and dat.result=="OK" then
		
			for _,rname in pairs{"active","last"} do -- current active game and last round winers
			
				local hoe_nerf=0.5 -- half crowns by default
				if rname=="last" then hoe_nerf=0.5 end -- only the lastround gives 1/2 crowns

				if dat[rname] and dat[rname].info then -- sanity check
					
					for i=1,#dat[rname].info do local v=dat[rname].info[i]
							
						if v and v.id then -- this is an email
							if string.sub(v.id,-endlen)==ending then -- ends with proper
								local s=string.sub(v.id,1,-(endlen+1))
								local n=force_floor(s)
								if n>1 then
									local name=get_user_name_from_forum_id(n)
									if name then -- finally remember awards
										name=string.lower(name)
										local count=data.hoe.crowns.score[name] or 0
										local crown=math.ceil((v.crown or 0)*hoe_nerf)
										if crown>0 then
											count=count+crown
											data.hoe.crowns.score[name]=count
											names[name]=true
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

end


-----------------------------------------------------------------------------
--
-- user has told us what they are playing
--
-- now tell them if they have an out of date version
--
-- also send them some current minor data patches
--
-----------------------------------------------------------------------------
function game_swf_update(user)

local m={}

	m.swf_version="0" -- minimum version we require
	m.swf_urlbase=cfg.base_data_url
	m.swf_url=cfg.base_data_url.."/swf/WetVille."..m.swf_version..".swf"
	m.swf_dat=cfg.base_data_url.."/swf/WetVille."..m.swf_version..".dat"
	m.cmd="swf_update"

	if user.gamename == "WetVille" or user.gamename == "ZeeGrind" or user.gamename == "WetPokr" then
	
		user.gametype="WetVille"
		
		m.swf_class="ville"
		m.swf_version="0.941" -- minimum version we require
		m.swf_url=cfg.base_data_url.."/swf/WetVille."..m.swf_version..".swf"
		m.swf_dat=cfg.base_data_url.."/swf/WetVille."..m.swf_version..".dat"
		
		m.swf_json=Json.Encode({})
	
		usercast(user,m) -- tell the client to check the version of the swf
	
	elseif user.gamename == "Only1" then
	
		m.swf_class="only1"
		m.swf_version="0" -- minimum version we require
		
		m.swf_json=Json.Encode({vid="FuX5_OWObA0"})
		
		usercast(user,m) -- tell the client to check the version of the swf
		
	end

end



-----------------------------------------------------------------------------
--
-- called once a minute to update games pulse in all active games
--
-----------------------------------------------------------------------------
function game_pulse()


	for i,v in pairs(data.games) do
	
		local gtab=data.gametypes[v.name or ""]

		if gtab and gtab.pulse then
			gtab.pulse(v)
		end	
	end

end

