
local common_words={["the"]=true,["a"]=true,["in"]=true,["of"]=true,["it"]=true,["by"]=true,["at"]=true,["d"]=true}

local gamehints={
}

gamehints.asue2={
"Here are some hints on the game asue2, type hint asue2 for the next hint.",
"Find the real vase.",
"If it says you are here then it is probably a map.",
"highlight all the rooms.",
"The map looks like a letter.",
"Gnomes hide in grass.",
"Pictures of taps sometimes leak into other realities.",
"Gnomes like to fish.",
"Fish like to eat shiny things.",
"If it says you are here then it is probably a map.",
"2 maps will get you 2 letters.",
"A=1,B=2,C=3,etc",
"Add 2 letters to get a number.",
"Hens lay eggs.",
"Cleanliness is next to godliness.",
}

gamehints.cthulhu={
"Here are some hints on ways to spend your cookies, type hint cthulhu for the next hint.",
"just say CTHULHU COOKIES to undo bans/gags etc, it will however cost cookies.",
"You may use /me calls cthulhu to spend your cookies. Make sure you have enough cookies...",
"/me calls cthulhu to dis username : This disemvowels username for five minutes and costs 5 cookies",
"/me calls cthulhu to gag username : This gags username for five minutes and costs 10 cookies",
"/me calls cthulhu to ban username : This bans username for five minutes and costs 15 cookies",
}

local wordclues={
["color"]={"red","green","blue","orange","gold","black","white","yellow"},
["pet"]={"cat","dog","bird","fish","turtle","pony","rock","hamster"},
["body part"]={"nose","ear","arm","leg","head","chin","boob","toe","foot","hand","belly",},
["drink"]={"juice","coke","lemonade","milk","tea","coffee","vodka","beer","cider"},
["slutty celebrity"]={"Carmen Electra","Britney Spears","Angelina Jolie","Pamela Anderson","Madonna","Paris Hilton","Christina Aguilera","Jodie Marsh","Lindsay Lohan"},
["emo band"]={"Fall Out Boy","Panic at the Disco","Dashboard Confessional","Brand New","Anberlin","American Rejects","Chemical Romance","Jimmy Eat World",},
["treat"]={"cookie","cake","brownies","lollypop","chocolate","candy",},
["cartoon character"]={"garfield","invader zim","gir","care bear","smurf","mickey mouse","donald duck","spongebob","cookie monster","bart simpson","eric cartman"},
["game character"]={"sonic","mario","master chief","snake","glados","link","cloud","alice","Duke Nukem",},
["swear word"]={"fuck","cunt","piss","cock","whore","shit","poop","feck","arse","nuns",},
["vegetable"]={"carrot","turnip","potato","sprout","cucumber","lettuce","onion","pea","corn",},
["fruit"]={"banana","apple","orange","lemon","pear","pineapple","strawberry","grape","mango","kiwi",},
["fast food"]={"burger","hotdog","fries","taco","pizza","kebab","chips","onion rings","pie","fried chicken",},
["prime number"]={"11","13","17","19","23","29","31","37","41","43","47","53","59","61","67","71","73","79","83","89","97",},
["american state"]={"New York","California","Illinois","Texas","Arizona","Pennsylvania",},
["dinosaur"]={"diplodocus","velociraptor","brontosaurus","yourmoma saurus","triceratops","stegosaurus","tyrannosauraus rex","pterodactyl","brachiosaurus",},
["meat"]={"pork","chicken","ham","bacon","gammon","lamb","beef","hotdog","burger","spam",},
["spice"]={"coriander","cumin","paprika","saffron","pepper","tumeric","nutmeg","cardamom","clove","star anise",},
["herb"]={"mint","thyme","sage","rosemary","oregano","basil","tarragon","bay leaf","parsley",},
["philosopher"]={"Socrates","Plato","Pythagoraus","Nietzsche","Euclid Alexandria","Rene Descartes","Bob","Immanuel Kant","Noam Chomsky","Carl Sagan","Robert Wilson"},
["icecream flavour"]={"vanilla","chocolate","strawberry","banana","mint chip","rum raisin","coffee","tiramisu",},
["country"]={"United Kingdom","United States","Germany","France","Russia","Australia","Sweden","Spain","Norway","Mexico","Brazil",},
["teletubby"]={"Tinky Winky","Dipsy","Laa Laa","Po",},
["Beatle"]={"John Lennon","Paul McCartney","George Harrison","Ringo Starr","Stuart Sutcliffe","Pete Best",},
["film by David Lynch"]={"Eraserhead","The Elephant Man","Dune","Blue Velvet","Wild at Heart","Twin Peaks Fire Walk with Me","Lost Highway","Straight Story","Mulholland Drive","Inland Empire",},
["film by M. Night Shyamalan"]={"Happening","Lady in the Water","The Village","Signs","Unbreakable","Sixth Sense",},
["Autobot"]={"Optimus Prime","Bumblebee","Jazz","Ironhide","Ratchet",},
["Decepticon"]={"Megatron","Starscream","Frenzy","Barricade","Bonecrusher"},
["4chan meme"]={"Caturday","Epic Fail","Lurk Moar","Chocolate Rain","Pedobear","Rule 34","Rick Roll"},
["number between 2 and 3"]={"2.1","2.2","2.3","2.4","2.5","2.6","2.7","2.8","2.9",},
["spice girl"]={"Victoria Beckham","Melanie Brown","Emma Bunton","Melanie Chisholm","Geri Halliwell",},
["sex pistol"]={"John Lydon","Steve Jones","Paul Cook","Glen Matlock","Sid Vicious",},
["smashing pumpkin"]={"Billy Corgan","Jimmy Chamberlin","James Iha","D'arcy Wretzky","Melissa Auf der Maur",},
["film director who likes to wear angora sweaters"]={"Edward D Wood Jr",},
["musician who likes to wear angora sweaters"]={"Kurt Kobain",},
["Eloi eater"]={"Morlock","Ted Turner"},
["ingredient of omelette"]={"egg","salt","pepper",},
["ingredient of toast"]={"bread","butter",},
["ingredient of ratatouille"]={"courgette","aubergine","tomato","onion","bell pepper","garlic",},
["ingredient of cookies"]={"flour","chocolate chip","sugar","butter","salt","egg",},
["ingredient of porridge"]={"oats","milk",},
["ingredient of meringue"]={"egg white","sugar",},
["film by uwe boll"]={"who cares they all suck",},
["shape"]={"square","triangle","circle","hexagon","rhombus","star"},
["board game"]={"chess","monopoly","cluedo","risk","scrabble",},
["musical instument"]={"piano","guitar","tambourine","cello","violin","trumpet","flute","organ",},
["Planet"]={"Uranus"},
["word that makes noir respond"]={"noir cookies","time","noir poop","myspace","facebook","digg",},
["number of cookies that I would have if after finding ten cookies on the floor I then won five cookies in a cookie eating competition"]={"fourteen",},
["number of cookies that I would have if after finding ten cookies on the floor I then won five cookies in a jam eating competition"]={"fifteen",},
["number of cookies that I would have if after finding fourteen cookies on the floor I then won six cookies in a two cookie eating competition"]={"eighteen",},
["wetard who is delicious raw"]={"fish", "lunboks",},
["wetarded faggot"]={"erik revolution", "commrade kommisar", "jshaw 995", "taokaka", "dorky", "entombor", "traces", "xenon", "bitch", "zat", "rakiro",},
["a games journo"]={"who cares they all suck",},
["book by Robert Anton Wilson"]={"Cosmic Trigger", "Illuminatus Trilogy", "Prometheus Rising", "Quantum Psychology", "TSOG", "Schrodingers Cat Trilogy",},
["film by John Carpenter"]={"The Thing", "Assault on Precinct 13", "Big Trouble in Little China", "Prince of Darkness", "They Live", "In the Mouth of Madness", "Dark Star",},

}

-- A blue heart twin lost a story about an inland drive to a man named eraserhead on a dune.


local wordclues_idx={}

local wordclues_max=0

for s,_ in pairs(wordclues) do

	wordclues_max=wordclues_max+1
	wordclues_idx[wordclues_max]=s
	
end


-- table of words -> functions that trigger a noir response if preceeded by the bots name, eg noir cookies, this table contains "cookies"->func

local noir_triggers={}

-----------------------------------------------------------------------------
--
-- say something
--
-----------------------------------------------------------------------------
function noir_say(brain,s,user)

	if not brain.user then return end
	
	s=string.gsub(s,"http:","www:") -- stop reposting images, the bot shouldnt say explicit links anyway
	
--	brain.say={cmd="say",frm=brain.user.name,txt=s}
--	brain.saytime=os.time()+1
	if brain.user.room.name=="public.gaybar" then -- the bot in the gay bar talks with a sweeeeeeedish accent bork bork bork

		s=string_chef_filter(s)

	end
	
	local msg={cmd="say",frm=brain.user.name,txt=s}
	if user then msg.blame=user.name end
	
	roomqueue(brain.user.room,msg,brain.user)
	



	if brain.vid then
	
	local vobj=data.ville.vobjs[brain.vid]
	
		if vobj then
		
			local vroom=data.ville.vobjs[vobj.parent]
			
			if vroom then
	
				vobj_set(vobj,"xyz",vroom_random_xyz(vroom))
				
			end
		end
	end

end

-----------------------------------------------------------------------------
--
-- act something
--
-----------------------------------------------------------------------------
function noir_act(brain,s,user)

	if not brain.user then return end
	
--	brain.act={cmd="act",frm=brain.user.name,txt=s}
--	brain.acttime=os.time()+2

	local msg={cmd="act",frm=brain.user.name,txt=s}
	if user then msg.blame=user.name end
	
	roomqueue(brain.user.room,msg,brain.user)

end

-----------------------------------------------------------------------------
--
-- say and link to something
--
-----------------------------------------------------------------------------
function noir_link(brain,s,url,user)

	if not brain.user then return end
	
	if brain.user.room.name=="public.gaybar" then -- the bot in the gay bar talks with a sweeeeeeedish accent bork bork bork

		s=string_chef_filter(s)

	end
	
	local msg={cmd="lnk",frm=brain.user.name,txt=s,lnk=url}
	if user then msg.blame=user.name end
	
	roomqueue(brain.user.room,msg,brain.user)

end

-----------------------------------------------------------------------------
--
-- msg something
--
-----------------------------------------------------------------------------
function noir_msg(brain,msg,user)

	if not brain.user then return end
	

--	brain.say=msg
--	brain.saytime=os.time()+2
	if brain.user.room.name=="public.gaybar" then -- the bot in the gay bar talks with a sweeeeeeedish accent bork bork bork

		if msg.cmd=="say" then
		
			msg.txt=string_chef_filter(msg.txt)
			
		end

	end

	if user then msg.blame=user.name end
	
	roomqueue(brain.user.room,msg,brain.user)
	
end





-----------------------------------------------------------------------------
--
-- say the time
--
-----------------------------------------------------------------------------
function noir_say_help_wetv(brain,user,aa)

	local lnk="http://data.wetgenes.com/wetlinks/help/wetv.jpg"
	noir_link(brain,lnk,lnk,user)
	
end

for i,v in ipairs{"helpwetv","wetvhelp"} do
	noir_triggers[v]=noir_say_help_wetv
end

-----------------------------------------------------------------------------
--
-- say the time
--
-----------------------------------------------------------------------------
function noir_say_help_shadow(brain,user,aa)

	local lnk="http://data.wetgenes.com/wetlinks/help/shadow.jpg"
	noir_link(brain,lnk,lnk,user)
	
end

for i,v in ipairs{"helpshadow","shadowhelp"} do
	noir_triggers[v]=noir_say_help_shadow
end

-----------------------------------------------------------------------------
--
-- say the time
--
-----------------------------------------------------------------------------
function noir_say_time(brain,user,aa)

local s = os.date("it is now %H:%M:%S %a %d %b GMT")

	noir_say(brain,s,user)
	
end

for i,v in ipairs{"time"} do
	noir_triggers[v]=noir_say_time
end

-----------------------------------------------------------------------------
--
-- say a leaderboard link
--
-----------------------------------------------------------------------------
function noir_say_leaders(brain,user,aa)


noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click here to find out who is the leader!",
lnk="http://like.wetgenes.com/-/leaders.all"},user)
	

end

for i,v in ipairs{"leader","leaders"} do
	noir_triggers[v]=noir_say_leaders
end

-----------------------------------------------------------------------------
--
-- say a escrow link
--
-----------------------------------------------------------------------------
function noir_say_escrow(brain,user,aa)


noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click here to view your escrow page.",
lnk="http://like.wetgenes.com/-/escrow"},user)
	

end

for i,v in ipairs{"escrow"} do
	noir_triggers[v]=noir_say_escrow
end



-----------------------------------------------------------------------------
--
-- say a rates link
--
-----------------------------------------------------------------------------
function noir_say_rates(brain,user,aa)


noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click here to view exchange rates, 100,000 cookies is linked to one euro.",
lnk="http://www.ecb.int/stats/exchange/eurofxref/html/index.en.html"},user)
	

end

for i,v in ipairs{"rates"} do
	noir_triggers[v]=noir_say_rates
end


local noir_challenge_rand=0
-----------------------------------------------------------------------------
--
-- say a challenge
--
-----------------------------------------------------------------------------
function noir_say_challenge(brain,user,aa)

local awards

	noir_challenge_rand=noir_challenge_rand+1
	
	awards=game_awards[noir_challenge_rand]
	
	if not awards then noir_challenge_rand=1 end

	awards=game_awards[noir_challenge_rand]
	
	if aa and aa[3] then -- choose a game
	
		local t=game_awards[string.lower(aa[3])]
		if t then awards=t end
	end
	
	
	if awards then -- paranoia
		
noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click here to play "..awards.game_name.." and win upto "..awards.max[1][2].." cookies!",
lnk=awards.link},user)
	
	end
	
end

for i,v in ipairs{"challenge","games","game"} do
	noir_triggers[v]=noir_say_challenge
end

-----------------------------------------------------------------------------
--
-- return number of diggs a given url has been given
--
-----------------------------------------------------------------------------
function url_count_diggs(url)

local api="http://services.digg.com/stories/?link="..url_encode(url).."&appkey="..url_encode("http://4lfa.com").."&type=json"

local count=0

	local ret=lanes_url(api) -- pull in info

	if ret.body then
	
		local digg=Json.Decode(ret.body)
		
		if digg.stories then

			if digg.stories[1] then
		
				if digg.stories[1].diggs then
			
					count=force_floor(tonumber( digg.stories[1].diggs or 0) )
				end
			end
		
		end
		
	end
	
	return count
end

-----------------------------------------------------------------------------
--
-- say award
--
-----------------------------------------------------------------------------
function noir_say_claim(brain,user,aa)
		
local url="http://games.wetgenes.com/games/"..user.gamename..".php"
		
local count=url_count_diggs(url)

--dbg(user.name," : ",count," : ", url,"\n")

	
	if user.digg and user.digg.count and user.digg.url then -- in the middle of a claim
	
		if url == user.digg.url then
		
			if user.digg.count<count then -- win
			
			local win=(500*(count-user.digg.count))
			
				if user.digg.count==0 then -- first digg bonus
				
					win=win+1000
				
				end
		
				noir_say(brain, "Congratulations on digging("..count..") "..user.gamename..", here are "..win.." cookies.",user)
				
				user.cookies=user.cookies+win -- even guests can win

				user.digg=nil
			
			else -- fail
			
				noir_say(brain, "Sorry no new diggs("..count..") detected for "..user.gamename.." so no reward for you.",user)
			
			end
		end
	
	else -- starting a claim
	
		user.digg={url=url,count=count}
		noir_say(brain, "You have begun a digg cookie claim, now when the number of diggs("..count..") for "..user.gamename.." goes up (There is an easy digg button at the top of this page). Type "..brain.user.name.." claim again to receive a reward.",user)
	
	end
		
--	noir_say(brain, username.." has been awarded "..given.." of "..awards.max[1][2].." cookies for playing "..awards.game_name.." today" ,user)
	
end
--[[
for i,v in ipairs{"claim"} do
	noir_triggers[v]=noir_say_claim
end
]]

-----------------------------------------------------------------------------
--
-- say award
--
-----------------------------------------------------------------------------
function noir_say_award(brain,user,aa)

local gnam
local awards
local given
local total

local username=user.name
local ip=user.ip or 0
local ipcookies=0

	if aa[4] and (aa[4]~="") then -- can request info about others
	
		username=aa[4]
		ip=data.ipmap[string.lower(username)] or 0
	
	end
	
	if aa[3]=="all" or aa[3]=="total" then -- count all
	
		given=0
		total=0
		
		for i,awards in ipairs(game_awards) do
		
			if ip~=0 then
				ipcookies=day_flag_get_num( ip , awards.name..".part" ) or 0
			else
				ipcookies=0
			end
			
			given = given + (  day_flag_get_num( username , awards.name..".part" ) or ipcookies )
			total = total + awards.max[1][2]
		end
		
		noir_say(brain, username.." has been awarded "..given.." of "..total.." cookies available today" ,user)
	
	else
	
		if aa[3] then -- use the given name
		
			gnam=aa[3]

		elseif user.this_game_name then -- last played version
		
			gnam=user.this_game_name
			
		else
		
			gnam=user.gamename
		
		end
		
		awards=game_awards[string.lower(gnam)]
			
		if not awards then -- no game

			noir_say(brain, "Sorry but "..gnam.." has no awards." ,user)

			return
		end
		
		if ip~=0 then
			ipcookies=day_flag_get_num( ip , awards.name..".part" ) or 0
		else
			ipcookies=0
		end
			
		given=day_flag_get_num( username , awards.name..".part" ) or ipcookies -- how much awarded so far
		
		noir_say(brain, username.." has been awarded "..given.." of "..awards.max[1][2].." cookies for playing "..awards.game_name.." today" ,user)
	
	end
	
end

for i,v in ipairs{"award","awards"} do
	noir_triggers[v]=noir_say_award
end



-----------------------------------------------------------------------------
--
-- issue or accept a challenge
--
-----------------------------------------------------------------------------
local function noir_say_thunderdome(brain,user,aa)

local tab,str
local name=string.lower(aa[3] or "")
local mudlen=force_floor(aa[4] or 10) or 10 -- default mudlenth of 10
local gaybar=false

	if mudlen<1 then mudlen=1 end
	if mudlen>1000 then mudlen=1000 end

-- must be level 10+ to play
	if user.room.name~="public.gaybar" then -- anyone in the gaybar
		if user_rank(user)<10 then
			noir_say(brain,"You must be this high(10) to ride the THUNDERDOME!.",user)
			return
		elseif name=="xix" then
			noir_say(brain,"Please don't, it, sickens me.",user)
			return
		elseif name=="shi" then
			noir_say(brain,"You have already lost, THEGAME!",user)
			return
		end
	else
		gaybar=true
	end
	
	brain.thunderdome=brain.thunderdome or {from="",vic="",start=0,mudlen=1} -- init?
	local td=brain.thunderdome
	local tim=os.time()-td.start
	if td.state=="active" then -- fight in progress
		noir_say(brain,"Thunderdome is already in progress ("..math.floor(tim)..").",user)
	else
		if name=="" or name==string.lower(user.name) then
		
			noir_say(brain,"Who would you like to challenge and how many days of mud do you want to risk? eg NOIR THUNDERDOME BOB 10 to fight bob for 10 days of mud.",user)
		
		else
			if td.vic==string.lower(user.name) and td.from==name and tim<30 and td.mudlen==mudlen and td.state=="challenge" then -- accept
			
				noir_say(brain,td.from.." has accepted "..td.vic.."s challenge to THUNDERDOME("..td.mudlen..")!",user)
				
-- now we start a special FIGHT

				td.start=os.time()
				td.state="active"
				
				td.p1={name=td.from,time=td.start,hp=100}
				td.p2={name=td.vic,time=td.start,hp=100}
				td.from=""
				td.vic=""
				
				local task={}
				task.name="thunderdome"
				
				local action=function(t)
					roomqueue( brain.user.room,{cmd="note",note="notice",arg1=t} )
				end
				
				local dokill=function(p,v)

					td.state="finished"
					
					if gaybar then -- no real mud
						action(p.name.." made "..v.name.." jizz their pants.")
					else
						action(p.name.." made "..v.name.." crap their pants for "..td.mudlen.." days.")
						data.mud_names[v.name]=td.mudlen
						data.thorns_mud[string.lower(v.name)]=-td.mudlen
						build_crowns_for(v.name)
log(p.name,"thunderdome",v.name,td.mudlen)
					end
					
					remove_update(task)
					brain.msghook=nil
				end
				
				td.task=task
				task.lock=20
				task.co=coroutine.create(function() -- we call this repeatedly
				local active=true
				while active do
					local tim=os.time()-td.start					
					if tim>120 then
						if math.random(0,100)<50 then -- random mud
							action(td.p2.name.." trips and falls...")
							dokill(td.p1,td.p2)
						else
							action(td.p1.name.." trips and falls...")
							dokill(td.p2,td.p1)
						end
						return
					end
					coroutine.yield()
				end
				end)
				task.update=function() coroutine.resume(task.co) end
				queue_update(task) -- queue this new task for a response
				
-- check for talking
				brain.msghook=function(b,msg,user)
				
					local tim=os.time()-td.start
					
					if tim>150 then -- sanity kill
						remove_update(task)
						brain.msghook=nil
						return
					end
					
					local frm=(msg.frm or ""):lower()
					if frm==td.p1.name or frm==td.p2.name then
						local p=td.p1 -- attacker
						local v=td.p2 -- defender
						if frm==td.p2.name then p=td.p2 v=td.p1 end
						local t=os.time()
						local hit=t-p.time
						p.time=t -- reset time
--dbg("hit = "..hit.."\n")
						hit=hit/10
						if hit<0 then hit=0 end
						if hit>1 then hit=1 end
						hit=math.floor((100*hit)) -- get a chance to hit number
--dbg("hit = "..hit.."\n")
						local r=math.random(0,100)
						local dam=0
						if r<hit then -- hit
							r=math.random(0,100)
							dam=hit-r
							if dam<1 then dam=1 end -- at least 1 on success
							v.hp=v.hp-dam
							action(p.name.."("..p.hp..") smashes "..v.name.."("..v.hp..") for "..dam.." damage.")
							if v.hp<=0 then
								dokill(p,v)
								return
							end
						else -- miss
							action(p.name.."("..p.hp..") swings wildly at "..v.name.."("..v.hp..") and misses.")
						end
					end
					
--					noir_say(brain,"THUNDERDOME "..(msg.frm or ""))
					
				end

					
			else -- new challenge
			
				td.from=string.lower(user.name)
				td.vic=name
				td.start=os.time()
				td.mudlen=mudlen
				
				td.state="challenge"
				
				noir_say(brain,td.from.." has challenged "..td.vic.." to THUNDERDOME("..td.mudlen..")! To accept say "..brain.user.name.." thunderdome "..td.from.." "..td.mudlen,user)
				
			end
		end		
	end

end

for i,v in ipairs{"thunderdome"} do
	noir_triggers[v]=noir_say_thunderdome
end



-----------------------------------------------------------------------------
--
-- say feats
--
-----------------------------------------------------------------------------
function noir_say_elo(brain,user,aa)

local who=aa[3] or ""
	who=string.gsub(who, "[^0-9a-zA-Z%-_]+", "" )
	who=string.lower(who)


	local t=elo_get_ranks(who,5)
	local tab={}
	
	for i,v in ipairs(t) do
	
		table.insert(tab,"#"..i.." "..v.name..":"..v.score)
	
	end
	
	if tab[1] then
		noir_say(brain, who.." ratings are "..str_join_english_list(tab),user)
	else
		noir_say(brain, who.." has no ratings",user)	
	end

end
for i,v in ipairs{"elo","rating","ratings"} do
	noir_triggers[v]=noir_say_elo
end


-----------------------------------------------------------------------------
--
-- say feats
--
-----------------------------------------------------------------------------
function noir_say_feats(brain,user,aa)

local gnam
local feats
local given
local total

local username=user.name
	
	if user.this_game_name then -- last played version
	
		gnam=user.this_game_name
		
	else
	
		gnam=user.gamename
	
	end
	
	if string.lower(gnam)=="wetville" then
	
		if user.room.ville_game then
			gnam=user.room.ville_game.name
		else
			local aa=str_split(".",user.room.name)
			if aa[2]=="tv" then
				gnam="WetV"
			end
		end
		
	end
	
	given,total=feats_given(user,gnam)
	
	noir_act(brain, "rates "..username.." "..given.."/"..total.." as a "..gnam.." gamer",user)
	local s="you suck at this game!"
	
	if total > 0 then
		local f=given/total
		if     f <= 0.1 then s="maybe you should improve on your hand-eye coordination."
		elseif f <= 0.2 then s="you know what? you need more practise."
		elseif f <= 0.3 then s="ok, i took 1 point off because your name is horrible."
		elseif f <= 0.4 then s="tell you what, why don't you quit now and save us all the trouble."
		elseif f <= 0.5 then s="get some skills. it's clear you don't have any."
		elseif f <= 0.6 then s="you got this far? lady luck must like you."
		elseif f <= 0.7 then s="FFS, TRY HARDER!!"
		elseif f <= 0.8 then s="seriously, why do you even bother?"
		elseif f <= 0.9 then s="is that all? what a waste of time."
		elseif f <= 1.0 then s="not bad but you could do better."
		end
	end
	noir_say(brain,s,user)

end

for i,v in ipairs{"feat","feats"} do
	noir_triggers[v]=noir_say_feats
end

-----------------------------------------------------------------------------
--
-- say limit
--
-----------------------------------------------------------------------------
function noir_say_fed(brain,user,aa)

local username=user.name

	if aa[3] and (aa[3]~="") then -- can request info about others
	
		username=string.sub(aa[3],1,30)
	
	end
	
	local done=""
	local given_max_total,given_total=0,0
	
	for i,v in ipairs({"wolf","vamp","zom","chav","man"}) do
	
		local given_max,given=username_given_cookies_max(username,v)
--		local bank,xtra=user_rank_bank(user,v)
	
		given_max_total = given_max_total + given_max
		given_total = given_total + given
		
--		if username==user.name then
		
			if given_max==given then -- fully banked
				done=done.." "..v
			end
			
--		end
		
	end
	
	if done~="" then
		done = " ("..done.." )"
	end
	
	noir_say(brain, username.." has fed "..given_total.." of "..given_max_total.." cookies to the bots today"..done ,user)
	
end

for i,v in ipairs{"bank","fed","feed"} do
	noir_triggers[v]=noir_say_fed
end

-----------------------------------------------------------------------------
--
-- say limit
--
-----------------------------------------------------------------------------
function noir_say_crown(brain,user,aa)

