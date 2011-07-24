


-----------------------------------------------------------------------------
--
-- return a new player , players are assoicated with a game
--
-----------------------------------------------------------------------------
function new_player(game,user,opt)

local player={}
	
	game.player_count=game.player_count+1
	
	game.player_id=game.player_id+1
	
	if user.player then del_player(user) end -- remove old player associated with this user
	user.player=player
	
	player.id=game.player_id
	
	player.game=game
	player.user=user
	player.status = opt.status or "idle"
	player.type   = opt.type or "voyeur"

	game.players[ player.id ]=player
	
	if user.room and user.room.game then -- tell the world that we have joined
	
		game_set_msg(user, { cmd="game",gcmd="set",gid=0, gnam=user.room.game.name , gvar="status" , gset="idle" } )
	end
	
	
	
	return player

end


-----------------------------------------------------------------------------
--
-- delete an old player
--
-----------------------------------------------------------------------------
function del_player(user)

	if not user.player then return end
	if not user.player.game then return end
	
	
	if user.room and user.room.game then -- tell the world that we have left
	
		game_set_msg(user, { cmd="game",gcmd="set",gid=0, gnam=user.room.game.name , gvar="status" , gset="gone" } )
	end
	
local player=user and user.player
local game=player and player.game
	
	if not player or not game then return end
	
	game.player_count=game.player_count-1

	if not game.flag_keep_voyeurs then -- delete voyeurs if flag is not set
	
		game.voyeurs[ user.name ]=nil
	
	end
	
	
	game.players[ player.id ]=nil
	
	user.player=nil
	
	if game.ups[user] then -- this player was an active player
	
		ups_str_to_tab( game )
		
		game_pbem_check(game)
		
	end
	
end

