
local feats=
{
	{
		id=1,
		name="pokr_high_cards",
		title="high fiver",
		desc="Show down in WetPokr with High Cards as your hand.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/highcards.png",
		cookies=1000,
		active=true,
	},
	{
		id=2,
		name="pokr_pair",
		title="double dealer",
		desc="Show down in WetPokr with Pair as your hand.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/onepair.png",
		cookies=1000,
		active=true,
	},
	{
		id=3,
		name="pokr_two_pair",
		title="four eyed dealer",
		desc="Show down in WetPokr with Two Pair as your hand.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/twopair.png",
		cookies=1000,
		active=true,
	},
	{
		id=4,
		name="pokr_three_of_a_kind",
		title="triad dealer",
		desc="Show down in WetPokr with Three of a kind as your hand.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/threeofakind.png",
		cookies=1000,
		active=true,
	},
	{
		id=5,
		name="pokr_straight",
		title="card sorter",
		desc="Show down in WetPokr with Straight as your hand.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/straight.png",
		cookies=1000,
		active=true,
	},
	{
		id=6,
		name="pokr_flush",
		title="snappy dresser",
		desc="Show down in WetPokr with Flush as your hand.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/flush.png",
		cookies=1000,
		active=true,
	},
	{
		id=7,
		name="pokr_full_house",
		title="bob saget",
		desc="Show down in WetPokr with Full House as your hand.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/fullhouse.png",
		cookies=2000,
		active=true,
	},
	{
		id=8,
		name="pokr_four_of_a_kind",
		title="card collector",
		desc="Show down in WetPokr with Four of a kind as your hand.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/fourofakind.png",
		cookies=4000,
		active=true,
	},
	{
		id=9,
		name="pokr_straight_flush",
		title="lucky bastard",
		desc="Show down in WetPokr with Straight Flush as your hand.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/royalflush.png",
		cookies=20000,
		active=true,
	},
	{
		id=10,
		name="pokr_split",
		title="copy cat",
		desc="Get exactly the same hand as one or more other players in WetPokr and split the pot.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/tie.png",
		cookies=1000,
		active=true,
	},
	{
		id=11,
		name="pokr_all_in",
		title="risk taker",
		desc="Go all in in WetPoker, risking everything.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/all_in.png",
		cookies=1000,
		active=true,
	},
	{
		id=12,
		name="pokr_wipe_out",
		title="ass wiper",
		desc="Wipe out another player, taking away all their cookies at the show down.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/wipe_out.png",
		cookies=1000,
		active=true,
	},
	{
		id=13,
		name="spew_megabank",
		title="cookiemon",
		desc="Bank over 1 million cookies with the bots.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/cookiemon.png",
		cookies=100000,
		active=true,
	},
	{
		id=14,
		name="zeegrind_complete",
		title="softcore bonker",
		desc="Complete all levels.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/softcore_bonker.png",
		cookies=4000,
		active=true,
	},
	{
		id=15,
		name="zeegrind_complete_nodie",
		title="hardcore bonker",
		desc="Complete all levels without dying.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/hardcore_bonker.png",
		cookies=8000,
		active=true,
	},
	{
		id=16,
		name="zeegrind_complete_nobonk",
		title="xxsXe bonkerxx",
		desc="Complete all levels without bonking.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/straightedge_bonker.png",
		cookies=10000,
		active=true,
	},
	{
		id=17,
		name="zeegrind_bonk_50_zombies",
		title="power bonker",
		desc="Bonk 50 zombies.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/power_bonker.png",
		cookies=1000,
		active=true,
	},
	{
		id=18,
		name="zeegrind_bonk_100_zombies",
		title="extreme bonker",
		desc="Bonk 100 zombies.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/extreme_bonker.png",
		cookies=2000,
		active=true,
	},
	{
		id=19,
		name="zeegrind_bonk_50_mini_zombies",
		title="midget hater",
		desc="Bonk 50 mini zombies.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/midget_hater.png",
		cookies=2000,
		active=true,
	},
	{
		id=20,
		name="zeegrind_cross_level_nobonk_lt5",
		title="moses lover",
		desc="Cross a level (before Level 5) without bonking.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/moses_lover.png",
		cookies=1000,
		active=true,
	},
	{
		id=21,
		name="zeegrind_cross_level_nobonk",
		title="super moses lover",
		desc="Cross a level (Level 5 and above) without bonking.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/super_moses_lover.png",
		cookies=2000,
		active=true,
	},
	{
		id=22,
		name="zeegrind_carry_friend_lt5",
		title="piggyback bonker",
		desc="Carry a friend to the Safezone(before Level 5).",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/piggyback_bonker.png",
		cookies=1000,
	},
	{
		id=23,
		name="zeegrind_carry_friend",
		title="super piggyback bonker",
		desc="Carry a friend to the Safezone(Level 5 and above).",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/super_piggyback_bonker.png",
		cookies=2000,
	},
	{
		id=24,
		name="zeegrind_chatting",
		title="bonking whiner",
		desc="Chatting in Dangerzone whilst being carried.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/bonking_whiner.png",
		cookies=2000,
	},
	{
		id=25,
		name="zeegrind_chatting_noheld",
		title="emo bonker",
		desc="Chatting in Dangerzone.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/emo_bonker.png",
		cookies=1000,
	},
	{
		id=26,
		name="zeegrind_safezone_bonk_5_zombies",
		title="dont come a knockin",
		desc="Sneaking out from the Safezone to bonk 5 zombies.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/dontcomeaknockin.png",
		cookies=1000,
		active=true,
	},
	{
		id=27,
		name="zeegrind_carried_to_safezone",
		title="royal bonker",
		desc="Carried to the Safezone.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/royal_bonker.png",
		cookies=1000,
	},
	{
		id=28,
		name="zeegrind_bring_own_balloon",
		title="byob bonker",
		desc="Bring your own balloon to bonk zombies.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/byob_bonker.png",
		cookies=4000,
		active=true,
	},
	{
		id=29,
		name="zeegrind_die_nobonk_lt5",
		title="n00b bonker",
		desc="Die without bonking (before Level 5).",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/noob_bonker.png",
		cookies=1000,
		active=true,
	},
	{
		id=30,
		name="zeegrind_die_nobonk",
		title="super n00b bonker",
		desc="Die without bonking (Level 5 and above).",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/super_noob_bonker.png",
		cookies=2000,
		active=true,
	},
	{
		id=31,
		name="zeegrind_sacrifice_lt4",
		title="zombie feeder",
		desc="Sacrifice a friend armed with any level balloon below +4.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/zombie_feeder.png",
		cookies=1000,
	},
	{
		id=32,
		name="zeegrind_sacrifice",
		title="super zombie feeder",
		desc="Sacrifice a friend armed with a balloon level +4.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/super_zombie_feeder.png",
		cookies=2000,
	},
	{
		id=33,
		name="zeegrind_sacrificed_lt4",
		title="zombie food",
		desc="Be sacrificed when armed with any level balloon below +4.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/zombie_food.png",
		cookies=1000,
	},
	{
		id=34,
		name="zeegrind_sacrificed",
		title="super zombie food",
		desc="Be sacrificed when armed with a balloon level +4.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/super_zombie_food.png",
		cookies=2000,
	},
	{
		id=35,
		name="wetv_23hours",
		title="giant couch potato",
		desc="Watch 23 hours of tv.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/giant_couchpotato.png",
		cookies=16000,
		active=true,
	},
	{
		id=36,
		name="wetv_jester",
		title="jester jeerer",
		desc="SUX the Jester's video.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/jester_jeerer.png",
		cookies=4000,
	},
	{
		id=37,
		name="wetv_yay100",
		title="extreme video extender",
		desc="YAY 100 videos.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/extreme_video_extender.png",
		cookies=2000,
		active=true,
	},
	{
		id=38,
		name="wetv_sux100",
		title="extreme video surfer",
		desc="SUX 100 videos.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/extreme_video_surfer.png",
		cookies=2000,
		active=true,
	},
	{
		id=39,
		name="wetv_yay1",
		title="video extender",
		desc="YAY 1 video.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/video_extender.png",
		cookies=1000,
		active=true,
	},
	{
		id=40,
		name="wetv_sux1",
		title="video surfer",
		desc="SUX 1 video.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/video_surfer.png",
		cookies=1000,
		active=true,
	},
	{
		id=41,
		name="wetv_post100",
		title="extreme video spammer",
		desc="Post 100 videos.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/extreme_video_spammer.png",
		cookies=4000,
		active=true,
	},
	{
		id=42,
		name="wetv_ban1",
		title="video nastee",
		desc="BAN 1 video.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/video_nastee.png",
		cookies=2000,
	},
	{
		id=43,
		name="wetv_post1",
		title="video spammer",
		desc="Post 1 video.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/video_spammer.png",
		cookies=1000,
		active=true,
	},
	{
		id=44,
		name="wetv_post1_lt1",
		title="super video spammer",
		desc="Post 1 video (Stays on screen less than 1 min).",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/super_video_spammer.png",
		cookies=1000,
	},
	{
		id=45,
		name="wetv_13hours",
		title="couch potato",
		desc="Watch 13 hours of tv.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/couchpotato.png",
		cookies=8000,
		active=true,
	},
	{
		id=46,
		name="wetv_yay_reg",
		title="reg lover",
		desc="YAY a REG video.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/reglover.png",
		cookies=2000,
	},
	{
		id=47,
		name="wetv_post_timed",
		title="video hacker",
		desc="Post a timed video.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/video_hacker.png",
		cookies=1000,
	},
	{
		id=48,
		name="wetv_10win",
		title="super video star",
		desc="Post 10 vieo wins.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/super_video_star.png",
		cookies=2000,
		active=true,
	},
	{
		id=49,
		name="wetv_10fail",
		title="super video nerd",
		desc="Post 10 video fails.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/super_video_nerd.png",
		cookies=2000,
		active=true,
	},
	{
		id=50,
		name="wetv_1win",
		title="video star",
		desc="Post a video win.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/video_star.png",
		cookies=1000,
		active=true,
	},
	{
		id=51,
		name="wetv_1fail",
		title="video nerd",
		desc="Post a video fail.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/video_nerd.png",
		cookies=1000,
		active=true,
	},
	{
		id=52,
		name="wetv_100win",
		title="extreme video star",
		desc="Post 100 video wins.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/extreme_video_star.png",
		cookies=4000,
		active=true,
	},
	{
		id=53,
		name="wetv_100fail",
		title="extreme video nerd",
		desc="Post 100 video fails.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/extreme_video_nerd.png",
		cookies=4000,
		active=true,
	},
	{
		id=54,
		name="wetv_1minute",
		title="video noob",
		desc="Watch one minute of tv.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/video_noob.png",
		cookies=500,
		active=true,
	},
	{
		id=55,
		name="wetv_4hours",
		title="couch new potato",
		desc="Watch 4 hours of tv.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/couchnewpotato.png",
		cookies=4000,
		active=true,
	},
	{
		id=56,
		name="wetv_1hour",
		title="couch sprout",
		desc="Watch one hour of tv.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/couchsprout.png",
		cookies=2000,
		active=true,
	},
	{
		id=57,
		name="spew_megabank2",
		title="cookiemon deux",
		desc="Bank over 2 million cookies with the bots.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/cookiemon_2.png",
		cookies=100000,
		active=true,
	},
	{
		id=58,
		name="spew_megabank4",
		title="cookiemon quadrophenia",
		desc="Bank over 4 million cookies with the bots.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/cookiemon_4.png",
		cookies=100000,
		active=true,
	},
	{
		id=59,
		name="spew_megabank8",
		title="cookiemon octopussy",
		desc="Bank over 8 million cookies with the bots.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/cookiemon_8.png",
		cookies=100000,
		active=true,
	},
	{
		id=60,
		name="spew_megabank16",
		title="cookiemon hexed",
		desc="Bank over 16 million cookies with the bots.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/cookiemon_16.png",
		cookies=100000,
		active=true,
	},
	
	{
		id=101,
		name="only1_toast",
		title="vegetarian student",
		desc="Cook some toast in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_toast.png",
		cookies=1000,
		active=true,
	},
	{
		id=102,
		name="only1_cheese_on_toast",
		title="cheesy vegan",
		desc="Cook some cheese on toast in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_cheese_on_toast.png",
		cookies=1000,
		active=true,
	},
	{
		id=103,
		name="only1_boiled_eggs",
		title="hard and infertile",
		desc="Boil some eggs in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_boiled_eggs.png",
		cookies=1000,
		active=true,
	},
	{
		id=104,
		name="only1_eggy_soldiers",
		title="adult baby",
		desc="Make eggy soldiers in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_eggy_soldiers.png",
		cookies=1000,
		active=true,
	},
	{
		id=105,
		name="only1_french_toast",
		title="jean luc baguette",
		desc="Create some french toast in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_french_toast.png",
		cookies=1000,
		active=true,
	},
	{
		id=106,
		name="only1_omelette",
		title="omnomnomnomnom",
		desc="Make an omelette in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_omelette.png",
		cookies=1000,
		active=true,
	},
	{
		id=107,
		name="only1_cheese_omelette",
		title="du fromage",
		desc="Create a cheese omelette in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_cheese_omelette.png",
		cookies=1000,
		active=true,
	},
	{
		id=108,
		name="only1_sashimi",
		title="dead fish",
		desc="Scrump sashimi in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_sashimi.png",
		cookies=1000,
		active=true,
	},
	{
		id=109,
		name="only1_sashimi_fresh",
		title="undead fish",
		desc="Scrump fresh sashimi in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_super_sashimi.png",
		cookies=1000,
		active=true,
	},
	{
		id=110,
		name="only1_radish_full",
		title="fruitarian magnifique",
		desc="Scrump a full on super radish in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_super_radish.png",
		cookies=1000,
		active=true,
	},
	{
		id=111,
		name="only1_top_world",
		title="white hot",
		desc="Reach the top of the world in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats//only1_top_of_the_world.png",
		cookies=1000,
		active=true,
	},
	{
		id=112,
		name="only1_cat_stuck",
		title="fat pussy",
		desc="Get stuck with a fat cat in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_stuck_cat.png",
		cookies=1000,
		active=true,
	},
	{
		id=113,
		name="only1_portrait",
		title="poseur",
		desc="Have your portrait taken in only1.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/only1_portrait.png",
		cookies=1000,
		active=true,
	},

	{
		id=120,
		name="manicminer_keymaster",
		title="keymaster",
		desc="Score over 9000 in manic miner.",
		data="&",
		imgurl=cfg.base_data_url.."/wetlinks/feats/manic_keymaster.png",
		cookies=9000,
		active=true,
	},
}
	
		
local feats_hash={}
for i,v in ipairs(feats) do
	feats_hash[v.id]=v
	feats_hash[v.name]=v
