
--
-- handle data checks and initialization
-- functions expect to be called multiple times after code has ben changed
-- so they nose arround and modify any previously setup data
--


-----------------------------------------------------------------------------
--
-- fill in basic data if it does not already exist
--
-----------------------------------------------------------------------------
function spew_setup(flags)

	spew_mysql_table_create("spew_escrow",
	{
		--	name		type			NULL	nil,	default		extra
		{	"id",		"int(11)",		"NO",	"PRI",	nil,		"auto_increment"	}, -- escrow id
		{	"type",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- type of transaction (1=pet for cookies)
		{	"state",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- state of this escrow (1=offer,2=active,3=canceled,4=complete)
		{	"owner",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- current owner of object
		{	"buyer",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- future owner of object
		{	"object",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- the id of the object (forum id of pet)
		{	"amount",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- total price in cookies
		{	"pay",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- amount payed so far, there is no refund
		{	"day",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- the day (unixtime) that offer ends
	})
	
local function dd(nam,dat)
	if not data[nam] then data[nam]=dat end
end

local function dr(dat)

	if not get_room(dat.name) then new_room(dat) end
	
	local room=get_room(dat.name) -- update...
	
	room.welcome=dat.welcome
	room.addnoir=dat.addnoir
	room.locked=dat.locked
	room.novillebot=dat.novillebot
	
	room.imgback=dat.imgback
	
end

	dd("spam",{})
	
	dd("vest",{})
	
	dd("muxouts",{})
	dd("clients",{})
	dd("clients_tab",{})
	dd("status",{ ["*"]={} })
	dd("idstrings",{})
	dd("names",{})
	dd("users",{})
	dd("rooms",{})
	dd("games",{})
	dd("gametypes",{}) -- extra special game brains for different game types
	dd("ville",{}) -- all ville related data sits in here
	dd("brains",{})
	dd("updates",{})
	dd("updates_kill",{})
	
	dd("msg_send_queue",{})
	
	dd("saved_cookies",{}) -- when registered users log out their cookies are saved here
	dd("last_seen",{}) -- name -> timestamp of last activity
	
	data.saved_form={} -- kill wasted memory
--	dd("saved_form",{}) -- when any user logs out their form is saved here

	dd("saved_color",{}) -- remember a users purchased color

	dd("saved_pet_cookies",{}) -- remember accumalative cookies earned by any pets
	dd("saved_pet_cookies_yesterday",{}) -- remember yesterdays rewards, to give the owner a chance to claim them
	
	dd("ipmap",{}) -- match ips to registered users
	dd("ipwho",{}) -- match ips to registered users
	dd("ipsux",{}) -- naughty ips, reduced priv

-- should build an ip data structure, gaining too many tables	
	dd("ipbadlogins",{}) -- because
	dd("last_login_time",{}) -- because
	
	
	
	dd("vidlists",{}) -- global names to table of youtube id lookup
	
	day_flags_reset_check()
		
	data.god_names=
	{
		shi=true,
		xix=true,
		
	}	-- super special, IE us
	data.god_bff=data.god_bff or {}
	
	data.bot_names=
	{
		kolumbo=true, -- wandering bot
		kolumbo_bob=true, -- wandering bot
		
		lieza=true, -- twittering bot
		
		noir=true,
		jeeves=true,
		meatwad=true,
		moon=true,
		ygor=true,
		reg=true,
	} -- special bots
	
	data.admin_names=
	{
	} -- there are no more admins, just gods and bots and user levels
	


	
	
	data.mod_names=
	{
	} -- there are no more mini mods, just gods and bots and user levels
	
-- bubble down the gods to admins
	
	for i,v in pairs(data.god_names) do
		data.admin_names[i]=v
		data.mod_names[i]=v
	end
-- and admins to mods
	for i,v in pairs(data.admin_names) do
		data.mod_names[i]=v
	end
	
-- check for godbot powah
	data.godbot_names=
	{
	}
	for i,v in pairs(data.god_names) do
		data.godbot_names[i]=v
	end
	for i,v in pairs(data.bot_names) do
		data.godbot_names[i]=v
	end	

-- these people are perma gimped, owner=gimp
	data.gimp_names=
	{
--		["sk8t3r_girl12"]="Hatsune_Miku",
		["shi"]="XIX",
	}

-- these people are not allowed in the same room as each other
	data.drama_names={}

--	data.drama_names["xbathingmonkeyx"]=2
	
--[[
	data.drama_names["erik_revolution"]=2
	data.drama_names["erik_reloaded"]=2
	data.drama_names["djrev"]=2
	data.drama_names["crowd"]=2
	data.drama_names["cthuihu"]=2
	data.drama_names["horny_mandy"]=2
	data.drama_names["missclayburn"]=2
	data.drama_names["missclaburn"]=2
	data.drama_names["missclayburn"]=2
	
	
	data.drama_names["lana"]=2
	data.drama_names["erik_revolution"]=2
	
	data.drama_names["playa11"]=3
	
	
	data.drama_names["lana"]=2
	data.drama_names["lena"]=2
	data.drama_names["luna"]=2
	data.drama_names["lona"]=2
	data.drama_names["lina"]=2
	data.drama_names["lyna"]=2
	data.drama_names["sana"]=2
	data.drama_names["neo"]=2
	data.drama_names["twilight"]=2
	data.drama_names["jason_sparks"]=2
	data.drama_names["spartan117"]=2
]]

	
	data.drama_ips=data.drama_ips or {}
--	data.drama_ips={} -- force clear list on next reload

	drama_update() -- clean up ips etc
	
	
-- these people are too dum to be allowed cthulhu privilages
-- I expect this list will grow grow grow
	data.dum_names=data.dum_names or {}
	
	
	data.hardmud_names=data.hardmud_names or {}
	data.mud_names=data.mud_names or {}


	
-- people who annoy us get this flag

--[[
	data.hardmud_names["sephiroth"]=true
	data.hardmud_names["dude"]=true
	data.hardmud_names["emoboy123"]=true
	data.hardmud_names["lynx"]=true
	data.hardmud_names["xlr7"]=true
	data.hardmud_names["potato"]=true
	data.hardmud_names["grim_reaper"]=true
	data.hardmud_names["xxhit_manxx"]=true
	data.hardmud_names["spikyballoons"]=true

	data.hardmud_names["erik_revolution"]=true
	data.hardmud_names["erik_reloaded"]=true
	data.hardmud_names["djrev"]=true
	data.hardmud_names["crowd"]=true
	data.hardmud_names["cthuihu"]=true
	data.hardmud_names["horny_mandy"]=true
	data.hardmud_names["missclaburn"]=true
	data.hardmud_names["missclayburn"]=true
	data.hardmud_names["fox_demon"]=true
	data.hardmud_names["portgaz"]=true
	data.hardmud_names["kikyo15"]=true
]]
	
--	data.hardmud_names["daishi"]=true

-- copy hardmud to mud
	for n,b in pairs(data.hardmud_names) do	
		data.mud_names[n]=10
	end

	data.alt_names=data.alt_names or {}
	

--award special crowns

	data.crowns_special={}
	local function addacrown(crown,name,num)
		data.crowns_special[name]=data.crowns_special[name] or {}
		data.crowns_special[name][crown]=num
	end

-- kill miss wetgenes
--	addacrown("miss_wetgenes","desu_boku",6)
--	addacrown("miss_wetgenes","kohaku",5)
--	addacrown("miss_wetgenes","qata",4)
--	addacrown("miss_wetgenes","traces",3)
--	addacrown("miss_wetgenes","bees",2)
--	addacrown("miss_wetgenes","tosi",2)
--	addacrown("miss_wetgenes","erik_revolution",1)

	addacrown("poet","riceguy",1)
	addacrown("putty","lunboks",1)
	
	
	
-- the ips these people login from are allowed multiple extra logins

	data.alt_names["xix"]=100
	data.alt_names["shi"]=100

-- cache the ips here, do not save these ips

	data.alt_ips=data.alt_ips or {}
	

data.badwords={ -- we are not dealing with smart people here, just trying to catch the first thing they say
"cunt",
"fuck",
"shit",
"nigger",
"faggot",
"boxxy",
"kongregate",
"steam",
}

-- create limbo room
dr{
	name="limbo",
	welcome="Welcome to limbo, all may exist here even those souless people who have yet to logon. Type /login nameyouwant if you want to change your name.",
	addlieza="lieza",
}

-- create public room
dr{
	name="public",
	welcome="Welcome to the public room, please to be behaving your self. That means do not simulate copulation and be careful not to share personal information.",
	addnoir="noir",
	imgback=cfg.base_data_url.."/game/s/spew/backs/public.png",
}

-- create swearbox room
dr{
	name="swearbox",
--	welcome="Welcome to the swearbox. This is temporarily Playa11's home. Please take a seat on that couch over there. It's smelly but it's still a good couch. Also, don't be a douchebag.",
	welcome="Welcome to the swearbox, unlike the public room you will not be ejected for swearing here. In an attempt to save boxes this room also doubles as a spambox and a shoggoth tummy. If you have been trapped here then try typing CTHULHU COOKIES",
}

-- create fiction room
dr{
	name="fiction",
	mux=true,
	welcome="Welcome to Wet Fiction, this is a MUSH ROOM, type *help for help and remember to put * before all commands otherwise you will just talk.",
}

-- create public room
dr{
	name="public.facebook",
	welcome="Welcome to the facebook public room, please to be behaving your self. That means do not simulate copulation and be careful not to share personal information.",
	addnoir="noir",
	imgback=cfg.base_data_url.."/game/s/spew/backs/public.png",
}

dr{
	name="public.vip",
	welcome="Welcome to the VIP public room, no guests or freaks allowed.",
	addnoir="jeeves",
	locked="man",
}

dr{
	name="public.wolf",
	welcome="Welcome to the werewolf public room, only wolfs are allowed in here. The full moon is always shining no matter what the time of day or night it is.",
	addnoir="moon",
	locked="wolf",
}
dr{
	name="public.vamp",
	welcome="Welcome to the vampire public room, only vamps are allowed in here. This is a very very dark room with dirt on the floor and a four poster bed in the corner. Every thing that can be black is black, many other things that shouldn't be black are also black.",
	addnoir="ygor",
	locked="vamp",
}
dr{
	name="public.zom",
	welcome="Welcome to the zombie public room, only zombies are allowed in here. Rotting body parts are strewn all over the place in case anyone feels hungry.",
	addnoir="meatwad",
	locked="zom",
}

dr{
	name="public.kickabout",
	welcome="Welcome to the kickabout room, where you can have a friendly game of footy.",
	addnoir="meatwad",
}

dr{
	name="public.bigpong",
	welcome="Welcome to bigpong, do you know what time it is?",
	addnoir="moon",
}

dr{
	name="public.zeegrind",
	welcome="Welcome to zeegrind, where you may grind zee zombies.",
	addnoir="meatwad",
	locked="ville",
	novillebot=true,
}

dr{
	name="kolumbo",
	welcome="Welcome to kolumbos room where you may browse his goods.",
	addnoir="kolumbo",
	locked="kolumbo",
	novillebot=true,
}

dr{
	name="kolumbo_bob",
	welcome="Welcome to kolumbo bobs room where you may browse his goods.",
	addnoir="kolumbo_bob",
	locked="kolumbo",
	novillebot=true,
}

dr{
	name="public.corridor",
	welcome="A place to pass through, please no loitering.",
	addnoir="jeeves",
}

dr{
	name="public.4lfa",
	welcome="Behold the comedy mines of comedy. If you click and hold on the comic you can choose to change it to another one.",
	addnoir="reg",
}

--[[
dr{
	name="public.news",
	welcome="This is the news room, where the gods may impart wisdom to you and you may not speak.",
	addnoir="noir",
	locked="news",
}
]]

dr{
	name="public.rank5",
	welcome="The gentlemans club where you can sit and relax in squeeky leather chairs whilst smoking cigars and sipping port. (non men are presented with a fake honorary manhood for the duration of their stay).",
	addnoir="noir",
	locked="rank5",
}

dr{
	name="public.rank10",
	welcome="The gentlemans gentlemans club where you can sit and relax in giant squeeky leather chairs whilst smoking huge cigars and sipping large jars of port. (non men are presented with a fake honorary vibrating manhood for the duration of their stay).",
	addnoir="noir",
	locked="rank10",
}
	
dr{
	name="public.pokr",
	welcome="Welcome to the public poker room where everday is made of assploading whale.",
	addnoir="ygor",
	locked="ville",
}

dr{
	name="panopticon",
	welcome="IGNORE ME!.",
	addnoir="reg",
	locked="all",
}
	
	for i=1,100 do
	
		local room=get_room("public."..i)
		
		if not room then break end
		
		room.imgback=cfg.base_data_url.."/game/s/spew/backs/public.png"
		room.welcome="Welcome to the public."..i.." room, please to be behaving your self. That means do not simulate copulation and be careful not to share personal information."
	
	end
	
-- run the gametype setups and checks
	build_and_check_environment()
	
-- read in some word data files	

	data.words={}
	data.words.adjectives={}
	for line in io.lines("spew_data_adjectives.txt") do 
		line=line:gsub("^%s*(.-)%s*$", "%1")		
		table.insert(data.words.adjectives,line)
	end
	data.words.nouns={}
	for line in io.lines("spew_data_nouns.txt") do 
		line=line:gsub("^%s*(.-)%s*$", "%1")		
		table.insert(data.words.nouns,line)
	end
	data.words.itsa={}
	for line in io.lines("spew_data_itsa.txt") do 
		line=line:gsub("^%s*(.-)%s*$", "%1")		
		table.insert(data.words.itsa,line)
	end
	
-- enable threads
	
	lanes_setup()

-- make sure data is setup

	build_and_check_elo()

	feats_data_setup()
	user_data_setup()
	item_data_setup()
	ville_data_setup()
	
-- check more stuffs

	check_rooms()
	check_idstrings()
	check_ipmap()
	check_spam()
	
-- reload bots
	remove_all_bots()
	add_bots()
	
-- hush the staffs moon
	local r=get_room("public.rank10")
	if r and r.brain then
		r.hush_time=os.time()+60*60*24*1000
	end
	
-- expand the news log and hush the bot
--[[
	local r=get_room("public.news")
	if r then
		r.history_max=128
	end
	if r and r.brain then
		r.hush_time=os.time()+60*60*24*1000
	end
]]
	
-- queue or reset the generic update tick
	
	setup_pulse()
	

--twiter problems?
--[[	
	if not cfg.skip_twitter then
	
dbg("reading data from twitter\n")
		local ret=lanes_url("http://twitter.com/status/user_timeline/wetgenes.json") -- pull in news feed
		
		if ret.body then
		
		local r=get_room("public.news")
		
		local twit=Json.Decode(ret.body)
		
	--		dbg(serialize(twit))

			r.history={} -- clear old history and ad in new from twitter
			
			for i=#twit,1,-1 do
			
				local v=twit[i]
				local msg={}
				
	--string.find(v.text,"#") or 
				if string.find(v.text,"@") then -- ignore these tweets, they are not for news
				
				else
				
					local aa=str_split(" ",v.text)
					local link
					
					for i,v in ipairs(aa) do
					
						local loc=string.find(v,"http://")
						
						if loc and loc==1 then
						
							link=v
							
							break
						end
					end
				
					if link then -- make it a clickable
					
						msg.frm="cthulhu"
						msg.cmd="lnk"
						msg.txt=v.text
						msg.lnk=link
					
					else
					
						msg.frm="cthulhu"
						msg.cmd="say"
						msg.txt=v.text
						
					end
				
					table.insert(r.history,msg)
				
				end
			end
			
		end
	--	dbg(ret.body)
dbg("read data from twitter\n")
	end
]]


	local tab={}
	for u,b in pairs(data.brains) do
		if u.room.brain~=u.brain then -- ignore room bots
			table.insert(tab,u.name)
		end
	end
	dbg( "BRAINS:",str_join_english_list(tab),"\n" )
	
-- dump GC numbers
--[[
for i,v in ipairs({"count","setpause","setstepmul"}) do
	dbg("GC ",v," ",collectgarbage(v),"\n");
end
]]


	spew_setup_stars()
	
	vest_load_rates()
	
	setup_room_protction()
	
if not (flags and flags.nocrowns) then
	game_thorns() -- check for the real weaners every day
	game_crowns() -- check for game weaners on the hour
end

end

-----------------------------------------------------------------------------
--
-- called every hour
--
-----------------------------------------------------------------------------
function setup_room_protction()

local room

	for i,v in ipairs({
		"public.vip",
		"public.wolf",
		"public.vamp",
		"public.zom",
		"public.pokr",
			}) do
		
		room=get_room(v)
		
		if room and ( (room.protect_time or 0 )<os.time()+(60*60) ) then room.protect_time=os.time()+(60*60) end
		
	end
	
	room=get_room("fail.tv")
	if room and ( (room.protect_time or 0 )<os.time()+(60*60*24*10) ) then room.protect_time=os.time()+(60*60*24*10) end

end

-----------------------------------------------------------------------------
--
-- check data
--
-----------------------------------------------------------------------------
function build_and_check_environment()

dbg("checking environment\n")

	for i,v in pairs(data.gametypes) do
	
		if v.build_and_check_environment then
		
			v.build_and_check_environment()
		
		end
	
	end
	
end


-----------------------------------------------------------------------------
--
-- save posix data if posix is enabled
--
-- eg PID 
--
-----------------------------------------------------------------------------
function save_posix_data(tim)

	if cfg.os=="nix" then

		local dat={}
		
		dat.pid=posix.getpid("pid")
		dat.time=tim or os.time() -- pass in time of 0 to signal instant reload in spewd proc
		
		
		local file = io.open("spewd.dat","w")	
		
		-- use this to send data to the file
		local fout=function(s)
			if file then file:write(s) end
		end
		
		-- dump the table
		fout("data=")
		serialize(dat,fout)
		fout("\n")

		-- close the file	
		if file then file:close() end
	
	end

end

-----------------------------------------------------------------------------
--
-- save data
--
-- so we can take the server down then restore the current state
--
-----------------------------------------------------------------------------
function save_data()

-- open the file
	local file = io.open("config.data.lua","w")	

-- need to wrap everything in functions so the file can grow to be huge without borking lua
-- hence the data.f junk, sorry

-- use this to send data to the file
	local fout=function(s)
		if file then file:write(s) end
	end
	
	allcast( {cmd="note",note="notice",arg1="saving state data"} )

	for i,v in ipairs({	"saved_cookies","saved_color","day_flags","drama_names",
						"drama_ips","hardmud_names","mud_names","dum_names","ipmap","ipwho","ipsux"}) do
	
		fout("function data.f()\ndata."..v.."=")
		serialize(data[v],fout)
		fout("end\ndata.f()\n\n")
	
	end
	
	fout("\n\n\n")
		
	for u,b in pairs(data.users) do -- also overide with important current user data if the user is logged in
	
		if u.name~="me" then -- ignore the army of mes
		
			fout("data.saved_cookies['"..string.lower(u.name).."']="..u.cookies.."\n")
			
		end
		
	end
	
	fout("\n\n\n")
	fout("local function ld(n,v) data.gametypes.wetv.vid_infos[n]=v end")
	fout("\n\n\n")
-- remember tv stats
	for n,v in pairs(data.gametypes.wetv.vid_infos) do
	
			fout("function data.f()\nld(\""..n.."\",\n")
			serialize(v,fout)
			fout(")end\ndata.f()\n")
	end
	fout("\n\n\n")

	
	fout("\n\n\n")
	fout("local function ld(n,v) data.gametypes.wetv.vid_ids[n]=v end")
	fout("\n\n\n")
-- remember tv recent
	for n,v in pairs(data.gametypes.wetv.vid_ids) do
	
			fout("function data.f()\nld(\""..n.."\",\n")
			serialize(v,fout)
			fout(")end\ndata.f()\n")
	end
	fout("\n\n\n")

-- remember room info, so less junks is lost

	for i,r in pairs(data.rooms) do
	
	local tab={}
	
	local aa=str_split(".",r.name)
	
		if aa[1]~="public" then -- do not try and save rooms that begin with public, they should autocreate
	
			for i,v in ipairs{"locked","allow","deny","owners","welcome","vback","retain_noir","retain_noir_name","history","protect_time","hush_super","hush_time","badwords"} do -- copy these bits across
			
				tab[v]=r[v]
			
			end
		
			fout("\nfunction data.f()\n\nmanifest_room('"..string.lower(r.name).."',nil,\n")
			serialize(tab,fout)
			fout("\n)end\ndata.f()\n")
			
		end
	
	end
	
	fout("\ndata.f=nil\n") -- dont leave the function in data just in case...
		
-- close the file	
	if file then file:close() end

end

-----------------------------------------------------------------------------
--
-- load data, this is unsafe as it will wipe the current settings and the saved file...
--
-----------------------------------------------------------------------------
function load_data()

local fname="config.data.lua"

	allcast( {cmd="note",note="notice",arg1="loading state data"} )
		
		
	local file=io.open(fname,"r") -- only if file exists
	if file then	
		file:close()
		load_brains(fname)
	end
	
end


-----------------------------------------------------------------------------
--
-- check the alignment of the stars today
--
-----------------------------------------------------------------------------
function spew_setup_stars()

local d=os.date("*t")

--	d.day=13
--	d.month=3

	data.date=d

dbg( "STARS ARE ALIGNED TO ", d.year , " " , d.month , " " , d.day , "\n" )

	if d.month==9 and d.day==9 then -- tagged player may only proclaim cirno to be the strongest

		day_flag_set("*","tag","strong")
		
	elseif d.month==1 and d.day==1 then -- mini mes for the first day of the year

		day_flag_set("*","ville_size",75)
		
	elseif d.month==1 and d.day==18 then -- welcome to freedom day

		day_flag_set("*","tag","redacted")
		
	end

	if d.day==1 then -- first day of each month gets...
	
		day_flag_set("*","force_level",d.month) -- forced levels
		
	end
	
end




