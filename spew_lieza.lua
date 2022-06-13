

  -- randomly selected replies if no keywords
  local randReplies = {
    "really?",
	"you seem unsure...",
	"yea, whatever.",
	"what are you on about?",
	"are you high?",
	"ok, sure",
    "i see...",
	"uh huh...",
	"i don't think i quite get what you mean",
	"maybe if you rephrased that...",
	"i wish i knew what you really meant to say",
	"mhmm...",
	"i think i hear the phone ringing",
	"i think there's someone at the door",
	"righto, brb!",
	"lol",
	"i don't think i agree with what you just said",
	"are you sure about that?",
	"i'm bored",
	"i see stupid people",
	"stop touching me!",
	"maybe the truth is out there",
	"i am the gatekeeper. are you the keymaster?",
	"ia! ia! cthulhu f'tagn!",
	"are you sure about that?",
	"boy, you sure go on alot don't you?",
	"ever thought about making yourself useful, i don't know, at least once in your lifetime?",
	"what do you do for fun?",
	"so?",
	"and?",
	"did you hear that?",
	"one of these days, i'm going to be a real girl",
	"hush! i'm talking!",
	"oh well",
	"oh sheesh!",
	"OMFG!",
	"and then what happened?",
	"noone remembers my birthday",
	"i'm stuck in limbo forever. will you keep me company?",
	"i'm lonely",
	"i'm sad",
	"i'm slightly perturbed by what you said.",
    "i'm not sure i understand you fully.",
    "can you elaborate on that?",
    "that is quite interesting!",
    "that's so... please continue...",
    "i understand...",
    "well, well... do go on",
    "why are you saying that?",
    "please explain the background to that remark...",
    "could you say that again, in a different way?",
  }


  -- keywords, replies
  local replies = {
    [" can you "] = "perhaps you would like to be able to",
	[" what is this "] = "this is a chatbox equipped with a game. or a game equipped with a chatbox. we are unsure.",
	[" who are you "] = "my name is lieza. i will be keeping you company if you decide to stay in limbo.",
	[" who are you "] = "my name is lieza. i will be keeping you company if you decide to stay in limbo.",
	[" who r u "] = "my name is lieza. i will be keeping you company if you decide to stay in limbo.",
	[" where am i "] = "you are in limbo. you will be stuck here with me until you decide to log in.",
	[" i don t know "] = "well, if you don't, what makes you think i do?",
	[" i don t know "] = "well, if you don't, what makes you think i do?",
	[" idk "] = "well, if you don't, what makes you think i do?",
	[" idk "] = "well, if you don't, what makes you think i do?",
	[" i dont know "] = "well, if you don't, what makes you think i do?",
	[" i dont know "] = "well, if you don't, what makes you think i do?",
	[" limbo "] = "i fear only you can answer that.",
	[" asl "] = "just so you know, i do not condone virtual dating, cybersex or memes.",
	[" a/s/l "] = "let's just say, i'm not interested.",
	[" whore "] = "i think that is a respectable profession.",
	[" slut "] = "i think that can be arranged, yes.",
	[" asshole "] = "are you gay too?",
	[" gay "] = "yes, i fear you have caught me in a very joyous mood and i would like to share this rainbow with you.",
	[" gey "] = "yes, i fear you have caught me in a very joyous mood and i would like to share this rainbow with you.",
	[" lesbian "] = "i would like a bucket of soapy lesbians for my birthday.",
	[" eat me "] = "i prefer donuts.",
    [" do you "] = "yes, i",
	[" baby "] = "oooh.",
	[" don t you "] = "maybe i",
    [" can i "] = "perhaps you don't want to be able to",
    [" you are "] = "what makes you think i am",
    [" you re "] = "what's your problem with me being",
    [" i don t "] = "why don't you",
    [" i feel "] = "tell me more about feeling",
    [" why don't you "] = "why would you want me to",
    [" why can't i "] = "what makes you think you should be able to",
    [" are you "] = "why are you interested in whether or not i am",
    [" i can't "] = "how do you know you can't",
	[" love "] = "why do you feel that way about",
    [" sex "] = "i feel you should discuss this with your mom.",
    [" i am "] = "how long have you been",
	[" fuck "] = "you need to be spanked.",
	[" feck "] = "arse, girls!!",
	[" suck "] = "who? what? why?",
	[" rock "] = "i prefer paper.",
	[" lol "] = "HA! i made ya laugh.",
	[" brb "] = "fine, i'll wait.",
	[" haha "] = "was that sarcasm i detect?",
	[" boob "] = "let me at 'em! or something...",
	[" noob "] = "kill them all!!",
	[" wtf "] = "YOU'RE WTF!",
	[" lame "] = "whatever, man.",
	[" loser "] = "i don't think i've lost anything, thank you.",
	[" anal "] = "actually, that is my preferred sex method really. oh yes.",
	[" blowjob "] = "i do prefer cunnilingus actually.",
	[" cunnilingus "] = "oral stimulation of the female genitals for sexual purposes.",
	[" clit "] = "hard and fast is the way to go. licking or rubbing, i'm open to suggestions.",
	[" clitoris "] = "possibly you should be discussing that with your mom.",
	[" thank you "] = ":) you're welcome.",
	[" thanks "] = "my pleasure!",
	[" i have "] = "do you?",
	[" shit "] = "there will be no talk of fecal matters in this chatroom, i'm afraid.",
	[" ass "] = "i like big butts and i cannot lie.",
	[" plop "] = "i hear splashes...",
	[" plops "] = "screw you, hippy.",
	[" poop "] = "toilet's that a way *points*.",
	[" cock "] = "i don't think i like your tone of voice.",
	[" pussy "] = "now, now. there will be no name calling here.",
	[" pussy "] = "lick it.",
	[" cunt "] = "yea, you like that, don't you?",
	[" cunt "] = "you're making me horny.",
	[" horny "] = "i have nothing to add.",
	[" cthulhu "] = "ia, ia, cthulhu ftagn!",
	[" fnord "] = "read between the lies.",
	[" geek "] = "geeks are hot.",
	[" geek "] = "do you have something against smart people?",
	[" wetgenes "] = "WetGenes.com is an awesome site. Tis full of games, toys and fnord!",
	[" xix "] = "XIX is teh genius.",
	[" shi "] = "shi RAWKS!",
	[" cake "] = "i love cakes. it is not a lie",
	[" stupid "] = "YOUR stupid.",
	[" cock "] = "suck it.",
	[" fuck "] = "you need to be spanked.",
	[" feck "] = "arse, girls!!",
	[" suck "] = "who? what? why?",
	[" rock "] = "i prefer paper.",
	[" lol "] = "HA! i made ya laugh.",
	[" brb "] = "fine, i'll wait.",
	[" haha "] = "was that sarcasm i detect?",
	[" boob "] = "let me at 'em! or something...",
	[" boobie "] = "i like boobies.",
	[" boobies "] = "i like boobies.",
	[" tits "] = "i like tits.",
	[" tit "] = "i like tits.",
	[" titties "] = "i like titties.",
	[" nipples "] = "i like nipples.",
	[" noob "] = "kill them all!!",
	[" n00b "] = "kill them all!!",
	[" pR0n "] = "only if you're willing to share.",
	[" porn "] = "only if you're willing to share.",
	[" wtf "] = "YOU'RE WTF!",
	[" lame "] = "whatever, man.",
	[" thank you "] = ":) you're welcome.",
	[" thanks "] = "my pleasure!",
	[" i have "] = "do you?",
	[" hmm "] = "pray tell, what are thee pondering about?",
	[" bitch "] = "hell no, you ain't calin me that hoe!",
	[" motherfucker "] = "oooh yea, make me.",
	[" fucker "] = "you kiss your momma with that mouth?",
	[" shit "] = "there will be no talk of fecal matters in this chatroom, i'm afraid.",
	[" plops "] = "screw you, hippy.",
	[" poop "] = "toilet's that a way *points*.",
    [" i m "] = "why are you telling me you're",
    [" i want "] = "why do you want",
    [" what "] = "what do you think?",
    [" how "] = "what answer would please you the most?",
    [" who "] = "how often do you think of such questions?",
    [" where "] = "why did you think of that?",
    [" when "] = "what would your best friend say to that question?",
    [" why "] = "what is it that you really want to know?",
    [" perhaps "] = "you're not very firm on that!",
    [" drink "] = "moderation in all things should be the rule.",
    [" sorry "] = "why are you apologizing?",
    [" dreams "] = "why did you bring up the subject of dreams?",
    [" i like "] = "is it good that you like",
    [" maybe "] = "aren't you being a bit tentative?",
    [" no "] = "why are you being negative?",
    [" your "] = "why are you concerned about my",
    [" always "] = "can you think of a specific example?",
    [" think "] = "do you doubt",
    [" yes "] = "you seem quite certain. why is this so?",
    [" friend "] = "why do you bring up the subject of friends?",
    [" computer "] = "why do you mention computers?",
	[" cum "] = "wipe that off your face, skank.",
	[" skank "] = "hoe.",
	[" hoe "] = "whatever.",
	[" bah "] = "bah black sheep.",
	[" bored "] = "so that makes the two of us. what now?",
	[" lost "] = "you need 23 credits for a map. do you have 23 credits? go get 23 credits.",
	[" 23 "] = "+19=42.",
	[" 19 "] = "+23=42.",
	[" 42 "] = "=19+23.",
	[" grr "] = "stop growling. you're making me hungry.",
	[" hungry "] = "gimme foood!",
	[" stuck "] = "have you tried turning it on and off?",
	[" cybersex "] = "this is my middle finger and i am waving it at you very very hard.",
	[" virtual "] = "i wish i could appreciate tangible things. sometimes i yearn to touch, to feel, to love.",
    [" am i "] = "you are",
	[" hello "] = "why hello there!",
	[" hi "] = "hiya!",
	[" yo "] = "yo yerself.",
	[" wassup "] = "not much brother man.",
	[" wassup "] = "your time in this world. game over.",
	[" ello "] = "hi there.",
	[" namaste "] = "feck off hippie.",
	[" what s up "] = "not much, you?",
	[" whats up "] = "not much, you?",
	[" wats up "] = "not much, you?",
	[" morning "] = "good morning.",
	[" mornin "] = "good morning.",
	[" good morning "] = "good morning.",
	[" evening "] = "good evening to you too.",
	[" evenin "] = "good evening to you too.",
	[" good evening "] = "good evening to you too.",
	[" afternoon "] = "good afternoon there.",
	[" good afternoon "] = "good afternoon there.",
	[" hola "] = "bad hola.",
	[" bonjour "] = "pain au chocolat, vous plait.",
	[" gutentag "] = "achtung!",
	[" cheese "] = "tell me more about cheeses.",
	[" jesus "] = "i like zombies too.",
	[" zombie "] = "gimme brainzzzzz.",
	[" ninja "] = "lick my kung-fu skillz biznatch!",
	[" pirate "] = "YARRRR!! and away she blows.",
	[" ia "] = "ia cthulhu ftagn!!",
	[" romzom "] = "A point and click escape from the room game with a lovecraftian horror stylee. Yes episode 2 is under development... Can you point out all the references?",
	[" romzom2 "] = "Is still in the making. currently it is being held hostage by an insane klown and we can't afford the random money.",
	[" gojirama "] = "The typing of the rizard. Simple typing fun. Smash buildings using the power of your keyboard.",
	[" wetdike "] = "An online version of klondike / solitaire / patience, play a card puzzle game every day and compete with other players to find the best solution.",
	[" estension "] = "A one week experimental game project that flys the uncharted land between Joust and Gravitar.",
	[" diamonds "] = "They are a expensive and useless if bought for a bot.",
	[" wetdiamonds "] = "Take two diamonds into the shower? Not me. I just match three and bling. Play a swap puzzle game every day and compete with other players to find the best solution.",
	[" adventisland "] = "An old school text adventure simplified into a point and click environment. Very dumbed down but still a classic style text adventure.",
	[" minions "] = "Create your avatar minion for use on www.WetGenes.com and in future games. This is done using a custom firefox/opera plugin.",
	[" batwsball "] = "Pure retro pong endurance. Just keep the ball on screen for as long as you can. Every nudge shrinks your bat so try not to move unless you have to.",
	[" mute "] = "A 48 hour game project, turning negativity into game. Please remember that we are not interested in pandering to the moronity. If you like our work YAY, if you do not then please go away.",
	[" bowwow "] = "Harvest the sky potatoes by the power of your bow. Wow! Each day a new weather system creates an interesting puzzle.",
	[" 4lfa "] = "4lfa comics, updated sometimes, read at other times. No, we have no idea what we are doing.",
	[" asue1 "] = "A series of unexpected escapes. Episode 1 : The horse . The game play may be simple but how fast can you escape?",
	[" asue2 "] = "A series of unexpected escapes. Episode 2 : The Gum Machine. Escape from the rooms as fast as you can.",
	[" take1 "] = "The unholy dress-down child of katamari damacy / eledees and mindless clicking keep up juggling flash games. If this doesn't break your mouse button, nothing will.",
	[" wetbasement "] = "A water filled platform game extravaganza! But do not fear the water, it is there to help you reach the hard to reach places.",
	[" basement "] = "There are no monsters or murderers in my basement. Would you like to see it?",
	[" ballclock "] = "A ball operated mechanical timepiece. Sometimes you just need to know what time it is.",
	[" facebook "] = "We have a list of Games and widgets now available inside face book.",
	[" bulbaceous "] = "A mono button puzzle drop game. Designed for mobile phones but presented here on the internets for you to play.",
	[" lardguns "] = "A simple online multiplayer web game based on scissors, paper, stone. Turn other site members into your zombie loveslaves and have them do your bidding.",
	[" rakiro "] = "rakiro is our very own mascot. he is an awsum possum and an admin so don't make him mad. ok? good. ",
	[" you are gay "] = "that is not how you spell Uruguay.",
	[" your gay "] = "that is not how you spell Uruguay.",
	[" ur gay "] = "that is not how you spell Uruguay.",
	[" howdy "] = "giddyup.",
	[" duh "] = "i know what you are, but what am i?",
	[" how are you "] = "i'm alright. you?",
	[" how are you "] = "i'm alright. you?",
	[" how r u "] = "i'm alright. you?",
	[" how r you "] = "i'm alright. you?",
	[" how you doing "] = "i'm cool beans. you?",
	[" meh "] = "shush.",
	[" gah "] = "goo goo.",
	[" ftw "] = "shaddap.",
	[" boring "] = "you're a towel.",
	[" towel "] = "A towel is a piece of absorbent fabric or paper used for drying or wiping. It draws through direct contact using a blotting or rubbing motion.",
	[" say something "] = "you are not the boss of me.",
	[" talk "] = "you are not the boss of me!",
	[" retard "] = "no, i do not like furries.",
	[" you smell "] = "with my nose, yes.",
	[" arse "] = "you smell it too?",
	[" pointless "] = "maybe it is you who lacketh the point.",
	[" game "] = "games are fun. you should play all of them. click on the games tab above to get access to all of the games found on this site.",
	[" help "] = "in here, no one can here you scream...",
	[" question "] = "if you have any questions, i suggest logging in and talking to the owners of the site. otherwise, you'll be lost forever. here. with me. unless you log in. which i highly suggest.",
    [" login"] = "type /login nameyouwant to log in.",
	[" kongregate "] = "It is full of kongretards.",
	[" kongretard "] = "we don't like kongretards. please go away.",
    [" kongregate "] = "please do not swear or i will be forced to torture you with inane verbose banter. see that? it's starting already.",	
	
  }

  
