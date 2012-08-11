
local gtab=data.gametypes["zeegrind"] or {}


-----------------------------------------------------------------------------
-- 
-- zombie info / stats
-- 
-----------------------------------------------------------------------------
gtab.zombies=
{
	{
		name="baldie",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.baldie.xml",
		size=100,
		walkspeed=100,
		sniff=400,
		jump=150,
		bite=50,
		evade=0,
		armour=1,
		roam_area={0,0.75,0,1},
		group="base",
	},
	{
		name="creep",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.creep.xml",
		size=100,
		walkspeed=105,
		sniff=400,
		jump=150,
		bite=50,
		evade=0,
		armour=1,
		roam_area={0.25,1,0,1},
		group="base",
	},
	{
		name="hippie",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.hippie.xml",
		size=100,
		walkspeed=110,
		sniff=500,
		jump=150,
		bite=50,
		armour=1,
		evade=0,
		roam_area={0,1,0,0.50},
		group="base",
	},
	{
		name="kid",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.kid.xml",
		size=100,
		walkspeed=115,
		sniff=500,
		jump=150,
		bite=50,
		evade=0,
		armour=1,
		roam_area={0,1,0.50,1},
		group="base",
	},
	{
		name="liz",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.liz.xml",
		size=100,
		walkspeed=120,
		sniff=600,
		jump=175,
		bite=50,
		evade=0,
		armour=1,
		roam_area={0,0.50,0,1},
		group="base",
	},
	{
		name="maddy",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.maddy.xml",
		size=100,
		walkspeed=125,
		sniff=600,
		jump=175,
		bite=50,
		evade=0,
		armour=1,
		roam_area={0.50,1,0,1},
		group="base",
	},
	{
		name="mary",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.mary.xml",
		size=100,
		walkspeed=130,
		sniff=700,
		jump=175,
		bite=50,
		evade=0,
		armour=1,
		roam_area={0,1,0,0.50},
		group="base",
	},
	{
		name="nerd",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.nerd.xml",
		size=100,
		walkspeed=135,
		sniff=700,
		jump=175,
		bite=50,
		evade=0,
		armour=1,
		roam_area={0,1,0.50,1},
		group="base",
	},
	{
		name="rock",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.rock.xml",
		size=100,
		walkspeed=140,
		sniff=800,
		jump=200,
		bite=50,
		evade=0,
		armour=1,
		roam_area={0,0.25,0,1},
		group="base",
	},
	{
		name="rod",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.rod.xml",
		size=100,
		walkspeed=145,
		sniff=800,
		jump=200,
		bite=50,
		evade=0,
		armour=1,
		roam_area={0.75,1,0,1},
		group="base",
	},	
	{
		name="prof",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.prof.xml",
		size=100,
		walkspeed=150,
		sniff=900,
		jump=250,
		bite=50,
		evade=0,
		armour=1,
		roam_area={0,1,0,1},
		group="base",
	},
	
	
	
	
	{
		name="minibaldie",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.baldie.xml",
		size=75,
		walkspeed=100,
		sniff=400,
		jump=300,
		bite=50,
		evade=0,
		armour=0.75,
		roam_area={0,0.75,0,1},
		group="mini",
	},
	{
		name="minicreep",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.creep.xml",
		size=75,
		walkspeed=105,
		sniff=400,
		jump=300,
		bite=50,
		evade=0,
		armour=0.75,
		roam_area={0.25,1,0,1},
		group="mini",
	},
	{
		name="minihippie",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.hippie.xml",
		size=75,
		walkspeed=110,
		sniff=500,
		jump=300,
		bite=50,
		armour=0.75,
		evade=0,
		roam_area={0,1,0,0.50},
		group="mini",
	},
	{
		name="minikid",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.kid.xml",
		size=75,
		walkspeed=115,
		sniff=500,
		jump=300,
		bite=50,
		evade=0,
		armour=0.75,
		roam_area={0,1,0.50,1},
		group="mini",
	},
	{
		name="miniliz",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.liz.xml",
		size=75,
		walkspeed=120,
		sniff=600,
		jump=300,
		bite=50,
		evade=0,
		armour=0.75,
		roam_area={0,0.50,0,1},
		group="mini",
	},
	{
		name="minimaddy",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.maddy.xml",
		size=75,
		walkspeed=125,
		sniff=600,
		jump=300,
		bite=50,
		evade=0,
		armour=0.75,
		roam_area={0.50,1,0,1},
		group="mini",
	},
	{
		name="minimary",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.mary.xml",
		size=75,
		walkspeed=130,
		sniff=700,
		jump=300,
		bite=50,
		evade=0,
		armour=0.75,
		roam_area={0,1,0,0.50},
		group="mini",
	},
	{
		name="mininerd",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.nerd.xml",
		size=75,
		walkspeed=135,
		sniff=700,
		jump=300,
		bite=50,
		evade=0,
		armour=0.75,
		roam_area={0,1,0.50,1},
		group="mini",
	},
	{
		name="minirock",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.rock.xml",
		size=75,
		walkspeed=140,
		sniff=800,
		jump=300,
		bite=50,
		evade=0,
		armour=0.75,
		roam_area={0,0.25,0,1},
		group="mini",
	},
	{
		name="minirod",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.rod.xml",
		size=75,
		walkspeed=145,
		sniff=800,
		jump=300,
		bite=50,
		evade=0,
		armour=0.75,
		roam_area={0.75,1,0,1},
		group="mini",
	},	
	{
		name="miniprof",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.prof.xml",
		size=75,
		walkspeed=150,
		sniff=900,
		jump=300,
		bite=50,
		evade=0,
		armour=0.75,
		roam_area={0,1,0,1},
		group="mini",
	},
	
	
	
	
	
	
	
	
	{
		name="maxibaldie",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.baldie.xml",
		size=125,
		walkspeed=100,
		sniff=400,
		jump=300,
		bite=50,
		evade=0,
		armour=0.1,
		roam_area={0,0.75,0,1},
		group="maxi",
	},
	{
		name="maxicreep",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.creep.xml",
		size=125,
		walkspeed=105,
		sniff=400,
		jump=300,
		bite=50,
		evade=0,
		armour=0.1,
		roam_area={0.25,1,0,1},
		group="maxi",
	},
	{
		name="maxihippie",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.hippie.xml",
		size=125,
		walkspeed=110,
		sniff=500,
		jump=300,
		bite=50,
		armour=0.1,
		evade=0,
		roam_area={0,1,0,0.50},
		group="maxi",
	},
	{
		name="maxikid",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.kid.xml",
		size=125,
		walkspeed=115,
		sniff=500,
		jump=300,
		bite=50,
		evade=0,
		armour=0.1,
		roam_area={0,1,0.50,1},
		group="maxi",
	},
	{
		name="maxiliz",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.liz.xml",
		size=125,
		walkspeed=120,
		sniff=600,
		jump=300,
		bite=50,
		evade=0,
		armour=0.1,
		roam_area={0,0.50,0,1},
		group="maxi",
	},
	{
		name="maximaddy",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.maddy.xml",
		size=125,
		walkspeed=125,
		sniff=600,
		jump=300,
		bite=50,
		evade=0,
		armour=0.1,
		roam_area={0.50,1,0,1},
		group="maxi",
	},
	{
		name="maximary",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.mary.xml",
		size=125,
		walkspeed=130,
		sniff=700,
		jump=300,
		bite=50,
		evade=0,
		armour=0.1,
		roam_area={0,1,0,0.50},
		group="maxi",
	},
	{
		name="maxinerd",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.nerd.xml",
		size=125,
		walkspeed=135,
		sniff=700,
		jump=300,
		bite=50,
		evade=0,
		armour=0.1,
		roam_area={0,1,0.50,1},
		group="maxi",
	},
	{
		name="maxirock",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.rock.xml",
		size=125,
		walkspeed=140,
		sniff=800,
		jump=300,
		bite=50,
		evade=0,
		armour=0.1,
		roam_area={0,0.25,0,1},
		group="maxi",
	},
	{
		name="maxirod",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.rod.xml",
		size=125,
		walkspeed=145,
		sniff=800,
		jump=300,
		bite=50,
		evade=0,
		armour=0.1,
		roam_area={0.75,1,0,1},
		group="maxi",
	},	
	{
		name="maxiprof",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.prof.xml",
		size=150,
		walkspeed=150,
		sniff=900,
		jump=300,
		bite=50,
		evade=0,
		armour=0.1,
		roam_area={0,1,0,1},
		group="maxi",
	},
	
	
	{
		name="greeter",
		start_state="help",
		avatar=cfg.base_data_url.."/game/s/ville/test/vtard/z.greeter.xml",
		size=100,
		walkspeed=100,
		sniff=-100,
		jump=-100,
		bite=-100,
		evade=0,
		armour=0,
		roam_area={0,1,0,1},
		group="greeter",
	},
	
	
}
for i,v in ipairs(gtab.zombies) do

	v.id=i gtab.zombies[v.name]=v  -- link names and remember ids

	v.avatar=v.avatar or cfg.base_data_url.."/game/s/ville/test/vtard/z."..(v.name)..".xml"
	
	v.sniff2=v.sniff*v.sniff
	v.jump2=v.jump*v.jump
	v.bite2=v.bite*v.bite
	
	local group=gtab.zombies[v.group] or {}
	table.insert(group,v)
	gtab.zombies[v.group]=group
	
