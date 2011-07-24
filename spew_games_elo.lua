
local starting_score=1500

data.elo_games={
	diamonds=1,
	shadow=2,
	pokr=3,
	batwsbat=4,
}
for i,v in pairs(data.elo_games) do if type(i)=="string" then data.elo_games[v]=i end end


-----------------------------------------------------------------------------
--
-- Build and check environment
--
-----------------------------------------------------------------------------
function build_and_check_elo()

dbg("checking elo data\n")

	spew_mysql_table_create("wet_games_elo",
	{
		--	name		type			NULL	key,	default		extra
		{	"user",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- forum user id
		{	"game",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- id of game	
		{	"score",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- total score
		{	"stamp",	"bigint(20)",	"NO",	"MUL",	nil,		nil					}, -- unix time of last game
		{	"data",		"text",			nil,	nil,	nil,		nil					}, -- json serialised data
	}," UNIQUE `user_game` (  `user` ,  `game` ) "
	)

	spew_mysql_table_create("wet_games_elo_log",
	{
		--	name		type			NULL	key,	default		extra
		{	"id",		"int(11)",		"NO",	"PRI",	nil,		"auto_increment"	}, -- id
		{	"game",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- id of game	
		{	"user1",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- forum user1 id
		{	"user2",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- forum user2 id
		{	"score1",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- total score1
		{	"score2",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- total score2
		{	"result",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- rank adjustment
		{	"stamp",	"bigint(20)",	"NO",	"MUL",	nil,		nil					}, -- unix time of game
	})
	
--	local change=elo_do("diamonds",2,14,1234,1240)
	
end


-----------------------------------------------------------------------------
--
-- get top num players
--
-----------------------------------------------------------------------------
function elo_get_ranks(game,num)

	if type(game)=="string" then game=data.elo_games[game] end
	if not game or game<=0 then  return {} end -- bad game

	local t={}
	
	local r=lanes_sql( "SELECT * FROM wet_games_elo where game="..game.." ORDER BY score DESC LIMIT 0,5" )

	if r then

		for i=1,10 do
		
			if r[i] then
			local d=sql_named_tab(r,i)
			
				t[i]=d
				
				d.name=get_user_name_from_forum_id( tonumber(d.user) ) -- fill in user name
		
			end
		end
	
	end

	return t
end


-----------------------------------------------------------------------------
--
-- get elo information, or create new
--
-- user must be a registered users ID, game can be a name or number id
--
-----------------------------------------------------------------------------
function elo_get(game,user)

local it={}

	if type(game)=="string" then game=data.elo_games[game] end
	
	it.user=user
	it.game=game
	it.score=starting_score -- new users start with this rating
	it.stamp=0
	local ret=lanes_sql( "SELECT * FROM wet_games_elo where game="..game.." AND user="..user )
	
	if ret and ret[1] then -- set to data from database
	
		local d=sql_named_tab(ret,1)
		
		it.user= tonumber(d.user)
		it.game= tonumber(d.game)
		it.score=tonumber(d.score)
		it.stamp= tonumber(d.stamp)
		
	end

	return it
end


-----------------------------------------------------------------------------
--
-- see if we have saved any games for this given time
--
-- shadow uses this to tell if we have awarded rankings yet
--
-----------------------------------------------------------------------------
function elo_check_stamp(game,tim)

	if type(game)=="string" then game=data.elo_games[game] end
	
	local ret=lanes_sql( "SELECT * FROM wet_games_elo_log where game="..game.." AND stamp="..tim.." limit 0,1 " )
	
	if ret and ret[1] then -- set to data from database
	
		return true
	end

	return false
end


-----------------------------------------------------------------------------
--
-- adjust elo information, 
--
-- user must be a registered users ID, game can be a name or number id
--
-- score is a + or - adjustment
--
-----------------------------------------------------------------------------
function elo_set(game,user,score,tim)

	tim=tim or os.time()
	
	if type(game)=="string" then game=data.elo_games[game] end

local change -- + or - score string
	if score<0 then change=tostring(score) else	change="+"..score end	
	
	lanes_sql(
		" INSERT INTO wet_games_elo SET "..
		"   user="..user..
		" , game="..game..
		" , score="..(starting_score+score)..
		" , stamp="..tim..
		" ON DUPLICATE KEY UPDATE "..
		" score=score"..change..
		" ; ")
	
end

-----------------------------------------------------------------------------
--
-- log a game and adjust the score for the given user ids
--
-- take a binary win/lose/draw from the score
--
-----------------------------------------------------------------------------
function elo_do(game,user1,user2,score1,score2,tim)

	local result=0.5
	
	if score1>score2 then result=1 end
	if score2>score1 then result=0 end

	tim=tim or os.time()

	if type(game)=="string" then game=data.elo_games[game] end
	
	if not game then return 0 end -- bad game name, do, nothing
	
	
	local old1=elo_get(game,user1)
	local old2=elo_get(game,user2)
	
	local change=elo_calc_adjust( old1.score , old2.score , result )

	lanes_sql(
		" INSERT INTO wet_games_elo_log SET "..
		"   game="..game..
		" , user1="..user1..
		" , user2="..user2..
		" , score1="..score1..
		" , score2="..score2..
		" , result="..change..
		" , stamp="..tim..
		" ")
	
	elo_set(game,user1, change,tim)
	elo_set(game,user2,-change,tim)
	
	return change	
end

-----------------------------------------------------------------------------
--
-- log a game and adjust the score for the given user ids
--
-- take a binary win/lose/draw from the score
--
-----------------------------------------------------------------------------
function elo_do_groups(game,users1,users2,rank1,rank2,result,tim)

	tim=tim or os.time()

	if type(game)=="string" then game=data.elo_games[game] end
	
	if not game then return 0 end -- bad game name, do, nothing
	
	local change=elo_calc_adjust( rank1 , rank2 , result )
	
	
	for i,v in ipairs(users1) do
	
		elo_set(game,v, change,tim)
	
	end
	
	
	for i,v in ipairs(users2) do
	
		elo_set(game,v, -change,tim)
	
	end
	
	lanes_sql(
		" INSERT INTO wet_games_elo_log SET "..
		"   game="..game..
		" , user1="..(0)..
		" , user2="..(0)..
		" , score1="..rank1..
		" , score2="..rank2..
		" , result="..change..
		" , stamp="..tim..
		" ")
	
	return change	
end

-----------------------------------------------------------------------------
--
-- given two ratings p1 and p2 and a result of 0=(r1 lost) 0.5=(draw) 1=(r1 won)
--
-- return the number of points that should be added to player 1 and subtracted from player 2
--
-- if a player is 200 points ahead of another player you should have a 100% chance of winning
-- and the maximum change of points is 20 (200/10) also dont bother with a bell curve :)
--
-- generally if two people rated the same play, the winner should get +10
-- and you really shouldnt play anyone who is 200 points higher or lower than you
--
-----------------------------------------------------------------------------
function elo_calc_adjust(p1,p2,result)

local chance=(p1-(p2-400))/800 -- expected chance of player 1 winning

	if chance<0 then chance=0 end
	if chance>1 then chance=1 end

local diff=result-chance -- the diference between the expected outcome and the actual outcome

local ret=diff*20

-- do rounding to make this number as big a diference as possible, so 0 is a very unlikly result
	if ret>0 then ret=math.ceil(ret) end
	if ret<0 then ret=math.floor(ret) end

	return ret
end


--[[

local t1=1000
local t2=1000

for i=1,50 do

local d=elo_calc_adjust(t1,t2,1)

	t1=t1+d
	t2=t2-d

dbg("ELO "..t1.." : "..t2.."\n")

end

for i=1,50 do

local d=elo_calc_adjust(t1,t2,0.5)

	t1=t1+d
	t2=t2-d

dbg("ELO "..t1.." : "..t2.."\n")

end

]]

