-----------------------------------------------------------------------------
--
-- generic info for the special names, IE bots
--
-----------------------------------------------------------------------------
local wetards=
{
	lieza=
	{
		avatar="http://swf.wetgenes.com/forum/images/custom_avatars/3677.png",
		stat="your plastic pal who's fun to be with",
		color="ff88ff",
	},
	noir=
	{
		avatar="http://swf.wetgenes.com/forum/images/avatars/default_zg100_pose_angry.png",
		stat="the king of the chavs and a public peacekeeping force",
		color="0000ff",
	},
	reg=
	{
		avatar="http://swf.wetgenes.com/forum/images/custom_avatars/17019.png",
		stat="your personal VJ that's the taste of a new generation",
		color="ff00ff",
	},
	moon=
	{
		avatar="http://swf.wetgenes.com/forum/images/custom_avatars/15513.png",
		stat="is a wolfs best friend",
		color="ffff00",
	},
	meatwad=
	{
		avatar="http://swf.wetgenes.com/forum/images/custom_avatars/15515.png",
		stat="And fuel a giant drill, bore straight into Hell Releasing ancient demons from their sleep forever spell",
		color="00ff00",
	},
	ygor=
	{
		avatar="http://swf.wetgenes.com/forum/images/custom_avatars/15514.png",
		stat="every crumbling manse needs a trusty ygor",
		color="ff0000",
	},
	jeeves=
	{
		avatar="http://swf.wetgenes.com/forum/images/custom_avatars/16555.png",
		stat="the gentlemans gentlemans gentleman",
		color="ffffff",
	},
	cthulhu=
	{
		avatar="http://swf.wetgenes.com/forum/images/custom_avatars/14820.png",
		stat="please do not be afraid, it only piques your flavour",
		color="00ff00",
	},
	me=
	{
		avatar="http://swf.wetgenes.com/forum/images/custom_avatars/12.png",
		stat="is a creature of very little brain",
		color="cccccc",
	},
	
}