end

-----------------------------------------------------------------------------
-- 
-- weapon info / stats
-- 
-----------------------------------------------------------------------------
gtab.weapons=
{
	{
		name="banana",
		balloon="0:zeegrind:11:50:50",
		walkspeed=110,
		damage=6,
		reload=3,
		hit_dist=400,
		about="A banana is a girls best friend.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=20,
			damage=4,
			reload=-0.5,
			hit_dist=200,
		},
		group="g1",
	},
	{
		name="newspaper",
		balloon="0:zeegrind:13:50:50",
		walkspeed=120,
		damage=4,
		reload=2,
		hit_dist=500,
		about="A newspaper that is black and white and read all over.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=2,
			reload=-0.25,
			hit_dist=50,
		},
		group="g1",
	},
	{
		name="chicken",
		balloon="0:zeegrind:0:50:50",
		walkspeed=140,
		damage=2,
		reload=1,
		hit_dist=600,
		about="A chicken, a rubber chicken.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=10,
			damage=4,
			reload=-0.25,
			hit_dist=50,
		},
		group="g1",
	},
	
	
	{
		name="record",
		balloon="0:zeegrind:4:50:50",
		walkspeed=110,
		damage=9,
		reload=3,
		hit_dist=400,
		about="A record (ask a tribal elder what that is).",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=4,
			reload=-0.25,
			hit_dist=50,
		},
		group="g2",
	},
	{
		name="slipper",
		balloon="0:zeegrind:12:50:50",
		walkspeed=120,
		damage=6,
		reload=2,
		hit_dist=500,
		about="A fluffy fluffy slipper that is not a vagina, baker.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=3,
			reload=-0.25,
			hit_dist=50,
		},
		group="g2",
	},
	{
		name="fishy",
		balloon="0:zeegrind:10:50:50",
		walkspeed=140,
		damage=3,
		reload=1,
		hit_dist=600,
		about="A fishy that is possibly even a red herring.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=2,
			reload=-0.25,
			hit_dist=50,
		},
		group="g2",
	},
	
	
	{
		name="umbrella",
		balloon="0:zeegrind:1:50:50",
		walkspeed=150,
		damage=4,
		reload=1,
		hit_dist=800,
		about="An umbrella sans corperation.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=2,
			reload=-0.25,
			hit_dist=50,
		},
		group="g3",
	},
	{
		name="fryingpan",
		balloon="0:zeegrind:2:50:50",
		walkspeed=130,
		damage=4,
		reload=1,
		hit_dist=800,
		about="A frying pan that smells of bacon.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=2,
			reload=-0.25,
			hit_dist=50,
		},
		group="g3",
	},
	
