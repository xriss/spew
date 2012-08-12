
local gtab={}
data.gametypes=data.gametypes or {}
data.gametypes["itsacoop"]=gtab


local game_tab_name="wet_game_itsacoop"

-----------------------------------------------------------------------------
--
-- Build and check environment
--
-- called by the main game after a spew: reload to make sure mysql tables etc exist
--
-----------------------------------------------------------------------------
gtab.build_and_check_environment = function()

dbg("checking itsacoop data\n")

local con,cur,ret,tab

	con=sql:connect(cfg.mysql_database,cfg.mysql_username,cfg.mysql_password)
	
	if con then
	
--		ret=con:execute("DROP TABLE IF EXISTS "..game_tab_name)
		
		ret=con:execute(
		[[ CREATE TABLE IF NOT EXISTS ]]..game_tab_name..[[ ( ]]..
		[[ id INT NOT NULL PRIMARY KEY , ]]..	-- an id for this gamedata
		[[ forum_id INT NOT NULL , ]]..			-- the forum id of the owner of this game or 0
		[[ created BIGINT NOT NULL , ]]..		-- timestamp of creation
		[[ word1 CHAR(16) NOT NULL , ]]..		-- word1 being guessed
		[[ word2 CHAR(16) NOT NULL , ]]..		-- word2 being guessed
		[[ victors TEXT , ]]..					-- /name/name/ list of people who guessed the word for this game first name is artist
		[[ data TEXT , ]]..						-- serialized game data of this game
		[[ INDEX(forum_id) , ]]..
		[[ INDEX(created) , ]]..
		[[ INDEX(word1) , ]]..
		[[ INDEX(word2) ]]..
		[[ ) ]]
		)
		
	end
	
	if cur then cur:close() end
	if con then con:close() end

end

-----------------------------------------------------------------------------
-- 
-- setup extra game stuffs
--
-- Probably shouldnt use styles as they get passed to all clients
-- but it will be fine for now
-- I mean there is nothing stopping the artist from just telling people to type the words
-- anyhow should be using the objects system its just that i aint written that yet :)
-- 
-----------------------------------------------------------------------------
gtab.setup = function(game)

-- build a random word if we do not already have them

	local word=data.words.itsa[ math.random(#data.words.itsa) ]

	if not game.styles.word_adjective then
		game.styles.word_adjective = word
	end
	
	if not game.styles.word_noun then
		game.styles.word_noun      = word
	end
	
	if not game.styles.word then
		game.styles.word           = word
	end
	
	game.styles.victors="//"
	game.victors={} -- put the winners in here
	
	game.styles.prize=0
end

-----------------------------------------------------------------------------
-- 
-- clean extra games stuff
-- 
-----------------------------------------------------------------------------
gtab.clean = function(game)


end


-----------------------------------------------------------------------------
-- 
-- update the list of winers, from the winners tab
-- send msgs if the winners string has changed
-- 
-----------------------------------------------------------------------------
local function update_victors(game)

local s=""
local tot=0
local prize=0

	for v,b in pairs(game.victors) do
	
		tot=tot+1
	
		if s~="" then s=s.."/" end
		
		s=s..v
	
	end
	s="/"..s.."/"
	
	if tot>0 then -- work out the prize
	
		prize=math.ceil(1000/(tot+1))
		
	end
	
	if game.styles.prize ~= prize then -- update
	
		game.styles.prize=prize
		roomcast( game.room , {cmd="game",gcmd="style",gid=0,gvar="prize",gset=prize} ) -- broadcast the style change
		
	end
	
	if game.styles.victors ~= s then -- update
	
		game.styles.victors=s
		roomcast( game.room , {cmd="game",gcmd="style",gid=0,gvar="victors",gset=s} ) -- broadcast the style change
		
	end

end
	


-----------------------------------------------------------------------------
-- 
-- handle custom game msgs
-- 
-----------------------------------------------------------------------------
gtab.game_do_msg = function(game,msg,user)	

local ret={cmd="game",gcmd="ret",gid=msg.gid,gret="Command failed."}

	if msg.gdo=="artist_start" then
	
		roomqueue(user.room,{cmd="act",frm=user.name,txt="is beginning to draw."})
		roomqueue(user.room,{cmd="note",note="act",arg1="Watch carefully and try to guess the word."})

-- send to everyone in room
		roomqueue(user.room,{cmd="game",gcmd="do",gid=0,gnam=game.name,gdo="drawing"} )
		
	elseif msg.gdo=="artist_end" then
	
	local award=game_awards["itsacoop.0"]
		if not award then return end -- sanity

		roomqueue(user.room,{cmd="act",frm=user.name,txt="has ended the game."})
		roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." was drawing "..game.styles.word})
		
		
		local tab={}
		local artist_award=true
		
		for v,b in pairs(game.victors) do
		
			local u=get_user(v)
			
			if u then
			
				if u==user or user_ip(u)==user_ip(user) then -- punish artist for using the word in chat
				
					artist_award=false
					
				else -- not artist
					
					table.insert(tab,u.name)
					game_award_cookies(game,u,game.styles.prize,award.max[1][2]) -- award users
					
				end

			end
		
		end
		
		if artist_award then
		
			table.insert(tab,user.name)
			game_award_cookies(game,user,game.styles.prize,award.max[1][2]) -- award artist
		
		end
		
		if game.styles.prize > 0 then
		
			if tab[2] then
			
				roomqueue(user.room,{cmd="note",note="act",
				arg1="For playing "..game.basename.." "..str_join_english_list(tab).." have been given a daily reward of "..game.styles.prize.." cookies!! "})
				
			elseif tab[1] then
			
				roomqueue(user.room,{cmd="note",note="act",
				arg1="For playing "..game.basename.." "..tab[1].." has been given a daily reward of "..game.styles.prize.." cookies!! "})
			
			end
			
		end
		