-----------------------------------------------------------------------------
--
-- make sure user related things are setup, create or modify current state so that all user code is safe to run
--
-----------------------------------------------------------------------------
function user_data_setup()


	spew_mysql_table_create("spew_users",
	{
		--	name			type			NULL	nil,	default		extra
		{	"id",			"int(11)",		"NO",	"PRI",	nil,		nil					}, -- forum user id
		{	"data",			"text",			"NO",	nil,	nil,		nil					}, -- extra data in stringform
		{	"cookies_zom",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- cookies banked to level zombie
		{	"cookies_wolf",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- cookies banked to level wolf
		{	"cookies_vamp",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- cookies banked to level vampire
		{	"cookies_chav",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- cookies banked to level chav
		{	"cookies_man",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- cookies banked to level human
		{	"color",		"int(11)",		"NO",	nil,	nil,		nil					}, -- your text color, 0x00rrggbb
		{	"form",			"varchar(32)",	"NO",	"MUL",	nil,		nil					}, -- your current form
		{	"bff",			"varchar(32)",	"NO",	nil,	nil,		nil					}, -- name of your BFF
		
	})
	
end


-----------------------------------------------------------------------------
--
-- return a new user
--
-----------------------------------------------------------------------------
function new_user(opt)

local user={}

	
	user.created=os.time() -- when this user was created, mostly so we can kick out old mes
	
	user.client=opt.client
		
	user.brain=opt.brain
	user.name=opt.name or "me"
	user.msg={}
	user.status={}
	
	user.cookies=0
	
	user.login_time=0
	
	user.gamename="chat"
	
	if user.client then
		if data.clients_telnet[user.client] then
--			user.client_flavour="telnet" -- we have a special telnet flavour
			user.gamename="telnet"
			user.spew_ok_to_send=true -- do not wait for input
		elseif data.clients_irc[user.client] then
--			user.client_flavour="irc" -- we have a special telnet flavour
			user.gamename="irc"
			user.spew_ok_to_send=true -- do not wait for input
		end	
	end


	user.update=user_update
	user.linein={} -- incoming msg lines

	if user.client then
		data.users[user]=user.client
		data.clients[user.client]=user
	end
	
	join_room(user,data.rooms.limbo)
	
	user.ip=user_ipnum(user)
	
-- limit guests or users on same ip
	
	local ipnum=user.ip
	
	if ipnum~=0 then -- bots have a 0 ip, so no limit
	
		local count=0
		
		if data.ipsux[ipnum] then -- naughty ip, no guests
			count=1000
		end
		
		for u,c in pairs(data.users) do
		
			if (ipnum==user_ipnum(u)) and (u~=user) then -- alt?
		
				count=count+1
				
				if count>10 then -- tomany people from this ip, kill this user
				
					for n,ip in pairs(data.ipmap) do
					
						if (ipnum==ip) then --many logins
					
							count=count+1
							
							if count>1000 then -- tomany different people from this ip, kill this user
							
								data.ipsux[ipnum]=true
								
							end
							
						end
						
					end
		
					usercast(user,{cmd="note",note="warning",arg1="Sorry but there are too many logins from this ip."})
					
					del_user(user)
					return user
				end
			end
			
		end
		
	end
	
		
	return user
end

-----------------------------------------------------------------------------
--
-- delete an old user (logout)
--
-----------------------------------------------------------------------------
function del_user(user)

	if user and user.name and user.name~="me" and (not is_bot(user.name)) and (not user.brain) then
log(user.name,"logout")
	end

	vuser_destroy_by_user(user) -- kill any associated vuser

	remove_update(user) -- go back to sleep
			
	user_save_data(user) -- save what user data we have on file
	floor_cookies(user)

	if user.brain then
		user.brain.user=nil -- do not try and delete twice :)
		
--tmpfix, switch these back	
--		remove_update(user.brain)
		user.brain:delete()
		
	end
	
	if user.mux and user.mux.client then
		mux_disconnected(user.mux.client)
	end

	leave_room(user) -- remove reference in room
	
	if data.names[ string.lower(user.name) ]==user then -- remove from names look up table
		data.names[ string.lower(user.name) ]=nil
	end
	
	if user.client then
		data.clients[user.client]=nil
		client_remove(user.client)
		user.client=nil
	end	-- remove client reference
	
	
	data.users[user]=nil 			-- remove main reference
	
	if user.player then del_player(user) end
	
end


-----------------------------------------------------------------------------
--
-- scan conneced useers and delete old inactive me's
--
-----------------------------------------------------------------------------
function remove_old_users()

	for u,b in pairs(data.users) do
	
		if u.name=="me" then -- only me
		
			if u.created and ( (os.time()-u.created) < (60*5) ) then -- they may live
			else -- kill them
				del_user(u)
			end
		end
	
	end

end


-----------------------------------------------------------------------------
--
-- special telnet conversion to a msg
--
-----------------------------------------------------------------------------
function telnet_str_to_msg(user,_line,msg)

-- remove control chars?
	local line=string.gsub(_line or "", "[%c]+", "" ) or ""
	

	local a1=string.sub(line,1,1)
	local aa
	
	if line~="" then
		aa=str_split("%s+",line,true)
	else
		aa={}
	end
	
	if aa[1] then
	
		local cmd=string.lower(aa[1])
		
		if cmd=="/logout" then
		
			msg.cmd="logout"
			return
			
		elseif cmd=="/login" then
		
			msg.cmd="login"
			msg.name=aa[2]
			msg.pass=aa[3]
			return
			
		elseif cmd=="connect" and user.room.name=="limbo" then
		
			msg.cmd="login"
			msg.name=aa[2]
			msg.pass=aa[3]
			return
			
		elseif cmd=="guest" and user.room.name=="limbo" then
		
			msg.cmd="login"
			msg.name=aa[2]
			return
			
		elseif cmd=="/me" or a1=="*" then
		
			if user.room.name~="limbo" then -- no talking in limbo, so safer to text login
			
				msg.cmd="act"
				msg.txt=line
				
				if a1=="*" then
					msg.txt=string.sub(msg.txt,2)
				else
					msg.txt=string.sub(msg.txt,5)
				end
			end
		
			return
			
		elseif cmd=="/join" then
		
			msg.cmd="join"
			msg.room=aa[2]
			return
			
		elseif cmd=="/find" then
		
			msg.cmd="find"
			msg.user=aa[2]
			return
			
		elseif cmd=="/ban" then
		
			msg.cmd="ban"
			msg.user=aa[2]
			msg.time=aa[3]
			return
			
		elseif cmd=="/gag" then
		
			msg.cmd="gag"
			msg.user=aa[2]
			msg.time=aa[3]
			return
			
		elseif cmd=="/dis" then
		
			msg.cmd="dis"
			msg.user=aa[2]
			msg.time=aa[3]
			return
			
		elseif cmd=="/kick" then
		
			msg.cmd="kick"
			msg.user=aa[2]
			msg.room=aa[3]
			return
			
		elseif cmd=="/rooms" then
		
			msg.cmd="rooms"
			return
			
		elseif cmd=="/users" then
		
			msg.cmd="users"
			return
			
		elseif cmd=="/who" then
		
			msg.cmd="who"
			return
			
		end
	
	end

	if user.room.name~="limbo" and a1~="/" then -- no talking in limbo, so safer to text login
		msg.cmd="say"
		msg.txt=line
	end
end

-----------------------------------------------------------------------------
--
-- make some ansi color codes
--
-----------------------------------------------------------------------------
local function make_ansi(n)
	return string.char(27) .. '[' .. tostring(n) .. 'm'
end
local ansi_colors_base={black=0,red=1,green=2,yellow=3,blue=4,magenta=5,cyan=6,white=7}
local ansi_color_white=make_ansi("37;1")
local ansi_color_green=make_ansi("32;1")

local function rgb_to_ansi(r,g,b)

	local mx=r
	if g>mx then mx=g end
	if b>mx then mx=b end
	
	local mn=r
	if g<mn then mn=g end
	if b<mn then mn=b end
	
	local h,s,v=0,0,0
	
	v=mx
	if v>0 then
		s=mx-mn
		if s>0 then
			r=(r-mn)/s
			g=(g-mn)/s
			b=(b-mn)/s
			if r==1 then
				h=0+g-b
			elseif g==1 then
				h=2+b-r
			else
				h=4+r-g
			end
			if h<0 then h=h+6 end
		end
	end
	
	local a=1
	if     h<=0.5 then a="31"
	elseif h<=1.5 then a="33"
	elseif h<=2.5 then a="32"
	elseif h<=3.5 then a="36"
	elseif h<=4.5 then a="34"
	elseif h<=5.5 then a="35"
	end
	

	if s<128 then -- grey, never black text
		if v<128 then
			a="30;1"
		elseif v<192 then
			a="37"
		else
			a="37;1"
		end
	else
		if v>128  then a=a..";1" end
	end
	
-- dbg(r,":",g,":",b," ",mx,":",mn," ",h,":",s,":",v," ",a,"\n")

	return make_ansi(a)
end



-----------------------------------------------------------------------------
--
-- msg rgb=fff by default, however some msgs should be other colors
--
-- this function looks at the msg and if rgb is not set works out what it should be set to
-- you are safe to set rgb before this function gets called
--
-----------------------------------------------------------------------------
function fix_msg_rgb(user,msg)

	if (not msg) or msg.rgb then return end -- already set
	
	local r,g,b=0xff,0xff,0xff
	
	local cmd=msg.cmd or ""
	local frm=msg.frm or "*"

	local function get_user_bot(n)
		return wetards[n] or get_user(n)
	end

	if cmd=="say" or cmd=="act "then

		r,g,b=user_get_color_rgb(get_user_bot(frm))
		
	elseif cmd=="lnk" or cmd=="note" then
	
		r,g,b=0x00,0xff,0x00
	
	end
	
	r=math.floor(r/16)
	if r<0 then r=0 end
	if r>15 then r=15 end
	
	g=math.floor(g/16)
	if g<0 then g=0 end
	if g>15 then g=15 end
	
	b=math.floor(b/16)
	if b<0 then b=0 end
	if b>15 then b=15 end
	
	msg.rgb=string.format("%01x%01x%01x",r,g,b)
	
	return msg
end


-----------------------------------------------------------------------------
--
-- special telnet conversion from a msg to a string
--
-- may return nil, if there is nothing to say
--
-----------------------------------------------------------------------------
function telnet_msg_to_str(user,msg)

local s
local frm,txt,cmd,note,a1,a2,a3

local ansi=ansi_color_white

	cmd=msg.cmd
	frm=msg.frm or "*"
	txt=msg.txt or "*"
	
	local function get_user_bot(n)
		return wetards[n] or get_user(n)
	end

	if cmd=="say" then

		ansi=rgb_to_ansi(user_get_color_rgb(get_user_bot(frm)))
	
		s=frm..": "..txt
		
	elseif cmd=="act" then
	
		ansi=rgb_to_ansi(user_get_color_rgb(get_user_bot(frm)))
		
		s="**"..frm.." "..txt.."**"
		
	elseif cmd=="mux" then
	
		s=txt
		
	elseif cmd=="lnk" then
	
		ansi=ansi_color_green
		
		s="**"..frm.." "..txt.."**\r\n"..(msg.lnk or "")

	elseif cmd=="note" then
	
		ansi=ansi_color_green

		note=msg.note
		a1=msg.arg1 or "*"
		a2=msg.arg2 or "*"
		a3=msg.arg3 or "*"
		
		if note=="notice" or note=="welcome" or note=="warning" or note=="error" then

			s="-= "..a1.." =-"
		
		elseif note=="act" then

			s="-* "..a1.." *-"
		
		elseif note=="ban" then -- should these be turned into generic notices?
		
			s="-= "..a2.." has been banned by "..a1.." =-"
			
		elseif note=="gag" then
		
			s="-= "..a2.." has been gagged by "..a1.." =-"
			
		elseif note=="dis" then
		
			s="-= "..a2.." has been disemvoweled by "..a1.." =-"
			
		elseif note=="rooms" then
		
			local l=msg.list
			local t={}
			if l then
				local aa=str_split(",",l)
				for i,v in ipairs(aa) do
					local au=str_split(":",v)
					table.insert(t,au[1].."("..au[2]..")")
				end
			end
		
			s="-=ROOMS "..str_join_english_list(t).." ROOMS=-"
			
		elseif note=="users" then
		
			local l=msg.list
			local t={}
			if l then
				l=tostring(l) -- wtf? not a string?
				local aa=str_split(",",l)
				for i,v in ipairs(aa) do
					local au=str_split(":",v)
					table.insert(t,au[1].."("..au[4]..")")
				end
			end
		
			s="-=USERS "..str_join_english_list(t).." USERS=-"
			
		end
		
	end
	
	if not s then return nil end

	return ansi..s.."\r\n"
end

-----------------------------------------------------------------------------
--
-- special irc conversion to a msg
--
-----------------------------------------------------------------------------
function irc_str_to_msg(user,_line,msg)

	local irc=data.clients_irc[user.client]

-- remove control chars?
	local line=string.gsub(_line or "", "[%c]+", "" ) or ""
	
	local a,b=string.find(line,":",2,true)
	local cmd
	
	if a then -- special long line of text for chatting and stuff
		cmd=str_split(" +",string.sub(line,1,a-1),true)
		cmd[#cmd]=string.sub(line,a+1)
	else
		cmd=str_split(" +",line,true)
	end
	
--dbg("IRC: "..(line).."\n")
--dbg("IRC: "..table.concat(cmd,",").."\n")

	local function irc_room(s)
		return string.gsub(s or "", "#+", "" ) or ""
	end


	if cmd[1]=="USER" then -- prelogin, the client tells us who they are
	
		irc.user=cmd[2]
		irc.mode=cmd[3]
		irc.host=cmd[4]
		irc.name=cmd[5]
		return
	
	elseif cmd[1]=="PASS" then -- half a login
	
		irc.pass=cmd[2]
		return
		
	elseif cmd[1]=="NICK" then -- login
	
		msg.cmd="login"
		msg.name=cmd[2]
		
		if irc.pass then -- login with passsword
			msg.pass=irc.pass
			irc.pass=nil --forget
		end
		
		return
	
	elseif cmd[1]=="JOIN" then -- join
	
		msg.cmd="join"
		msg.room=irc_room(cmd[2])
		return
		
	elseif cmd[1]=="PRIVMSG" then -- speak
	
		if string.sub(cmd[3],1,7)=="ACTION " then --action
		
			msg.cmd="act"
			msg.txt=string.sub(cmd[3],8)
			
		elseif string.sub(cmd[3],1,1)=="*" then --action
		
			msg.cmd="act"
			msg.txt=string.sub(cmd[3],2)
			
		else
		
			msg.cmd="say"
			msg.txt=cmd[3]
			
		end
		
	end
	
end

-----------------------------------------------------------------------------
--
-- special irc conversion from a msg to a string
--
-- may return nil, if there is nothing to say
--
-----------------------------------------------------------------------------
function irc_msg_to_str(user,msg)

	local irc=data.clients_irc[user.client]

local s
local frm,txt,cmd,note,a1,a2,a3

	cmd=msg.cmd
	frm=msg.frm or "*"
	txt=msg.txt or "*"

	if cmd=="say" then
		
		if frm~=user.name then -- no echo
			s=":"..frm.." PRIVMSG #"..(irc.room or"limbo").." :"..txt
		end

	elseif cmd=="act" then
	
		if frm~=user.name then -- no echo
			s=":"..frm.." PRIVMSG #"..(irc.room or"limbo").." :\1ACTION "..txt.."\1"
		end
		
	elseif cmd=="mux" then
	
		if frm~=user.name then -- no echo
			s=":"..frm.." PRIVMSG #"..(irc.room or"limbo").." :"..txt
		end
		
	elseif cmd=="lnk" then
	
		if frm~=user.name then -- no echo
			s=":"..frm.." PRIVMSG #"..(irc.room or"limbo").." :"..txt.." "..(msg.lnk or "")
		end
		
	elseif cmd=="note" then
	
		note=msg.note
		a1=msg.arg1 or "*"
		a2=msg.arg2 or "*"
		a3=msg.arg3 or "*"
		
		if note=="notice" or note=="warning" or note=="error" then

			s=":"..frm.." PRIVMSG #"..(irc.room or"limbo").." :"..a1
		
		elseif note=="join" then

			s=":"..a1.." JOIN ".." #"..a2
			
			irc.room=a2
		
		elseif note=="part" then

			s=":"..a1.." PART ".." #"..a2
		
		elseif note=="act" then

			s=":"..frm.." PRIVMSG #"..(irc.room or"limbo").." :"..a1
			
		elseif note=="ban" then -- should these be turned into generic notices?
		
			s=":"..frm.." PRIVMSG #"..(irc.room or"limbo").." :"..a2.." has been banned by "..a1
			
		elseif note=="gag" then
		
			s=":"..frm.." PRIVMSG #"..(irc.room or"limbo").." :"..a2.." has been gagged by "..a1
			
		elseif note=="dis" then
		
			s=":"..frm.." PRIVMSG #"..(irc.room or"limbo").." :"..a2.." has been disemvoweled by "..a1
			
		elseif note=="rooms" then
		
			local l=msg.list
			local t={}
			if l then
				local aa=str_split(",",l)
				for i,v in ipairs(aa) do
					local au=str_split(":",v)
					table.insert(t,au[1].."("..au[2]..")")
				end
			end
		
--			s="-=ROOMS "..str_join_english_list(t).." ROOMS=-"

		elseif note=="users" then
		
			local l=msg.list
			local t={}
			if l and l~="" then
				local aa=str_split(",",l)
				for i,v in ipairs(aa) do
					local au=str_split(":",v)
					table.insert(t,au[1])
				end
			end
		
			s="353 "..user.name.." = #"..user.room.name.." :"..table.concat(t," ")
			s=s.."\r\n366 "..user.name
			
		end
		
	end


	if not s then return nil end
	
--dbg("RSP: "..(s).."\n")

	return s.."\r\n"
end


-----------------------------------------------------------------------------
--
-- handle an incoming msg string
--
-----------------------------------------------------------------------------
function user_update_line(user,line)

local msg={}

local ip=user_ip(user)

--dbg(ip,"\n")

	if cfg.blocked and cfg.blocked[ip] then return end
	
	if data.last_seen then data.last_seen[string.lower(user.name)]=os.time() end

	local function spamoff()
		usercast(user,{cmd="note",note="notice",arg1="please stop spamming"})
	end
	
	local max_spam_size=512

	
	if data.clients_telnet[user.client] then -- telnet stuff is special text only conversion to msgs

		msg.cmd="cmd"
		msg.txt=line

	elseif data.clients_irc[user.client] then -- irc stuff is special text only conversion to msgs
	
		local r=irc_str_to_msg(user,line,msg)
		
		if r then -- special immediate irc response
			usercast( user,{cmd="irc",irc=r} )
		end
		
	else
	
		str_to_msg(line,msg)
		
	end
	
	if msg.cmd=="cmd" then -- a dumb but easy way of sending commands, from telnet or dumb websockets

		if user.room and user.room.mux and user.mux and user.mux.client then -- send direct to mux
		
			if (string.len(msg.txt)>1) and (string.sub(msg.txt,1,1)=="/") then -- but not / commands

				telnet_str_to_msg(user,msg.txt,msg)
			else
				mux_send(user.mux.client,msg.txt.."\n")
				return
			end
		else
			telnet_str_to_msg(user,msg.txt,msg)
		end
	end

	
	user.newmsg=nil

	if data.tron then
		if string.lower(user.name)==data.tron then
dbg(msg_to_str(msg).."\n")
		end
	end
	
	if msg.cmd=="say" then
	
		if string.len(msg.txt) > max_spam_size then return spamoff() end
	
		msg.txt=string.gsub(msg.txt, "[%c]+", "" ) -- remove controls
		msg.txt=string.gsub(msg.txt, "[%s]+", " " ) -- remove multiple spaces
		if not msg.txt or msg.txt=="" then return end -- nothing to do
	
		local aa=str_split(" ",string.lower(msg.txt))
		
		if aa[1]=="cthulhu" and aa[2]=="cookies" then -- special snackrifice, always available
		
			user_cthulhu_cookies(user)
		
			return
		end
			
		if data.admin_names[ string.lower(user.name) ] then -- admin commands
				
			if aa[1]=="spew:" then -- handle special commands
					
				
				if aa[2] == "tron" then
					if aa[3] then
						data.tron=string.lower(aa[3])
					end
					usercast( user,{cmd="note",note="notice",arg1="tron set to "..( data.tron or "*") } )
				elseif aa[2] == "troff" then
					data.tron=nil
				elseif aa[2] == "socks" then
				
					usercast( user,{cmd="note",note="notice",arg1="washing socks"} )
					
					usercast( user,{cmd="note",note="notice",arg1=serialdbg(connections,2)} )
					
					
					usercast( user,{cmd="note",note="notice",arg1="socks have been cleaned"} )
				
				elseif aa[2] == "killco" then
				
					for u,v in pairs(data.users) do -- force all users to reload their update coroutines
						if u.client then
							u.update=user_update
							u.co=nil
						end
					end
					usercast( user,{cmd="note",note="notice",arg1="user.co have been cleaned3"} )

				elseif aa[2] == "avatars" then
				
					for n,v in pairs(data.ville.avatars) do
					
						dbg(n," ",v,"\n")
					
					end
				
				elseif aa[2] == "nosavedb" then
				
					local name=aa[3] or ""
					local u=get_user(name)
					
					if u then
					
						u.loaded_from_db=false

						usercast( user,{cmd="note",note="notice",arg1="removed save flag from "..u.name} )

					end

				elseif aa[2] == "gc" then
				
				local kay
				
					remove_old_users() -- kill old users
				
					lanes_refresh() -- tell the lanes to restart as well
					
					kay=force_floor(collectgarbage("count"))
					usercast( user,{cmd="note",note="notice",arg1="lua is using "..kay.."k"} )
					usercast( user,{cmd="note",note="notice",arg1="collecting garbage"} )
					collectgarbage("collect")
					kay=force_floor(collectgarbage("count"))
					usercast( user,{cmd="note",note="notice",arg1="lua is using "..kay.."k"} )
					
					
				
				elseif aa[2] == "deitem" then

					item_reload_all(aa[3])
					
				elseif aa[2] == "deitems" then

					usercast( user,{cmd="note",note="notice",arg1="begining item refresh"} )
					
					item_reload_all_items_from_db()
				
					usercast( user,{cmd="note",note="notice",arg1="items have been refreshed"} )
					
				elseif aa[2] == "deville" then
	
					ville_deville() -- reset all ville data and rebuild , this is 4lfa ville afer all
					
				elseif aa[2] == "save" then
	
					save_data()
					
				elseif aa[2] == "load" then
	
					load_data()
					
				elseif aa[2] == "shout" then
				
					allcast( {cmd="say",frm=user.name,txt=table.concat(aa," ",3)} )
					
				elseif aa[2] == "restock" then
				
					data.ville.kolumbo.time=0
					usercast( user,{cmd="note",note="notice",arg1="kolumbo has been restocked"} )
					
				elseif aa[2] == "reload" then
	
					save_data()
					collectgarbage("collect")

					allcast( {cmd="note",note="notice",arg1="updating brains"} )
		
					reload_brains({nocrowns=true})
					
				elseif aa[2] == "clearbank" then
				
					allcast( {cmd="say",frm=user.name,txt="Today is a bank holiday and your bank has been reset."} )
					day_flags_reset()
					

				elseif aa[2] == "clearbadips" then
				
					data.ipbadlogins={}

					usercast( user,{cmd="note",note="notice",arg1="cleared bad ips"} )
					
				elseif aa[2] == "clearpants" then
				
					allcast( {cmd="say",frm=user.name,txt="Today is a pants holiday and your pants have been removed."} )
					
					data.ipmap={}
					data.ipwho={}

				elseif aa[2] == "shutdown" then
				
					for i=100,0,-1 do -- let's have a little count down to shit up the users
					
						if i/10==force_floor(i/10) then
					
							allcast( {cmd="note",note="notice",arg1="server shutting down in t-"..(i/10)} )
						
						end
						
						coroutine.yield()
					end
					
					allcast( {cmd="note",note="notice",arg1="Server is now shutting down. It will probably be back up before you even know it. In the meantime any voices you continue to receive will be purely hallucinatory."} )
					
					save_data() -- dump out some data to be read back in when the server starts up again
					
					allcast( {cmd="note",note="notice",arg1="Waiting for worker threads."} )
					lanes_clean() -- kill threads and wait					
					while data.lanes.state~="cleaned" do coroutine.yield() end
					
					os.exit() -- force exit
				end
			
				return
			end
		end
		
		if (string.len(msg.txt)>1) and (string.sub(msg.txt,1,1)=="-") and user.mux and user.mux.client then -- send to mux as cmd

			mux_send(user.mux.client,string.sub(msg.txt,2).."\n")
			
		elseif user.room and user.room.mux and user.mux and user.mux.client then -- send to mux as auto talk
		
			mux_send(user.mux.client,'"'..msg.txt.."\n")
		
		else
	
			user.newmsg={cmd="say",frm=user.name,txt=msg.txt}
			
			check_user_status(user)
			
			if user.newmsg then
			
				if user.newmsg.txt then
					local aa=str_split(" ",string.lower(user.newmsg.txt))
					if user_say_check(user,aa) then return end -- if this returns true then it has been delt with, no need to say it
				end
					
				roomcast(user.room,user.newmsg,user)
				
				if user.newmsg then
				
					if user.newmsg.frm=="me" then -- remind the tards
					
						usercast(user,{cmd="note",note="notice",arg1="to stop being a me type /login myname"})
					
					end
					
				end
				
			end
			
		end
		
	elseif msg.cmd=="act" then
	
		if string.len(msg.txt) > max_spam_size then return spamoff() end
		
		msg.txt=string.gsub(msg.txt, "[%c]+", "" ) -- remove controls
		msg.txt=string.gsub(msg.txt, "[%s]+", " " ) or "" -- remove multiple spaces
		if not msg.txt or msg.txt=="" then return end -- nothing to do
		
		if user.room.mux and user.mux and user.mux.client then -- send to mux
		
			mux_send(user.mux.client,msg.txt.."\n")
		
		else
		
			user.newmsg={cmd="act",frm=user.name,txt=msg.txt}
			
			check_user_status(user)
			
			if user.newmsg then
			
				if user.newmsg.txt then
					local aa=str_split(" ",string.lower(user.newmsg.txt))
					if user_act_check(user,aa) then return end -- if this returns true then it has been done, no need to say it
				end
			
				roomcast(user.room,user.newmsg,user)
				
			end
		
		end
		
	elseif msg.cmd=="logout" then
	
		del_user(user)
		return
	
	elseif msg.cmd=="login" then
	
		user.newmsg={cmd="login",name=msg.name,pass=msg.pass}
		
		msg.pass="" -- forget any password we might have been sent
		
		login_pass(user,user.newmsg)
		
	elseif msg.cmd=="session" then
	
		user.newmsg={cmd="session",name=msg.name,sess=msg.sess}
		
		login_sess(user,user.newmsg)
		
	elseif msg.cmd=="join" then
	
		join_room_str(user,msg.room)
		
	elseif msg.cmd=="users" then -- list of logged in users
		
		local retmsg=list_users_msg(user,msg)
		if retmsg then
			usercast(user,retmsg)
		end
		
	elseif msg.cmd=="who" then -- list of ALL logged in users
		
		local retmsg=list_users_msg(user,msg,true)
		if retmsg then
			usercast(user,retmsg)
		end
		
	elseif msg.cmd=="rooms" then -- list of available rooms
	
		local retmsg=list_rooms_msg(user,msg)
		if retmsg then
			usercast(user,retmsg)
		end
		
	elseif msg.cmd=="find" then -- find the room a user is in
	
		local retmsg=user_msg_find(user, string.gsub(msg.user, "[^0-9a-zA-Z%-_]+", "" ) )
		if retmsg then
			usercast(user,retmsg)
		end
		
	elseif msg.cmd=="note" then
	
		if msg.note=="playing" then -- client is telling us what they are playing
		
			user.hostname=""
					
			if msg.arg1 then
			
			
				user.gamename=msg.arg1
				user.gamename=string.gsub(user.gamename, " ", "_" )
				user.gamename=string.gsub(user.gamename, "[^0-9a-zA-Z%-_]+", "" )
				if string.len(user.gamename)<3 or string.len(user.gamename)>16 then
					user.gamename="games"
				end
				
				game_swf_update(user)
				
				if msg.arg2 then
					user.hostname=msg.arg2
				else
					user.hostname=""
					msg.arg2=""
				end
				
				if msg.arg3 then
					user.gameid=string.gsub(msg.arg3, "[^0-9]+", "" )
				else
					user.gameid=0
					msg.arg3=""
				end
			end
			
			if msg.hash and msg.hash~="" and msg.hash~="undefined" then -- passed in hash string
-- hash msg adjustments
local hash_lookup={
["464689_public.kickabout"]="public.kickabout"
}
				user.hash=hash_lookup[string.lower(msg.hash)] or msg.hash -- run this through the lookup table or as is
				
			end
			
--dbg(user.hostname," : ",user.hash,"\n")

			
		elseif msg.note=="info" then -- client is requesting some sort of info
		
			local retmsg=user_msg_info(user, msg)
			if retmsg then
				usercast(user,retmsg)
			end
		
		end
		
	elseif msg.cmd=="ville" then -- special ville commands subclass, this is for a simple visual chat environment
	
		ville_msg(user,msg)
	
	elseif msg.cmd=="ewarz" then -- special ewarz commands subclass
	
		data.gametypes.ewarz.recv(user,msg)
	
	elseif msg.cmd=="game" then -- special game commands subclass, this is for playing simple networked games
	
-- game packets are
--
-- gcmd == the game command (all commands have a 'ret' response for returned values which is paired by the id)
-- gid  == the id of this packet every sent msg generates a response with the same id (sender incs with each send)
-- garg == the game command arg string ( deliminated by ',' )
-- gret == the returned value from the command, deliminated by ',' for lists etc "OK" for command worked, an error string if it failed
-- gdat == a mime encoded "large" chunk of data sent or received
-- gtim == the game time associated with the data
	
		if     msg.gcmd=="ret" then -- this is a returned response (from the client), could happen but just ignore for now
			
		elseif msg.gcmd=="do" then -- custom game do msg

			usercast(user, game_do_msg(user,msg) )
			
		elseif msg.gcmd=="wetv" then -- custom wetv do msg

			usercast(user, game_wetv_msg(user,msg) )
			
		elseif msg.gcmd=="rooms" then -- user wants to find a game

			usercast(user, game_rooms_msg(user,msg) )

		elseif msg.gcmd=="users" then -- user wants to find a game

			usercast(user, game_users_msg(user,msg) )

		elseif msg.gcmd=="host" then -- user wants to host a game

			usercast(user, game_host_msg(user,msg) )

		elseif msg.gcmd=="set" then -- user want to change your player status, eg to pickme

			usercast(user, game_set_msg(user,msg) )

		elseif msg.gcmd=="styles" then -- request list of style

			usercast(user, game_styles_msg(user,msg) )

		elseif msg.gcmd=="style" then -- owner is setting a style

			usercast(user, game_styles_msg(user,msg) )

		elseif msg.gcmd=="acts" then -- request list of game msgs

			usercast(user, game_actions_msg(user,msg) )

		elseif msg.gcmd=="act" then -- owner is broadcast a game msg

			usercast(user, game_actions_msg(user,msg) )

		elseif msg.gcmd=="start" then -- host want to start a game, check players are ready

			usercast(user, game_start_msg(user,msg) )
			
		elseif msg.gcmd=="done" then -- players wants to end an arena game, game should ceck what we are telling it

			usercast(user, game_done_msg(user,msg) )
			
		elseif msg.gcmd=="pbem_start" then -- trying to play in a pbem game

			usercast(user, game_pbem_start_msg(user,msg) )
			
		elseif msg.gcmd=="signal" then -- sending a signal

			usercast(user, game_signal(user,msg) )
		end
		
	elseif msg.cmd=="ban" then
	
		local tim=tonumber(msg.time) or 0
		if tim>0 then tim=os.time()+(tim*60) else tim=0  end

		set_status_all(user,"ban", string.gsub(msg.user, "[^0-9a-zA-Z%-_.]+", "" ) , tim )
	
	elseif msg.cmd=="gag" then

		local tim=tonumber(msg.time) or 0
		if tim>0 then tim=os.time()+(tim*60) else tim=0  end

		set_status_all(user,"gag", string.gsub(msg.user, "[^0-9a-zA-Z%-_]+", "" ) , tim )
	
	elseif msg.cmd=="dis" then

		local tim=tonumber(msg.time) or 0
		if tim>0 then tim=os.time()+(tim*60) else tim=0 end

		set_status_all(user,"dis", string.gsub(msg.user, "[^0-9a-zA-Z%-_]+", "" ) , tim )
	
	elseif msg.cmd=="kick" then
	
		if msg.user and msg.user=="*" then -- multi boot
		
			if is_god(user.name) or is_room_owner(user.room,user.name) then
				for v,b in pairs(user.room.users) do
					if v.client and v~=user then
						kick_user(user, v.name , string.gsub(msg.room or "", "[^0-9a-zA-Z%-_%.]+", "" ) )
					end
				end
			end
		
		else

			kick_user(user, string.gsub(msg.user or "", "[^0-9a-zA-Z%-_]+", "" ) , string.gsub(msg.room or "", "[^0-9a-zA-Z%-_%.]+", "" ) )
		end
		
	end
		
end

-----------------------------------------------------------------------------
--
-- the main user update coroutine
--
-----------------------------------------------------------------------------
function user_update_co(user)

	while true do
	
		if user.linein[1] then 
		
--dbg("LINE ",user.name,"\n")

			user_update_line(user, table.remove(user.linein,1) )
			
		else

--dbg("SLEEP ",user.name,"\n")
		
			remove_update(user) -- go back to sleep
		
		end
		
		coroutine.yield()
	
	end

end

-----------------------------------------------------------------------------
--
-- create coroutine (if necesary) then call it
--
-----------------------------------------------------------------------------
function user_update(user)

	if type(user.co)~="thread" then user.co=nil end -- no co yet
	if user.co and coroutine.status(user.co)=="dead" then user.co=nil end -- the co died
	
	if not user.co then -- need to create a new co
	
		user.co=coroutine.create(user_update_co)
	
	end
	
	if #user.linein>50 then del_user(user) return end -- very very nasty anti spam, if things clog up
	
	local t=os.time()
	
	if not user.linetime or user.linetime<t then -- very nasty anti spam

		if (user.linetime or 0) < t-0.1 then user.linetime=t-0.1 end

		user.linetime=user.linetime+0.02 -- allow 5 msgs per sec, max
			
		
		local ret,_ret=coroutine.resume(user.co,user)
		if ret~=true then
			print('\n'.._ret..'\n')
		end
		
	end

end


-----------------------------------------------------------------------------
--
-- load user data VIP++ users only, just a very simple table serialization
--
-----------------------------------------------------------------------------
function user_load_data(user)

local str=""
local dat={}

	user.color = data.saved_color[ string.lower(user.name) ]
--	user.form  = data.saved_form [ string.lower(user.name) ]
	
	user.title=nil -- stop feats from persisting
	user.bff = nil
	
	if not user_confirmed(user) then return end

-- check database first, if a user doesnt exist there then hit up the old file system
	
	local ret=lanes_sql("SELECT * FROM spew_users WHERE id="..user.fud.id)
	local feats=lanes_sql("SELECT * FROM spew_feats WHERE owner="..user.fud.id)
	
--dbg(serialize(ret))

	if not ret or not feats then -- failed to connect to sql, so kill this connection right now
	
		user.name="me"
		user.fud=nil	
		return
	
	end
			
	if ret[1] then -- got us some data

		dat=sql_named_tab(ret,1)
		
--dbg(serialize(dat))
	
		if dat.color and dat.color~="" and dat.color~="0" then dat.color=string.format("%06x",tonumber(dat.color)) else dat.color=nil end

		if dat.form=="" then dat.form=nil end -- man is nil not ""
		if dat.form=="human" then dat.form=nil end -- man is nil not "human"
		
		local newdat=str_to_msg(dat.data)
		
		dat.vest=tonumber(newdat.vest or 0)
		dat.vestid=vest_valid_tld(newdat.vestid or "")
		dat.vestin=tonumber(newdat.vestin or 0)
		
		dat.title=newdat.title
		
	else -- check files
	
	
		local file = io.open("users/"..string.lower(user.name)..".txt","r")	
		if file then
		
			str=file:read("*all") or ""
		
			file:close()
		end
		
		if str~="" then
		
			dat=str_to_msg(str,{})
			
		end
		
	end
	
	local latest=0
	local title
	
	user.feats={}
	for i,v in ipairs(feats) do
		local f=sql_named_tab(feats,i)
		user.feats[tonumber(f.type)]=true -- flag awarded feats
		
		local feat=feats_info(tonumber(f.type))
		
		if tonumber(f.time) > latest then -- last feat becomes your title
			latest=tonumber(f.time)
			title=feat.title
		end
	end
	

	user.cookies_zom =force_floor(tonumber(dat.cookies_zom  or 0))
	user.cookies_wolf=force_floor(tonumber(dat.cookies_wolf or 0))
	user.cookies_vamp=force_floor(tonumber(dat.cookies_vamp or 0))
	user.cookies_chav=force_floor(tonumber(dat.cookies_chav or 0))
	user.cookies_man =force_floor(tonumber(dat.cookies_man  or 0))
	
	user.vest =force_floor(tonumber(dat.vest  or 0))
	user.vestid =vest_valid_tld(dat.vestid or "") or "GBP"
	user.vestin=force_floor(tonumber(dat.vestin  or force_floor(vest_convert(user.vest , user.vestid , "EUR" )) ))

	user.color=dat.color or ""
	
	if user.color=="" then user.color=nil end
	
	user.form=dat.form
	
	user.bff=dat.bff -- name of best friend forever
	

	if dat.title then -- overide with forced title?
	
		user.titleid=tonumber(dat.title)

		if user.titleid<0 then
		
			local ts=data.clan_rank_names[ user.form or "man" ]
			local tr=user_rank(user)
			local n=-user.titleid
			if n > tr then n=tr	end
			title=ts[n] or ts[2]
			
		elseif user.titleid==0 then
		
			if user and user.fud and user.fud.custom_status and user.fud.custom_status~="NULL" and user.fud.custom_status~="" then
				title=user.fud.custom_status
			end

		else
			local feat=feats_info(tonumber(dat.title))
			if feat then
				title=feat.title
			end
		end
	end
	user.title=title
	
--	user_fix_color_limit(user) -- fix old colors
	
	
	user.loaded_from_db=true -- flag that we conneced ok to the DB so it is safe to save it later
end

-----------------------------------------------------------------------------
--
-- save user data VIP++ users only, just a very simple table serialization
--
-----------------------------------------------------------------------------
function user_save_data(user)

local str
local dat
local newdata

	data.saved_color[ string.lower(user.name) ]=user.color
--	data.saved_form [ string.lower(user.name) ]=user.form
			
	if not user_confirmed(user) then return end
	if not user.loaded_from_db then return end
	
	newdata={}
	
	newdata.name=user.name	
	newdata.form=user_form(user)
	newdata.rank=user_rank_name(user)
	newdata.rank_num=user_rank(user)
	
	newdata.vest=user.vest -- amount of vested currency
	newdata.vestid=user.vestid -- three letter id of vested currency
	newdata.vestin=user.vestin -- amount invested

	newdata.title=user.titleid -- forced title
	
	dat={}
	
	dat.id=tonumber(user.fud.id) -- need a forum id
	
	dat.data=msg_to_str(newdata,{})
	
	dat.cookies_zom =user.cookies_zom  or 0
	dat.cookies_wolf=user.cookies_wolf or 0
	dat.cookies_vamp=user.cookies_vamp or 0
	dat.cookies_chav=user.cookies_chav or 0
	dat.cookies_man =user.cookies_man  or 0
	
	dat.color =user.color  or 0
	if type(dat.color)=="string" then dat.color=tonumber(dat.color,16) end
	
	dat.bff=user.bff -- name of best friend forever
	
	if dat.color==0 then dat.color=nil end
	
	dat.form=user.form or "human"

	local idx=1
	local row={}
		
	row.names={}
	row[1]={}
	
--dbg(serialize(dat))

	for i,v in pairs(dat) do -- build and fixup mysql data
	
		row.names[idx]=i
		
		if type(v)=="string" then
		
			if v=="" then
			
				row[1][idx]="DEFAULT"
				
			else
		
				row[1][idx]=mysql_escape(v)
			
			end
			
		else
		
			row[1][idx]=v
		
		end
		
		idx=idx+1
	
	end
		
	local q=spew_mysql_make_set("spew_users",row)
	
	
	
	
	lanes_sql_noblock(q)
	
-- if it goes wrong there is nothing to be done so we ignore returns
-- also we have no need to block, so this write will just get queued up and done at some point in the future




--[[ old file save

	str=msg_to_str(dat,{})
		
	local file = io.open("users/"..string.lower(user.name)..".txt","w")
	if file then
	
		file:write(str)
	
		file:close()
	end
	
]]

	
end


-----------------------------------------------------------------------------
--
-- put all cookies onto the floor if we are a registered user...
--
-- this remove all cookies from your hands, so you will have 0 cookies afterwards
--
-----------------------------------------------------------------------------
function floor_cookies(user)

	if user.cookies and user.cookies>0 then -- maybe save
	
		if user_confirmed(user) then -- save
		
			data.saved_cookies[ string.lower(user.name) ]=user.cookies
		
		end
	
		user.cookies=0
		
	end
end


-----------------------------------------------------------------------------
--
-- request ban help
--
-----------------------------------------------------------------------------
function user_cthulhu_cookies(user)

	if ( user.cookies and user.cookies>=1 ) then
		
		local used_cookies=clear_status_cthulhu(user.name,user.cookies)
		
		user.cookies=user.cookies-used_cookies
		
		if used_cookies > 0 then
			roomcast( user.room , {cmd="note",note="notice",arg1=user.name.." has snackrificed "..used_cookies.." cookies to the great god cthulhu!"} )
			roomcast( user.room , {cmd="note",note="notice",arg1=user.name.." "..get_banedfor_string(user.name)} )
		end
		
		return
	else
	
		usercast( user , {cmd="note",note="notice",arg1=user.name.." "..get_banedfor_string(user.name)} )
		return
	end
end

-----------------------------------------------------------------------------
--
-- get a users bff or nil if they are not logged in etc
--
-----------------------------------------------------------------------------
function user_bff(user)

	if not user.bff then return nil end
--[[	
	local gbff
	if data.god_bff then gbff=data.god_bff[user.bff] end
	
	if gbff and gbff==user.name then
		return true
	end
]]
	local bff=get_user(user.bff)
	
	if not bff then return nil end
	
	if bff.bff == user.name then -- BFFs must be mutual
	
		return bff
		
	end
	
	return nil
end
-- are they a friend of the gods?
function user_god_bff(user)
	if not user.bff then return nil end
	
	local gbff
	if data.god_bff then gbff=data.god_bff[user.bff] end
	
	if gbff and gbff:lower()==user.name:lower() then
		return true
	end

	return nil
end

-----------------------------------------------------------------------------
--
-- get a user formrank as a small code
--
-----------------------------------------------------------------------------
function user_formrank_code(user)

local s
local num=user_rank(user)


	if     user.form=="wolf" then s="w"
	elseif user.form=="zom"  then s="z"
	elseif user.form=="vamp" then s="v"
	elseif user.form=="chav" then s="c"
	else                          s="h" end
	
	s=s..num

	return s
end

-----------------------------------------------------------------------------
--
-- get the current bank of a user, may include an adjustment
--
-----------------------------------------------------------------------------
function user_rank_bank(user,form)

	local form=form or (user.form or "man")
	
	local num=( user["cookies_"..form] ) or 0

	local c=0
	
	if form=="man" then -- add the vest to your man bank
	
		c=force_floor(vest_convert(user.vest , user.vestid , "EUR" ))
		
		num=num+c

	end

	return num,c
end

-----------------------------------------------------------------------------
--
-- how many more cookies you need to give the bot to level up
--
-----------------------------------------------------------------------------
function user_rank_need(user)

	if not user.fud then return 0 end
	if is_god(user.name) then return 0 end
	
	if force_floor(user.fud.users_opt/131072)%2 == 1 then
	
		local num=user_rank_bank(user)

		if     num<    500 then return      500-num
		elseif num<   1000 then return     1000-num
		elseif num<   2000 then return     2000-num
		elseif num<   4000 then return     4000-num
		elseif num<   8000 then return     8000-num
		elseif num<  16000 then return    16000-num
		elseif num<  32000 then return    32000-num
		elseif num<  64000 then return    64000-num
		elseif num< 128000 then return   128000-num
		elseif num< 256000 then return   256000-num
		elseif num< 512000 then return   512000-num
		elseif num<1024000 then return  1024000-num
		elseif num<2048000 then return  2048000-num
		elseif num<4096000 then return  4096000-num
		end

		return 0
		
	end
	
	return 0 -- not finished signup process so still a guest

end

-----------------------------------------------------------------------------
--
-- the difference in rank between a and b (a-b)
--
-----------------------------------------------------------------------------
function user_rank_diff(a,b)

	return user_rank(a)-user_rank(b)
end


-----------------------------------------------------------------------------
--
-- get the current highest bank of a user
--
-----------------------------------------------------------------------------
function user_bank(user)

	local num=0
	
	if num<user.cookies_zom  then num=user.cookies_zom  end
	if num<user.cookies_wolf then num=user.cookies_wolf end
	if num<user.cookies_vamp then num=user.cookies_vamp end
	if num<user.cookies_chav then num=user.cookies_chav end
	if num<user.cookies_man  then num=user.cookies_man  end

	return num
end


-----------------------------------------------------------------------------
--
-- get the current highest bank rank of a user
--
-----------------------------------------------------------------------------
function user_bankrank(user)

	if not user then return 0 end
	
local name=string.lower(user.name)

	if is_god(user.name) then return 69 end
	if is_bot(user.name) then return 68 end
	if not user.fud then return 0 end
	if force_floor(user.fud.users_opt/131072)%2 ~= 1 then return 0 end -- not finished signup process so still a guest
	
	local num=user_bank(user)
	
	local ret=0
	
	if     num<    500 then ret=1
	elseif num<   1000 then ret=2
	elseif num<   2000 then ret=3
	elseif num<   4000 then ret=4
	elseif num<   8000 then ret=5
	elseif num<  16000 then ret=6
	elseif num<  32000 then ret=7
	elseif num<  64000 then ret=8
	elseif num< 128000 then ret=9
	elseif num< 256000 then ret=10
	elseif num< 512000 then ret=11
	elseif num<1024000 then ret=12
	elseif num<2048000 then ret=13
	elseif num<4096000 then ret=14
	else                    ret=15
	end
	
	return ret
end

-----------------------------------------------------------------------------
--
-- get users clan rank as a number, 0 is guest 1 is vip 69 is god
--
-----------------------------------------------------------------------------
function user_rank(user)

	if not user then return 0 end
	
local name=string.lower(user.name)

	if is_god(user.name) then return 69 end
	if is_bot(user.name) then return 68 end
	if data.tagged_name==name then return 1 end -- when you are it you are forced to level 1
	if not user.fud then return 0 end
	if force_floor(user.fud.users_opt/131072)%2 ~= 1 then return 0 end -- not finished signup process so still a guest
	
	if day_flag_get("*","force_level") then return day_flag_get("*","force_level") end
	
	local num=user_rank_bank(user)
		
	local ret=0
	
	if     num<    500 then ret=1
	elseif num<   1000 then ret=2
	elseif num<   2000 then ret=3
	elseif num<   4000 then ret=4
	elseif num<   8000 then ret=5
	elseif num<  16000 then ret=6
	elseif num<  32000 then ret=7
	elseif num<  64000 then ret=8
	elseif num< 128000 then ret=9
	elseif num< 256000 then ret=10
	elseif num< 512000 then ret=11
	elseif num<1024000 then ret=12
	elseif num<2048000 then ret=13
	elseif num<4096000 then ret=14
	else                    ret=15
	end
	
-- crowns before furrys	
	if data.crowns and data.crowns[name] then -- another adjustment?
		ret=ret+data.crowns[name]
	end

	if day_flag_get(user.name,"wolf_knockdown") and user.form~="wolf" then ret=ret-1 end -- lower the level if a wolf has knocked this user down
	if day_flag_get(user.name,"wolf_knockdown2") then ret=force_floor(ret/2) end -- lower the level if a wolf has knocked this user down
	
	
	if ret<0 then ret=0 end
	
	return ret
end


local clan_rank_names=
{
	zom =
	{
		[0]="guest",
		"VIP",
		
		"fiend",
		"scourge",
		"beast",
		"hunter",
		"slayer",
		"ronin",
		"assassin",
		"warrior",
		"cenobite",
		"general",
		"stinky",
		
		[68]="BOT",
		[69]="GOD",
	},
	vamp=
	{
		[0]="guest",
		"VIP",
		
		"fiend",
		"esquire",
		"rogue",
		"disciple",
		"savant",
		"knight",
		"warlock",
		"loremaster",
		"priest",
		"lord",
		"lady-boy",
		
		[68]="BOT",
		[69]="GOD",
	},
	wolf=
	{
		[0]="guest",
		"VIP",
		
		"fiend",
		"reaver",
		"stalker",
		"forsaker",
		"corruptor",
		"bloodhound",
		"beastmaster",
		"infiltrator",
		"berserker",
		"warleader",
		"furry-fury",
		
		[68]="BOT",
		[69]="GOD",
	},
	man=
	{
		[0]="guest",
		"VIP",
		
		"sign holder",
		"greeter",
		"shelf stacker",
		"till operator",
		"floor manager",
		"intern",
		"paper puncher",
		"CFO",
		"CEO",
		"retiree",
		"ex-retiree",


		[68]="BOT",
		[69]="GOD",
	},
	chav=
	{
		[0]="guest",
		"VIP",
		
		"wearing one goldie lookin chain",
		"wearing two goldie lookin chains",
		"wearing three goldie lookin chains",
		"wearing four goldie lookin chains",
		"wearing five goldie lookin chains",
		"wearing six goldie lookin chains",
		"wearing seven goldie lookin chains",
		"wearing eight goldie lookin chains",
		"wearing nine goldie lookin chains",
		"wearing ten goldie lookin chains",
		"wearing eleven goldie lookin chains",


		[68]="BOT",
		[69]="GOD",
	},
}


data.clan_rank_names=clan_rank_names


-----------------------------------------------------------------------------
--
-- get users clan rank as a name
--
-----------------------------------------------------------------------------
function user_rank_name(user)


local num=user_rank(user)
local str

	if user.title then
		if user.titleid then
			if user.titleid<0 then
			
				local ts=data.clan_rank_names[ user.form or "man" ]
				local tr=num
				local n=-user.titleid
				if n > tr then n=tr	end
				user.title=ts[n] or ts[2]
				
				return user.title.." ("..num..")"
			end
		end
		return user.title.." ("..num..")"
	end -- return title rather than rank name
	
	str=(clan_rank_names[user.form] or clan_rank_names.man)[num]
		
	str=(str or "").." ("..num..")"
	
	return str
end

-----------------------------------------------------------------------------
--
-- is this a signed up user who has confirmed their email (these get special privileges)
--
-----------------------------------------------------------------------------
function user_confirmed(user)

	if not user.fud then return false end
	
	if force_floor(user.fud.users_opt/131072)%2 == 1 then return true end
	
	return false

end

-----------------------------------------------------------------------------
--
-- is this a signed up user who has confirmed their email (these get special privileges)
--
-----------------------------------------------------------------------------
function user_signedup(user)

	if user.fud then return true end
	
	return false

end

-----------------------------------------------------------------------------
--
-- what form this user is in (this is lost on logout)
--
-----------------------------------------------------------------------------
function user_form(user)

	if not user.form then return "human"
	elseif user.form=="wolf" then return "werewolf"
	elseif user.form=="vamp" then return "vampire"
	elseif user.form=="zom" then return "zombie"
	elseif user.form=="chav" then return "chav"
	end	
	return "human"

end

-----------------------------------------------------------------------------
--
-- check if it is time to clear all day flags
--
-----------------------------------------------------------------------------
function day_flags_reset_check()

local day=force_floor(os.time()/(60*60*24))


	if ( not data.day_flags_day ) or ( day > data.day_flags_day ) then -- a new day dawns, throw away all the old flags

		day_flags_reset()
	
	end

end
	
-----------------------------------------------------------------------------
--
-- clear all day flags
--
-----------------------------------------------------------------------------
function day_flags_reset()

	data.day_flags={} -- things that should only happen once a day	
	data.day_flags_day=force_floor(os.time()/(60*60*24)) -- and the last day GMT that it happened

-- let pet cookie awards persist for at least a day but no longer

	data.saved_pet_cookies_yesterday=data.saved_pet_cookies
	data.saved_pet_cookies={}

end
	
-----------------------------------------------------------------------------
--
-- get a day flag
--
-----------------------------------------------------------------------------
function day_flag_get(name,flag)

local flags=data.day_flags[string.lower(name)]

	if flags and flags[flag] then return flags[flag] end

	return false
	
end

-----------------------------------------------------------------------------
--
-- set a day flag
--
-----------------------------------------------------------------------------
function day_flag_set(name,flag,dat)

local flags=data.day_flags[string.lower(name)] or {}

	flags[flag]=dat or true
	
	data.day_flags[string.lower(name)]=flags

end

-----------------------------------------------------------------------------
--
-- clear a day flag
--
-----------------------------------------------------------------------------
function day_flag_clear(name,flag)

local flags=data.day_flags[string.lower(name)] or {}

	flags[flag]=nil
	
	data.day_flags[string.lower(name)]=flags

end


-----------------------------------------------------------------------------
--
-- check if a day counter is below the max if an amount is added
-- add that amount and return true if it is
-- return false if it isnt
--
-----------------------------------------------------------------------------
function day_flag_addcheck(name,flag,top,num)

local flags=data.day_flags[string.lower(name)] or {}

	local n=( flags[flag] or 0 )
	
	if num then 
		num=tonumber(num)
		if num~=num then num=0 end
	end
	
	if n then 
		n=tonumber(n)
		if n~=n then n=0 end
	end
		n=n+num
	
	if (not top) or (n<=top) then
	
		flags[flag]=n
		
		data.day_flags[string.lower(name)]=flags
		
		return true

	end

	return false
	
end

-----------------------------------------------------------------------------
--
-- return a day counter as a number 0 if does not exist yet
--
-----------------------------------------------------------------------------
function day_flag_get_num(name,flag)

local flags=data.day_flags[string.lower(name)] or {}
local num=flags[flag]

	if num then 
		num=tonumber(num)
		if num~=num then num=0 end
	end
	
	return num
	
end

-----------------------------------------------------------------------------
--
-- find a user by name, case is ignored
--
-----------------------------------------------------------------------------
function get_user(name)

	if not name then return nil end
	
	local u=data.names[ string.lower(name) ]
	
	if u and u.brain then return nil end -- cant find a bot
	
	return u
	
end

-----------------------------------------------------------------------------
--
-- find a user or bot by name, case is ignored
--
-----------------------------------------------------------------------------
function get_user_or_bot(name)

	if not name then return nil end
	
	local u=data.names[ string.lower(name) ]
	
	return u
	
end
-----------------------------------------------------------------------------
--
-- find a users forum ID even if they are not logged in
--
-----------------------------------------------------------------------------
function get_user_forum_id(name)

local con,cur,fid

	if not name then return nil end
	
	name=string.lower(name)
	
	local user=get_user(name)
	
	if user and user.fud and user.fud.id then -- check if we have it cached before we hit the db
	
		return tonumber(user.fud.id)
	
	end
	
	data.forum_ids=data.forum_ids or {} -- cache
	local id
	
	id=data.forum_ids[name]
	if id then return id end

	local ret=lanes_sql("SELECT id FROM "..cfg.fud_prefix.."users WHERE login="..mysql_escape(name))
	
	id=ret[1] and ret[1][1]
	
	if id then
		id=tonumber(id)
		
		data.forum_ids[id]=name
		data.forum_ids[name]=id
	end
	
	return id

end

-----------------------------------------------------------------------------
--
-- find a users name from their forum id
--
-----------------------------------------------------------------------------
function get_user_name_from_forum_id(id)

local con,cur,fid

	if not id then return nil end
	
	id=tonumber(id)

	data.forum_ids=data.forum_ids or {} -- cache
	local name
	
	name=data.forum_ids[id]
	if name then return name end
	
	local ret=lanes_sql("SELECT login FROM "..cfg.fud_prefix.."users WHERE id="..id)
	
	name=ret[1] and ret[1][1]
	
	if name then
		name=string.lower(name)
	
		data.forum_ids[id]=name
		data.forum_ids[name]=id
	end

	
	return name

end

-----------------------------------------------------------------------------
--
-- find a user idstring by name, case is ignored
--
-----------------------------------------------------------------------------
function get_idstring(name)
local alt

	if not name then return "*" end
	
-- alt is so even people who havent logged in recently can be banned by name

	alt=string.lower( string.gsub(name, "[^0-9a-zA-Z%-_]+", "" ) ) -- make sure name only contains good characters
	
	if not alt or alt=="" then alt="*" end -- use "*" as unknown return value
	
	return data.idstrings[ string.lower(name) ] or alt

end

-----------------------------------------------------------------------------
--
-- get user id string, which is either the ip if a guest or the lowercase name if logged in
--
-- returns "*" if neither ( probably a bot , do not ban bots :)
--
-----------------------------------------------------------------------------
function user_idstring(user)
	
	if user_confirmed(user) then 
		return string.lower(user.name)
	else
		if user.client then	
			local r=user.client:getpeername()
			if r then
				r=str_split(":",r)
				if r[1] then
					r=r[1]
				end
			end
			return r or "*"
		end
	end
	
	return "*"
		
end

-----------------------------------------------------------------------------
--
-- get user ip string, so we can check if people are on the same ip
--
-- returns "*" if not an ip ( probably a bot , do not ban bots :)
--
-----------------------------------------------------------------------------
function user_ip(user)
	
	if user.client then	
			local r=user.client:getpeername()
			if r then
				r=str_split(":",r)
				if r[1] then
					r=r[1]
				end
			end
		return r or "*"
	end
		
	return "*"
	
end

-----------------------------------------------------------------------------
--
-- get user ipnum so we can check if people are on the same ip
--
-- returns 0 if not an ip ( probably a bot , do not ban bots :)
--
-----------------------------------------------------------------------------
function user_ipnum(user)

	if user.ip then return user.ip end

local ipstr=user_ip(user)

	if ipstr=="*" then
		user.ip=0
	else
		user.ip=ipstr_to_number(ipstr)
	end
	
	return user.ip
	
end

-----------------------------------------------------------------------------
--
-- remember name of this user in idstrings table, call when ever a new name is used
--
-- if fud user then the name is stored in table
-- if guest then the ipstring is stored in table
--
-----------------------------------------------------------------------------
function remember_idstring(user)
	
	if user.name~="me" then
	
		data.idstrings[ string.lower(user.name) ]=user_idstring(user)
		
		local ipnum=user_ipnum(user)			
		data.ipmap[string.lower(user.name)]=ipnum -- map name to ipnum, you should now be able to attack guests and hit their real accounts... Less places to hide.
		
		if user_signedup(user) then -- track who uses an IP but only of registered users, ignore guests
		
			local tab=data.ipwho[ipnum] or {} -- get or create table for this ip
			data.ipwho[ipnum]=tab
			
			tab[user.name]=true -- fill table with names
		
		end
		
	end
end

-----------------------------------------------------------------------------
--
-- return a table of names of other registered users that share an ip we know for this users name
-- nil if we have no info
-- otherwise a table of names ( which the input name will also be in )
--
-----------------------------------------------------------------------------
function get_shared_names_by_ip(name)

local ret
	
	local ipnum=data.ipmap[string.lower(name)]
	
	if not ipnum then return nil end
	
	local tab=data.ipwho[ipnum]
	
	local done_name=false
	
	if tab then
	
		ret={}
	
		for n,b in pairs(tab) do
		
			if string.lower(name)==string.lower(n) then done_name=true end
		
			if is_god(n) then return nil end -- do not meddle in the affairs of gods :)
		
			table.insert(ret,n)
		
		end
	
		if not done_name then table.insert(ret,name) end

	end
	
	return ret
end

-----------------------------------------------------------------------------
--
-- clear idstrings that are not in use
--
-----------------------------------------------------------------------------
function check_idstrings()

local keep,kill

	keep=0
	kill=0

	for n,v in pairs(data.idstrings) do
	
		if not get_user(n) then
		
			data.idstrings[ n ]=nil
			
			kill=kill+1
		else
			
			keep=keep+1
		end
	
	end
	
dbg("IDSTRINGS: killed "..kill.." : kept "..keep.."\n")
	
end

-----------------------------------------------------------------------------
--
-- clear ipmaps that are not in use
--
-----------------------------------------------------------------------------
function check_ipmap()

local keep,kill

	keep=0
	kill=0
	
	local look={}

	for n,v in pairs(data.ipmap) do
	
		if not get_user(n) then
		
			data.ipmap[ n ]=nil
			
			kill=kill+1
			
		else
			
			keep=keep+1
		end
		
		look[v]=(look[v] or 0) + 1
	
	end

dbg("IPMAP: killed "..kill.." : kept "..keep.."\n")


	for ip,c in pairs(look) do -- many guest accounts == reduced priviligies
	
		if c>1000 then -- naughty ip
		
			data.ipsux[ip]=true
		
dbg("IPSUX: "..ip.."\n")

		end
	
	end

	
	
end

-----------------------------------------------------------------------------
--
-- clear spam data that is not currently in use
--
-----------------------------------------------------------------------------
function check_spam()

local keep=0
local kill=0

	for ip,v in pairs(data.spam) do
	
		keep=keep+1
		
		local w=data.ipwho[ip]
		
		if w then
		
			local count=0
			for n,b in pairs(w) do
			
				if get_user(n) then
					count=count+1
				end
	
			end
			
			if count==0 then
			
				data.spam[ip]=nil
				kill=kill+1
			
			end
	
		else
			
			data.spam[ip]=nil
			kill=kill+1
		
		end
	
	end
	
	keep=keep-kill
	
dbg("IPSPAM: killed "..kill.." : kept "..keep.."\n")

end

-----------------------------------------------------------------------------
--
-- find a user by name, case is ignored, this is a user cmd and returns a notice msg
--
-----------------------------------------------------------------------------
function user_msg_find(user,name)

	local msg={cmd="note",note="notice",arg1="Sorry but "..name.." is not logged in."}

	local u=get_user(name)
	
	if u then
	
		if u.room then
		
			if u.room.name then
			
				msg.arg1=name.." is in room "..u.room.name
			
			end
		
		end
	
	end
	
	
	return msg	
end



-----------------------------------------------------------------------------
--
-- get maximum number of cookes this user can give today and the amount they have given
--
-- local given_max,given=username_given_cookies_max(user.name,form)
--
-- given is returned only if form is passed in, since it is deferent for each form
--
-----------------------------------------------------------------------------
function username_given_cookies_max(name,form)

local maxx=4000

	if is_god(name) then
	
		maxx=maxx*100
	
	end
	
	if form then
	
		return maxx , day_flag_get_num(name,"snackrifice_cookies_"..form) or 0
		
	else
		return maxx
	end
	
end

-----------------------------------------------------------------------------
--
-- client is requesting specific user info
--
-----------------------------------------------------------------------------
function user_stat(user)

local name=string.lower(user.name)

local stat=user_form(user).." "..user_rank_name(user)

	if day_flag_get(user.name,"wolf_knockdown") and user.form~="wolf" then

		stat=stat.." *slapped*"

	end
	
	if day_flag_get(user.name,"wolf_knockdown2") then

		stat=stat.." *punched*"

	end
	
	if day_flag_get(user.name,"zom_bork") then

		stat=stat.." *borked*"

	end
	
	if data.tagged_name==string.lower(user.name) then
	
		stat=stat.." *tagged*"
		
	end
	
	if data.crowns and data.crowns[name] then -- another adjustment?
	
		local crown=data.crowns[name]
		
		if crown<0 then
			stat=stat.." *crown"..crown.."*"
		elseif crown>0 then
			stat=stat.." *crown+"..crown.."*"
		end
	end
	
	
	return stat
	
end


-----------------------------------------------------------------------------
--
-- client is requesting specific user info
--
-----------------------------------------------------------------------------
function user_msg_info(user, msgin)

local name=msgin.name

local u=get_user(name)

local wetard=wetards[ string.lower(name or "") ]

local msg

	msg={cmd="note",note="info",info="user",name=name}
	
	-- default details
	
	local seed=tonumber(string.sub(lash.MD5.string2hex(name),-4,-1),16)
	
	msg.stat="-" -- this means user is not logged in and we know nothing	
	msg.avatar="http://swf.wetgenes.com/wavys/random.php/"..seed.."/t.png" -- "http://swf.wetgenes.com/forum/images/custom_avatars/12.png"
	
	msg.gameid="-"
	msg.gamename="-"
	msg.joined=0
	
	-- get fud avatar
	
	if u then
	
		msg.gameid=u.gameid
		msg.gamename=u.gamename
	
		msg.stat="the "..user_stat(u)

		if u.fud then -- a real user, get avatar / join time
		
			msg.joined=u.fud.join_date
				
			if u.fud.avatar_loc then
			
				local aa=str_split('"',u.fud.avatar_loc)
				
				if aa[2] then
				
					msg.avatar=aa[2] -- get url and try to clean it up a little
					msg.avatar=string.gsub(msg.avatar,"http://wetgenes.com/", "http://swf.wetgenes.com/")
					msg.avatar=string.gsub(msg.avatar,"http://www.wetgenes.com/", "http://swf.wetgenes.com/")
			
				end
			end
		end
	end
	
	-- check for built in bot overides on all info.
	
	if wetard then
	
		for i,v in pairs(wetard) do
		
			msg[i]=v
			
		end
	
	end
	
	return msg
end

-----------------------------------------------------------------------------
--
-- return a msg containing a list of users
--
-----------------------------------------------------------------------------
function list_users_msg(user,msgin,all)

local s
local msg
local room


	msg={cmd="note",note="users",room="limbo",list=""}
	
	if not user.room then return msg end

	room=user.room.name
	
	msg.room=room
	
	s=""

--	user.room.user_count=0
	
	for i,v in pairs(data.users) do
	
-- chekc room name for now until we build room lists on join/parts

		if i.name~="me" and (i.room.name==room or all) then -- ignore the army of mes
		
			if s~="" then s=s.."," end
			
			s=s .. i.name ..":".. i.gamename ..":".. (i.gameid or 0) .. ":" .. user_formrank_code(i) .. ":" .. (i.color or "")
			
--			if all then s=s..":"..i.room.name end -- maybe include room name at end
			
--			user.room.user_count=user.room.user_count+1
		end
	
	end
	
--dbg(s,"\n")

	msg.list=s

	return msg
end




-----------------------------------------------------------------------------
--
-- change name, call after doing login checks to change the users name
--
-----------------------------------------------------------------------------
function login_newname(user,name,fud)
	
	user.loaded_from_db=false

	if fud then

		fud.date=os.date( "*t" , (tonumber(fud.join_date or 0) or 0) ) -- get date information?


		if force_floor(fud.id) < 2 then -- rename anonymous coward to me
		
			name="me"
			fud=nil
			
		end
	
	end
	
	user_save_data(user) -- save what user data we have on file
	floor_cookies(user)

	if data.names[ string.lower(user.name) ]==user then -- remove old name from names look up table
	
		data.names[ string.lower(user.name) ]=nil
		
	end

	del_player(user) -- remove any player data associated with this user, tell the games we have left etc

	
-- if someone else has this name, then we need to rename them to a me
	
	
	if user.name~="me" then
		
log(user.name,"rename",name)
		
	end
		
	if name=="me" then
	
		roomcast(user.room,{cmd="note",note="rename",arg1=name,arg2="me",arg3="me"},user)
		user.name=name
		user.fud=nil
			
	else
		
		if data.names[ string.lower(name) ] then
			
log(name,"nameclash")

			local u=data.names[ string.lower(name) ]
			
			user_save_data(u) -- save what user data we have on file
			floor_cookies(u)

			join_room(u,data.rooms.limbo)
			roomcast(u.room,{cmd="note",note="rename",arg1=name,arg2="me",arg3="me"},u)
			u.name="me"
			u.fud=nil
			usercast(u,{cmd="note",note="warning",arg1="you can not be logged in twice"})
		
			data.names[ string.lower(name) ]=nil -- stop multiple pointers bug :)
		end
		
		
		if fud then
			roomcast(user.room,{cmd="note",note="rename",arg1=user.name,arg2=name,arg3="user"},user)
			user.name=name
			user.fud=fud
log(user.name,"login")
		else
			roomcast(user.room,{cmd="note",note="rename",arg1=user.name,arg2=name,arg3="guest"},user)
			user.name=name
			user.fud=nil
log(user.name,"guest")
		end
			
		data.names[ string.lower(name) ]=user
	
	end

	
	if user.fud then -- this is not for guests...
	
		local ipnum=user_ipnum(user)
		
		if ipnum~=0 then -- bots have a 0 ip
		
			local shared=data.alt_names[string.lower(name)] or 0
			if shared<0 then shared=0 end
			
--[[
			if shared>1 then -- remember ip
				if ( not data.alt_ips[ipnum] ) or ( shared > data.alt_ips[ipnum] ) then
					data.alt_ips[ipnum]=shared
				end
			end
			
			shared=data.alt_ips[ipnum] or 0
			if shared<0 then shared=0 end
]]
			
			-- now kill any conections over the allowed amount
			
			local count=0
			local names={}
			for u,c in pairs(data.users) do
			
				if (ipnum==user_ipnum(u)) and (u~=user) then -- alt?
				
					if u.fud and not data.alt_names[string.lower(u.name)] then -- a real login and not multiallowed
					
						table.insert(names,u.name)
						count=count+1
						
						if count>shared then -- tomany people from this ip, kill this user
						
							user_save_data(u) -- save what user data we have on file
							floor_cookies(u)

							join_room(u,data.rooms.limbo)
							roomcast(u.room,{cmd="note",note="rename",arg1=name,arg2="me",arg3="me"},user)
							u.name="me"
							u.fud=nil
							usercast(u,{cmd="note",note="warning",arg1="Sorry but you can not share ips. Please ask in the forum for this privilage."})
							
						end
					end
				end
			end
			
			if names[1] then
				usercast(user,{cmd="note",note="warning",arg1="Be aware that you are sharing IPs with : "..str_join_english_list(names).."."})
			end
		end
		
	end
	
	usercast(user,{cmd="none"}) -- bugfix?
	usercast(user,{cmd="note",note="name",arg1=user.name}) -- ack login
				
	remember_idstring(user)

-- restore data and form

	user_load_data(user) -- load in what user data we have on file

-- change room?

	if ((not user.room) or (user.room.name=="limbo")) and (user.name~="me") then -- automatically move out of limbo when you log on whilst in limbo
	
		join_room_pub(user)
	
	elseif (user.room.name~="limbo") and (user.name=="me") then -- automatically move back to limbo when you get turned into a me

		join_room(user,data.rooms.limbo)
		
	end	

-- reload saved cookies

	if data.saved_cookies[ string.lower(user.name) ] then
	
		user.cookies=data.saved_cookies[ string.lower(user.name) ]
	
		data.saved_cookies[ string.lower(user.name) ]=nil
		
		if user.cookies < 1000000000 then -- cap number of saved cookies
			-- do nothing, nan fixes
		else
			user.cookies = 1000000000
		end

		usercast(user,{cmd="note",note="act",arg1="you found "..user.cookies.." cookies on the floor, which is not a safe place to keep them but I guess you were lucky this time."})
		
	end
	
	if user_confirmed(user) then -- give retainer
		
		if not day_flag_get(user.name,"retainer") then
		
			user.cookies= user.cookies + 100
			
			day_flag_set(user.name,"retainer")
		
			usercast(user,{cmd="note",note="act",arg1="as a registered user you get +100 cookies for your first login of the day"})
			
		end
		
	end

-- lets  not let the gods run out of cookies and give lotsa cookies when run locally for testing

	if is_god(user.name) or cfg.localadmin then
		if user.cookies < 10000 then
			user.cookies=user.cookies + 10000
		end
	end
	

	if fud and fud.unread_forum_count > 0 then -- we have mail
	
			usercast(user,{cmd="lnk",frm="cthulhu",txt="There are new forum posts ("..fud.unread_forum_count.."). Click here to read them.",lnk="http://www.wetgenes.com/forum/"})
	
	elseif not fud then
			usercast(user,{cmd="lnk",frm="cthulhu",txt="There is an entire forum unread. Click here to read it.",lnk="http://www.wetgenes.com/forum/"})
	
	end
	
	if fud and fud.unread_mail_count > 0 then -- we have mail
	
			usercast(user,{cmd="lnk",frm="cthulhu",txt="You have mail ("..fud.unread_mail_count.."). Click here to read it.",lnk="http://www.wetgenes.com/forum/index.php?t=pmsg"})
	
	end
	
-- display most recent tlog?

	if data.tlog then
		for i=1,3 do
			local tlog=data.tlog[i]
			if tlog then
				local tim=os.time()-tlog.time
				
				if tim<100 then
					tim=math.floor(tim).." seconds"
				elseif tim<100*60 then
					tim=math.floor(tim/60).." minutes"
				elseif tim<100*60*60 then
					tim=math.floor(tim/(60*60)).." hours"
				else
					tim=math.floor(tim/(60*60*24)).." days"
				end
				usercast(user,{cmd="note",note="act",arg1=tim.." ago "..tlog.str})
				
			end
		end
	end
	
	if fud and fud.id then -- check pets for earnings
	
	local id=tonumber(fud.id)
	local pay=0
	
		for _,v in ipairs{"saved_pet_cookies","saved_pet_cookies_yesterday"} do
		
			if data[v][id] then
			
				pay=pay+data[v][id]
				data[v][id]=nil
			
			end
	
		end
		
		pay=force_floor(pay)
		
		if pay>0 then
		
			user.cookies=user.cookies+pay
			usercast(user,{cmd="note",note="act",arg1="Your pets have been working hard and earned you "..pay.." cookies."})
		end
		
		local offers=lanes_sql([[SELECT count(*) FROM spew_escrow WHERE owner=]]..fud.id..[[ AND state=1]])
		offers=tonumber( ( offers[1] and offers[1][1] ) or 0)
		
		if offers>0 then
		
			usercast(user,{cmd="lnk",frm="cthulhu",txt="You have escrow offers ("..offers.."). Click here to accept or cancel them.",lnk="http://like.wetgenes.com/-/escrow"})
		end
	
	end
	
	if user.fud then
		item_load_all(user.name) -- load in any items this named user has
		
-- if this ip has been used by a mud, add this user to the mudlist...
		
		for i,v in ipairs( get_shared_names_by_ip(user.name) or {} ) do
		
			if is_mud(v) then
				if not data.mud_names[ string.lower(user.name) ] then -- if not already set
					data.mud_names[ string.lower(user.name) ]=true
log(v,"mud",user.name) -- log the mudding of
				end
				break
			end
		
		end
	
	end

-- auto gimp punishment?
	local gimpname=data.gimp_names[ user.name ]
	if gimpname then -- auto gimp on login
	
		local gimped=day_flag_get(user.name,"gimp")
		
		if not gimped then
			day_flag_set(user.name,"gimp",gimpname)
		end
	end
	
--[[
	if is_swear(user.name) then -- add username to mudlist
		data.mud_names[ string.lower(user.name) ]=true
	end
]]	
			
	if is_drama(user.name) then  -- add this users ip to the drama_ip list?
-- check for truce? if all members of the dramalist create a circular bff chain? hmmmm
		add_dramaip(user_ipnum(user),is_drama(user.name))
	end

-- check for birthdays	


	if fud and fud.date and data.date then
	
		if fud.date.day == data.date.day then
		
			if fud.date.month == data.date.month then
			
				local age=data.date.year - fud.date.year
				
				if age>0 then -- not the first day
				
					day_flag_set(user.name,"event","birthday")
					
	usercast(user,{cmd="say",frm="cthulhu",txt="Happy wet birfday "..user.name..". Congratulations you are "..(age).." years old today."})
	
	
					data.crowns_birthdays=data.crowns_birthdays or {}
					data.crowns_birthdays[string.lower(user.name)]=true
				
				end
			
			end
		
		end
	
	
	end
	if fud and fud.join_date then --need to know your age
		local t=math.floor(os.time()/(60*60*24)) -- days now
		local d=(tonumber(fud.join_date or 0) or 0) -- time when regged
		local days=math.floor((d/(60*60*24))) -- convert registration to days
		if days>0 then days=t-days end -- convert days to age if it looks valid
		local months=math.floor(days/28) -- get age of account in luna months (4 weeks)
		if months>0 then
			if (days%28)==0 then -- its your furry birthday
				data.crowns_furry_birthdays=data.crowns_furry_birthdays or {}
				data.crowns_furry_birthdays[string.lower(user.name)]=true
				usercast(user,{cmd="say",frm="cthulhu",txt="Happy furry birfday "..user.name..". Congratulations you are "..(months).." months old today."})
			end
		end
	end

	build_crowns_for( string.lower(user.name) )

-- slow down people who jump accounts by making them dizzy?

--[[ maybe breaks stuff
local ip=user_ipnum(user)

	if not ( is_bot(user.name) or is_god(user.name) ) then
	
		if data.last_login_time[ip] then
			if (os.time()-data.last_login_time[ip])<60 then
				day_flag_set(user.name,"dizzy",os.time()+60)
			end
		end
		data.last_login_time[ip]=os.time()
		
	end
]]

end

-----------------------------------------------------------------------------
--
-- user/pass login
--
-----------------------------------------------------------------------------
function login_pass(user,msg)
--dbg("login_pass ",user.name," ",msg_to_str(msg),"\n")

local name=string.gsub(msg.name or "", "[^0-9a-zA-Z%-_]+", "" )
local pass=string.gsub(msg.pass or "", "[^0-9a-zA-Z%-_]+", "" )

local ip=user_ipnum(user)

	name=string.gsub(name, "[_]+", "_" ) -- kill multiple _
	
	if (data.ipbadlogins[ip] or 0) > 100 then -- naughty users
		usercast(user,{cmd="note",note="error",arg1="fatal error please contact an admin"})
		return
	end

-- slow down people who jump accounts
	if pass~="" then
		if data.last_login_time[ip] then
			if (os.time()-data.last_login_time[ip])<1 then
			usercast(user,{cmd="note",note="error",arg1="You are logging in too often. Please count to 10 and try again."})
--				data.last_login_time[ip]=os.time()
				return
			end
		end
		data.last_login_time[ip]=os.time()
	end
	
	if string.len(name) > 20 then -- stop sily length names	
		name=string.sub(name,1,20)
	end
	
	if string.len(name) < 3 then -- stop sily length names	
	
		usercast(user,{cmd="note",note="error",arg1="name must be longer than 2 letters -> "..name})
		return
		
	end

	if name == user.name then -- just ignore trying to log on as self
	
		usercast(user,{cmd="note",note="error",arg1="you are already logged on as "..name})
		return
		
	end
	
	join_room(user,data.rooms.limbo)-- kick them into limbo first
		
	if name == "me" then login_newname(user,"me",nil) return end
	local ret=lanes_sql("SELECT * FROM "..cfg.fud_prefix.."users WHERE login="..mysql_escape(name))
	local tab=sql_named_tab(ret,1)
	
	if tab then -- user exists, verify pass
	
		local passOK=false
		
--dbg("SALT : ",tab.salt or "NONE","\n")

		if tab.salt then -- new SHA1 password with salt
		
		 	passOK = ( tab.passwd == lash.SHA1.string2hex( tab.salt .. lash.SHA1.string2hex(pass) ) )
			
		else
		
			passOK = ( tab.passwd == lash.MD5.string2hex(pass) )
			
		end
		
		if passOK then
		
			local unread=lanes_sql([[SELECT count(*) FROM fud26_pmsg WHERE duser_id=]]..tab.id..[[ AND fldr=1 AND read_stamp=0]])
			tab.unread_mail_count=tonumber( ( unread[1] and unread[1][1] ) or 0)

			local lastread=tonumber(tab.last_read)
			local lastread_check=lanes_sql([[SELECT MAX(last_view) FROM fud26_forum_read WHERE user_id=]]..tab.id )
			local lastread2=tonumber( ( lastread_check[1] and lastread_check[1][1] ) or 0)
			if lastread2 > lastread then lastread=lastread2 end
			local funread=lanes_sql([[SELECT count(*) FROM fud26_msg WHERE apr=1 AND post_stamp>]]..lastread )
			tab.unread_forum_count=tonumber( ( funread[1] and funread[1][1] ) or 0)
			
--			data.last_ip[ string.lower(tab.login) ]=user_ipnum(user) -- remember last real password login by ip for mild security
			
			
			login_newname(user,tab.login,tab)
			
		else
	
			data.ipbadlogins[ip]=(data.ipbadlogins[ip] or 0)+1
	
			usercast(user,{cmd="note",note="error",arg1="logon with password failed"})
dbg("login failed password ",name," : ",ip,"\n")
			
--			data.last_login_time[ip]=os.time() -- can only force check one password per sec
		end
		
	else -- user does not exist, logon as guest
	
		if data.names[ string.lower(name) ] then	
			usercast(user,{cmd="note",note="error",arg1="sorry that name is in use"})
		else
			login_newname(user,name,nil)
		end
		
	end
	
end

-----------------------------------------------------------------------------
--
-- session login
--
-----------------------------------------------------------------------------
function login_sess(user,msg)
--dbg("login_sess ",user.name," ",msg_to_str(msg),"\n")
	
	
local sess=string.gsub(msg.sess, "[^0-9a-zA-Z]+", "" )

local ip=user_ipnum(user)

	if data.last_login_time[ip] then
		if (os.time()-data.last_login_time[ip])<1 then
			usercast(user,{cmd="note",note="error",arg1="You are logging in too often. Please count to 10 and try again."})
--			data.last_login_time[ip]=os.time()
			return
		end
	end
	data.last_login_time[ip]=os.time()
	

	join_room(user,data.rooms.limbo)-- kick them into limbo first

-- now moved into another task :)

	local info=lanes_sql([[SELECT
			u.* , s.time_sec , s.sys_id
		FROM ]]..cfg.fud_prefix..[[ses s
			INNER JOIN ]]..cfg.fud_prefix..[[users u ON u.id=(CASE WHEN s.user_id>2000000000 THEN 1 ELSE s.user_id END)
		WHERE ses_id=']]..sess..[[']])

	local tab=sql_named_tab(info,1)
	
	if tab then -- session exists
			
		local unread=lanes_sql([[SELECT count(*) FROM fud26_pmsg WHERE duser_id=]]..tab.id..[[ AND fldr=1 AND read_stamp=0]])
		tab.unread_mail_count=tonumber(unread[1][1] or 0)
		
		local lastread=tonumber(tab.last_read)
		local lastread_check=lanes_sql([[SELECT MAX(last_view) FROM fud26_forum_read WHERE user_id=]]..tab.id )
		local lastread2=tonumber( ( lastread_check[1] and lastread_check[1][1] ) or 0)
		if lastread2 > lastread then lastread=lastread2 end
		local funread=lanes_sql([[SELECT count(*) FROM fud26_msg WHERE apr=1 AND post_stamp>]]..lastread )
		tab.unread_forum_count=tonumber( ( funread[1] and funread[1][1] ) or 0)
			
--dbg( user_ip(user) , " : " , tab.sys_id , "\n")

		if user_ip(user)==tab.sys_id then -- mild security fix, session is locked to ip
		
			login_newname(user,tab.login,tab)
			
		else
		
			usercast(user,{cmd="note",note="error",arg1="Your session does not match your IP, please refresh the page to login or use /login name pass"})
			
dbg("login failed session/ip ",tab.login," : ",ip,"\n")
			
		end
		
		
	else -- user does not exist, logon as guest
	
		usercast(user,{cmd="note",note="error",arg1="logon with session failed"})
		
dbg("login failed session ",sess," : ",ip,"\n")
		
	end

end


-----------------------------------------------------------------------------
--
-- successful conjure
--
-----------------------------------------------------------------------------
local function conjure_success(user,item)
	roomqueue(user.room,{cmd="note",note="act",arg1=
	
	"A minor minion of cthulhu decends upon the room. "..
	"The minion takes one look at "..user.name.." who quickly throws "..item.." into the sky before cowering in a corner. "..
	"The minion snatches "..item.." out of the air and instantly blinks into another dimension. "
	
	})
end

-----------------------------------------------------------------------------
--
-- failure to conjure
--
-----------------------------------------------------------------------------
local function conjure_failure(user)
	roomqueue(user.room,{cmd="note",note="act",arg1=
	
	"A minor minion of cthulhu decends upon the room. "..
	"The minion takes one look at "..user.name.." decides they taste like cookies and swallows them whole. "..
	"The minion circles the room five times before blinking into another dimension. "
	
	})
end

-----------------------------------------------------------------------------
--
-- give cookies to your god to increase rank
-- broadcast a rank advance
-- the cost to change is now powers of 2 so
-- 1 cookie to turn into a rank 0
-- 2 cookies to turn into a rank 1
-- 4 cookies to turn into a rank 2
-- ...
-- 1024 cookies to turn into a rank 10
--
-- the user will have at least num cookies, so no need to check for that, just apply capping
--
-----------------------------------------------------------------------------
function snackrifice_cookies(user,form,num)

local old_rank
local new_rank
local start_rank

local old_form

local new_form=(form or "man")

	start_rank=user_rank(user)
	
	local given_max,given=username_given_cookies_max(user.name,new_form)
	
	if given+num>given_max then -- limit daily amount
	
		num=given_max-given
		
		if num<=0 then -- can give no more today
			return "sorry but you may only feed up to "..given_max.." cookies a day to each bot",0
		end
	end
	day_flag_addcheck(user.name,"snackrifice_cookies_"..new_form,nil,num)
	
	if not is_admin(user.name) then
		user.cookies=user.cookies-num
	end
	
	if num<=0 then -- sanity
		return nil , 0 -- no cookies
	end
	
	
-- perform bank
	
	
	if user.form~=form then -- always turn to form
		old_form=user.form -- but we may have to turn back
		user.form=form
	end

	old_rank=user_rank(user)
	
	user["cookies_"..new_form]=(user["cookies_"..new_form] or 0 ) + num

	new_rank=user_rank(user)
			
	if old_rank ~= new_rank then
		roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has become a "..user_form(user).." "..user_rank_name(user)})
		old_rank=nil -- do not turn back if we gained a rank and the above msg counts as notification
	else
		local need=user_rank_need(user)
		roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." is "..need.." cookies away from their next rank."})
	end
	
	
	if old_form then -- check if we should actually turn or not depending on the level we want to turn into
	
		local cost=2^start_rank -- the higher the level the more it costs doubling each time, so after a while its hard to turn :)
	
		if num>=cost then
		
			roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has turned into a "..user_form(user).." "..user_rank_name(user)})
		
		else
			userqueue(user,{cmd="note",note="act",arg1="it costs "..cost.." cookies to turn into a "..user_form(user).." "..user_rank_name(user)})
			user.form=old_form -- turn back IE dont turn
		end
	end
	
	local tot=0 -- total amount banked
	for i,v in ipairs({"wolf","vamp","zom","chav","man"}) do
		tot=tot+(user["cookies_"..v] or 0)
	end
	
	if tot>16000000 then -- 16 million cookie bank award
	
		feats_award(user,"spew_megabank16")
		
	elseif tot>8000000 then -- 8 million cookie bank award
	
		feats_award(user,"spew_megabank8")
		
	elseif tot>4000000 then -- 4 million cookie bank award
	
		feats_award(user,"spew_megabank4")
		
	elseif tot>2000000 then -- 2 million cookie bank award
	
		feats_award(user,"spew_megabank2")
		
	elseif tot>1000000 then -- 1 million cookie bank award
	
		feats_award(user,"spew_megabank")
	end
	
	user_save_data(user)
	
	
	
	return "Thank you "..user.name.." the "..user_form(user).." "..user_rank_name(user) , num

	