--
	
	{
		name="baseballbat",
		balloon="0:zeegrind:14:50:50",
		walkspeed=110,
		damage=12,
		reload=4,
		hit_dist=400,
		about="A baseball bat that will knock you for six.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=6,
			reload=-0.25,
			hit_dist=50,
		},
		group="g4",
	},
	{
		name="hammer",
		balloon="0:zeegrind:3:50:50",
		walkspeed=100,
		damage=12,
		reload=4,
		hit_dist=500,
		about="A hammer of hammering.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=6,
			reload=-0.25,
			hit_dist=50,
		},
		group="g4",
	},
	{
		name="pistol",
		balloon="0:zeegrind:5:50:50",
		walkspeed=100,
		damage=12,
		reload=4,
		hit_dist=900,
		about="My pistol goes PEWPEW.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=6,
			reload=-0.25,
			hit_dist=50,
		},
		group="g4",
	},
	
	
	{
		name="brick",
		balloon="0:zeegrind:8:50:50",
		walkspeed=120,
		damage=20,
		reload=5,
		hit_dist=500,
		about="A brick is a brick is a brick.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=10,
			reload=-0.25,
			hit_dist=50,
		},
		group="g5",
	},
	{
		name="forearm",
		balloon="0:zeegrind:9:50:50",
		walkspeed=120,
		damage=20,
		reload=5,
		hit_dist=500,
		about="A zombie forearm bitten off by another zombie.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=10,
			reload=-0.25,
			hit_dist=50,
		},
		group="g5",
	},
	{
		name="chainsaw",
		balloon="0:zeegrind:6:50:50",
		walkspeed=150,
		damage=20,
		reload=5,
		hit_dist=500,
		about="A chainsaw of epic proportions.",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=10,
			reload=-0.25,
			hit_dist=50,
		},
		group="g5",
	},
	
	
	{
		name="boomstick",
		balloon="0:zeegrind:7:50:50",
		walkspeed=100,
		damage=20,
		reload=4,
		hit_dist=900,
		about="This is my BOOMSTICK!",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=10,
			reload=-0.25,
			hit_dist=50,
		},
		group="g6",
	},
	{
		name="tentonnes",
		balloon="0:zeegrind:15:50:50",
		walkspeed=75,
		damage=60,
		reload=10,
		hit_dist=300,
		about="A ten tonne weight. What else do you need to know?",
		desc="A NAME with a damage/reload of DAMAGE/RELOAD and a speed/range of SPEED/RANGE.",
		level_max=8,
		level_up=
		{
			walkspeed=5,
			damage=30,
			reload=-1,
			hit_dist=50,
		},
		group="g6",
	},
}
for i,v in ipairs(gtab.weapons) do
	v.id=i gtab.weapons[v.name]=v -- link names and remember ids

	v.levels={}
	for level=1,v.level_max do
		
		local l={}
		v.levels[level]=l
		
		if level>1 then
			l.name=v.name.."+"..(level-1)
		else
			l.name=v.name
		end
		
		l.level=level
		l.walkspeed	=v.walkspeed	+ ( v.level_up.walkspeed	*(level-1) )
		l.hit_dist	=v.hit_dist		+ ( v.level_up.hit_dist		*(level-1) )
		l.damage	=v.damage		+ ( v.level_up.damage		*(level-1) )
		l.reload	=v.reload		+ ( v.level_up.reload		*(level-1) )
		
		if l.reload<0.5 then l.reload=0.5 end
		if l.walkspeed<50 then l.walkspeed=50 end
		if l.walkspeed>200 then l.walkspeed=200 end
		
		local aa=str_split(":",v.balloon)
		aa[4]=tonumber(aa[4])+ ( 10*(level-1) )
		l.balloon=table.concat(aa,":")
		
		l.desc = string.gsub(v.desc, "%a+", { NAME=l.name , LEVEL=l.level , SPEED=l.walkspeed , RANGE=l.hit_dist, DAMAGE=l.damage , RELOAD=l.reload } )
		l.about = v.about
	end
	
	local group=gtab.weapons[v.group] or {}
	table.insert(group,v)
	gtab.weapons[v.group]=group
	