end

local feats_games={}
for i,v in ipairs(feats) do
	local aa=str_split("_",v.name)
	local t=feats_games[ aa[1] ] or {}

	table.insert(t,v)
	feats_games[ aa[1] ]=t
end

-----------------------------------------------------------------------------
--
-- return given feats for a user
--
-----------------------------------------------------------------------------
function feats_given(user,gamename)
	local t=feats_games[string.lower(gamename)] or feats
	local count=0
	local total=0
	for i,v in ipairs(t) do
		if v.active then
			if user.feats[v.id] then
				count = count + 1
			end
			total = total + 1
		end
	end
	return count,total
end

-----------------------------------------------------------------------------
--
-- setup feats data
--
-- building and filling the mysql table
--
-----------------------------------------------------------------------------
function feats_data_setup()

--	data.items = data.items or {}
	

	-- available feats
	spew_mysql_table_create("spew_feats_data",
	{
		--	name		type			NULL	nil,	default		extra
		{	"id",		"int(11)",		"NO",	"PRI",	nil,		nil					}, -- feat number ID
		{	"name",		"varchar(255)",	"NO",	"MUL",	nil,		nil					}, -- short name
		{	"title",	"varchar(255)",	"NO",	"MUL",	nil,		nil					}, -- user title associated with this feat
		{	"imgurl",	"varchar(255)",	"NO",	nil,	nil,		nil					}, -- img url
		{	"txt",		"text",			"NO",	nil,	nil,		nil					}, -- description of this feat
		{	"dat",		"text",			"NO",	nil,	nil,		nil					}, -- extra data
		
	})
	
	-- awarded feats
	spew_mysql_table_create("spew_feats",
	{
		--	name		type			NULL	nil,	default		extra
		{	"id",		"bigint(20)",	"NO",	"PRI",	nil,		"auto_increment"	}, -- unique object ID
		{	"time",		"bigint(20)",	"NO",	"MUL",	nil,		nil					}, -- time this feat was awarded
		{	"type",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- the feat id (spew_feats_data id)
		{	"owner",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- forum user id
		{	"flags",	"int(11)",		"NO",	"MUL",	0,			nil					}, -- bitflags (1==posted to facebook)
		
	})
	

	for i,v in ipairs(feats) do
		local idx=1
		local row={}
			
		row.names={}
		row[1]={}
	
		row.names[idx]="id"
		row[1][idx]=v.id
		idx=idx+1
		
		row.names[idx]="name"
		row[1][idx]=mysql_escape(v.name)
		idx=idx+1
		
		row.names[idx]="title"
		row[1][idx]=mysql_escape(v.title)
		idx=idx+1

		row.names[idx]="imgurl"
		row[1][idx]=mysql_escape(v.imgurl)
		idx=idx+1

		row.names[idx]="txt"
		row[1][idx]=mysql_escape(v.desc)
		idx=idx+1
		
		if v.data then
			row.names[idx]="dat"
			row[1][idx]=mysql_escape(v.data)
			idx=idx+1
		end
		
		local q=spew_mysql_make_set("spew_feats_data",row)
--dbg(q,"\n")		
		lanes_sql_noblock(q)

	end
	
end

-----------------------------------------------------------------------------
--
-- info about a feat given its name or number
--
-----------------------------------------------------------------------------
function feats_info(id)

	return feats_hash[id]
end


-----------------------------------------------------------------------------
--
-- to tell the client that their rank score has gone up or down by this amount
--
-----------------------------------------------------------------------------
function feats_rank(user,name,amount)

	if not user or not user.client then return end -- must be real user
	
	usercast(user,{cmd="note",note="rank",arg1=name,arg2=amount}) -- tell the client (even guests) that their rank score has changed, they send it to other interested parties
	
end

-----------------------------------------------------------------------------
--
-- award a feat
--
-----------------------------------------------------------------------------
function feats_award(user,name)

	if not user or not user.client then return end -- must be real user
	
	if is_mudip(user.name) then return end -- no feats for the muds
	
local feat=feats_hash[name]

	if not feat then return end -- must be real feat
	
	if day_flag_get(user.name,"feats."..name) then return end -- already signaled to this client today, so do not do it again (less spammy)
	day_flag_set(user.name,"feats."..name)
	
	local count=0
	if user.feats and user.feats[feat.id] then
		count=1 -- already awarded server side
	end
	
	usercast(user,{cmd="note",note="feat",arg1=name,arg2=count}) -- tell the client (even guests) that they got a new feat, they send it to other interested parties
	
	if count>0 then return end -- already awarded it
	
	if not user_confirmed(user) then return end -- must be real user
	
	user.feats=user.feats or {} -- live server fix
	
	user.feats[feat.id]=true
	
	user.cookies=user.cookies+feat.cookies
	
	local idx=1
	local row={}
		
	row.names={}
	row[1]={}

	row.names[idx]="time"
	row[1][idx]=os.time()
	idx=idx+1
	
	row.names[idx]="type"
	row[1][idx]=feat.id
	idx=idx+1
	
	row.names[idx]="owner"
	row[1][idx]=tonumber(user.fud.id)
	idx=idx+1
	
	local q=spew_mysql_make_set("spew_feats",row)
--dbg(q,"\n")
	lanes_sql_noblock(q)

	roomcast(user.room,{cmd="note",note="act",
	arg1=user.name.." has performed the feat of "..string.upper(feat.title).." and been given a reward of "..feat.cookies.." cookies!! "})
	
	user.title=feat.title
	user.titleid=feat.id

	game_award_pet_owner(user,feat.cookies) -- also hand out some cookies to the owner of this pet...
	
	tlog(user.name, user.name.." achieved the feat of "..feat.title) -- log it to stream
	
	return feat -- we got a reward, return details for possible further use
end


-----------------------------------------------------------------------------
--
-- signal something the feats may want to keep track of and award based on
--
-- since this is virtual world, we have a vuser handy rather than a user so thats what is passed in
--
-- name is the name of the signal and dat contains extra info about the user thet we may be interested in
-- what data you get depends on the signal type, keep track of any counters in the users dayflags.
--
-----------------------------------------------------------------------------
function feats_signal_zeegrind(vuser,signal,dat)

local user=get_user(vuser.owner) -- convert vuser to user
	
	if not user or not user.client then return end -- must be real user
	

	if signal=="bonk" then -- a zombie has been bonked
	
--dbg(user.name," : ",signal," : ",dat.zom.zom.name,"\n")

		local bonks=day_flag_get(user.name,"zeegrind.bonks") or 0
		bonks=bonks + 1
		day_flag_set(user.name,"zeegrind.bonks",bonks)
		
		local minibonks=day_flag_get(user.name,"zeegrind.minibonks") or 0
		if string.sub(dat.zom.zom.name,1,4)=="mini" then -- midget hater
			minibonks=minibonks + 1
			day_flag_set(user.name,"zeegrind.minibonks",minibonks)
		end
		
		if bonks >= 50 then
			feats_award(user,"zeegrind_bonk_50_zombies")
		end
		if bonks >= 100 then
			feats_award(user,"zeegrind_bonk_100_zombies")
		end
		if minibonks >= 50 then
			feats_award(user,"zeegrind_bonk_50_mini_zombies")
		end
	
--dbg("bonk count = ",bonks,"\n")
--dbg("minibonk count = ",minibonks,"\n")

	elseif signal=="dead" then -- this user has died
	
--dbg(user.name," : ",signal," : ",dat.zom.zom.name,"\n")

		local deaths=day_flag_get(user.name,"zeegrind.deaths") or 0
		deaths=deaths + 1
		day_flag_set(user.name,"zeegrind.deaths",deaths)
		
	elseif signal=="zone" then -- this user has moved to another zone
	
--dbg(user.name," : ",signal," : ",dat.zone,".",dat.level,"\n")

		local deaths=day_flag_get(user.name,"zeegrind.deaths") or 0
		local bonks=day_flag_get(user.name,"zeegrind.bonks") or 0

--dbg("bonk count = ",bonks,"\n")
--dbg("death count = ",deaths,"\n")
		
		if dat.level >= 11 then
		
			local startings=day_flag_get(user.name,"zeegrind.startings")
			if startings then
				if startings.bonks == bonks then -- no bonk
					feats_award(user,"zeegrind_complete_nobonk")
				end
				if startings.deaths == deaths then -- no deaths
					feats_award(user,"zeegrind_complete_nodie")
				end
			end
			
			feats_award(user,"zeegrind_complete")
			
		end
		
		if dat.zone == "entrance" then
			day_flag_set(user.name,"zeegrind.crossings",{bonks=bonks, deaths=deaths, level=dat.level})
			
			if dat.level<=1 then
				day_flag_set(user.name,"zeegrind.startings",{bonks=bonks, deaths=deaths, level=dat.level})
			end
			
		elseif dat.zone == "exit" then
			local crossings=day_flag_get(user.name,"zeegrind.crossings")
			if crossings then
				if dat.level == crossings.level + 1 then
					if crossings.bonks == bonks then
						if dat.level < 5 then
							feats_award(user,"zeegrind_cross_level_nobonk_lt5")
						else
							feats_award(user,"zeegrind_cross_level_nobonk")
						end
					end
				end
			end
		end
		
		if dat.zone == "entrance" or dat.zone == "exit" then
			local sneaking=day_flag_get(user.name,"zeegrind.sneakings")
			if sneaking then
				if dat.level == sneaking.level and dat.zone == sneaking.zone then
					if sneaking.bonks + 5 <= bonks and deaths == sneaking.deaths then
						feats_award(user,"zeegrind_safezone_bonk_5_zombies")
					end
					if bonks == sneaking.bonks and deaths == sneaking.deaths + 1 then
						if dat.level < 5 then
							feats_award(user,"zeegrind_die_nobonk_lt5")
						else
							feats_award(user,"zeegrind_die_nobonk")
						end
					end
				end
			end
			day_flag_set(user.name,"zeegrind.sneakings",{bonks=bonks, deaths=deaths, level=dat.level, zone=dat.zone})
		end

	elseif signal=="byob" then -- brought a balloon in to play with
	
--dbg(user.name," : ",signal,"\n")
		feats_award(user,"zeegrind_bring_own_balloon")
	else
--dbg(user.name," : ",signal,"\n")
	
	end

end

-----------------------------------------------------------------------------
--
-- signal something the feats may want to keep track of and award based on
--
-- name is the name of the signal and dat contains extra info about the user thet we may be interested in
-- what data you get depends on the signal type, keep track of any counters in the users dayflags.
--
-----------------------------------------------------------------------------
function feats_signal_wetv(user,signal,dat)

	if not user or not user.client then return end -- must be real user
	
	if user and user.room and user.room.owners and user.room.owners[1] then return end -- no more private room feats
	
	if signal=="play" then -- got a video played
	
	elseif signal=="watched" then -- we watched all of this video (in room at start and at end)
	
		local t=0
		local vi=dat.vi
		if vi then t= os.time() - vi.vid_start end
	
		local watched=(day_flag_get(user.name,"wetv.watched") or 0)+t
		day_flag_set(user.name,"wetv.watched",watched)

--dbg(user.name," watched=",watched,"\n")

-- hand out awards but dont over spam msgs so also keep simple track serverside in the user
		if     watched > 23*60*60 then feats_award(user,"wetv_23hours") 
		elseif watched > 13*60*60 then feats_award(user,"wetv_13hours") 
		elseif watched >  4*60*60 then feats_award(user,"wetv_4hours")  
		elseif watched >    60*60 then feats_award(user,"wetv_1hour")   
		elseif watched >       60 then feats_award(user,"wetv_1minute") 
		end
	
	elseif signal=="win" then -- our video ended and we won
	
		local wins=(day_flag_get(user.name,"wetv.wins") or 0)+1
		day_flag_set(user.name,"wetv.wins",wins)
	
--dbg(user.name," wins=",wins,"\n")

-- hand out awards but dont over spam msgs so also keep simple track serverside in the user
		if     wins >= 100 then feats_award(user,"wetv_100win")
		elseif wins >=  10 then feats_award(user,"wetv_10win") 
		elseif wins >=   1 then feats_award(user,"wetv_1win")  
		end
		
		local plays=(day_flag_get(user.name,"wetv.plays") or 0)+1
		day_flag_set(user.name,"wetv.plays",plays)
		
--dbg(user.name," plays=",plays,"\n")

		if     plays >= 100 then feats_award(user,"wetv_post100")
		elseif plays >=   1 then feats_award(user,"wetv_post1")  
		end
		
	elseif signal=="fail" then -- our video ended and we failed
	
		local fails=(day_flag_get(user.name,"wetv.fails") or 0)+1
		day_flag_set(user.name,"wetv.fails",fails)
	
--dbg(user.name," fails=",fails,"\n")

-- hand out awards but dont over spam msgs so also keep simple track serverside in the user
		if     fails >= 100 then feats_award(user,"wetv_100fail")
		elseif fails >=  10 then feats_award(user,"wetv_10fail") 
		elseif fails >=   1 then feats_award(user,"wetv_1fail")  
		end
		
		local plays=(day_flag_get(user.name,"wetv.plays") or 0)+1
		day_flag_set(user.name,"wetv.plays",plays)
		
--dbg(user.name," plays=",plays,"\n")

		if     plays >= 100 then feats_award(user,"wetv_post100")
		elseif plays >=   1 then feats_award(user,"wetv_post1")  
		end
		
	elseif signal=="yay" then -- yayed a video
	
		local yays=(day_flag_get(user.name,"wetv.yays") or 0)+1
		day_flag_set(user.name,"wetv.yays",yays)
	
--dbg(user.name," yays=",yays,"\n")

-- hand out awards but dont over spam msgs so also keep simple track serverside in the user
		if     yays >= 100 then feats_award(user,"wetv_yay100")
		elseif yays >=   1 then feats_award(user,"wetv_yay1")  
		end
		
	elseif signal=="sux" then -- suxed a video
	
		local suxs=(day_flag_get(user.name,"wetv.suxs") or 0)+1
		day_flag_set(user.name,"wetv.suxs",suxs)
	
--dbg(user.name," suxs=",suxs,"\n")

-- hand out awards but dont over spam msgs so also keep simple track serverside in the user
		if     suxs >= 100 then feats_award(user,"wetv_sux100")
		elseif suxs >=   1 then feats_award(user,"wetv_sux1")  
		end
		
	end

end