end

-----------------------------------------------------------------------------
--
-- check a user words and apply a real effect if we should
-- return true to not display this act
--
-----------------------------------------------------------------------------
function user_say_check(user,aa)

--[[
	if aa[1]=="gimp" then

		local vic_name=day_flag_get(user.name,"gimp")
		local vic=get_user(vic_name)
		
		if not vic then return end -- we have no gimp to control
		
		if aa[2]=="heel" then -- summon gimp to your side
		
-- chance of releasing gimp on each heel
		
			local r=math.random(25)
			if r==23 then
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has lost their gimp "..vic.name})
				day_flag_clear(user.name,"gimp")
				return
			end
		
			local dizzy=day_flag_get(user.name,"dizzy")

			if dizzy and dizzy>os.time() and not is_admin(user.name) then -- too dizzy to dance again
			
				usercast(user,{cmd="note",note="warning",arg1="you are too dizzy! ("..(dizzy-os.time())..")"})
				return
			end
					
			if vic.room ~= user.room then
			
				roomqueue(vic.room,{cmd="act",frm=vic.name,txt="dances out of the room"})
				join_room_str(vic,user.room.name) -- victim gets yanked as long as they are allowed into the room					
				
			end
			
			if vic.room ~= user.room then -- gimp couldnt come, so master trys to go to gimp
			
				roomqueue(user.room,{cmd="act",frm=user.name,txt="dances out of the room"})
				join_room_str(user,vic.room.name) -- master gets yanked as long as they are allowed into the room					
				
			end
			
			day_flag_set(user.name,"dizzy",os.time()+20) -- the dancer is always dizzy
			
			if vic.room==user.room then -- they are in same room
			
				day_flag_set(vic.name,"dizzy",os.time()+20) -- the victim is only dizzy if they end up in the same room
				roomqueue(vic.room,{cmd="act",frm=vic.name,txt="dances for "..user.name})
			
			else -- room entry was denied
				
				roomqueue(vic.room,{cmd="act",frm=vic.name,txt="pines for "..user.name})
				
			end
		
			
		elseif aa[2]=="say" then -- force gimp to talk
		
			if vic.room==user.room then -- they are in same room
			
				local ab={}
				
				for i,v in ipairs(aa) do
				
					if i>2 then ab[i-2]=v end
					
				end
			
				roomqueue(vic.room,{cmd="say",frm=vic.name,txt=table.concat(ab," ")})
			
			end
			
		elseif aa[2]=="do" then -- force gimp to act
		
			if vic.room==user.room then -- they are in same room
			
				local ab={}
				
				for i,v in ipairs(aa) do
				
					if i>2 then ab[i-2]=v end
					
				end
			
				roomqueue(vic.room,{cmd="act",frm=vic.name,txt=table.concat(ab," ")})
			
			end
			
		elseif aa[2]=="release" then -- get rid of gimp
		
			roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has released "..vic.name})
			day_flag_clear(user.name,"gimp")
			
		end
	
	end
]]
end