local username=user.name

	if aa[3] and (aa[3]~="") then -- can request info about others
	
		username=aa[3]
	
	end
	
	username=string.lower(username)
	username=string.sub(username,1,30)
	
	local why=data.crowns_why[username]
	
	if why then
	
		local tab=str_split(",",why)
		
		noir_say(brain, username.." has "..str_join_english_list(tab).." crowns.",user)
	
	else

		noir_say(brain, username.." has no crowns" ,user)
	
	end
	
end

for i,v in ipairs{"crown","crowns"} do
	noir_triggers[v]=noir_say_crown
end

-----------------------------------------------------------------------------
--
-- say gaybar
--
-----------------------------------------------------------------------------
function noir_say_help(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click here to RTFM.",
lnk="http://help.wetgenes.com/"},user)
	
end

for i,v in ipairs{"help","rtfm"} do
	noir_triggers[v]=noir_say_help
end


-----------------------------------------------------------------------------
--
-- say gaybar
--
-----------------------------------------------------------------------------
function noir_say_gaybar(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="I wanna take you to a gay bar! Gay bar! Gay bar! Click here to come with.",
lnk="http://uk.youtube.com/watch?v=HTN6Du3MCgI"},user)
	
end

for i,v in ipairs{"gaybar"} do
	noir_triggers[v]=noir_say_gaybar
end


-----------------------------------------------------------------------------
--
-- say a horse
--
-----------------------------------------------------------------------------
function noir_say_horse(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click here to see my lovely horse in action!",
lnk="http://uk.youtube.com/watch?v=8linZiGYSeE"},user)
	
end

for i,v in ipairs{"horse","donkey","pony"} do
	noir_triggers[v]=noir_say_horse
end

-----------------------------------------------------------------------------
--
-- say a hook
--
-----------------------------------------------------------------------------
function noir_say_hook(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click here to see my feelings expressed through the medium of song!",
lnk="http://uk.youtube.com/watch?v=PJQVlVHsFF8"},user)
	
end

for i,v in ipairs{"hooked","hook","love","feeling","hoff"} do
	noir_triggers[v]=noir_say_hook
end


-----------------------------------------------------------------------------
--
-- say a rock
--
-----------------------------------------------------------------------------
function noir_say_rock(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click here to see my song expressed through the medium of actor!",
lnk="http://uk.youtube.com/watch?v=DvQwXOCKNLY"},user)
	
end



for i,v in ipairs{"rock","rocket","shat","shatner"} do
	noir_triggers[v]=noir_say_rock
end

-----------------------------------------------------------------------------
--
-- say glc
--
-----------------------------------------------------------------------------
function noir_say_glc(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click to see a real goldie lookin chain.",
lnk="http://uk.youtube.com/watch?v=ygN8H3kI1qE"},user)
	
end

for i,v in ipairs{"glc"} do
	noir_triggers[v]=noir_say_glc
end

-----------------------------------------------------------------------------
--
-- say penis
--
-----------------------------------------------------------------------------
function noir_say_penis(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click to see if your momma has a penis.",
lnk="http://uk.youtube.com/watch?v=wAZTLVJSlNw"},user)
	
end

for i,v in ipairs{"penis"} do
	noir_triggers[v]=noir_say_penis
end

-----------------------------------------------------------------------------
--
-- say guns
--
-----------------------------------------------------------------------------
function noir_say_guns(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click to see rappers kill people.",
lnk="http://uk.youtube.com/watch?v=xv-2XYOtgCg"},user)
	
end

for i,v in ipairs{"guns"} do
	noir_triggers[v]=noir_say_guns
end

-----------------------------------------------------------------------------
--
-- say moonstar
--
-----------------------------------------------------------------------------
function noir_say_moonstar(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click to find out PIEF's lover.",
lnk="http://uk.youtube.com/watch?v=oZ8-ETHE9AI"},user)
	
end

for i,v in ipairs{"moonstar"} do
	noir_triggers[v]=noir_say_moonstar
end

-----------------------------------------------------------------------------
--
-- say pencil
--
-----------------------------------------------------------------------------
function noir_say_pencil(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click to find out who'll help you draw and erase; waste not want not",
lnk="http://uk.youtube.com/watch?v=4MjTb5A68VA"},user)
	
end

for i,v in ipairs{"pencil"} do
	noir_triggers[v]=noir_say_pencil
end


-----------------------------------------------------------------------------
--
-- say miku old: http://www.youtube.com/watch?v=tZCX72VvU5k
--
-----------------------------------------------------------------------------
function noir_say_miku(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click to see WetV's favourite blue haired virtual pop idol.",
lnk="http://www.youtube.com/watch?v=lo9zS0S6hGU"},user)
	
end

for i,v in ipairs{"miku"} do
	noir_triggers[v]=noir_say_miku
end


-----------------------------------------------------------------------------
--
-- say a poop
--
-----------------------------------------------------------------------------
function noir_say_poop(brain,user)

	noir_act(brain,"has pooped on your head",user)
	
end

for i,v in ipairs{"poop"} do
	noir_triggers[v]=noir_say_poop
end


-----------------------------------------------------------------------------
--
-- say tea
--
-----------------------------------------------------------------------------
function noir_say_tea(brain,user)

	noir_act(brain,"puts the kettle on",user)
	
end

for i,v in ipairs{"tea","kettle"} do
	noir_triggers[v]=noir_say_tea
end


-----------------------------------------------------------------------------
--
-- say a roll
--
-----------------------------------------------------------------------------
function noir_say_roll(brain,user)

	if brain.user.room.game and brain.user.room.game.basename=="wetv" then
	
noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="You been rolled fule.",
lnk="http://uk.youtube.com/watch?v=oHg5SJYRHA0"},user)

		return

	end

local r=math.random(4)

	if r==4 then
	
		noir_act(brain,"eats sausage rolls",user)
		
	elseif r==3 then
	
		noir_act(brain,"rolls lundmans eyes",user)
	
	elseif r==2 then
	
		noir_act(brain,"barrel rolls",user)
	
	else
	
		noir_act(brain,"rick rolls",user)

	end
	
end

for i,v in ipairs{"roll"} do
	noir_triggers[v]=noir_say_roll
end

-----------------------------------------------------------------------------
--
-- say a roll
--
-----------------------------------------------------------------------------
function noir_say_dice(brain,user,aa)

	local style="plain"
	local count=2
	local side=6
	
	if aa[2]=="flip" then -- special flip
		count=1
		side=2
	end
	
	if aa[3] then
	
		local ds=str_split("d",aa[3])
		
		if ds[1] then
		
			local n=tonumber(ds[1])
			if n then
				count=math.floor(n)
			end
		
			local n=tonumber(ds[2])
			if n then
				side=math.floor(n)
			end
			
		end
		
	end
	
	if count<1 then count=1 end
	if count>16 then count=16 end
	if side<2 then side=2 end
	if side>20 then side=20 end
	
	local rolls={}
	for i=1,count do
		rolls[i]=math.random(1,side)
	end
	
	local nums=table.concat(rolls," ")
	local str=table.concat(rolls,".")
	
	local lnk="http://wet.appspot.com/dice/image/"..style.."/"..side.."/"..str..".jpg"
	
	noir_link(brain,lnk,lnk,user)

end

for i,v in ipairs{"dice","flip"} do
	noir_triggers[v]=noir_say_dice
end

-----------------------------------------------------------------------------
--
-- say where to bookmark
--
-----------------------------------------------------------------------------
function noir_say_chat(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click here to visit the site that this game/chat lives on.",
lnk="http://ville.wetgenes.com/"},user)
		
end

for i,v in ipairs{"chat","site"} do
	noir_triggers[v]=noir_say_chat
end


-----------------------------------------------------------------------------
--
-- say how to signup
--
-----------------------------------------------------------------------------
function noir_say_signup(brain,user)

if user and user.name and string.lower(user.name)=="traces" then

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="http://mklasing.files.wordpress.com/2008/09/spiderman-gay.jpg",
lnk="http://join.wetgenes.com/"..user.name},user)

else

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="The simplest way to signup is to click here and create an account on the wetgenes forum, this name and password can also be used to login to all of the games and chat.",
lnk="http://join.wetgenes.com/"..user.name},user)

end

end


for i,v in ipairs{"members","member","signup","vip","register"} do
	noir_triggers[v]=noir_say_signup
end
			
-----------------------------------------------------------------------------
--
-- say how to confirm email
--
-----------------------------------------------------------------------------
function noir_say_confirm(brain,user)
	
noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="If you have not received a confirmation e-mail then click here. Note that you will need to refresh this page and login again after confiming to change your status to VIP.",
lnk="http://www.wetgenes.com/forum/index.php?t=uc"},user)

end

for i,v in ipairs{"email","confirm"} do
	noir_triggers[v]=noir_say_confirm
end



-----------------------------------------------------------------------------
--
-- say how to fix forgoten password
--
-----------------------------------------------------------------------------
function noir_say_forgot(brain,user)

noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="If you have forgotten your password then click here to open a web page where you can enter your email address and change your password. If you have forgotten your email or lost control of it then there is nothing else we can do. This is why each account must have a unique and working email.",
lnk="http://www.wetgenes.com/forum/index.php?t=reset"},user)

end

for i,v in ipairs{"forgot","forgotten","forum","password"} do
	noir_triggers[v]=noir_say_forgot
end





-----------------------------------------------------------------------------
--
-- say how to edit your profile
--
-----------------------------------------------------------------------------
function noir_say_profile(brain,user)
	
noir_msg(brain,{cmd="lnk",frm=brain.user.name,
txt="Click here to edit your profile. Other people profiles can be viewed by clicking on their name in chat and choosing the view profile option.",
lnk="http://www.wetgenes.com/forum/index.php?t=register"},user)

end

for i,v in ipairs{"profile"} do
	noir_triggers[v]=noir_say_profile



end



-----------------------------------------------------------------------------
--
-- howmany cookies
--
-----------------------------------------------------------------------------
local function noir_say_cookies(brain,user)

	local cookies=user.cookies or 0

	local april_fools=false
	if data.date.day==1 and data.date.month==4 then april_fools=true end
	

	if (not april_fools) and (cookies > 9000) then	noir_say(brain,user.name.." has OVER NINE THOUSAAAAANDD!" ,user)
	elseif cookies > 1 then	noir_say(brain,user.name.." has "..cookies.." cookies!" ,user)
	elseif cookies == 1 then noir_say(brain,user.name.." has a cookie." ,user)
	else noir_say(brain,user.name.." has no cookies." ,user) end
end

for i,v in ipairs{"cookie","cookies"} do
	noir_triggers[v]=noir_say_cookies
end

-----------------------------------------------------------------------------
--
-- who has been tagged
--
-----------------------------------------------------------------------------
local function noir_say_tagged(brain,user)

--[[
if true then -- disable tag for a whine
	data.tagged_name=nil
	noir_say(brain, "No one has the tag." ,user)
	return
end
]]


local u

	if data.tagged_name=="me" then data.tagged_name=nil end

	if data.tagged_name then -- someone is it
	
		u=get_user(data.tagged_name)
		
		if u and u.room then -- this person is it
		
			data.tagged_name=string.lower(u.name)
			
		else -- clear who is tagged
		
			u=nil
			data.tagged_name=nil
					
		end
		
	end
	

	if not u then -- give the asker the tag?
	
		if not user.room.owners[1] then -- not if in  a private room
			data.tagged_name=string.lower(user.name)
			u=user
		end
	
	end
	
	if u then
		noir_say(brain, u.name.." is it and is in room "..u.room.name ,user)
	else
		noir_say(brain, "No one has the tag." ,user)
	end

end

for i,v in ipairs{"tag","tags","tagged"} do
	noir_triggers[v]=noir_say_tagged
end

-----------------------------------------------------------------------------
--
-- control your bff
--
-----------------------------------------------------------------------------
local function noir_say_bff(brain,user,aa)

local bff

local who=aa[3] or ""
	who=string.gsub(who, "[^0-9a-zA-Z%-_]+", "" )
	who=string.lower(who)

	if who and who~="" then -- requesting a bff change
	
		if is_god(user.name) then
		
			data.god_bff[user.name]=who
			user.bff=who
			user_save_data(user)
			
			noir_say(brain, user.name.." will auto protect "..who.." from abuse." ,user)
			
			return
			
		else
			
			bff=get_user(who)
			
			if bff==user then -- cant be bff with self
			
				noir_say(brain,"You cannot be BFFs with yourself." ,user)
				user.bff="their left hand" -- remove bff if you try and bff yourself
				user_save_data(user)
				return
				
			elseif bff then
			
				user.bff=bff.name
				user_save_data(user)
			
			else
			
				noir_say(brain,"Sorry but "..who.." is not logged in." ,user)
				return
			end
	
		end
		
	else
	
		bff=get_user(user.bff)
		
	end

	if bff and bff.bff==user.name then -- mutual
	
		noir_say(brain, user.name.." and "..bff.name.." are BFFs." ,user)
		
	elseif bff then -- we link to them but they dont link to us
	
		noir_say(brain, user.name.." wishes that "..bff.name.." was their BFF." ,user)
		
	else -- we have no bff logged in
	
		if user.bff and user.bff=="their left hand" then
		
			noir_say(brain, user.name.." really only loves themself." ,user)
		
		elseif user.bff and user.bff~="" then
		
			noir_say(brain, user.name.." wishes that "..user.bff.." was logged in." ,user)
		
		else
	
			noir_say(brain, user.name.." doesn't have a BFF." ,user)
	
		end
		
	end

end

for i,v in ipairs{"bff"} do
	noir_triggers[v]=noir_say_bff
end

-----------------------------------------------------------------------------
--
-- control your balloon
--
-----------------------------------------------------------------------------
local function noir_say_balloon(brain,user,aa)