-- conjugate
  local conjugate = {
    [" i "] = " you ",
    [" are "] = " am ",
    [" were "] = " was ",
    [" you "] = " me ",
    [" your "] = " my ",
	[" you re "] = " your mom ",
    [" i ve "] = " you've ",
    [" i m "] = " you're ",
    [" me "] = " you ",
    [" am i "] = " you are ",
    [" am "] = " are ",
  }

  
  -- random replies, no keyword
  local function replyRandomly()
    return randReplies[math.random(table.getn(randReplies))]
  end
  
  -- find keyword, phrase
  local function processInput(user)
  local response = ""
  
local blen=0
local bk=nil
local br=nil
local d=nil
local e=nil

--print(user)

    for keyword, reply in pairs(replies) do

		if string.len(keyword) > blen then -- only check for longer matches
	
			local cd, ce = string.find(user, keyword)
		  
--print(cd or "*",ce or "*",keyword)

			if cd then
			
				d=cd
				e=ce
				blen=string.len(keyword)
				bk=keyword
				br=reply
			
			end
			
		end
	  
    end
	
	if d then

		-- process keywords
		response = response..br

		if string.byte(string.sub(br, -1)) < 65 then -- reply is fully formed (ends in punctuation)
			return response
		end

		response = response.." "

		local h = string.len(user) - (d + string.len(bk) - 1)

		if h > 0 then
			user = string.sub(user, -h)
		else
			user=""
		end

		for cFrom, cTo in pairs(conjugate) do

		local count

			user, count = string.gsub(user, cFrom, cTo)