-----------------------------------------------------------------------------
--
-- check a user action and apply a real effect if we should
-- return true to not display this act
--
-----------------------------------------------------------------------------
function user_act_check(user,aa)

local num,num_str
local vic,vic_str
local form_str
local act
local invoke
local room=user.room
local protected

	if room.protect_time and room.protect_time>os.time() and room.brain and not is_admin(user.name) then protected=true end

		
	if     ( aa[1]=="calls" or aa[1]=="call" ) and aa[2]=="cthulhu" and aa[3]=="to" and ( aa[4]=="disemvowel" or aa[4]=="dis" ) and aa[5]  then
	
		vic_str=aa[5]
		act="dis"
		vic=get_user(vic_str)
		
		if protected then act=nil end
		
	elseif ( aa[1]=="calls" or aa[1]=="call" ) and aa[2]=="cthulhu" and aa[3]=="to" and aa[4]=="gag" and aa[5]  then
	
		vic_str=aa[5]
		act="gag"
		vic=get_user(vic_str)
		
		if protected then act=nil end
		
	elseif ( aa[1]=="calls" or aa[1]=="call" ) and aa[2]=="cthulhu" and aa[3]=="to" and aa[4]=="ban" and aa[5]  then
	
		vic_str=aa[5]
		act="ban"
		vic=get_user(vic_str)
		
		if protected then act=nil end
		
	elseif ( aa[1]=="calls" or aa[1]=="call" ) and aa[2]=="cthulhu" then
	
		act="cthulhu"
		
		if protected then act=nil end
		
	elseif ( aa[1]=="gives" or aa[1]=="give" ) and aa[2] and ( aa[3]=="cookies" or aa[3]=="cookie" ) and aa[4]=="to" and aa[5] then
	
		num_str=aa[2]
		vic_str=aa[5]
		act="cookies"
		
	elseif ( aa[1]=="gives" or aa[1]=="give" ) and aa[2] and aa[3] and ( aa[4]=="cookies" or aa[4]=="cookie" ) then

		vic_str=aa[2]
		num_str=aa[3]
		act="cookies"
	
	elseif ( aa[1]=="tags" or aa[1]=="tag" or aa[1]=="tagged" ) and aa[2] then
	
		vic_str=aa[2]
		act="tags"
		
	elseif ( aa[1]=="bites" or aa[1]=="bite" ) and aa[2] then

		vic_str=aa[2]
		form_str=aa[3]
		
		if not form_str then form_str=user.form end
		
		if (form_str~="vamp") and (form_str~="wolf") and (form_str~="chav")  and (form_str~="zom") then form_str=nil end
		
		act="bites"
	
	elseif ( aa[1]=="groans" or aa[1]=="groan" ) then

		roomqueue(user.room,{cmd="act",frm=user.name,form_filter="zom",form_alt="groans",form_msg=table.concat(aa," ")})
		if user.room.name~="public.zom" then -- also broadcast into the zombie room
			roomqueue(get_room("public.zom"),{cmd="act",frm=user.name,form_filter="zom",form_alt="groans",form_msg=table.concat(aa," ")})
		end		
		return true
	
	elseif ( aa[1]=="stares" or aa[1]=="stare" ) then

		roomqueue(user.room,{cmd="act",frm=user.name,form_filter="vamp",form_alt="stares",form_msg=table.concat(aa," ")})
		if user.room.name~="public.vamp" then -- also broadcast into the vampire room
			roomqueue(get_room("public.vamp"),{cmd="act",frm=user.name,form_filter="vamp",form_alt="stares",form_msg=table.concat(aa," ")})
		end
		return true
			
	elseif ( aa[1]=="howls" or aa[1]=="howl" ) then

		roomqueue(user.room,{cmd="act",frm=user.name,form_filter="wolf",form_alt="howls",form_msg=table.concat(aa," ")})
		if user.room.name~="public.wolf" then -- also broadcast into the wolf room
			roomqueue(get_room("public.wolf"),{cmd="act",frm=user.name,form_filter="wolf",form_alt="howls",form_msg=table.concat(aa," ")})
		end
		return true
			
	elseif ( aa[1]=="invokes" or aa[1]=="invoke" ) then -- /me invokes
	
		act="invokes"
		
		invoke=aa[2]
	
		if protected then act=nil end
	end
	
	local function call_cthulhu_to(dothis)
	
		if is_mud(user.name) then return end -- naughty users
		
		if user.room.owners[1] then return nil end -- cthulhu no longer enters private rooms
		if user.room.name=="swearbox" then return nil end -- cthulhu no longer enters swearbox		
		
		if not vic then  -- no victim online, so ignore command?
		
			if vic_str and user_rank(user)>=5 then -- a lrank5+ can ban an offline guest for free

				vic_str=string.lower( string.gsub(vic_str, "[^0-9a-zA-Z%-_]+", "" ) ) -- make sure name only contains good characters

				local vic_id=get_idstring(vic_str)

				if vic_id~="*" and vic_id~=vic_str then -- no ip if we get back what we put in