end

-----------------------------------------------------------------------------
-- 
-- return a unique table with info about this weapon at its current level
-- 
-----------------------------------------------------------------------------
gtab.get_weapon_info = function(str)

local aa=str_split(":",str)

	aa[2]=tonumber(aa[2] or 1)

local weapon=gtab.weapons[ aa[1] ]

	if not weapon then return nil end -- no weapon found

	if aa[2]>weapon.level_max then aa[2]=weapon.level_max end
	if aa[2]<1 then aa[2]=1 end
	aa[2]=force_floor(aa[2])
	
local weapon_level=weapon.levels[ aa[2] ]

local ret={}

	ret.str=str
	ret.name=weapon.name
	
	ret.levelname=weapon_level.name -- eg banana+4
	
	ret.fullname=str -- name containing level and levelups
	
	ret.level		=	weapon_level.level
	ret.balloon		=	weapon_level.balloon
	ret.walkspeed	=	weapon_level.walkspeed
	ret.damage		=	weapon_level.damage
	ret.reload		=	weapon_level.reload
	ret.hit_dist	=	weapon_level.hit_dist
	ret.desc		=	weapon_level.desc
	ret.about		=	weapon_level.about

	return ret
end

-----------------------------------------------------------------------------
-- 
-- room info / stats
-- 
-----------------------------------------------------------------------------
gtab.rooms=
{
	{
		name="Level 0",
		level=0,
		zombie_count=0,
	},
	{
		name="Level 1",
		level=1,
		weapon_chance={
			g1=50,
			g2=30,
			g3=20,
			g4=1,
			g5=1,
			g6=1,
		},
		zombie_chance={
			base=100,
			mini=1,
			maxi=1,
		},
		zombie_count=2,
	},
	{
		name="Level 2",
		level=2,
		weapon_chance={
			g1=50,
			g2=30,
			g3=20,
			g4=1,
			g5=1,
			g6=1,
		},
		zombie_chance={
			base=100,
			mini=1,
			maxi=1,
		},
		zombie_count=4,
	},
	{
		name="Level 3",
		level=3,
		weapon_chance={
			g1=50,
			g2=30,
			g3=20,
			g4=1,
			g5=1,
			g6=1,
		},
		zombie_chance={
			base=100,
			mini=1,
			maxi=1,
		},
		zombie_count=6,
	},
	{
		name="Level 4",
		level=4,
		weapon_chance={
			g1=50,
			g2=30,
			g3=20,
			g4=1,
			g5=1,
			g6=1,
		},
		zombie_chance={
			base=100,
			mini=1,
			maxi=1,
		},
		zombie_count=8,
	},
	{
		name="Level 5",
		level=5,
		weapon_chance={
			g1=50,
			g2=30,
			g3=20,
			g4=1,
			g5=1,
			g6=1,
		},
		zombie_chance={
			base=80,
			mini=20,
			maxi=1,
		},
		zombie_count=10,
	},
	{
		name="Level 6",
		level=6,
		weapon_chance={
			g1=50,
			g2=30,
			g3=20,
			g4=1,
			g5=1,
			g6=1,
		},
		zombie_chance={
			base=60,
			mini=40,
			maxi=1,
		},
		zombie_count=12,
	},
	{
		name="Level 7",
		level=7,
		weapon_chance={
			g1=50,
			g2=30,
			g3=20,
			g4=1,
			g5=1,
			g6=1,
		},
		zombie_chance={
			base=40,
			mini=60,
			maxi=1,
		},
		zombie_count=12,
	},
	{
		name="Level 8",
		level=8,
		weapon_chance={
			g1=50,
			g2=30,
			g3=20,
			g4=1,
			g5=1,
			g6=1,
		},
		zombie_chance={
			base=20,
			mini=80,
			maxi=1,
		},
		zombie_count=12,
	},
	{
		name="Level 9",
		level=9,
		weapon_chance={
			g1=1,
			g2=1,
			g3=1,
			g4=20,
			g5=30,
			g6=50,
		},
		zombie_chance={
			base=1,
			mini=100,
			maxi=1,
		},
		zombie_count=12,
	},
	{
		name="Level 10",
		level=10,
		weapon_chance={
			g1=1,
			g2=1,
			g3=1,
			g4=10,
			g5=10,
			g6=80,
		},
		zombie_chance={
			base=1,
			mini=80,
			maxi=20,
		},
		zombie_count=12,
	},
	{
		name="Level 11",
		level=11,
		weapon_chance={
			g1=1,
			g2=1,
			g3=1,
			g4=1,
			g5=1,
			g6=100,
		},
		zombie_count=0,
	},
}
local randseed,rand=(function() -- closure
	local seed=0
	local function randseed(r) seed=force_floor(r)%65536 end
	local function rand(a,b) -- replacement for math.random
		seed=(((seed+1)*75)-1)%65537
		if a and b then 	return (seed%(1+b-a))+a		-- a to b
		elseif a then		return (seed%a)+1			-- 1 to a
		else				return seed/65535			-- 0.0 to 1.0
		end
	end
	return randseed,rand
end)()