-- save masterpiece in artists log if we are registered

		local dat

		if user_confirmed(user) then -- must be registered

			local s=""
			
			for ip=1,game.max_up do
			
				if string.lower(game.upsids[ip]) == string.lower(user.name) then -- just get data from the artist
			
					if game.actions[ip] then
					
						for i,v in ipairs(game.actions[ip]) do
								s=s..v[2] -- stick all actions together
						end
						
					end
				end
			end
			
			if string.len(s) > 32 then -- dont bother saving empty or very small scribbles, this is an arbitrary number
			
				dat=game.styles.word.."\t"..s.."\n"
			
			end
		
		end
		
		if dat then -- we have something to write to the end of our file
		
			local fp=io.open("save/itsa/"..string.lower(user.name)..".txt","a")
			
			if fp then -- it could go wrong, just fail silently, such is life
			
				fp:write(dat)
			
				fp:close()
			end
		end
			
		
-- send gameover msg to everyone	
		gamecast( game , {cmd="game",gcmd="done",gid=0,gnam=game.name,atim=0} )

-- reset gameroom
		setup_gameroom(user.room,{ name=msg.gnam , arena={duration=60*15} })

	end


	return ret
end

	
-----------------------------------------------------------------------------
-- 
-- watch what is being said
-- 
-----------------------------------------------------------------------------
gtab.game_room_chat = function(game,msg,user)


-- only pay atention to talking users, check if the text contains the words we are looking for

	if msg.cmd=="say" and user then
	
	local msgtxt=string.lower(msg.txt)
	
	local tab=str_split(" ",game.styles.word)
	
		for i,v in ipairs(tab) do
		
			if string.find(msgtxt,v) then -- found a word
			
				game.victors[ string.lower(user.name) ]=true
						
				update_victors(game)
				
				local artist=get_user(game.upsids[1])
				if artist then -- need to tell the artist too?
				
					if artist==user then
					
						userqueue(artist,{cmd="note",note="act",arg1="PLEASE DO NOT CHEAT..."})
						
					else
					
						userqueue(user,{cmd="note",note="act",arg1="Congratulations the word was "..game.styles.word.." and the prize is now "..game.styles.prize.." cookies."})
						userqueue(artist,{cmd="note",note="act",arg1="Congratulations the word was "..game.styles.word.." and the prize is now "..game.styles.prize.." cookies."})
						
					end
				else
				
					userqueue(user,{cmd="note",note="act",arg1="Congratulations the word was "..game.styles.word.." and the prize is now "..game.styles.prize.." cookies."})
				
				end
				
			end
		
		end
	
	end

end


-----------------------------------------------------------------------------
-- 
-- 
-- 
-----------------------------------------------------------------------------
gtab.game_save = function(game)


end


-----------------------------------------------------------------------------
-- 
-- someone has joined this room
-- 
-----------------------------------------------------------------------------
gtab.game_room_join = function(game,user)

local nam="cthulhu"
		
	if game.room.brain then nam=game.room.brain.user.name end

	if user.gamename~="ItsaCoop" then
		userqueue(user,{cmd="lnk",frm=nam,
		txt="This is a ItsaCoop room. Click here to play ItsaCoop with everyone else.",
		lnk="http://itsacoop.wetgenes.com/"})
		
	end
		
end