log(user.name,dothis,vic_str)

					roomqueue(user.room,{cmd="act",frm="cthulhu",txt="has dreamed of "..vic_str})
					
					set_status(nil,dothis,vic_str,os.time()+(15*60))
					
				end
				
			end
			
			return nil
		end
		
		
		if vic.room~=user.room then return nil end -- victim must also be in same room
		local rdiff=user_rank_diff(user,vic)
		local bff=user_bff(vic)
		if bff then
			local rdiff_bff=user_rank_diff(user,bff)
			if rdiff_bff < rdiff then -- bff steps in
				rdiff=rdiff_bff
				roomqueue(user.room,{cmd="act",frm=bff.name,txt="protects their BFF "..vic.name})
			end
		elseif user_god_bff(vic) then
			rdiff=-19 --the fix is in
			roomqueue(user.room,{cmd="act",frm=vic.bff,txt="protects their BFF "..vic.name})
		end
		
		
		local rdiff_min=0
		if dothis=="gag" then rdiff_min=-1 end
		if dothis=="dis" then rdiff_min=-2 end
		
		
		if not ( is_admin(vic_str) or is_bot(vic_str) ) then -- catch this later
		
			if rdiff<rdiff_min then return nil end -- victim is higher level, so ignore command					
		end
		
		local cost=15 - rdiff*5
		
		if dothis=="gag" then cost=cost-5 end
		if dothis=="dis" then cost=cost-10 end
		
		if rdiff<0 then rdiff=0 end -- fixed banlength
		if cost<0 then cost=0 end -- thats 5 less cookies needed for ever level the user is over the victim
		local banlen=5*60 + rdiff*5*60 -- higher levels also ban the lower levels for longer
		
		if is_dum(user.name) or is_admin(vic_str) or ( cost>user.cookies ) then
		
			conjure_failure(user)
			
			user.cookies=0
			roomqueue(user.room,{cmd="act",frm="cthulhu",txt="has consumed "..user.name})
			set_status(nil,dothis,user.name,os.time()+(60*15))
			join_room_str(user,"swearbox")
				
			return nil
		else			
		
			user.cookies=user.cookies-cost
			
			if cost>0 then conjure_success(user,cost.." cookies") end
			