local balloon

	if not is_admin(user.name) then
	
		if brain.user and brain.user.name=="kolumbo" then
			
			noir_say(brain, "Enter me to visit my children who suckle upon my body.",user)

		else
			
			noir_say(brain, "I don't have any today. You should go talk to Kolumbo, I hear he grows his own, maybe you could grow your own too.",user)

		end
		
		return
		
	end
		
local title=aa[5]
local name=aa[3]
local size=force_floor(tonumber(aa[4] or 50) or 50)
local stze

	if aa[5] then
		stze=force_floor(tonumber(aa[5] or 50) or 50)
		if stze<0 then stze=0 end
		if stze>100 then stze=100 end
	end

	if size<0 then size=0 end
	if size>100 then size=100 end

local it=get_item_by_home(string.lower(user.name).."/balloon")

	if name then -- requesting a balloon
	
		local vuser=data.ville.users[ string.lower(user.name) ]
		
		if it then
		
			if name=="0" then -- kill it
			
				item_discard(it)
--				vuser_check_balloon(vuser)
				vobj_set(vuser,"balloon", "0:float:0:0:0" )
				
				noir_say(brain, "Balloon be gone.",user)
				return
			else
		
				noir_say(brain, "You already have a balloon, dumdum.",user)
				return
			end
		end
	
		
		if vuser then
		
			local tab={}
			tab.props={}
			
			tab.props.type="abc"
			tab.props.idx=string.byte(string.lower(name))-string.byte("a")
			tab.props.size=size
			tab.props.string=stze or size
			tab.props.title=title
	
			item_setname_balloon(tab.props,name) -- choose the balloon
			
			tab.type="balloon"
			tab.owner=string.lower(user.name)		
			tab.home=tab.owner.."/balloon" -- we are holding it
	
			local item=item_create(tab)

			item_save(item)
			
			vuser_check_balloon(vuser)
			
		end
		
	end
	
--[[
	if aa[3] then -- requesting a balloon
	
		local id=force_floor(tonumber(aa[3] or "") or 0)
		if id<0 then id=0 end
		

		local vuser=data.ville.users[ string.lower(user.name) ]

		if vuser then
		
			if id==0 then -- kill balloon
			
				vobj_set(vuser,"balloon","0:0:0:0:0")
				
			else
			
				id=(id-1)
				
				local bsize=user_rank(user)*3
				
				if bsize>50 then bsize=50 end
			
				vobj_set(vuser,"balloon","0:abc:"..id..":"..(25 + bsize) )
			
			end
		
		end

	else
	
		noir_say(brain, "Today is a balloon give away day, say "..brain.user.name.." balloon 1 to get your free balloon.",user)
	
	end
]]

end

for i,v in ipairs{"balloon"} do
	noir_triggers[v]=noir_say_balloon
end

-----------------------------------------------------------------------------
--
-- control your balloon
--
-----------------------------------------------------------------------------
local function noir_say_event(brain,user,aa)

local balloon

	if not is_admin(user.name) then
	
		noir_say(brain, "Are you a god?",user)
		return
		
	end
		
local name=aa[3]
local event=aa[4]


	if name and event then -- setting an even for a user
	
		day_flag_set(name,"event",event)
		noir_say(brain, name.." will now experience a "..event.." for the rest of the day.",user)
			
	elseif name then -- asking what event this person has
	
		event=day_flag_get(name,"event")
		
		if event then
		
			noir_say(brain, name.." is experiencing a "..event.." for the rest of the day.",user)
			
		else
		
			noir_say(brain, name.." has no event.",user)
		end
		
	end

end

for i,v in ipairs{"event"} do
	noir_triggers[v]=noir_say_event
end

-----------------------------------------------------------------------------
--
-- control your home room wall
--
-----------------------------------------------------------------------------
local function noir_say_vback(brain,user,aa)

local room=user.room

	if is_room_owner(room,user.name) or is_admin(user.name) then
	
	else -- not your room
	
		room=nil
	
	end

	if not room then
	
		noir_say(brain, "You are not allowed to change this rooms vback.",user)
		
	
	elseif aa[3] then -- requesting a wall
	
		if room then
		
			local vb=( ( ( str_split("http://",aa[3]) or {"",""} ) [2] ) or "" )
			
			room.vback="http://wet.appspot.com/thumbcache/640/220/" .. vb
		
			noir_say( brain, user.name.." has changed their ville home room vback to "..vb ,user)
			
			local vroom=get_vroom(user.name)
			
			if vroom then
				vroom_check_vobjs(vroom)
			end
		end


	else
	
		noir_say(brain, "You may adjust the back wall of your home room. Set to any image, but 640x220 is the recomended size. Say "..brain.user.name.." vback url",user)
	
	end


end

for i,v in ipairs{"vback"} do
	noir_triggers[v]=noir_say_vback
end

-----------------------------------------------------------------------------
--
-- control your home room wall
--
-----------------------------------------------------------------------------
local function noir_say_brainhook(brain,user,aa)

local room=user.room

	if is_room_owner(room,user.name) or is_admin(user.name) then
	
	else -- not your room
	
		room=nil
	
	end

	if not room then
	
		noir_say(brain, "You are not allowed to change this rooms vback.",user)
		
	
	elseif aa[3] then -- requesting a wall
	
		if room then
		
			room.brainhook=aa[3] or ""
			if room.brainhook=="-" or room.brainhook=="" then
				room.brainhook=nil
				noir_say( brain, user.name.." has cleared this rooms brainhook",user)
			else
				noir_say( brain, user.name.." has changed this rooms brainhook to "..room.brainhook,user)
			end
		end

	else
	
		if room.brainhook then
			noir_say( brain, "This room brainhook is "..room.brainhook,user)
		else
			noir_say( brain, "This room has no brainhook",user)
		end
	end


end

for i,v in ipairs{"brainhook"} do
	noir_triggers[v]=noir_say_brainhook
end

-----------------------------------------------------------------------------
--
-- control your home room wall
--
-----------------------------------------------------------------------------
local function noir_say_userhook(brain,user,aa)

	if not user then return end

	if aa[3] then -- requesting a change
		user.hook=aa[3] or ""
		if user.hook=="-" or user.hook=="" then
			user.hook=nil
		end
	end

	if user.hook then
		noir_say( brain, user.name.."'s userhook is "..user.hook,user)
	else
		noir_say( brain, user.name.." has no userhook",user)
	end

end

for i,v in ipairs{"userhook"} do
	noir_triggers[v]=noir_say_userhook
end

-----------------------------------------------------------------------------
--
-- control your home welcome.
--
-----------------------------------------------------------------------------
local function noir_say_welcome(brain,user,aa,msg)

local room=user.room

	if is_room_owner(room,user.name) or is_admin(user.name) then
	
	else -- not your room
	
		room=nil
	
	end
	
	local desc=str_split(" welcome ",msg.txt)[2] -- this only works if you say welcome in lowercase...

	if not room then
	
		noir_say(brain, "You are not allowed to change this rooms welcome msg.",user)
		
	
	elseif desc then -- got description

		desc=string.sub(desc,1,256)
	
		room.welcome=desc
	
		noir_say(brain, "Room welcome is :"..room.welcome,user)

	else
	
		noir_say(brain, "You may adjust the welcome msg of your home room. Say "..brain.user.name.." welcome text to print",user)
	
	end


end

for i,v in ipairs{"welcome"} do
	noir_triggers[v]=noir_say_welcome
end


-----------------------------------------------------------------------------
--
-- status info
--
-----------------------------------------------------------------------------
local function noir_say_status(brain,user)

	if user_confirmed(user) then
		
		noir_say(brain,user.name.." is a "..user_stat(user).."." ,user)
	
	else
	
		if user_signedup(user) then
			noir_say(brain,user.name.." is a "..user_form(user).." guest (0). (You need to confirm your email and login again before you become a VIP)",user)
		else
			noir_say(brain,user.name.." is a "..user_form(user).." guest (0). (Signup to get 100 cookies a day)",user)
		end
	end

end

for i,v in ipairs{"status"} do
	noir_triggers[v]=noir_say_status
end

-----------------------------------------------------------------------------
--
-- count clans
--
-----------------------------------------------------------------------------
local function noir_say_clans(brain,user)

local n={"zom","vamp","wolf","chav","human"}
local p={zom=0,vamp=0,wolf=0,chav=0,human=0}
local c={zom=0,vamp=0,wolf=0,chav=0,human=0}

local s=""

	for u,_ in pairs(data.users) do
	
-- chekc room name for now until we build room lists on join/parts

		if u.name~="me" then -- ignore the army of mes
		
			if u.form then
			
				p[u.form]=p[u.form]+1
				c[u.form]=c[u.form]+u.cookies
			
			else
		
				p["human"]=p["human"]+1
				c["human"]=c["human"]+u.cookies
			
			end
			
		end
	
	end
	
	s=" humans="..p.human.." zombies="..p.zom.." werewolfs="..p.wolf.." vampires="..p.vamp.." chavs="..p.chav.." "

	noir_say(brain,s,user)
	
end

for i,v in ipairs{"clans","clan"} do
	noir_triggers[v]=noir_say_clans
end

-----------------------------------------------------------------------------
--
-- find user
--
-----------------------------------------------------------------------------
local function noir_say_find(brain,user,aa)

local name=aa[3] or ""

	local s="Sorry but "..name.." is not logged in."

	local u=get_user(name)
	
	if u and u.room and u.room.name then
			
		s=u.name.." is in room "..u.room.name
	
	end
		
	noir_say(brain,s,user)

end

for i,v in ipairs{"find"} do
	noir_triggers[v]=noir_say_find
end

-----------------------------------------------------------------------------
--
-- seen user
--
-----------------------------------------------------------------------------
local function noir_say_seen(brain,user,aa)

	local name=aa[3] or ""
	name=string.lower(name)
	
	local t=nil
	if data.last_seen then t=data.last_seen[name] end
	
	local s
	
	if t then
		t=os.time()-t
		if t<5 then
			s="I saw "..name.." just now."
		else
			s="I saw "..name.." "..rough_english_duration(t).." ago."
		end
	else
		s="Sorry but I havent seen "..name.." recently."
	end
	
	noir_say(brain,s,user)

end

for i,v in ipairs{"seen"} do
	noir_triggers[v]=noir_say_seen
end


-----------------------------------------------------------------------------
--
-- mail user
--
-----------------------------------------------------------------------------
local function noir_say_mail(brain,user,aa)

local name=aa[3]

	local fid
	
	if not user_confirmed(user) then
	
		noir_say(brain,"Sorry but only registered users can send mail.",user)
		
		return
	end

	if not name then
	
		noir_say(brain,"Please also say who you would like to mail.",user)
		
		return
	end
	
	local u=get_user(name)
	
local con,cur,tab

	if u and u.fud then
	
		fid=u.fud.id
	
	end

	if not fid then -- hit mysql
	
		fid=get_user_forum_id(name)
		
	end
	
	if fid then -- found them
	
		noir_link(brain,"Click here to mail "..name,
			"http://www.wetgenes.com/forum/index.php?t=ppost&toi="..fid,user)

	else
	
		noir_say(brain,"Sorry but "..name.." is not a registered user.",user)
	
	end

end

for i,v in ipairs{"mail"} do
	noir_triggers[v]=noir_say_mail
end

-----------------------------------------------------------------------------
--
-- anoint another user to admin a room
--
-----------------------------------------------------------------------------
local function noir_say_anoint(brain,user,aa)

local name=string.lower(aa[3] or "")
local tab=user.room.owners

	if string.lower(user.name)==tab[1] then -- we can anoint people in this private room
	
	local u=get_user(name)
	
		if u then -- ok, we can add or remove them
		
			local removed=false
			for i,v in ipairs(tab) do
			
				if i>1 and v==name then -- remove them
					removed=true
					table.remove(tab,i)
					break
				end
			
			end
			
			if not removed then -- add them
			
				table.insert(tab,name)
			
			end
				
		else -- we can only remove them
		
			for i,v in ipairs(tab) do
			
				if i>1 and v==name then -- remove them
					table.remove(user.room.owners,i)
					break
				end
			
			end
		end
	
		noir_say(brain,"The anointed ones are "..str_join_english_list(tab),user)

	else
		noir_say(brain,"You may only anoint someone in your rooms.",user)
	end
		
end

for i,v in ipairs{"anoint"} do
	noir_triggers[v]=noir_say_anoint
end


-----------------------------------------------------------------------------
--
-- dis user
--
-----------------------------------------------------------------------------
local function noir_say_dis(brain,user,aa)

local name=aa[3] or ""

	if is_mod(name) then return end
	if not ( is_room_owner(user.room,user.name) or is_god(user.name) ) then return end

	local u=get_user(name)
	
	if u and u.room==user.room then
			
		set_status(nil,"dis",name,os.time()+(60*5))
			
		noir_say(brain,"I have disemvoweled "..name.." as you requested, "..user.name,user)
	
	end
	

end

for i,v in ipairs{"dis","disemvowel"} do
	noir_triggers[v]=noir_say_dis
end

-----------------------------------------------------------------------------
--
-- gag user
--
-----------------------------------------------------------------------------
local function noir_say_gag(brain,user,aa)

local name=aa[3] or ""

	if is_mod(name) then return end
	if not ( is_room_owner(user.room,user.name) or is_god(user.name) ) then return end

	local u=get_user(name)
	
	if u and u.room==user.room then
			
		set_status(nil,"gag",name,os.time()+(60*5))
			
		noir_say(brain,"I have gagged "..name.." as you requested, "..user.name,user)
	
	end
	