local function pick_one_weight(tab) -- get a random keyname from a table of name->weights

	local total=0
	for i,v in pairs(tab) do total=total+v end
	local pick=rand(0,total-1)

	local ret
	local c=0
	for i,v in pairs(tab) do 
		c=c+v
		if c>=pick then
			ret=i
			break
		end
	end
	
	return ret
end

local function pick_one_list(tab) -- get a random key from a simple list of equal posibilities

	return tab[rand(#tab)]
	
end

gtab.roll_levels= function() -- build new random level contents

	randseed(force_floor(os.time()/(60*60*24))) -- new level every day

	for i,v in ipairs(gtab.rooms) do
	
		local l=gtab.rooms[i]
		
		if l.weapon_chance then
		
			l.weapon_base={}
			
			for j=1,3 do
			
				local wgroup=pick_one_weight(l.weapon_chance)
				local weapon
				
				for _=1,10 do -- sane loop numbers
					weapon=pick_one_list(gtab.weapons[wgroup])
					if not l.weapon_base[weapon.name] then break end -- try not to pick the same weapon twice
				end
			
--dbg(i," ",wgroup," ",weapon.name,"\n")

				l.weapon_base[j]=weapon.name
				l.weapon_base[weapon.name]=true

			end

		end
	
	end
	
	for i,v in ipairs(gtab.rooms) do
	
		local l=gtab.rooms[i]
		local l2=gtab.rooms[i+1]
		
		l.weapons={}
		if l and l.weapon_base then
		
			for i,v in ipairs(l.weapon_base) do
				local a,b
				a=1
				b=l.level
				table.insert(l.weapons,v..":"..a..":"..b)
			end
		end
		
		if l2 and l2.weapon_base then
			for i,v in ipairs(l2.weapon_base) do
				local a,b
				a=1
				b=l2.level
				table.insert(l.weapons,v..":"..a..":"..b)
			end
		end
		
		l.zombies={}
		if l.level<=1 then table.insert(l.zombies,"greeter") end
		if l.zombie_count>0 and l.zombie_chance then
			for j=1,l.zombie_count do
			
				local wgroup=pick_one_weight(l.zombie_chance)
				local zombie
				
				for _=1,10 do -- sane loop numbers
					zombie=pick_one_list(gtab.zombies[wgroup])
					if not l.zombies[zombie.name] then break end -- try not to pick the same zombie twice
				end
				
				table.insert(l.zombies,zombie.name)
				l.zombies[zombie.name]=true
				
--dbg(i," ",wgroup," ",zombie.name,"\n")

			end
		end
	end
end

gtab.roll_levels()

local award=0
for i,v in ipairs(gtab.rooms) do
	v.id=i gtab.rooms[v.name]=v -- link names and remember ids
	
	award=award+(100*v.level) -- build accumalitive award
	v.award=award
end