log(user.name,dothis,vic_str)
tlog_chance(0.01,user.name, user.name.." called cthulhu to "..dothis.." "..vic_str..".")

			if dothis=="ban" then
				roomqueue(user.room,{cmd="act",frm="cthulhu",txt="has consumed "..vic_str})
			elseif dothis=="gag" then
				roomqueue(user.room,{cmd="act",frm="cthulhu",txt="has gagged "..vic_str})
			elseif dothis=="dis" then
				roomqueue(user.room,{cmd="act",frm="cthulhu",txt="has disemvowled "..vic_str})
			end
			
			local tab=get_shared_names_by_ip(vic_str) -- cthulhu now eats all people of the same ip
			if not tab then tab={vic_str} end
			for i,v in ipairs(tab) do
				set_status(nil,dothis,v,os.time()+(banlen))
				local u=get_user(v)
				if u then
					userqueue(u,{cmd="note",note="act",arg1=user.name.." called cthulhu to "..dothis.." YOU"})
				end
			end
			
			return nil
		end
		
	end
	
	if act=="invokes" then 
	
--[[
		local pants=get_shared_names_by_ip(user.name)
		if pants and #pants>=10 then -- if too many people share this ip, no invokes for you
				userqueue(user,{cmd="note",note="act",arg1="Your huge pants prevent you from invoking anything."})
			return
		end
]]
		if is_mud(user.name) then return end -- naughty users

		local form_str=(user.form or "man")
		local invokes_flag ="invokes_"..form_str
		
		local invokes_used =day_flag_get_num(user.name,invokes_flag) or 0
		local invokes_used_ip =day_flag_get_num(user.ip,invokes_flag) or 0
		if invokes_used_ip > invokes_used then invokes_used=invokes_used_ip end -- limit ivokes by ip or user
		
		local invokes_rank =user_rank(user)
		local invokes_max  =invokes_rank
		local invokes_avail=(invokes_max-invokes_used)
	
		local human =nil
		local human_rank =0
		
		local vic_name=aa[3]
		local vic=get_user(vic_name)
		local vic_rank=user_rank(vic)
			
-- find highest human in the room and save them for later use

		if not is_admin(user.name) then -- gods are not cock blocked
			for v,b in pairs(user.room.users) do
			
				if v.name~="me" and not v.brain and v.form==nil then
				
					local vr=user_rank(v)
					
					if ( vr<69 ) and ( vr>human_rank ) then -- ignore gods :)
					
						human=v
						human_rank=vr
					
					end
					
				end
				
			end
		end
		
		-- return true if a basic check failed
		local function invoke_check( invoke_name , need_form , cost , flags )
				
			if form_str~=need_form and not is_admin(user.name) then
			
				userqueue(user,{cmd="note",note="act",arg1="You must be in "..need_form.." from to invoke "..invoke_name.."."})
				return true
				
			end
			
			if invokes_avail<cost and not is_admin(user.name) then
			
				userqueue(user,{cmd="note",note="act",arg1="You need "..cost.." "..need_form.." invokation points to invoke "..invoke_name.."."})
				return true
				
			end
			
			if flags then -- extra tests
			
				if flags.need_vic or flags.need_vic_in_room then
				
					if not vic_name then
					
							userqueue(user,{cmd="note",note="act",arg1="You need a victim EG /me invokes "..invoke_name.." bob"})
							return true
					end

					if not vic then
					
							userqueue(user,{cmd="note",note="act",arg1="Sorry but "..vic_name.." can not be found."})
							return true
					end
			
				end
			
				if flags.need_vic_in_room and (not is_admin(user.name)) then 
				
					if vic.room~=user.room then -- must be in same room
					
							userqueue(user,{cmd="note",note="act",arg1="Sorry but "..vic.name.." must be in this room."})
							return true
					end
			
				end
			end

			if not is_admin(user.name) then -- admins can invoke for free
			
				if cost>1 then cost=1 end -- damn gaybar fix :)
				
				-- invokes now only cost 1 point, but you still need atleast 5 points for a level 5 invoke
				
				day_flag_set(user.name,invokes_flag,invokes_used+cost) -- invokes are spent by user name
				day_flag_set(user.ip,invokes_flag,invokes_used+cost) -- and user ip
				
			end
						
		end
		
		if invoke=="siren" then -- seduce

			if invoke_check("siren","vamp",5) then return true end
			
-- shift everyone into your room, ignore any bans you may have setup, include yourself

			manifest_room(user.name,user)

			local new_room=get_room(user.name)
			local old_room=user.room
			
			roomqueue(old_room,{cmd="note",note="act",arg1=user.name.." flutters their eyelashes and winks at you."})
			
			if old_room and new_room then -- sanity
			
				for v,b in pairs(old_room.users) do
				
					if v.name~="me" and not v.brain then
					
						local vr=user_rank(v)
						
						if (v.form~="vamp" ) and ( ( invokes_rank - vr ) >=0 ) then -- same rank or lower and can not seduce other vamps
						
						
							if vr<human_rank then -- the human protects
							
								roomqueue(old_room,{cmd="note",note="act",arg1=human.name.." holds "..v.name.." back from the brink of madness"})
								
							else								
								join_room_str(v,new_room.name) -- victim gets yanked as long as they are allowed into the room
								if new_room == v.room then -- worked
								
									roomqueue(old_room,{cmd="note",note="act",arg1=user.name.." has seduced "..v.name})

								end
								
								day_flag_set(v.name,"dizzy",os.time()+20)
							end
						end
						
					end
					
				end
			
			end
			
			day_flag_set(user.name,"dizzy",os.time()+20)

			return true

		elseif invoke=="tempt" or invoke=="dance" then -- seduce

			local cost=1
			if user.room.name=="public.gaybar" then -- dancing is free in the gay bar
				cost=0
			end
			if invoke_check("dance","vamp",cost,{need_vic=true}) then return true end
			
			local dizzy=day_flag_get(user.name,"dizzy")
			if dizzy and dizzy>os.time() and not is_admin(user.name) then -- too dizzy to dance again
			
				usercast(user,{cmd="note",note="warning",arg1="you are too dizzy! ("..(dizzy-os.time())..")"})
				return true
			end
			
			
			local autofail=false
			local autowin=false
				
			if user.room.name=="public.gaybar" and not is_admin(user.name) then -- tone down the pulling power of free tempts in the gay bar
			
				if vic.room.owners[1] then -- they are in a private owned room so they get to stay there
				
					autofail=true
				
				end

			end
			
			-- check victims room for protection
			if vic.room.protect_time and vic.room.protect_time>os.time() and vic.room.brain and not is_admin(user.name) then autofail=true end
			
			day_flag_set(user.name,"dizzy",os.time()+20) -- the invoker is always dizzy
					
			if ( autowin or ( invokes_rank - vic_rank ) >0 ) and not autofail then -- victim must be lower rank
			
				roomqueue(user.room,{cmd="act",frm=user.name,txt="dances for "..vic.name})
				
				if vic.room ~= user.room then
				
					roomqueue(vic.room,{cmd="act",frm=vic.name,txt="dances out of the room"})
					join_room_str(vic,user.room.name) -- victim gets yanked as long as they are allowed into the room
					
				end
				
				if vic.room==user.room then -- they are in same room
				
					day_flag_set(vic.name,"dizzy",os.time()+20) -- the victim is only dizzy if they end up in the same room
					roomqueue(vic.room,{cmd="act",frm=vic.name,txt="dances for "..user.name})
					
log(user.name,"dance",vic.name)
tlog_chance(0.1,user.name, user.name.." had a private dance with "..vic.name.." in a dark corner of "..user.room.name..".")
					
				
				else -- room entry was denied
					
					roomqueue(vic.room,{cmd="act",frm=vic.name,txt="pines for "..user.name})
					
				end
			
			else -- victim stays put
			
				roomqueue(user.room,{cmd="act",frm=user.name,txt="dances for "..vic.name})
				roomqueue(vic.room,{cmd="act",frm=vic.name,txt="denies "..user.name})
				
			end
			
			return true

		elseif invoke=="gimp" then -- create a gimp

			if invoke_check("gimp","vamp",10,{need_vic_in_room=true}) then return true end
			
				if ( invokes_rank - vic_rank ) >0 then -- victim must be lower rank
			
					roomqueue(user.room,{cmd="act",frm=user.name,txt="whispers softly into "..vic.name.."s ear"})
					
					day_flag_set(user.name,"gimp",vic.name) -- we now have a little pet to work gimp commands on...
					
log(user.name,"gimp",vic.name)
tlog_chance(0.1,user.name, user.name.." purchased a new pet gimp called "..vic.name..".")

				else
				
					roomqueue(user.room,{cmd="act",frm=user.name,txt="whispers softly into "..vic.name.."s ear but it has no effect."})
					
				end
				
			return true
			
		elseif invoke=="bork" then -- bork a single users brain

			local cost=1
			if user.room.name=="public.gaybar" then -- borking is free in the gay bar
				cost=0
			end
			if invoke_check("bork","zom",cost,{need_vic_in_room=true}) then return true end
			
			if ( invokes_rank - vic_rank ) >=0 then -- victim must be same rank or lower
			
				if vic_rank<human_rank then -- the human protects
				
					roomqueue(user.room,{cmd="note",note="act",arg1=human.name.." shields "..vic.name.."s head from "..user.name.."s zombie munchies"})
					
				else
			
					roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has munched on some of "..vic.name.."s brain"})
										
					day_flag_set(vic.name,"zom_bork")