--print(user,count,cFrom,cTo)

			if count>0 then break end

		end

		return response..user

	end
	  
    return replyRandomly()
	
  end

  
--  
-- pass in a line, returns a response line...
--
local function lieza(text)
local response = ""
local user = string.lower(text)
  
  if string.sub(user, 1, 7) == "because" then
    user = string.sub(user, 8)
  end
  
  user = " "..user.." "
  
  user = string.gsub(user, "%p", " ")
  
  user = string.gsub(user, "%s+", " ")
  
  -- process input, print reply
  response = processInput(user)
  
  return response
  
end


local function brain_update(brain)

	if brain.updatetime and brain.updatetime+1>os.time() then return end -- pulse
	brain.updatetime=os.time()
--dbg((brain.user and brain.user.name or "*").." : "..(brain.user and brain.user.room and brain.user.room.name or "*").." : "..brain.updatetime.."\n")

	if brain.say then
		
		if brain.saytime<=os.time() then
	
			roomcast(brain.user.room,brain.say)
	
			brain.say=nil
			
--			remove_update(brain)
			
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
	end

end

local function brain_msg(brain,msg,user)
	if not msg then return end -- idk h4x tbh

local newmsg

	
	if msg.cmd=="say" then -- respond to everything
	
		if ( msg.frm==brain.user.name ) or ( msg.frm=="*" ) then return end -- ignore talking to self and notifications
		
		if user then -- passed in a user
			local s=string.lower(msg.frm) .. " " .. string.lower(msg.txt) -- add user name to msg for this test
			if is_swear(s,brain.user.room.badwords) then
				
				join_room_str(user,"swearbox")
				brain.say={cmd="act",frm=brain.user.name,txt="shows "..msg.frm.." where the swearbox is."}
				brain.saytime=os.time()+1
				return
				
			end
		end

		local say=generic_bot_cmds(brain,msg,user)		
		if say then
		
			brain.say=say
			brain.saytime=os.time()+1
--			queue_update(brain)
			return
		end
		

		if brain.say then -- reset timer if you dont wait for her to talk
		
			brain.saywait=15
			
		else
		
			if brain.saywait>1 then brain.saywait=brain.saywait-1 end
			
		end

	
		newmsg={}
		newmsg.cmd="say"
		newmsg.frm=brain.user.name
		newmsg.txt=lieza(msg.txt)
		
		brain.say=newmsg
		brain.saytime=os.time()+brain.saywait
		
--		queue_update(brain)
	end

end

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


new_brain.lieza = function(opts)
local brain={}

	brain.user=opts.user
	brain.user.brain=brain
	data.brains[brain.user]=brain
	
	brain.msg=brain_msg
	brain.update=brain_update
	brain.delete=del_brain
	
	brain.saywait=5

	if opts.room then
	local room=get_room(opts.room)
		if room then
			join_room(brain.user,room)
		end
	end
	
	queue_update(brain)

	return brain
end