end

for i,v in ipairs{"gag"} do
	noir_triggers[v]=noir_say_gag
end

-----------------------------------------------------------------------------
--
-- ban user
--
-----------------------------------------------------------------------------
local function noir_say_ban(brain,user,aa)

local name=aa[3] or ""
local tim=(60*5)

	if is_mod(name) then return end -- can never attack owners of rooms
	
	if is_mudip(name) then -- the victim must be mud or on a mudded ip
		tim=(60*60)
	else
		if not ( is_room_owner(user.room,user.name) or is_god(user.name) ) then -- you must own the room
				noir_say(brain,"I'm sorry, "..user.name..", I'm afraid I can't do that.",user)
				return
		end
	end

	local u=get_user(name)
	
	if u and u.room==user.room then -- must be in same room
			
		set_status(nil,"ban",name,os.time()+tim)
		join_room_str(u,"swearbox")
			
		noir_say(brain,"I have banned "..name.." as you requested, "..user.name,user)
	
	end
	

end

for i,v in ipairs{"ban"} do
	noir_triggers[v]=noir_say_ban
end

-----------------------------------------------------------------------------
--
-- ban user
--
-----------------------------------------------------------------------------
local function noir_say_stat(brain,user,aa)

	if not is_admin(user.name) then return end
	

local name=aa[3] or "me"

		noir_say(brain,name.." "..get_banedfor_string(name),user)

		local u=get_user(name)
		
		if u then
		
			local ip=user_ip(u)
			noir_say(brain,u.name.." is a user with an ip of "..ip,user)
			
		end

end

for i,v in ipairs{"stat"} do
	noir_triggers[v]=noir_say_stat
end

-----------------------------------------------------------------------------
--
-- spy on user and report their possible alts
--
-----------------------------------------------------------------------------
local function noir_say_spy(brain,user,aa)

local tab,str
local name=string.lower(aa[3] or "")
--local pay=force_floor(tonumber(aa[4] or "") or 0)

	if name=="xix" then
		noir_say(brain,"I believe that "..name.." is a dragon.",user)
		return
	elseif name=="shi" then
		noir_say(brain,"I believe that "..name.." has hacked this site.",user)
		return
	end
	
--	if not is_admin(user.name) then return end -- admin only for now

	tab=get_shared_names_by_ip(name)
	if tab then str=str_join_english_list(tab) or "" else str="" end -- make sure we have a str