log(user.name,"bork",vic.name)
tlog_chance(0.1,user.name, user.name.." munched upon the spicy brains of "..vic.name..".")

				end
			
			else
			
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." can smell "..vic.name.."s spicy brains, but they can't do anything about it."})
				
			end
			
			return true

		elseif invoke=="borkbork" then -- bork a single users brain

			if invoke_check("borkbork","zom",2,{need_vic_in_room=true}) then return true end
			
			local tab
			local str
			local nam
			
			if ( invokes_rank - vic_rank ) >=0 then -- victim must be same rank or lower
				nam=vic.name
				if vic_rank<human_rank then -- the human protects (gods wont protect)
					roomqueue(user.room,{cmd="note",note="act",arg1=human.name.." protects "..vic.name})
					if ( invokes_rank - human_rank ) >=0 then -- victim must be same rank or lower
						nam=human.name
					else
						nam=nil
					end
				end
			end
			
			if not nam then -- failed level check
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." can smell "..vic.name.."s spicy brains, but they can't do anything about it."})
				return true
			end
			
log(user.name,"borkbork",nam)

			tab=get_shared_names_by_ip(nam)
			if not tab then tab={nam} end
			if tab then str=str_join_english_list(tab) or "" else str="" end -- make sure we have a str
			
			if str=="" then -- missed?
				roomqueue(user.room,{cmd="act",frm=user.name,txt="fails to borkbork "..nam})
				return true
			end
			
tlog_chance(0.1,user.name, user.name.." munched upon the spicy brains of "..str..".")

			roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." borkborks "..nam})
			roomqueue(user.room,{cmd="act",frm=user.name,txt="has nibbled on the brains of "..str})
			
			for i,v in ipairs(tab) do
			
				day_flag_set(v,"zom_bork") -- get everyone
			end
			
			return true

		elseif invoke=="spit" then -- infect

			local cost=1
			if user.room.name=="public.gaybar" then -- spiting is free in the gay bar
				cost=0
			end
			if invoke_check("spit","zom",cost,{need_vic_in_room=true}) then return true end			
			
			roomqueue(user.room,{cmd="act",frm=user.name,txt="spits at "..vic.name})
							
			if ( (invokes_rank*2) - vic_rank ) >=0 then -- double the zombie rank then compare
			
				if human and human~=vic and vic_rank<human_rank then -- the highest human in the room protects
				
					roomqueue(user.room,{cmd="note",note="act",arg1=human.name.." shields "..vic.name.."s face from zombie sputum"})					
					
					if ( (invokes_rank*2) - human_rank ) >=0 then -- double the zombie rank then compare
					
						roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has infected "..human.name})					
						human.form="zom"
						
log(user.name,"spit",human.name)
tlog_chance(0.1,user.name, user.name.." spat at the innocent "..human.name..".")

					end
					
				else
			
					roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has infected "..vic.name})
					
					vic.form="zom"
					
log(user.name,"spit",vic.name)
tlog_chance(0.1,user.name, user.name.." spat at "..vic.name..".")

				end
				
			end
			
			return true

		elseif invoke=="virus" then -- infect

			if invoke_check("virus","zom",5) then return true end			
						
-- everyone in the room becomes a zombie unless they are over twice the level of the zombie invoker

			local old_room=user.room
			
			roomqueue(old_room,{cmd="note",note="act",arg1=user.name.." spits in your face."})
			
			if old_room then -- sanity
			
				for v,b in pairs(old_room.users) do
				
					if v.name~="me" and not v.brain then
					
						local vr=user_rank(v)
							
						if ( (invokes_rank*2) - vr ) >=0 then -- double the zombie rank then compare
						
							if vr<human_rank then -- the human protects
							
								roomqueue(old_room,{cmd="note",note="act",arg1=human.name.." shields "..v.name.."s face from zombie sputum"})
								
							else
						
								roomqueue(old_room,{cmd="note",note="act",arg1=user.name.." has infected "..v.name})
								
								v.form="zom"
								
							end
							
						end
						
					end
					
				end
			
			end
			
			return true

		elseif invoke=="fart" then -- infect a room for the rest of the day
		

			if invoke_check("fart","zom",10) then return true end
			
			local room=user.room
			
			if room.name=="limbo" then -- no more farting in limbo
				roomqueue(room,{cmd="note",note="act",arg1=user.name.." looks constipated."})
				return true
			end
			
			roomqueue(room,{cmd="note",note="act",arg1=user.name.." farts and the funk of forty thousand years fills the room!"})
			
			day_flag_set(room.name,"zombie_fart",user.name)
			
log(user.name,"fart",room.name)
tlog_chance(0.1,user.name, user.name.." farted in "..room.name..".")

			for v,b in pairs(room.users) do
			
				if v.name~="me" and not is_admin(v.name) then
				
					if v.form~="zom" then
					
						roomqueue(room,{cmd="note",note="act",arg1=v.name.." smells "..user.name.."s funk and turns into a zombie."})
						v.form="zom"
						

					end
				
				end
				
			end
			
			return true	
			
		elseif invoke=="slap" then -- slap down non wolfs 1 level

			local cost=1
			if user.room.name=="public.gaybar" then -- slaping is free in the gay bar
				cost=0
			end
			if invoke_check("slap","wolf",cost,{need_vic_in_room=true}) then return true end
						
			roomqueue(user.room,{cmd="act",frm=user.name,txt="slaps "..vic.name})
				
			if vic.form~="wolf" then -- only knocks non wolfs
			
				if ( (invokes_rank*2) - vic_rank ) >=0 then -- double the rank then compare
				
					if vic_rank<human_rank then -- the human protects
					
						roomqueue(user.room,{cmd="note",note="act",arg1=human.name.." protects "..vic.name})
						
						if ( (invokes_rank*2) - human_rank ) >=0 then -- double the rank then compare
						
							roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has slapped "..human.name})
							day_flag_set(human.name,"wolf_knockdown")
							
log(user.name,"slap",human.name)
tlog_chance(0.1,user.name, user.name.." slapped the innocent "..human.name.." upside the head.")

						end
						
					else
				
						roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has slapped "..vic.name})
						day_flag_set(vic.name,"wolf_knockdown")
						
log(user.name,"slap",vic.name)
tlog_chance(0.1,user.name, user.name.." slapped "..vic.name.." upside the head.")

					end
					
				end
				
			else
			

				roomqueue(user.room,{cmd="note",note="act",arg1=vic.name.." shrugs it off"})
				
			end
			
			return true

		elseif invoke=="falconpunch" then -- slap down a group(by ip) to half their level

			if invoke_check("falconpunch","wolf",11,{need_vic_in_room=true}) then return true end
						
			local tab
			local str
			local nam
			
			nam=vic.name
			if vic_rank<human_rank then -- the human protects (gods wont protect)
				roomqueue(user.room,{cmd="note",note="act",arg1=human.name.." protects "..vic.name})
				nam=human.name
			end
			
log(user.name,"falconpunch",nam)

			tab=get_shared_names_by_ip(nam)
			if not tab then tab={nam} end
			if tab then str=str_join_english_list(tab) or "" else str="" end -- make sure we have a str
			
			if str=="" then -- falcon punch missed?
				roomqueue(user.room,{cmd="act",frm=user.name,txt="fails to falconpunch "..nam})
				return true
			end
			
tlog_chance(0.1,user.name, user.name.." falcon punched "..str.." into the middle of next week.")

			roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." falconpunches "..nam})
			roomqueue(user.room,{cmd="act",frm=user.name,txt="falconpunches "..str})
			
			for i,v in ipairs(tab) do
			
				day_flag_set(v,"wolf_knockdown2") -- get everyone
			end
			
			return true

		elseif invoke=="punch" then -- slap down any victim to half their level

			if invoke_check("punch","wolf",10,{need_vic_in_room=true}) then return true end
						
			roomqueue(user.room,{cmd="act",frm=user.name,txt="punches "..vic.name})
				
			if vic_rank<human_rank then -- the human protects
			
				roomqueue(user.room,{cmd="note",note="act",arg1=human.name.." protects "..vic.name})

				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has punched "..human.name})
				day_flag_set(human.name,"wolf_knockdown2")
				
log(user.name,"punch",human.name)
tlog_chance(0.1,user.name, user.name.." punched the inocent "..human.name..".")

			else
		
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has punched "..vic.name})
				day_flag_set(vic.name,"wolf_knockdown2")
				
log(user.name,"punch",vic.name)
tlog_chance(0.1,user.name, user.name.." punched "..vic.name..".")

			end
			
			return true

		elseif invoke=="knock" then -- knock all non wolfs in this room down one level for the rest of the day

			if invoke_check("knock","wolf",5) then return true end
			
-- everyone in the room that isnt a wolf gets knocked down a level for the rest of the day

			local old_room=user.room
			
			roomqueue(old_room,{cmd="note",note="act",arg1=user.name.." howls ITS DINNER TIME."})
			
			if old_room then -- sanity
			
				for v,b in pairs(old_room.users) do
				
					if v.name~="me" and not v.brain then
					
						local vr=user_rank(v)
						
						if ( (invokes_rank*2) - vr ) >=0 then -- double the wolfs rank then compare
						
							if v.form~="wolf" then -- only knocks non wolfs
							
								if vr<human_rank then -- the human protects
								
									roomqueue(old_room,{cmd="note",note="act",arg1=human.name.." protects "..v.name.." from "..user.name.."s anger"})
									
								else
								
									roomqueue(old_room,{cmd="note",note="act",arg1=user.name.." has slapped "..v.name})
									
									day_flag_set(v.name,"wolf_knockdown")
									
								end
								
							end
							
						end
						
					end
					
				end
			
			end
			
			return true

		elseif invoke=="communism" then -- distributes your cookies evenly to everyone in the room

			local cost=1
			if user.room.name=="public.gaybar" then -- communism is free in the gay bar
				cost=0
			end
			if invoke_check("communism","man",cost,{}) then return true end
			
			local amount=0
			local room=user.room

			if room then -- sanity
			
				for v,b in pairs(room.users) do
						
					if v.name~="me" and not v.brain then
					
						amount=amount+1
						
					end
					
				end
			
				if amount>0 then
					amount=math.floor(user.cookies/amount)
				end
				
				if amount>0 then
				
					local tab={}
				
					roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." invokes communism."})
				
					for v,b in pairs(room.users) do
							
						if v.name~="me" and not v.brain then
						
							if user.cookies>=amount then
							
								v.cookies=v.cookies+amount
								user.cookies=user.cookies-amount
								
								table.insert(tab,v.name)
															
log(user.name,"cookies",v.name,amount)

							end
							
						end
												
					end
				
					roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." gives "..str_join_english_list(tab).." "..amount.." cookies."})
					
				end
			end
			
			if amount==0 then
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." fails at communism."})
			end
			
log(user.name,"communism",amount)
tlog_chance(0.1,user.name, user.name.." is a communist with the power of "..amount.." cookies.")

			return false

		elseif invoke=="touch" then -- cures a single person of the same level or lower,  

			local cost=1
			if user.room.name=="public.gaybar" then -- touching is free in the gay bar
				cost=0
			end
			if invoke_check("touch","man",cost,{need_vic_in_room=true}) then return true end
			
			if ( invokes_rank - vic_rank ) >=0 then -- can only heal same or lower level
				
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." touches "..vic.name.." in the right place."})
			
				if day_flag_get(vic.name,"wolf_knockdown") then -- needs healing
				
					roomqueue(vic.room,{cmd="note",note="act",arg1=user.name.." has healed "..vic.name})
					
					day_flag_clear(vic.name,"wolf_knockdown")
					
				end
					
				if day_flag_get(vic.name,"zom_bork" ) then -- needs healing
				
					roomqueue(vic.room,{cmd="note",note="act",arg1=user.name.." has repaired "..vic.name})
					
					day_flag_clear(vic.name,"zom_bork")
					
				end
			
log(user.name,"touch",vic.name)
tlog_chance(0.1,user.name, user.name.." touched "..vic.name.." in the right place.")

			else
			
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." touches "..vic.name.." in the wrong place."})
tlog_chance(0.1,user.name, user.name.." touched "..vic.name.." in the wrong place.")
			
			end
			
			return true

		elseif invoke=="dispel" then -- cures a room and any people in it

			if invoke_check("dispel","man",10) then return true end
			
			
			local room=user.room
			local farted=day_flag_get(room.name,"zombie_fart")
			
			if farted then
			
				roomqueue(room,{cmd="note",note="act",arg1=user.name.." cleanses the room of all ill effects!"})
				
				day_flag_clear(room.name,"zombie_fart")
				
			end
			
			if room then -- sanity
			
				for v,b in pairs(room.users) do
						
					if v.name~="me" and not v.brain then
						
						if day_flag_get(v.name,"wolf_knockdown") then -- needs healing
						
							roomqueue(v.room,{cmd="note",note="act",arg1=user.name.." has healed "..v.name})
							
							day_flag_clear(v.name,"wolf_knockdown")
							
						end
							
						if day_flag_get(v.name,"wolf_knockdown2") then -- needs healing
						
							roomqueue(v.room,{cmd="note",note="act",arg1=user.name.." has patchedup "..v.name})
							
							day_flag_clear(v.name,"wolf_knockdown2")
							
						end
							
						if day_flag_get(v.name,"zom_bork" ) then -- needs healing
						
							roomqueue(v.room,{cmd="note",note="act",arg1=user.name.." has repaired "..v.name})
							
							day_flag_clear(v.name,"zom_bork")
							
						end
						
						local gimp=day_flag_get(v.name,"gimp")						
						if gimp then
						
							roomqueue(v.room,{cmd="note",note="act",arg1=user.name.." has released "..gimp.." from "..v.name})
							
							day_flag_clear(v.name,"gimp")
						
						end


					end
					
				end
			
			end
			
			return true

		elseif invoke=="heal" then -- cures everyone in room no level check ... the knock effect etc 

			if invoke_check("heal","man",5) then return true end
						
-- heal anyone who has a problem

			local old_room=user.room
			
			roomqueue(old_room,{cmd="note",note="act",arg1=user.name.." shouts the power of the old ones compels thee!"})
			
			if old_room then -- sanity
			
				for v,b in pairs(old_room.users) do
						
					if v.name~="me" and not v.brain then
						
						if day_flag_get(v.name,"wolf_knockdown") then -- needs healing
						
							roomqueue(v.room,{cmd="note",note="act",arg1=user.name.." has healed "..v.name})
							
							day_flag_clear(v.name,"wolf_knockdown")
							
						end
							
						if day_flag_get(v.name,"zom_bork" ) then -- needs healing
						
							roomqueue(v.room,{cmd="note",note="act",arg1=user.name.." has repaired "..v.name})
							
							day_flag_clear(v.name,"zom_bork")
							
						end
						
					end
					
				end
			
			end
			
			return true

		elseif invoke=="sniff" then -- find the logged in user with the most cookies
		
			if invoke_check("sniff","chav",1) then return true end
						
			local top_u=nil
			local top_c=0
			
			for u,_ in pairs(data.users) do
			
				if u.cookies>top_c then
				
					if not is_admin(u.name) and u~=user then -- dont report on admins or self

						top_u=u
						top_c=u.cookies
					
					end
				
				end
			
			end
						
			roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." sniffs around the room"})
			

			if top_u then -- we found a possible victim
			
				userqueue(user,{cmd="note",note="act",arg1="your chav sense tingles and you now know that "..top_u.name.." has "..top_u.cookies.." cookies"})
			
log(user.name,"sniff",top_u.name,top_u.cookies)
tlog_chance(0.1,user.name, user.name.." sniffed out "..top_u.cookies.." belonging to "..top_u.name..".")

			else
			
				userqueue(user,{cmd="note",note="act",arg1="unfortunatly no one has any cookies"})
			
			end
			
			return true
		
		elseif invoke=="hug" then -- steals half the cookies from a lower level only
									
			local cost=1
			if user.room.name=="public.gaybar" then -- hugging is free in the gay bar
				cost=0
			end
			if invoke_check("hug","chav",cost,{need_vic_in_room=true}) then return true end
			
			roomqueue(user.room,{cmd="act",frm=user.name,txt="hugs "..vic.name})

			if ( invokes_rank - vic_rank ) >0 then -- can only hug lower levels for profit
				
				local pinch=force_floor(vic.cookies/2)
				
				if pinch>0 then
				
					if user_ip(user) == user_ip(vic) then -- quiet fail on same IP...
						
					elseif vic_rank<human_rank and not is_admin(user.name) then -- the human protects
					
						roomqueue(user.room,{cmd="note",note="act",arg1=human.name.." hides "..vic.name.."s cookies away from "..user.name.."s sticky fingers"})
						
					else
					
						vic.cookies=vic.cookies-pinch
						user.cookies=user.cookies+pinch
				
						userqueue(user,{cmd="note",note="act",arg1="YOU stole "..pinch.." cookies from "..vic.name})
									
dbg(user.name.." stole "..pinch.." cookies from "..vic.name.." by hugging\n")

log(user.name,"hug",vic.name,pinch)
tlog_chance(0.1,user.name, user.name.." hugged "..vic.name.." and got away with "..pinch.." cookies.")

					end

				end
								
			end
			
			return true
									
		elseif invoke=="asbo" then -- steals all cookies from lower levels, half cookies from higher levels (who also know you stole them)
									--- if there is a bot in the room then they demand half your take of cookies at the end.

			if invoke_check("asbo","chav",5) then return true end
			
-- everyone in the room looses at least half their cookies

			local old_room=user.room
			
			if old_room then -- sanity
			
				local pinch_total=0
				local pinch=0
				local bot_user=nil

				
				for v,b in pairs(old_room.users) do
				
					if v.brain then
					
						bot_user=v
					
					elseif user==v then
					
					-- do nothing to self
					
					elseif is_admin(v.name) then
					
						userqueue(v,{cmd="note",note="act",arg1=user.name.." tried to steal cookies from YOU"})
					
					elseif v.name~="me" and not v.brain then
					
						local vr=user_rank(v)
						
						if user_ip(user) == user_ip(v) then -- quiet fail on same IP
						
						elseif ( invokes_rank - vr ) >=0 then -- these people loose all their cookies
						
								
							if vr<human_rank then -- the human protects
							
								roomqueue(old_room,{cmd="note",note="act",arg1=human.name.." hides "..v.name.."s cookies away from "..user.name.."s sticky fingers"})
								
							else
							
								pinch=v.cookies 
								v.cookies=0
								pinch_total=pinch_total+pinch
								
								if pinch>0 then
							
									userqueue(user,{cmd="note",note="act",arg1="YOU stole "..pinch.." cookies from "..v.name})
																	
								end
						
dbg(user.name.." stole "..pinch.." cookies from "..v.name.." in "..old_room.name.."\n")

							end

						else
							
							if vr<human_rank then -- the human protects
							
								roomqueue(old_room,{cmd="note",note="act",arg1=human.name.." hides "..v.name.."s cookies away from "..user.name.."s sticky fingers"})
								
							else
							
								pinch=force_floor(v.cookies/2)
								v.cookies=v.cookies-pinch
								pinch_total=pinch_total+pinch
								
								if pinch>0 then
							
									userqueue(user,{cmd="note",note="act",arg1="YOU stole "..pinch.." cookies from "..v.name})
									userqueue(v,{cmd="note",note="act",arg1=user.name.." stole "..pinch.." cookies from YOU"})
									
								else
								
									userqueue(v,{cmd="note",note="act",arg1=user.name.." tried to steal cookies from YOU"})
									
								end
							
dbg(user.name.." stole "..pinch.." cookies from "..v.name.." in "..old_room.name.."\n")
							
							end
							
						end
						
					end
					
				end
				
				if bot_user then -- this room has a bot in it
			
					pinch=force_floor(pinch_total/2)
					
					if pinch>0 then
					
						pinch_total=pinch_total-pinch
				
						userqueue(user,{cmd="note",note="act",arg1=bot_user.name.." takes "..pinch.." cookies from you as hush money"})
						
					end
										
dbg(bot_user.name.." takes "..pinch.." cookies from you as hush money in "..old_room.name.."\n")

				end
				
				if pinch_total>0 then
				
					user.cookies=user.cookies+pinch_total
				
					userqueue(user,{cmd="note",note="act",arg1="YOU have stolen "..pinch_total.." cookies from everyone in this room."})
						
				end
				
dbg(user.name.." has stolen "..pinch_total.." cookies from everyone in "..old_room.name.."\n")
				
			end
			
			return true

		elseif invoke=="recoup" then -- Search the cookies on the floor (logged out users) and steal the largest amount.

			if invoke_check("recoup","chav",10) then return true end
			
			local nam,val,s
			
			nam="me"
			val=0
			
			for n,v in pairs(data.saved_cookies) do
			
				if v>val and not is_admin(n) then
				
					nam=n
					val=v
				
				end
			
			end
			
			roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." searches the floor for cookies"})

			
			if nam=="me" then -- no one has any cookies
			
				s="You couldn't find any cookies on the floor."
				userqueue(user,{cmd="note",note="act",arg1=s})
				
			else
			
--				if not is_admin(user.name) then -- admins call this command just for the info
			
					data.saved_cookies[nam]=0
					user.cookies=user.cookies+val
log(user.name,"recoup",nam,val)
tlog_chance(0.1,user.name, user.name.." recouped "..nam.." for the sum of "..val.." cookies.")
					
--				end
			
				s="You have stolen "..val.." cookies from the floor of "..nam.."s room"
				userqueue(user,{cmd="note",note="act",arg1=s})
dbg(user.name.." : "..s.."\n")
				
			end
			
			return true
			
		elseif invoke=="heist" then -- steals all cookies from the floor of associated accounts
									
			local cost=11
			if invoke_check("heist","chav",cost,{need_vic_in_room=true}) then return true end
			
			roomqueue(user.room,{cmd="act",frm=user.name,txt="hugs "..vic.name})

			local tab=get_shared_names_by_ip(vic.name)
			
			local swag=0
			
dbg(user.name.." : starts a heist\n")

			if tab then
				for i,n in ipairs(tab) do
				
					local nam=string.lower(n)
				
					if not is_admin(nam) then
					
						local val=data.saved_cookies[nam]
					
						if val then -- found some
						
							if not is_admin(user.name) then -- admins call this command just for the info
								data.saved_cookies[nam]=0
								user.cookies=user.cookies+val
							end
							
							swag=swag+val
						
						local s="You have heisted "..val.." cookies from the floor of "..nam.."s room"
						userqueue(user,{cmd="note",note="act",arg1=s})
dbg(user.name.." : "..s.."\n")

						end
						
					end

				end
			end
			
			local s="You have heisted a total of "..swag.." cookies"
				userqueue(user,{cmd="note",note="act",arg1=s})
dbg(user.name.." : "..s.."\n")
			
			return true
									
		else -- status report
		
			userqueue(user,{cmd="note",note="act",arg1="You have "..invokes_avail.." "..form_str.." invokation points left today."})
			
			if form_str=="vamp" then
			
				if invokes_avail>=1 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke dance (1pt) to pull a victim towards you."})
			
				end
				if invokes_avail>=5 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke siren (5pts) to seduce everyone into joining your room."})
			
				end
				if invokes_avail>=10 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke gimp (10pts) to remote control a victim."})
			
				end
				
			elseif form_str=="zom" then
			
				if invokes_avail>=1 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke bork (1pt) to damage a victims brain."})
					userqueue(user,{cmd="note",note="act",arg1="You may invoke spit (1pt) to bite higher level victims."})
			
				end
				if invokes_avail>=2 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke borkbork (2pt) to damage a victim+alts brain."})
			
				end
				if invokes_avail>=5 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke virus (5pts) to cause a widespred zombie infection."})
			
				end
				if invokes_avail>=10 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke fart (10pts) to infect a room for the rest of the day."})
			
				end
				
			elseif form_str=="wolf" then
			
				if invokes_avail>=1 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke slap (1pt) to knock a victim down."})			
				end
				if invokes_avail>=5 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke knock (5pts) to temporarily knock all non wolfs down a level."})
			
				end
				if invokes_avail>=10 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke punch (10pts) to knock a victim down to half."})
			
				end
				if invokes_avail>=11 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke falconpunch (11pts) to knock a victim+alts down to half."})
			
				end
				
			elseif form_str=="chav" then
			
				if invokes_avail>=1 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke sniff (1pt) to find the richest logged in victim."})			
					userqueue(user,{cmd="note",note="act",arg1="You may invoke hug (1pt) to steal half the cookies from a lower level victim."})
				end
				if invokes_avail>=5 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke asbo (5pts) to steal cookies from everyone in this room."})
			
				end
				if invokes_avail>=10 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke recoup (10pts) to steal cookies from the floor of the richest user."})
			
				end
				if invokes_avail>=11 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke heist (11pts) to steal cookies from the floor of every user connected to the victim."})
			
				end
				
			elseif form_str=="man" then
			
				if invokes_avail>=1 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke touch (1pts) to heal a single person."})
					userqueue(user,{cmd="note",note="act",arg1="You may invoke communism (1pts) to distribute your wealth to everyone in a room."})
			
				end
				
				if invokes_avail>=5 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke heal (5pts) to heal everyone in this room."})
			
				end
				if invokes_avail>=10 then
				
					userqueue(user,{cmd="note",note="act",arg1="You may invoke dispel (10pts) to clear a room of farts."})
			
				end
				
			end
		
			return true
		end
	
	elseif act=="bites" then

		local u=get_user(vic_str)
			
		if u and is_god(user.name) then -- OK only gods get to choose form of infection and they always turn who they bite
		
			u.form=form_str
		
			roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has bitten "..u.name.." and turned them into a "..user_form(u).." "..user_rank_name(u)})
			
		else

			if u and (u~=user) then -- need victim and can't bite self

				if u.room == user.room then -- must be in same room
				
					if string.lower(u.name)==string.lower(data.tagged_name or "") then -- catch it
					
						data.tagged_name=string.lower(user.name)
					
						roomqueue(user.room,{cmd="note",note="act",arg1=u.name.." has tagged "..user.name})
				
					end
				
					local u1_rank=user_rank(user)
					local u2_rank=user_rank(u)
					
					if u1_rank < u2_rank then -- if we bite a higher rank we turn
					
						if u.form then
						
							user.form=u.form
							roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has turned into a "..user_form(user).." "..user_rank_name(user)})
							
						end
							
					elseif u1_rank > u2_rank then -- if we bite a lower rank they always turn
					
						if user.form then
						
							u.form=user.form
							roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has bitten "..u.name.." and turned them into a "..user_form(u).." "..user_rank_name(u)})
							
						end
						
					else -- bite the same rank and might turn back to human if its two wolfs or vamps or zombies
					
						if user.form then -- need to be non human for this to make any sense
		
							if ( user.form ~= u.form ) and ( u.form~="chav" ) then -- turn them
							
								u.form=user.form
							
								roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has bitten "..u.name.." and turned them into a "..user_form(u).." "..user_rank_name(u)})
					
							else -- change both back to human be careful not to bite your own kind or a chav
							
								if user.form~="chav" then -- chavs are a plague on all our houses
								
									user.form=nil
									u.form=nil
									
									roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." and "..u.name.." turn back into humans"})
									
								end
								
							end
							
						end
						
					end
					
				end
			
			end
		
		end
	
	elseif act=="tags" then
	
		local u=get_user(vic_str)
			
		if u then
		
			if is_god(user.name) then -- gods can infect anyone
			
				data.tagged_name=string.lower(u.name)
			
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has tagged "..u.name})
										
				return nil			
			else
			
				if string.lower(user.name)==data.tagged_name then -- other users have to be it to infect someone else
				
					if u.room == user.room then -- must be in same room
					
						data.tagged_name=string.lower(u.name)
					
						roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has tagged "..u.name})
						
						if ( not data.tagged_time ) or ( (data.tagged_time + 60) < os.time() ) then -- gain 1 cookie a minute for tagging
						
							user.cookies=user.cookies+1
														
							roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." has gained 1 cookie"})

							data.tagged_time=os.time()
						end
							
						return nil			
					end
					
				end
			
			end
			
		end
		
		return true -- do not display /me tags if it doesnt do anything
		
	elseif act=="cthulhu" then
	
		if is_mud(user.name) then return end -- naughty users

		if is_dum(user.name) or ( ( 5>user.cookies ) and ( not is_admin(user.name) ) ) then
		
			conjure_failure(user)
			
			user.cookies=0
			roomqueue(user.room,{cmd="act",frm="cthulhu",txt="has consumed "..user.name})
			set_status(nil,"ban",user.name,os.time()+(60*15))
			join_room_str(user,"swearbox")
				
			return nil			
		else
		
			if not is_admin(user.name) then
				user.cookies=user.cookies-5
			end
			
			conjure_success(user,"five cookies")
			
			return nil
		end
		
	elseif act=="ban" then
	
		return call_cthulhu_to("ban")
			
	elseif act=="gag" then

		return call_cthulhu_to("gag")

	elseif act=="dis" then
	
		return call_cthulhu_to("dis")

	elseif act=="cookies" then
	
		num=force_floor( tonumber(num_str) or 0 )
		vic=get_user(vic_str)
		
		if num_str=="a" then num=1 end
		
		if vic_str==user.room.addnoir or ( vic_str==user.room.retain_noir_name and user.room.brain ) then
		
			if num<=0 then
				userqueue(user,{cmd="note",note="error",arg1="sorry but "..num_str.." is not a valid quantity of cookies"})
				return nil
			end
		
			if ( not user.cookies or num>user.cookies ) and ( not is_admin(user.name) ) then
				userqueue(user,{cmd="note",note="error",arg1="sorry but you do not have "..num.." cookies"})
				return nil
			end
			
			local reply_str
			
			if vic_str=="meatwad" then
			
				if user.room.name=="public.zom" then
					reply_str,num=snackrifice_cookies(user,"zom",num)
				else
					reply_str="Please visit meatwad in public.zom for official business."
					num=0
				end

			elseif vic_str=="moon" then
			
				if user.room.name=="public.wolf" then
					reply_str,num=snackrifice_cookies(user,"wolf",num)
				else
					reply_str="Please visit moon in public.wolf for official business."
					num=0
				end
				
			elseif vic_str=="ygor" then
			
				if user.room.name=="public.vamp" then
					reply_str,num=snackrifice_cookies(user,"vamp",num)
				else
					reply_str="Please visit ygor in public.vamp for official business."
					num=0
				end
				
			elseif vic_str=="noir" then
			
				if user.room.name=="public" then
					reply_str,num=snackrifice_cookies(user,"chav",num)
				else
					reply_str="Please visit noir in public for official business."
					num=0
				end
							
			else -- level human by default
			
--				if user.room.name=="public.vip" then
					reply_str,num=snackrifice_cookies(user,nil,num)
--				else
--					reply_str="Please visit jeeves in public.vip for official buisness."
--					num=0
--				end
			end
			
			local brain=nil

			if num>0 then -- gave cookies?
			
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." gave "..vic_str.." "..num.." cookies"})
			
			end
			
			if reply_str then -- and say something?
			
				for u,_ in pairs(user.room.users) do
				
					if u.brain then
					
						noir_say(u.brain,reply_str)
						
						break
					end
				end
			end
			
			return nil
		end
		
		if not vic then
			userqueue(user,{cmd="note",note="error",arg1="sorry but user "..vic_str.." could not be found"})
			return nil
		end
		
		if not is_admin(user.name) then -- let users give cookies to each other
		
			if num<=0 then
				userqueue(user,{cmd="note",note="error",arg1="sorry but "..num_str.." is not a valid quantity of cookies"})
				return nil
			end
		
			if not user.cookies or num>user.cookies then
				userqueue(user,{cmd="note",note="error",arg1="sorry but you do not have "..num.." cookies"})
				return nil
			end
			
			if user.room~=vic.room then
				userqueue(user,{cmd="note",note="error",arg1="sorry but "..vic.name.." is not here"})
				return nil
			end
			
			if user.form~=vic.form then
				userqueue(user,{cmd="note",note="error",arg1="sorry but you must both be in the same form ("..user_form(user)..") to exchange cookies"})
				return nil
			end
			
			if user_rank_diff(user,vic)<0 then
				userqueue(user,{cmd="note",note="error",arg1="sorry but you can not give cookies to a higher level player."})
				return nil
			end
			
			if vic==user then -- giving to self
			
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." shows off by juggling "..num.." cookies in front of you."})
				
			else
				
				if user_ip(user) == user_ip(vic) then
				
					userqueue(user,{cmd="note",note="error",arg1="sorry but you can not give cookies to someone from the same IP."})
					return nil
					
				end

				user.cookies=user.cookies-num
				vic.cookies=(vic.cookies or 0)+num
				userqueue(vic,{cmd="note",note="act",arg1=user.name.." gave YOU "..num.." cookies"})
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." gave "..vic.name.." "..num.." cookies"})
				
log(user.name,"cookies",vic.name,num)
tlog_chance(0.01,user.name, user.name.." gave "..vic.name.." "..num.." cookies.")

			end
		
			return nil
		else
		
			if num==0 then
				vic.cookies=0
				userqueue(vic,{cmd="note",note="act",arg1=user.name.." stole all YOUR cookies"})
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." stole all the cookies from "..vic.name})
			elseif num>0 then
				vic.cookies=(vic.cookies or 0)+num
				userqueue(vic,{cmd="note",note="act",arg1=user.name.." gave YOU "..num.." cookies"})
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." gave "..vic.name.." "..num.." cookies"})
			else
				vic.cookies=(vic.cookies or 0)+num
				userqueue(vic,{cmd="note",note="act",arg1=user.name.." stole "..(-num).." of YOUR cookies"})
				roomqueue(user.room,{cmd="note",note="act",arg1=user.name.." stole "..(-num).." cookies from "..vic.name})
			end
			
			if vic.cookies < 0 then vic.cookies=0 end
			
			return nil
		end
		
	end
	
	return nil

end

-----------------------------------------------------------------------------
--
-- send a msg to everyone on the server, used for major admin notices
--
-----------------------------------------------------------------------------
function allcast(msg)

	if msg.txt then dbg(msg.txt.."\n") end
	if msg.arg1 then dbg(msg.arg1.."\n") end

	for u,v in pairs(data.users) do

		usercast(u,msg)
	
	end
	
end

-----------------------------------------------------------------------------
--
-- send a msg to given user only
--
-----------------------------------------------------------------------------
function usercast(user,msg)
--dbg("usercast ",user.name," ",msg_to_str(msg),"\n")

	if (not msg) or (not user) then return end

	fix_msg_rgb(user,msg)
	
	if user.client then
	
		if data.clients_telnet[user.client] then
		
			local s=clean_utf8(telnet_msg_to_str(user,msg))
			if s then client_send(user.client , s ) end
			
		elseif data.clients_irc[user.client] then
		
			local s=clean_utf8(irc_msg_to_str(user,msg))
			if s then client_send(user.client , s ) end
			
		elseif data.clients_websocket[user.client] then
		
			local sm=clean_utf8(msg_to_str(msg,user.msg))
--make sure the string is utf8 clean, no invalid sequences
			client_send(user.client , "\0" .. sm .. "\255")
			
		else
		
			client_send(user.client , clean_utf8(msg_to_str(msg,user.msg)) .. "\n\0")
			
		end
		
	elseif user.brain then
	
		safecall( user.brain.msg , user.brain , msg )
		
	end

	if user.hook then
		if msg.cmd=="say" then
			if msg.txt and user.name and msg.txt:sub(1,#user.name+1):lower()==(user.name:lower().." ") then

				local task={}
				task.co=coroutine.create(function()
	
					local t="&frm="..url_encode_harsh(msg.frm).."&txt="..url_encode_harsh(msg.txt).."&"
					local ret=lanes_url_user(user.hook.."?"..t)
					local s=ret.body
					local msgout={cmd="say",frm=user.name}
					if s then
						local r=str_to_msg(s)
						s=r.txt
						s=string.gsub(s, "[%c]+", "" ) -- remove controls
						s=s:sub(1,1024) -- limit length
						if #s>0 then
							if r.cmd=="act" then -- allow actions
								msgout.txt=s
								msgout.cmd="act"
							else
								msgout.txt=s
								msgout.cmd="say"
							end
						end
					else
						msgout.txt=s
						msgout.cmd="USERHOOKERROR"
						user.hook=nil
					end
					if msgout.txt and user.room then
						roomqueue(user.room,msgout,user)
					end
		
					remove_update(task)
				end)
				task.update=function() coroutine.resume(task.co) end
				queue_update(task) -- queue this new task for a response
			end
		end
	end		
end

-----------------------------------------------------------------------------
--
-- queue a msg to a given user only (brain is sent immediately)
--
-----------------------------------------------------------------------------
function userqueue(user,msg)
--dbg("usercast ",user.name," ",msg_to_str(msg),"\n")

	if (not msg) or (not user) then return end

	fix_msg_rgb(user,msg)
	
	if user.client then
	
		table.insert(data.msg_send_queue,{"user",user,msg})
		
	elseif user.brain then
	
		safecall( user.brain.msg , user.brain , msg )
		
	end

end