--	num=100+(tonumber(string.sub(md5.sumhexa(name..str),-4),16) % 900) -- a 3 digit decimal number as a price
	
	if name=="" then
	
		noir_say(brain,"Who would you like me to spy on?",user)
	
	else
	
		if tab and ( tab[2] or (string.lower(tab[1])~=string.lower(name)) ) then -- more than one person...
		
			noir_say(brain,name.." looks exactly like "..(#tab).." other people.",user)
			userqueue(user,{cmd="note",note="notice",arg1="spy results : "..str})
		
		else
		
			noir_say(brain,"I believe that "..name.." is a unique individual and I haven't seen anyone else that looks like them.",user)
			
		end
		
	end

end

for i,v in ipairs{"spy"} do
	noir_triggers[v]=noir_say_spy
end

-----------------------------------------------------------------------------
--
-- escrow offer and pay
--
-----------------------------------------------------------------------------
local function noir_say_escrow(brain,user,aa)

if not data.user_thread_available then
	noir_say(brain,"This is why we can't have nice things.",user)
	return
end


local cmd=aa[3] or ""
local name=aa[4] or ""
local num=force_floor(tonumber(aa[5] or "") or 0)

local pet_info
local owner_info

local old_id

	if cmd=="offer" then -- make an offer to buy a pet
		
		if user.cookies<100 then
		
			noir_say(brain,"Sorry but it costs 100 cookies just to make an offer and you do not have enough.",user)
			return			
		end
		
		if not user_confirmed(user) then
		
			noir_say(brain,"Sorry but only registered users can own pets.",user)
			return
		end
		
		if name=="" then
		
			noir_say(brain,"who would you like to buy? say "..brain.user.name.." pet offer bob 1000 to offer to buy bob from bobs owner.",user)
			return
		end
	
		if num<500 then
		
			noir_say(brain,"You must offer at least 500 cookies for a pet.",user)
			return
		end
		
		pet_info=sql_named_tab(lanes_sql("SELECT * FROM "..cfg.fud_prefix.."users WHERE login="..mysql_escape(name)),1)
		
		if not pet_info or tonumber(pet_info.id)==0 then
		
			noir_say(brain,"Sorry but "..name.." must be a registered user to become your pet.",user)
			return
		end
		
		if tonumber(pet_info.referer_id)==0 then -- self ownership
			
			owner_info=pet_info
		
		else
		
			owner_info=sql_named_tab(lanes_sql("SELECT * FROM "..cfg.fud_prefix.."users WHERE id="..tonumber(pet_info.referer_id)),1)
		
		end
		
		if not owner_info or tonumber(owner_info.id)==0 then -- double check owner is valid
		
			noir_say(brain,"Sorry but "..name.." has a broken leash, please contact an admin.",user)
			return
		end

		if owner_info.login == user.name then -- cant buy from self
		
			noir_say(brain,"Sorry but you can not make an offer to buy from yourself.",user)
			return
		end
		
		-- check for previous offer
		
		local r=sql_named_tab(lanes_sql("SELECT * FROM spew_escrow WHERE owner="..owner_info.id.." AND buyer="..user.fud.id.." AND object="..pet_info.id.." "),1)
		
		if r and r.id then
		
			noir_say(brain,"You already have an escrow offer, to buy "..pet_info.login.." from "..owner_info.login.." please delete it at your escrow control page if you want to create a new one.",user)
			return			
		end
		
		local dat={}
		
		dat.type=1
		dat.state=1 -- this is only an offer
		dat.owner=tonumber(owner_info.id)
		dat.buyer=tonumber(user.fud.id)
		dat.object=tonumber(pet_info.id)
		dat.amount=tonumber(num)
		dat.pay=0
		dat.day=get_today()+10 -- default offer of 10 days to pay
		
		spew_mysql_insertup("spew_escrow",dat)
		
		user.cookies=user.cookies-100 -- pay fee		
		noir_say(brain,user.name.." is offering to buy "..pet_info.login.." from "..owner_info.login.." for "..num.." cookies and has just paid a 100 cookie processing fee",user)
		
	elseif cmd=="pay" then -- pay for an active escrow transaction
	
		if name=="" then
		
			noir_say(brain,"who would you like to pay for? say "..brain.user.name.." pet pay bob 100 to pay for 100 cookies of bob.",user)
			return
		end
		
		pet_info=sql_named_tab(lanes_sql("SELECT * FROM "..cfg.fud_prefix.."users WHERE login="..mysql_escape(name)),1)
		
		if not pet_info or tonumber(pet_info.id)==0 then
		
			noir_say(brain,"Sorry but "..name.." must be a registered user to become your pet.",user)
			return
		end
		
		if tonumber(pet_info.referer_id)==0 then -- self ownership
			
			owner_info=pet_info
		
		else
		
			owner_info=sql_named_tab(lanes_sql("SELECT * FROM "..cfg.fud_prefix.."users WHERE id="..tonumber(pet_info.referer_id)),1)
		
		end
		
		if not owner_info or tonumber(owner_info.id)==0 then -- double check owner is valid
		
			noir_say(brain,"Sorry but "..name.." has a broken leash, please contact an admin.",user)
			return
		end
		
		-- check for previous offer
		
		local r=sql_named_tab(lanes_sql("SELECT * FROM spew_escrow WHERE owner="..owner_info.id.." AND buyer="..user.fud.id.." AND object="..pet_info.id.." "),1)
		
		if r and r.id then -- lets work on the offer
		
		local days=r.day-get_today()
			if days<0 then days=0 end
		
			if tonumber(r.state)~=2 then -- must be active offer
			
				noir_say(brain,"You have no escrow active to buy "..pet_info.login.." from "..owner_info.login.." ",user)
				return
			end
			
			num=r.amount-r.pay -- force full amount
			if num>0 then -- paying in
				
--				if r.amount-r.pay < num then num=r.amount-r.pay end -- cap ammount to what is left
				if num>user.cookies then
				
					noir_say(brain,"Sorry but you don't have "..num.." cookies",user)
					return
				end
				
				-- transfer cookies
				r.pay=tonumber(r.pay)+num
				user.cookies=user.cookies-num
				local touse=get_user( owner_info.login )
				if touse then -- logged in
					touse.cookies=touse.cookies+num
				else -- put on floor
					data.saved_cookies[tonumber(owner_info.id)] = ( data.saved_cookies[tonumber(owner_info.id)] or 0 ) + num
				end
				
				if tonumber(r.amount)==tonumber(r.pay) then -- fully paid
				
					lanes_sql("UPDATE spew_escrow SET pay="..r.pay.." , state=3 WHERE id="..r.id)
					lanes_sql("UPDATE "..cfg.fud_prefix.."users SET referer_id="..user.fud.id.." WHERE id="..r.object)

					noir_say(brain,"Congratulations, with that payment of "..num.." cookies you now own "..pet_info.login,user)
					return
			
				else -- partialy paid
				
					lanes_sql("UPDATE spew_escrow SET pay="..r.pay.." WHERE id="..r.id)
					
				end
			end

			noir_say(brain,"You have payed "..r.pay.." of "..r.amount.." to buy "..pet_info.login.." from "..owner_info.login.." and have "..days.." days left to pay",user)
			return
		else
		
			noir_say(brain,"You have no escrow active to buy "..pet_info.login.." from "..owner_info.login.." ",user)
			return
		
		end
		
		
	else -- no command give out some help
		
		noir_link(brain,"say "..brain.user.name.." pet offer bob 1000 this will offer to buy bob for 1000 cookies from whoever owns them. The owner may then refuse or accept. To pay this debt say "..brain.user.name.." pet pay bob 1000","http://like.wetgenes.com/-/escrow",user)
		return
	end
	
end

for i,v in ipairs{"escrow","pet"} do
	noir_triggers[v]=noir_say_escrow
end

-----------------------------------------------------------------------------
--
-- for when you accidently type your password
--
-- login, change pass then use this to logout and clear any cached sessions
--
-----------------------------------------------------------------------------
local function noir_say_logout(brain,user,aa)

local num=force_floor(tonumber(aa[3] or "") or 0)

local test=100+(force_floor( os.time()/(24*60*60) )%900)

	if num==test then -- passed check
	
		if user.fud then -- kill all session logins for this user
		
			local ret=lanes_sql_noblock("DELETE FROM fud26_ses WHERE user_id="..user.fud.id)

		end
	
		login_newname(user,"me",nil) -- become a me
		join_room(user,data.rooms.limbo)-- and kick them into limbo
		
	else -- about
	
		noir_say(brain,"Type "..brain.user.name.." logout "..test.." to logout and disable all autologins on your account.",user)
	end

end

for i,v in ipairs{"logout"} do
	noir_triggers[v]=noir_say_logout
end

-----------------------------------------------------------------------------
--
-- choose to avoid drama,
-- people who have not been assigned drama groups may assign themselves to group 1 to avoid/block all other groups
--
-----------------------------------------------------------------------------
local function noir_say_drama(brain,user,aa)

local act=string.lower(aa[3] or "")

local drama=is_dramaip(user_ipnum(user)) or 0

	if drama==0 then
	
		noir_say(brain,"Your drama("..drama..") is disarmed. (engage is no longer an option).",user)
	
	elseif drama==1 then
	
		if act=="disarm" then
		
			drama_update(user.name,0)
			drama=is_dramaip(user_ipnum(user)) or 0
			
			noir_say(brain,"Your drama("..drama..") is disarmed.",user)
		else
		
			noir_say(brain,"Your drama("..drama..") is engaged. Type "..brain.user.name.." drama disarm to return to normal.",user)
		
		end
		
	else
	
		noir_say(brain,"Your drama("..drama..") is unfortunate.",user)
	
	end

end

for i,v in ipairs{"drama"} do
	noir_triggers[v]=noir_say_drama
end

-----------------------------------------------------------------------------
--
-- pay noir to hush
--
-----------------------------------------------------------------------------
local function noir_say_hush(brain,user,aa)

	if not brain.room then return end

local num=force_floor(tonumber(aa[3] or "") or 0)

local function saytime()
	local super=""
	if brain.room.hush_super then super="super " end
	local minutes=math.ceil(((brain.room.hush_time or 0)-os.time())/60)
	if minutes>0 then
		noir_say(brain,"I will "..super.."hush for another "..minutes.." minutes.",user)
	else
		noir_say(brain,"I am not "..super.."hushed.",user)
	end
end

	if is_admin(user.name) or is_room_owner(brain.room,user.name) then -- must be room owner
	
		if aa[3] == "super" then
			brain.room.hush_super=true
			saytime()
			return
		elseif aa[3] == "normal" then
			brain.room.hush_super=false
			saytime()
			return
		end
		
	end

	local check=0
	local maxx=username_given_cookies_max(user.name) -- maximum number of cookies to be invested (probably 4k)
		
	if brain.room.hush_time then
		check=( brain.room.hush_time -os.time() )/6 -- number of cookies invested in hush so far
	end
	
	if check<0 then check=0 end
	
	if check+num > maxx then num=force_floor(maxx-check) end -- do not allow hush to go above 4k cookies in total :)
	if num < 0 then num=0 end -- no paying negative cookies
		
	if num>0 and num<=user.cookies then -- pay
	
		user.cookies=user.cookies-num
	
		if not brain.room.hush_time or brain.room.hush_time<os.time() then brain.room.hush_time=os.time() end
		
		brain.room.hush_time=brain.room.hush_time+(num*6) -- 6 secs per cookie
		
		saytime()
		
	else -- about
	
		if ( not brain.room.hush_time or brain.room.hush_time<os.time() ) then
		
			noir_say(brain,"You can pay me to shutup, my rates are 10 cookies per minute. Type "..brain.user.name.." hush 100 to pay 100 cookies and shut me up for 10 minutes.",user)
			
		else
		
			saytime()
			
		end
		
	end

end

for i,v in ipairs{"hush"} do
	noir_triggers[v]=noir_say_hush
end

-----------------------------------------------------------------------------
--
-- pay noir to protect a room
--
-----------------------------------------------------------------------------
local function noir_say_protect(brain,user,aa)

local num=force_floor(tonumber(aa[3] or "") or 0)

local room=user.room

local max_time=username_given_cookies_max(user.name)*100

-- must be in room to abandon it...
--[[
	if aa[4] then -- can pick a room we are not in, for info use something like : noir abandon 0 roomname
	
		local r=get_room(aa[4])
		
		if r then room=r end
		
		
	end
]]

local function saytime()
	local minutes=math.ceil(((room.protect_time or 0)-os.time())/60)
	if minutes<=0 then
		noir_say(brain,room.name.." room is not protected.",user)
	else
		noir_say(brain,"I will protect "..room.name.." room for another "..minutes.." minutes.",user)
	end
end

	if aa[2]=="abandon" then -- undo a protection
	
		if not room.protect_time or room.protect_time<os.time() then
			noir_say(brain,room.name.." room is not protected.",user)
		else
			local cost=force_floor(( room.protect_time-os.time() )/0.6)
			
			if num<0 then num=0 end
			if num>cost then num=cost end

			if num<cost then
			
				if num>0 and num<=user.cookies then

					user.cookies=user.cookies-num
					room.protect_time=room.protect_time-(num*0.6)
					noir_say(brain,"Thanx for the "..num.." cookies, but I need "..(cost-num).." more.",user)
				else
					noir_say(brain,"It will cost "..cost.." cookies to stop me protecting "..room.name.." room. Type "..brain.user.name.." abandon "..cost.." to pay this price ",user)
				end

				
			elseif cost>0 and cost<=user.cookies then -- pay full to undo protection
			
				user.cookies=user.cookies-cost
				
				room.protect_time=nil
				
				noir_say(brain,"Thanx for the "..cost.." cookies, I won't bother protecting "..room.name.." room anymore.",user)
			end
		end
	else

		if num>0 and num<=user.cookies then -- pay
		
			if not room.protect_time or room.protect_time<os.time() then room.protect_time=os.time() end
			
			local sofar=force_floor((room.protect_time-os.time())/0.6) -- spend so far
			
			if (max_time-sofar)<num then num=(max_time-sofar) end -- reduce to 4k cap
			if num<0 then num=0 end -- sanity
			
			user.cookies=user.cookies-num
			
			room.protect_time=room.protect_time+(num*0.6) -- 0.6 secs per cookie
			
			saytime()
			
		else -- about
		
			if not room.protect_time or room.protect_time<os.time() then
			
				noir_say(brain,"You can pay me to protect "..room.name.." room from elder gods and other magicks, my rates are 100 cookies per minute. Type "..brain.user.name.." protect 1000 to pay 1000 cookies and protect "..room.name.." room for 10 minutes.",user)
				
			else
			
				saytime()
				
			end
			
		end
		
	end

end

for i,v in ipairs{"protect","abandon"} do
	noir_triggers[v]=noir_say_protect
end

-----------------------------------------------------------------------------
--
-- set a users color, 
--
-----------------------------------------------------------------------------

function user_get_color_rgb(user)
	if not user then return 255,255,255 end

local color=force_floor(tonumber(user.color or "ffffff",16) or ((256*256*256)-1) )

local rr,gg,bb
			
	rr=force_floor( color/(256*256) )
	gg=force_floor( (color-(rr*256*256))/256 )
	bb=force_floor( color-(rr*256*256)-(gg*256) )
	
	return rr,gg,bb
end

function user_fix_color_limit(user)

if not user or not user.color then return end

local rr,gg,bb=user_get_color_rgb(user)

local mm
	
	if not is_admin(user.name) then
	
		mm=1400-(user_rank(user)*50)	-- higher ranks can set better colors
		if mm<800 then mm=800 end -- but not that much better
		
		local bri=(rr*3+gg*5+bb*2)+1
		
		if bri < mm then -- make brighter
		
			rr=force_floor((rr+1)*mm/bri)-1
			gg=force_floor((gg+1)*mm/bri)-1
			bb=force_floor((bb+1)*mm/bri)-1
		
		end
	
	end
	
	if rr<0 then rr=0 end
	if gg<0 then gg=0 end
	if bb<0 then bb=0 end
	
	if rr>255 then rr=255 end
	if gg>255 then gg=255 end
	if bb>255 then bb=255 end
	
local hash = string.format("%02x%02x%02x",rr,gg,bb)


	user.color=hash

end

local function noir_say_color(brain,user,aa)

	if not aa[3] then
		usercast(user,join_room_build_msg(user.name))
		noir_say(brain,"You need to request a color, eg for red type "..brain.user.name.." color ff0000",user)		
		return
	end

local color=force_floor(tonumber(aa[3] or 0,16) or 0)
local cost=force_floor(tonumber(aa[4] or -1) or -1)

local rr,gg,bb,mm
			
	rr=force_floor( color/(256*256) )
	gg=force_floor( (color-(rr*256*256))/256 )
	bb=force_floor( color-(rr*256*256)-(gg*256) )
	
	if not is_admin(user.name) then
	
		mm=1400-(user_rank(user)*50)	-- higher ranks can set better colors
		if mm<800 then mm=800 end -- but not that much better
		
		local bri=(rr*3+gg*5+bb*2)+1
		
		if bri < mm then -- make brighter
		
			rr=force_floor((rr+1)*mm/bri)-1
			gg=force_floor((gg+1)*mm/bri)-1
			bb=force_floor((bb+1)*mm/bri)-1
		
		end
	
	end
	
	
	if rr<0 then rr=0 end
	if gg<0 then gg=0 end
	if bb<0 then bb=0 end
	
	if rr>255 then rr=255 end
	if gg>255 then gg=255 end
	if bb>255 then bb=255 end
	
local need = force_floor( 500*( (1+3*((256-rr)/128)) * (1+5*((256-gg)/128)) * (1+2*((256-bb)/128)) ) )
local hash = string.format("%02x%02x%02x",rr,gg,bb)

	if need==cost then -- confirmed
	
		if user.cookies<need  and not is_admin(user.name) then -- need more cookies
		
			noir_say(brain,"Sorry but you can not afford to change your chat color to #"..hash,user)
		
		else
		
			if not is_admin(user.name) then
			
				user.cookies=user.cookies-need
				
			end
			
			user.color=hash
			
			user_save_data(user)
	
			noir_say(brain,"Changing your chat color to #"..hash,user)
						
			roomcast(user.room,join_room_build_msg(user.name))
		end
	
	else
	
	local saved

-- allow preview of color	
		saved=user.color
		
		user.color=hash
		usercast(user,join_room_build_msg(user.name))
		user.color=saved
--		userqueue(user,join_room_build_msg(user.name))

		noir_say(brain,"Testing color #"..hash.." this color will cost "..need.." cookies. To apply this color type "..brain.user.name.." color "..hash.." "..need,user)
		
	end
		
end
	
for i,v in ipairs{"color","colour"} do
	noir_triggers[v]=noir_say_color
end


-----------------------------------------------------------------------------
--
--
-----------------------------------------------------------------------------
function noir_say_vest(brain,user,aa)

	local given_max=username_given_cookies_max(user.name)
	local given=day_flag_get(user.name,"vest_cookies") or 0
		
local function report()

	local given=day_flag_get(user.name,"vest_cookies") or 0
	
	local c=force_floor(vest_convert(user.vest , user.vestid , "EUR" ))
	local s=vest_name_tld(user.vestid)
	
	local d=c-user.vestin
	
	if d==0 then -- nochange
	
		noir_say(brain,user.name.." is keeping "..c.." cookies ("..given.." today) in "..(user.vest/100000).." "..user.vestid.." ("..s..")")
		
	elseif d>0 then -- gain
	
		noir_say(brain,user.name.." has gained "..d.." cookies investing.  Keeping "..c.." cookies ("..given.." today) in "..(user.vest/100000).." "..user.vestid.." ("..s..") ")
	
	else --loss
		
		noir_say(brain,user.name.." has lost "..(-d).." cookies investing.  Keeping "..c.." cookies ("..given.." today) in "..(user.vest/100000).." "..user.vestid.." ("..s..")")
		
	end
	
end

	user.vest=user.vest or 0
	user.vestid=user.vestid or "GBP"
	
local num=force_floor(tonumber(aa[3] or "") or 0)
local newtld=vest_valid_tld( aa[3] or "" )

	user.vestin=user.vestin or force_floor(vest_convert(user.vest , user.vestid , "EUR" ))

	if num>0 then -- invest more cookies in the current currency


		
		if given+num>given_max then -- limit daily amount
		
			num=given_max-given
			
			if num<=0 then -- can give no more today
				noir_say(brain,"sorry but you can only invest up to "..given_max.." cookies a day")
				return
			end
		end
		
		if not is_admin(user.name) then
			if user.cookies<num then
				noir_say(brain,"sorry but you do not have enough cookies")
				return		
			end
			user.cookies=user.cookies-num
		end
		
		day_flag_set(user.name,"vest_cookies",given+num)
		
		user.vest = force_floor( user.vest + vest_convert(num , "EUR" , user.vestid ) )
		user.vestin = user.vestin + num -- amount invested in total
		
		user_save_data(user)
		
		roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has given "..brain.user.name.." "..num.." cookies"})
		
		report()
	
	elseif newtld then -- convert to a new currency
		
		if newtld ~= user.vestid then
			
			if (vest_rate_tld(user.vestid) > 0) and (vest_rate_tld(newtld) > 0) then -- sanity
			
				noir_say(brain,"Converting your investment from "..user.vestid.." to "..newtld)
				
				user.vest = force_floor( vest_convert( user.vest , user.vestid , newtld) )
				user.vestid=newtld
			end
			
		end
		
		report()
	
	elseif aa[3] then -- give help
	
		noir_say(brain,"Type "..brain.user.name.." invest number to invest more cookies or "..brain.user.name.." invest TLD to change your investment currency. Available currencies are "..vest_available_tlds() )
			
	else -- just report curretn investment
	
		report()
	
	end

	
end

for i,v in ipairs{"vest","invest"} do
	noir_triggers[v]=noir_say_vest
end



-----------------------------------------------------------------------------
--
--
-----------------------------------------------------------------------------
function noir_say_swears(brain,user,aa)
	
local function report()

	local tab={}

	local badwords=brain.user.room.badwords or data.badwords
	
	for i,v in pairs(badwords) do
	
		table.insert(tab,v)
	
	end
	
	noir_say(brain,"I will punish you if you say...",user)
	userqueue(user,{cmd="note",note="notice",arg1=str_join_english_list(tab) or "nothing" })

end

local function check_room_badwords_exists()
	if not brain.user.room.badwords then
		brain.user.room.badwords={}
		for i,v in pairs(data.badwords) do
			table.insert( brain.user.room.badwords , v )
		end
	end
	return brain.user.room.badwords
end


	if aa[3]=="add" and aa[4]  then -- add this word

		if is_admin(user.name) or is_room_owner(user.room,user.name) then
			local badwords=check_room_badwords_exists()
			
			local found=false
			for i,v in ipairs(badwords) do
			
				if v==aa[4] then
				
					found=true
					break
				end
			
			end
			if not found then table.insert(badwords,aa[4]) end
		end
		
		report()
		
	elseif aa[3]=="remove" and aa[4] then -- add this word

		if is_admin(user.name) or is_room_owner(user.room,user.name) then
			local badwords=check_room_badwords_exists()
			
			for i,v in ipairs(badwords) do
			
				if v==aa[4] then
				
					table.remove(badwords,i)
					break
				end
			
			end
		end
		
		report()
		
	elseif aa[3]=="clear" then -- add this word

		if is_admin(user.name) or is_room_owner(user.room,user.name) then
			brain.user.room.badwords={}
		end
		
		report()
		
	elseif aa[3] then -- toggle this word
	
		if is_admin(user.name) or is_room_owner(user.room,user.name) then
			local badwords=check_room_badwords_exists()
			
			local found=false
			for i,v in ipairs(badwords) do
			
				if v==aa[3] then
				
					table.remove(badwords,i)
					found=true
					break
				end
			
			end
			if not found then table.insert(badwords,aa[3]) end
		end
		
		report()
		
	else -- just report
	
		report()
	
	end
	
end

for i,v in ipairs{"swear","swears"} do
	noir_triggers[v]=noir_say_swears
end

-----------------------------------------------------------------------------
--
--
-----------------------------------------------------------------------------
function noir_say_title(brain,user,aa)
	
local num=tonumber(aa[3] or -1) or -1

local custom
if user and user.fud and user.fud.custom_status and user.fud.custom_status~="NULL" and user.fud.custom_status~="" then
	custom=user.fud.custom_status
end

if not user.fud then
	return
end


local function report()

	local tab={}
	
	if custom then
		table.insert(tab,"(0) "..custom)
	end
	

	for i,b in pairs(user.feats or {}) do
	
		local f=feats_info(tonumber(i))
		
		table.insert(tab,"("..f.id..") "..f.title)
	
	end
	
	local ts=data.clan_rank_names[ user.form or "man" ]
	local tr=user_rank(user)
	
	for i=2,tr do
		if ts[i] then
			table.insert(tab,"(-"..i..") "..ts[i])
		end
	end
	
	
	
	noir_say(brain,user.name.." has "..(#tab).." titles available.",user)
	userqueue(user,{cmd="note",note="notice",arg1=str_join_english_list(tab)})

end

--	report()



	if num==0 and custom then
	
		user.title=custom
		user.titleid=0
	
		user_save_data(user)

		noir_say(brain,user.name.." is now known as "..user.title)
		
	elseif num<-1 then 
	
	local ts=data.clan_rank_names[ user.form or "man" ]
	local tr=user_rank(user)
		
		num=-num
		
		if num<=tr then
		
			if not ts[num] then num=2 end
			
			user.title=ts[num]
			user.titleid=-num
		
			user_save_data(user)

			noir_say(brain,user.name.." is now known as "..user.title)
		
		else
		
			report()
		
		end
	
	elseif user.feats and user.feats[num] then -- set to this title

		local f=feats_info(num)
		
		user.title=f.title
		user.titleid=f.id
	
		user_save_data(user)

		noir_say(brain,user.name.." is now known as "..user.title)
	
	else -- just report
	
		report()
	
	end
	
end

for i,v in ipairs{"title","titles"} do
	noir_triggers[v]=noir_say_title
end


-----------------------------------------------------------------------------
--
-- lock or unlock room
--
-----------------------------------------------------------------------------
local function noir_say_lock(brain,user,aa)

local lock=aa[3] or ""

local room=user.room
	
	if aa[2]=="lock" and lock=="" then 
	
		noir_link(brain,"LOCK is "..string.upper(room.locked or "OPEN").." : Please click here to RTFM about room locks.","http://help.wetgenes.com/-/Main/RoomLock",user)
		
		lock="all"
		
	end
	
-- noir lock defaults to locking all and noir unlock defaults to unlocking

	if not is_room_owner(room,user.name) then return end -- must be room owner
	
	if lock=="all" then
	
		room.locked="all"
		noir_say(brain,"Room has been locked to everyone.",user)
	
	elseif lock=="wolf" then
	
		room.locked="wolf"
		noir_say(brain,"Room has been locked to everyone that isn't a wolf.",user)
	
	elseif lock=="zom" then
	
		room.locked="zom"
		noir_say(brain,"Room has been locked to everyone that isn't a zombie.",user)
	
	elseif lock=="vamp" then
	
		room.locked="vamp"
		noir_say(brain,"Room has been locked to everyone that isn't a vampire.",user)
	
	elseif lock=="man" then
	
		room.locked="man"
		noir_say(brain,"Room has been locked to everyone that isn't a human.",user)
	
	elseif lock=="chav" then
	
		room.locked="chav"
		noir_say(brain,"Room has been locked to everyone that isn't a chav.",user)
		
	elseif lock=="guest" or lock=="guests" then
	
		room.locked="guests"
		noir_say(brain,"Room has been locked to everyone apart from guests.",user)
		
	elseif lock=="vip" then
	
		room.locked="vip"
		noir_say(brain,"Room has been locked to guests.",user)
		
	elseif lock=="rank5" then
	
		room.locked="rank5"
		noir_say(brain,"Room has been locked to everyone below rank5.",user)
		
	elseif lock=="rank10" then
	
		room.locked="rank10"
		noir_say(brain,"Room has been locked to everyone below rank10.",user)
		
	elseif lock=="nochav" then
	
		room.locked="nochav"
		noir_say(brain,"Room has been locked to tea leafs, your cookies are safer.",user)
		
	else
	
		if aa[2]=="lock" then
		
			noir_link(brain,"LOCK is "..string.upper(room.locked or "OPEN").." : Please click here to RTFM about room locks.","http://help.wetgenes.com/-/Main/RoomLock",user)
		
		else
		
			room.locked=nil	
			noir_say(brain,"Room has been unlocked.",user)
		
		end
		
	end

end

for i,v in ipairs{"lock","unlock"} do
	noir_triggers[v]=noir_say_lock
end


-----------------------------------------------------------------------------
--
-- fag control
--
-----------------------------------------------------------------------------
local function noir_say_fag(brain,user,aa)

	if not is_admin(user.name) then return end -- must be admin
	
local n=aa[3] or ""
local count=tonumber(aa[4] or "0") or 0
	
	if n=="" then  -- need a user
	
		local tab={}
		
		for n,b in pairs(data.fag_names) do
			table.insert(tab,n)
		end
		
		if tab[1] then
			noir_say(brain,string.sub(str_join_english_list(tab),1,256).." "..((tab[2] and "are") or "is").." fag.",user)
		else
			noir_say(brain,"I see no fags.",user)
		end
		
		return
	
	end
	
	if aa[2]=="fag" then -- make them fag
	
		local tab=get_shared_names_by_ip(n) -- hit all people of the same ip
		if not tab then tab={n} end
		if count==1 then tab={n} end -- just change this one user
		for i,v in ipairs(tab) do
		
			data.fag_names[ string.lower(v) ]=true
			
		end
	
		noir_say(brain,string.sub(str_join_english_list(tab),1,256).." "..((tab[2] and "are") or "is").." fag.",user)
			
			
	else -- release them if we must
		
		if n=="*" then data.fag_names={} end -- quick unfag
		
		local tab=get_shared_names_by_ip(n) -- hit all people of the same ip
		if not tab then tab={n} end
		if count==1 then tab={n} end -- just change this one user
		for i,v in ipairs(tab) do
		
			data.fag_names[ string.lower(v) ]=nil
			
		end
		
		noir_say(brain,string.sub(str_join_english_list(tab),1,256).." "..((tab[2] and "are") or "is").." not fag.",user)
		
	end

end

for i,v in ipairs{"fag","notfag"} do
	noir_triggers[v]=noir_say_fag
end

-----------------------------------------------------------------------------
--
-- lock or unlock room
--
-----------------------------------------------------------------------------
local function noir_say_dum(brain,user,aa)

	if not is_admin(user.name) then return end -- must be admin
	
local n=aa[3] or ""
local count=tonumber(aa[4] or "0") or 0
	
	if n=="" then  -- need a user
	
		local tab={}
		
		for n,b in pairs(data.dum_names) do
			table.insert(tab,n)
		end
		
		if tab[1] then
			noir_say(brain,string.sub(str_join_english_list(tab),1,256).." "..((tab[2] and "are") or "is").." dum.",user)
		else
			noir_say(brain,"I see no dumdums.",user)
		end
		
		return
	
	end
	
	if aa[2]=="dum" then -- make them dum
	
		local tab=get_shared_names_by_ip(n) -- hit all people of the same ip
		if not tab then tab={n} end
		if count==1 then tab={n} end -- just change this one user
		for i,v in ipairs(tab) do
		
			data.dum_names[ string.lower(v) ]=true
			
		end
	
		noir_say(brain,string.sub(str_join_english_list(tab),1,256).." "..((tab[2] and "are") or "is").." dum.",user)
			
			
	else -- release them if we must
		
		if n=="*" then data.dum_names={} end -- quick undum
		
		local tab=get_shared_names_by_ip(n) -- hit all people of the same ip
		if not tab then tab={n} end
		if count==1 then tab={n} end -- just change this one user
		for i,v in ipairs(tab) do
		
			data.dum_names[ string.lower(v) ]=nil
			
		end
		
		noir_say(brain,string.sub(str_join_english_list(tab),1,256).." "..((tab[2] and "are") or "is").." not dum.",user)
		
	end
	
-- noir lock defaults to locking all and noir unlock defaults to unlocking


end

for i,v in ipairs{"dum","notdum"} do
	noir_triggers[v]=noir_say_dum
end
-----------------------------------------------------------------------------
--
-- set or list current muds
--
-----------------------------------------------------------------------------
local function noir_say_mud(brain,user,aa)

	if not is_admin(user.name) then return end -- must be admin
	
local n=aa[3]

local mudtype="mud_names"
local smud=" mudded"

	if aa[2]=="hardmud" or aa[2]=="nothardmud" or aa[2]=="cake" or aa[2]=="notcake" then
		mudtype="hardmud_names"
		smud=" caked"
	end
	
	if n then
		if aa[2]=="mud" or aa[2]=="hardmud" or aa[2]=="cake" then -- make them mud

	
			local tab=get_shared_names_by_ip(n) -- hit all people of the same ip
			if not tab then tab={n} end
			if count==1 then tab={n} end -- just change this one user
			for i,v in ipairs(tab) do
		
				data[mudtype][ string.lower(v) ]=true
			
			end			
			
		elseif aa[2]=="notmud" or aa[2]=="nothardmud"  or aa[2]=="notcake" then -- release them if we must
		
			if n=="*" then data[mudtype]={} end -- quick unmud of everyone
		
			local tab=get_shared_names_by_ip(n) -- hit all people of the same ip
			if not tab then tab={n} end
			if count==1 then tab={n} end -- just change this one user
			for i,v in ipairs(tab) do
		
				data[mudtype][ string.lower(v) ]=nil
			
			end
		
		end
	end

	local tab={}
	local gotmud
	for n,b in pairs(data[mudtype]) do
		if n~="" then
			if type(b)~="number" then b=10 end -- default number
			tab[b]=tab[b] or {}
			table.insert(tab[b],n)
			gotmud=true
		end
	end
	
	
	if gotmud then
		for i=10,1,-1 do
			if tab[i] then
				noir_say(brain,string.sub(str_join_english_list(tab[i]),1,2048).." "..((tab[i][2] and "are") or "is")..smud..i,user)
			end
		end
	else
		noir_say(brain,"everyone is clean.",user)
	end

end

for i,v in ipairs{"mud","notmud","hardmud","nothardmud","cake","notcake"} do
	noir_triggers[v]=noir_say_mud
end
-----------------------------------------------------------------------------
--
-- lock or unlock room
--
-----------------------------------------------------------------------------
local function noir_say_allow(brain,user,aa)

local act=string.lower(aa[2] or "allow")
local who=aa[3] or ""
	who=string.gsub(who, "[^0-9a-zA-Z%-_]+", "" )
	who=string.lower(who)
	
-- noir lock defaults to locking all and noir unlock defaults to unlocking

local room=user.room

	if not ( is_room_owner(room,user.name) or is_god(user.name) ) then return end -- must be room owner
	
	if not room.allow then room.allow={} end
	if not room.deny then room.deny={} end
	
	if who~="" then
	
		if act=="allow" then
		
			room.deny[who]=nil
			room.allow[who]=true
			noir_say(brain,who.." has been allowed access to this room when it is locked.",user)
			
		else --deny
		
			room.allow[who]=nil
			room.deny[who]=true
			noir_say(brain,who.." has been denied access to this room even when it is open.",user)
			
		end
		
	else
	
		if act=="allowclear" then
		
			room.allow={}
			noir_say(brain,"The allow list has been cleared.",user)
			
		elseif act=="denyclear" then
		
			room.deny={}
			noir_say(brain,"The deny list has been cleared.",user)
			
		end
		
	end
	

	if act=="allow" then
		local tab={}
		for v,b in pairs(room.allow) do
			table.insert(tab,v)
		end
		
		if tab[1] then
			noir_say(brain,string.sub(str_join_english_list(tab),1,256).." "..((tab[2] and "are") or "is").." on the ALLOW list.",user)
		else
			noir_say(brain,"The ALLOW list is empty.",user)
		end
	end
	
	if act=="deny" then
		local tab={}
		for v,b in pairs(room.deny) do
			table.insert(tab,v)
		end
		
		if tab[1] then
			noir_say(brain,string.sub(str_join_english_list(tab),1,256).." "..((tab[2] and "are") or "is").." on the DENY list.",user)
		else
			noir_say(brain,"The DENY list is empty.",user)
		end
	end
end

for i,v in ipairs{"allow","deny","allowclear","denyclear"} do
	noir_triggers[v]=noir_say_allow
end


-----------------------------------------------------------------------------
--
-- pay noir to hush
--
-----------------------------------------------------------------------------
local function noir_say_retain(brain,user,aa)

local num=force_floor(tonumber(aa[3] or "") or 0)

local room=get_room(user.name)
local max_time=username_given_cookies_max(user.name)

local pub_names={["emo"]=true,["pool"]=true,["inuyasha"]=true,["gaybar"]=true,["butterfly"]=true,["revoltion"]=true,["iceberg"]=true,["pants"]=true}

local private_names={["tv"]=true,["zeegrind"]=true,["pokr"]=true}

local pub_room=string.lower(aa[4] or "")
local private_room=string.lower(aa[4] or "")

-- pub_name must be allowed here first

	if not pub_names[pub_room] then pub_room=nil end
	
	if not private_names[private_room] then private_room=nil end

	
local function saytime()	

	if room then
	
		local minutes=math.ceil((room.retain_noir-os.time())/60)
		noir_say(brain,"I have been paid to look after room "..room.name.." for another "..minutes.." minutes.",user)
	
	end

end
	
	if brain.user.room.retain_noir and brain.user.room.retain_noir>os.time() then -- we are a retained bot so any retaining pertains to this room
	
		room=brain.user.room
		
		if is_room_owner(room,user.name) then -- room owner may fire this bot
		
			if aa[3] == "defenestrate" then -- if they wish to
			
				room.retain_noir=os.time()
				return
			end
		
		end
	
	end
	
	if private_room then -- building a private room
	
		room=get_room(string.lower(user.name).."."..private_room)

		if not room then -- this private room needs to be made
		
			room=new_room{	name=string.lower(user.name).."."..private_room , locked="nochav" }
			room.needs_brain_to_exist=true -- this room to die without a bot in it
			room.owners[1]=string.lower(user.name)
			
			local gtab=data.gametypes[private_room]
			
			if gtab and gtab.add_to_room then
			
				gtab.add_to_room(room)
				
			end

			
		end
		
	elseif pub_room then -- building a public room
	
		room=get_room("public."..pub_room)

		if not room then -- this public room needs to be made
		
			room=new_room{	name="public."..pub_room }
			room.needs_brain_to_exist=true -- this room to die without a bot in it
			
		end
		
	end

	if not room then -- the users home room needs to be made
	
		room=new_room{	name=string.lower(user.name) }
		room.owners[1]=string.lower(user.name)
		
	end
			
	if room.brain and room.brain~=brain then
		noir_say(brain, room.name.." already has a bot, you should talk to them.",user)
		return
	end
		
	local minutes=math.ceil( ( (room.retain_noir or 0) - os.time() )/60 ) -- only let them retain for a maximum number, 4000 probably
	if minutes < 0 then minutes=0 end
	
	if minutes + num > max_time then -- cap max time
	
		num = max_time - minutes
		
		if num < 0 then num=0 end
		
		if num==0 then
		
			noir_say(brain, "You can only retain room "..room.name.." for a maximum of "..max_time.." minutes.",user)
			return
		
		end
	
	end
		
	if num>0 and num<=user.cookies then -- pay
			
		if room.brain==nil then -- create a bot
		
			room.retain_noir=os.time()
			room.retain_noir_name=brain.user.name
			
			local u=new_user{name=room.retain_noir_name}
			new_brain["noir"]{ user=u , room=room.name }
			u.room.brain=u.brain
	
		end
		
		user.cookies=user.cookies-num
		
		room.retain_noir=( tonumber(room.retain_noir) or os.time() )+(num*60) -- 60 secs per cookie
		
		saytime()
		
		local vroom=data.ville and data.ville.rooms and data.ville.rooms[room.name] -- check the virtual bots
		if vroom then
			vroom_check_bots(vroom)
		end
		
	else -- about
	
		if not room.retain_noir or room.retain_noir<os.time() then
		
			noir_say(brain,"You can pay me to look after your room, my rates are 1 cookie per minute. Type "..brain.user.name.." retain 60 to pay 60 cookies and retain me in room "..room.name.." for 60 minutes.",user)
			
		else
		
			saytime()
			
		end
		
	end

end

for i,v in ipairs{"retain"} do
	noir_triggers[v]=noir_say_retain
end

			
			
-----------------------------------------------------------------------------
--
-- found a clue
--
-----------------------------------------------------------------------------
local function noir_found_clue(brain,msg,user)

local ip=user_ip(user)
local cap=day_flag_get(ip,"clue_cookies") or 0

	if cap>=100 then -- hit limit of cookies you can win this way per day...
		noir_act(brain,"ignores "..user.name,user)
		return
	end
	day_flag_set(ip,"clue_cookies",cap+1)

	user.cookies=user.cookies or 0
	user.cookies=user.cookies+1

	noir_say(brain,"Congratulations "..user.name.." I was thinking of "..brain.clues.word ,user)
	noir_act(brain,"Gives "..user.name.." a cookie ("..user.name.." now has "..user.cookies..")" ,user)
	
	brain.clues.words={}
	brain.clues.word=""
	brain.clues.wordtype=""
	brain.clues.time=os.time()+2
end

-----------------------------------------------------------------------------
--
-- setup a clue (just repeats last clue if its too soon)
--
-----------------------------------------------------------------------------
local function noir_setup_clue(brain)

	if brain.room and ( brain.room.hush_time and brain.room.hush_time>=os.time() ) then return end

	if ( not brain.clues ) or ( brain.clues.time<os.time() ) then
	
		brain.clues={}
		brain.clues.time=os.time()+(5*60)
		
		if math.random(100)<=75 then -- word scramble
		
			brain.clues.word=data.words.nouns[math.random(#data.words.nouns)]
			brain.clues.words=str_split(" ",string.lower(brain.clues.word))
			
			local base=brain.clues.word
			local scramble=""
			local t={}
			
			for i=1,string.len(base) do
				t[i]=string.sub(base,i,i)
			end
			
			while t[1] do
				scramble=scramble..table.remove(t,math.random(#t))
			end
			scramble=string.upper(scramble)
			
			brain.clues.wordtype="word that can be made from the letters "..scramble
			
			
		else
			brain.clues.wordtype=wordclues_idx[math.random(wordclues_max)]
			
			local wordtab=wordclues[brain.clues.wordtype]
			
			brain.clues.word=wordtab[math.random(#wordtab)]
			
			brain.clues.words=str_split(" ",string.lower(brain.clues.word))
		end
	end
	
	if brain.clues.wordtype~="" then
		noir_say(brain,"I am thinking of a "..brain.clues.wordtype.." guess it and win a cookie!",user)
	end
end

for i,v in ipairs{"clue"} do
	noir_triggers[v]=noir_setup_clue
end


-----------------------------------------------------------------------------
--
-- display hints
--
-----------------------------------------------------------------------------
local function noir_hint_game(brain,gnam)

local game=gamehints[gnam]

	if not game then return end
	
	if not game.index then game.index=1 end
	if not game.time then game.time=0 end

	if game.time < os.time()-60*5 then -- forget place after five minutes
		game.index=1
	else
		game.index=game.index+1
	end
	
	if not game[game.index] then game.index=1 end -- restart hint list
	
	game.time=os.time()
	
	noir_say(brain,game[game.index],user)
	
end


-----------------------------------------------------------------------------
--
-- update to be called whenever we get a chance, hopefully at least once every 100ms
--
-----------------------------------------------------------------------------
local function brain_update(brain)

	if brain.updatetime and brain.updatetime+1>os.time() then return end -- pulse
	brain.updatetime=os.time()
--dbg((brain.user and brain.user.name or "*").." : "..(brain.user and brain.user.room and brain.user.room.name or "*").." : "..brain.updatetime.."\n")

	if brain.user and brain.user.room and brain.user.room.game then game_room_brain_update(brain.user.room.game,brain) end

	if brain.user and brain.user.room and brain.user.room.retain_noir then -- we are a retainer bot, so we leave when the time is up

		if brain.user.room.retain_noir<os.time() then -- time up

			local room=brain.user.room
			
			brain.user.room.retain_noir=nil
		
--			brain:delete() -- delete noir, i hope this works :)
			
			
			if room.needs_brain_to_exist then -- kill the room when the bot is gone
			
--				del_room(room)
			
			end

		end
	
	end

end




-----------------------------------------------------------------------------
--
-- warn user not to swear, 
--
-----------------------------------------------------------------------------
function noir_card_user(brain,msg,swear)

local user=get_user(msg.frm)
	
	if user then
	
		if not user.swear then
			user.swear={count=0,time=0}
		end
		
		if user.swear.time < os.time()-60*5 then -- forget count after five minutes
			user.swear={count=0,time=0}
		end
		
		if user.swear.count==0 then
		
			if is_fag(user.name) then
			
				data.mud_names[string.lower(user.name)]=10

				set_status(nil,"ban",msg.frm,os.time()+(60*60*24))
				
				join_room_str(user,"swearbox")
				
				return {cmd="act",frm=brain.user.name,txt="escorts "..msg.frm.." into the swearbox for the next 24 hours"}
			else
		
				user.swear.count=1
				user.swear.time=os.time()
			
				return {cmd="act",frm=brain.user.name,txt="shows "..msg.frm.." a yellow card"}
			end
			
		elseif user.swear.count==1 then
		
			user.swear.count=2
			user.swear.time=os.time()
			
--			if not data.admin_names[string.lower(msg.frm)] then -- no kick
--				join_room_str(user,"swearbox")
--			end
			
			return {cmd="act",frm=brain.user.name,txt="shows "..msg.frm.." a red card"}
			
		else
		
			user.swear=nil
			
			if data.admin_names[string.lower(msg.frm)] then -- no kick
			
			return {cmd="act",frm=brain.user.name,txt="shows "..msg.frm.." a rainbow card"}
				
			else
			
				set_status(nil,"ban",msg.frm,os.time()+(60*15))
				
				join_room_str(user,"swearbox")
				
				return {cmd="act",frm=brain.user.name,txt="escorts "..msg.frm.." into the swearbox for the next 15 minutes"}
			
			end
			
		end

	end

end


-----------------------------------------------------------------------------
--
-- incoming msgs, ie things that have been broadcast in the room the brain is in
--
-----------------------------------------------------------------------------
local function brain_msg(brain,msg,user)

local newmsg
local mud=false

	local say=generic_bot_cmds(brain,msg,user)
	if say then
	
		noir_msg(brain,say)
		return
	end
	
-- if your name is mud then the noir bots do not respond to you, but still check da swears mkay

	if user and is_mud(user.name) and not is_room_admin(user,user.room) then
		mud=true -- flag mud but keep going
	end
	

	if msg.cmd=="say" or msg.cmd=="act" then -- respond to talking
	
		if (not brain.user) or ( msg.frm==brain.user.name ) or ( msg.frm=="*" )  then return end -- ignore talking to self and notifications
		
		local s=string.lower(msg.frm) .. " " .. string.lower(msg.txt) -- add user name to msg for this test
		
		if not mud and ( not brain.room.hush_time or brain.room.hush_time<os.time() ) and user then
		
			if brain.clues then -- check word clues
			
				if brain.clues.time<os.time() then
					noir_setup_clue(brain)
				end
			
				for i,v in ipairs(brain.clues.words) do
				
					if not common_words[v] then -- ignore common words in the answer
					
						local d, e = string.find(s,v)
						
						if d then -- found word clue
						
							noir_found_clue(brain,msg,user)
							return

						end
						
					end					
				end
			
			else
					noir_setup_clue(brain)
			end
		
		end
		
		-- super hush turns off the bots swear filter
		if not ( brain.room and brain.room.hush_super and brain.room.hush_time and brain.room.hush_time>=os.time() ) then
		
			local swear=is_swear(s,brain.user.room.badwords)
			if swear then
				if not user or not is_room_owner(brain.user.room,user.name) then -- room owner is never carded
					noir_msg(brain,noir_card_user(brain,msg,swear))
					if not user or not is_god(user.name) then -- fine, but do as i say...
						return
					end
				end
			end
			
		end
		
		if msg.cmd=="say" and msg.txt and msg.txt~="" then -- comands must be said, no more acts
		
			if brain.msghook then -- special state hook
				brain.msghook(brain,msg,user)
			end

			local aa=str_split(" ",string.lower(msg.txt))

			if aa[1]==brain.user.name then -- handle special commands when we are being addressed
			
				local f=noir_triggers[ aa[2] ]

				if mud then
					if aa[2] == "retain" then -- muds may retain
					else
						f=nil -- do nothing
					end
				end
				
				if f then return f(brain,user,aa,msg) end
				
-- talk to a website about this command if the room has it setup
	
				if not mud and  brain.room.brainhook then
					local task={}
					task.co=coroutine.create(function()
					
						local hook="http://wet.appspot.com/spew/test.frame"
						local t="&frm="..url_encode_harsh(msg.frm).."&txt="..url_encode_harsh(msg.txt).."&"
						local ret=lanes_url_user(brain.room.brainhook.."?"..t)
						local s=ret.body
						if s then
							local r=str_to_msg(s)
							s=r.txt
							s=string.gsub(s, "[%c]+", "" ) -- remove controls
							s=s:sub(1,1024) -- limit length
							if #s>0 then
								if r.cmd=="act" then -- allow actions
									noir_act(brain,s,user)
								else
									noir_say(brain,s,user)
								end
							end
						else
							noir_say(brain,"brainhook removed due to error",user)
							brain.room.brainhook=nil
						end
						
						remove_update(task)
					end)
					task.update=function() coroutine.resume(task.co) end
					queue_update(task) -- queue this new task for a response
				end
			elseif not mud and aa[1]=="time" and (not aa[2]) then -- let time on its own still work on its own
			
				return noir_say_time(brain,user,aa,msg)

			end
			
		end
		
-- respond with a challenge every 100 chats

		if ( not brain.room.hush_time or brain.room.hush_time<os.time() ) then

			brain.chat_count=(brain.chat_count or 0)+1
		
			if brain.chat_count>100 then
			
				brain.chat_count=0
				noir_say_challenge(brain)
				return
			end
			
		end
		
	end

end

-----------------------------------------------------------------------------
--
-- delete this brains user and whtever
--
-----------------------------------------------------------------------------
local function del_brain(brain)

	if brain then
	
		if brain.user then
		
			data.brains[brain.user]=nil
			
			brain.user.room.brain=nil
			
			brain.user.brain=nil
			del_user(brain.user)
			brain.user=nil
		end
	
		remove_update(brain)
	end
	
end

-----------------------------------------------------------------------------
--
-- create a new brain which exposes the local functions from above
--
-----------------------------------------------------------------------------
new_brain.noir = function(opts)
local brain={}

	brain.name="noir"

	brain.user=opts.user
	brain.user.brain=brain
	data.brains[brain.user]=brain
	
	brain.msg=brain_msg
	brain.update=brain_update
	brain.delete=del_brain
	
	
	if opts.room then
	local room=get_room(opts.room)
		if room then
			join_room(brain.user,room)
		end
	end
	
	queue_update(brain) -- this brain always wants updates

	return brain
end



