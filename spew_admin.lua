
-----------------------------------------------------------------------------
--
-- check if name is a fag
--
-----------------------------------------------------------------------------
function is_fag(name)

	if data.fag_names[ string.lower(name) ] then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is an admin
--
-----------------------------------------------------------------------------
function is_admin(name)

	if data.admin_names[ string.lower(name or "") ] then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is a bot
--
-----------------------------------------------------------------------------
function is_bot(name)

	if data.bot_names[ string.lower(name) ] then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is a drama
--
-----------------------------------------------------------------------------
function is_drama(name)
	return data.drama_names[ string.lower(name) ]
end

-----------------------------------------------------------------------------
--
-- check if ip is a drama
--
-----------------------------------------------------------------------------
function is_dramaip(ip)
	return data.drama_ips[ ip ]
end
-----------------------------------------------------------------------------
--
-- add an ip num to the drama list
--
-----------------------------------------------------------------------------
function add_dramaip(ip,num)
	if ip and ip>0 and num and num>0 then
		if (not data.drama_ips[ ip ]) or (data.drama_ips[ ip ]<num) then data.drama_ips[ ip ]=num end -- only let the drama group rise, never lower
	elseif ip and ip>0 then
		if data.drama_ips[ ip ] and (data.drama_ips[ ip ]<2) then data.drama_ips[ ip ]=nil end -- only clear group 1 from ips
	end
end

-----------------------------------------------------------------------------
--
-- check if room contains possible drama
--
-----------------------------------------------------------------------------
function is_dramaroom(room)

	local d=65535
	if room then
		for i,n in ipairs(room.owners) do
			local r=is_drama(n)
			if r and r>0 then return r end -- room owners automagnawossname
		end
		
		local count=0
		for v,b in pairs(room.users) do
			if v.client then -- real people
				count=count+1
				if count>=5 then return 1 end -- auto drama engage in groups
				local n=is_dramaip(user_ipnum(v))
				if n and n<d and n>0 then d=n end -- lower group owns the room
			end
		end
	end
	if d==65535 then return false else return d end
end

-----------------------------------------------------------------------------
--
-- check drama setting
--
-----------------------------------------------------------------------------
function drama_update(name,num)

local function dramakickroom(room)
	if room then
		local d=is_dramaroom(room)
		
		if d and d>0 then
			for v,b in pairs(room.users) do
				if v.client then -- real people
					local n=is_dramaip(user_ipnum(v))
					if n and n>0 and n~=d then -- kickem into limbo
						join_room(v,data.rooms.limbo)
					end
				end
			end
		end
	end
end

	if name then -- dont need to set anything
		if num and num>0 then
			data.drama_names[ string.lower(name) ]=num
			
			local u=get_user(name)
			if u then add_dramaip(user_ipnum(u),num) end
		else
			data.drama_names[ string.lower(name) ]=nil
			
			local u=get_user(name)
			if u then add_dramaip(user_ipnum(u),0) end
		end
-- kick people out of room

			local user=get_user(name)
			local room=user and user.room
			
			dramakickroom(room)
		
		return
	end
	
	local active_drama={}
	
	for i,v in pairs(data.drama_names) do
		active_drama[v]=true
	end
	
	-- scan current users
	for u,v in pairs(data.users) do
		local d=is_drama(u.name) or 0
		if d>0 then add_dramaip(user_ipnum(u),d) end
	end
	
	-- remove old junks
	for i,v in pairs(data.drama_ips) do
		if not active_drama[v] then -- clear out cached drama that is no longer needed, when a group is removed
			data.drama_ips[i]=nil
		end
	end

-- fix some drama conflicts?
	for n,r in pairs(data.rooms) do
		dramakickroom(r)
	end
end

-----------------------------------------------------------------------------
--
-- check if name is an of a room, thats either world admins or local owners
--
-----------------------------------------------------------------------------
function is_room_admin(user,room)

	if not user then return false end

local name=string.lower(user.name)

	if data.admin_names[ name ] then return true end
	
	if room then
	
		for i,v in ipairs(room.owners) do
			if string.lower(v)==name then return true end
		end
		
	end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is a super admin :)
--
-----------------------------------------------------------------------------
function is_god(name)

	if name and data.god_names[ string.lower(name) ] then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is a server controled bot
--
-----------------------------------------------------------------------------
function is_bot(name)

	if data.bot_names[ string.lower(name) ] then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is mod, which is a mini admin,
-- which means some free cthulhu powers, (slowly trying to be phased out) and
-- allowed to enter the staff room
--
-----------------------------------------------------------------------------
function is_mod(name)

	if data.mod_names[ string.lower(name) ] then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is a mud, which means reduced powers
--
-----------------------------------------------------------------------------
function is_mud(name)	
		
	local days=data.mud_names[ string.lower(name) ]
	
	if days then return days end
	
	return false
end

function is_mudip(name)

	for i,v in ipairs( get_shared_names_by_ip(name) or {name} ) do
	
		local days=is_mud(v)
		if days then
			return days
		end
	
	end

	local ipnum=data.ipmap[string.lower(name)]
	if cfg.cockblocked and type(ipnum)=="string" then -- sanity
		for i,v in ipairs(cfg.cockblocked) do
			if ip:sub(1,#v) == v then -- string must begin with
--dbg("cock blocked "..ip.."\n")
				return 10
			end
		end
	end
	
		
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is a dum, which means reduced powers
--
-----------------------------------------------------------------------------
function is_dum(name)

	if data.dum_names[ string.lower(name) ] then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if name is a fag, which means we have lost patience
--
-----------------------------------------------------------------------------
function is_fag(name)

	if data.fag_names[ string.lower(name) ] then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- check if a string contains a bad word
--
-----------------------------------------------------------------------------
function is_swear(s,badwords)

	local badwords=badwords or data.badwords

	s=string.lower(s)

	for i,v in ipairs(badwords) do -- check for swears
	
		local d, e = string.find(s,v,1,true)
		
		if d then -- found bad word
		
			return v

		end
		
	end
	
	return false
end

-----------------------------------------------------------------------------
--
-- fags have limited ascii access
--
-----------------------------------------------------------------------------

function string_fag_filter(s)

	return string.gsub(s or "", "[^%s%l%u]+", "" )

end

-----------------------------------------------------------------------------
--
-- bork it up
--
-----------------------------------------------------------------------------

function string_chef_filter(s)

	if not s then return s end

local words=
{
	["the"]="zee",
}

local doub=
{
	["an"]="un",
	["au"]="oo",
	["en"]="ee",
	["ew"]="oo",
	["th"]="t",
}

local sing=
{
	["o"]="oo",
	["a"]="e",
	["f"]="ff",
	["i"]="ee",
	["v"]="f",
	["w"]="v",
}


local function f(s)

local t,ss,l

	if words[s] then return words[s] end
	
	ss=""
	l=string.len(s)
	
local i=1
	while i<=l do
	
		t=string.sub(s,i,i+1)
				
		if doub[t] then
		
			ss=ss..doub[t]
			
			i=i+2
		
		else
		
			t=string.sub(s,i,i)

			if sing[t] then
			
				ss=ss..sing[t]
				
			else
			
				ss=ss..t
				
			end
			
			i=i+1
			
		end
	
	end
	
	return ss
end

	s=string.lower(s)
	s=string.gsub(s, "[^a-z 0-9:]+", "" )
	s=string.gsub(s, "%a+", f)
	
	return s
end


-----------------------------------------------------------------------------

local guest_filter_strings=
{
["sex"]="cookies",
["SEX"]="milk and cookies",
["fag"]="fabulous person",
["FAG"]="really fabulous person",
["fags"]="fabulous persons",
["FAGS"]="really fabulous persons",
["cyber"]="share",
["CYBER"]="super share",
["gay"]="fabulous",
["GAY"]="really fabulous",
["horny"]="divine",
["HORNY"]="really divine",
["sexy"]="super",
["SEXY"]="really super",
["hot"]="sweaty",
["HOT"]="really sweaty",
["hi"]="salutations",
["Hi"]="salutations brothers",
["hI"]="salutations sisters",
["HI"]="salutations brothers and sisters",
["yo"]="salutations",
["Yo"]="salutations brothers",
["yO"]="salutations sisters",
["YO"]="salutations brothers and sisters",
["dirty"]="icky",
["DIRTY"]="grimey",
["wtf"]="twf",
["WTF"]="TWF",
["bored"]="a pretty pony",
["Bored"]="a lovely horse",
["BORED"]="a dirty donkey",
["boring"]="excellent",
["Boring"]="Excellent",
["BORING"]="EXCELLENT",
["whore"]="lady of the night",
["WHORE"]="big fat lady of the night",
["pussy"]="cat",
["PUSSY"]="big fat cat",
["suck"]="finger paint",
["SUCK"]="big fat finger paint",
["chick"]="ball",
["chicks"]="balls",
["CHICK"]="beach ball",
["CHICKS"]="beach balls",
["http"]="www",
}

-----------------------------------------------------------------------------
--
-- filter some dumb words that guests use
--
-----------------------------------------------------------------------------
function guest_filter(s)

	return string.gsub(s, "%a+", guest_filter_strings)

end





-----------------------------------------------------------------------------
--
-- a room admin can kick any user in their room into any other room (a public room is default)
--
-----------------------------------------------------------------------------
function kick_user(user,victim_name,room_name)

--dbg(room_name)

	if is_god(victim_name) then return end -- super special
	
	local victim=get_user(victim_name)
	
	if not victim then
		usercast(user,{cmd="note",note="notice",arg1="sorry but the victim cannot be found"})
		return
	end
	
	local room
	
	if room_name and room_name~="" then

		room=get_room(room_name)
	
	end
	
	if victim then
	
		if victim.room~=user.room and not is_admin(user.name) then
		
			usercast(user,{cmd="note",note="notice",arg1="sorry but the victim must be in the same room"})
			return
		end
	
		if is_admin(user.name) or is_room_owner(user.room,user.name) then
		
			if room then
		
				roomcast(user.room,{cmd="note",note="notice",arg1=user.name.." has kicked "..victim.name.." into "..room.name})
				if is_god(user.name) then
					join_room(victim,room) -- a god kick is a force join
				else
					join_room_str(victim,room.name) -- this checks they are allowed
				end
			else
			
				roomcast(user.room,{cmd="note",note="notice",arg1=user.name.." has kicked "..victim.name.." into public"})
				join_room_pub(victim)
			
			end
			
			vuser_check_and_set_god_act(user,victim_name)
			
		else
		
			usercast(user,{cmd="note",note="notice",arg1="I'm sorry "..user.name.. " I'm afraid I can't do that."})
		
		end
	end
	
end


-----------------------------------------------------------------------------
--
-- cthulhu will help you if you perform a snackrifice
--
-- 1 cookies undoes 1 minute of bans
--
-----------------------------------------------------------------------------
function clear_status_cthulhu(victim_name,avail_cookies)

	local used_cookies=0

	local idstr=get_idstring(victim_name)
	
	if idstr~="*" then -- this is a user we can effect
		
		local t=data.status["*"][idstr]
		local tim=os.time() -- now tim
		
		if t then
		
			for i,v in ipairs({"ban","gag","dis"}) do
			
				if t[v] then
				
					if t[v].time then
					
						if t[v].time<tim then -- already up?
						
							t[v]=nil
						
						else
						
							local need = math.ceil((t[v].time-tim))
							
							if need > (avail_cookies+used_cookies) then -- partial unban
							
								t[v].time=t[v].time-((avail_cookies+used_cookies))
							
								used_cookies=used_cookies+avail_cookies
								avail_cookies=0
							
							else -- full unban
							
								t[v]=nil
							
								if need > used_cookies then -- this cost some cookies
								
									used_cookies=used_cookies+(need-used_cookies)
									avail_cookies=avail_cookies-(need-used_cookies)
									
								end
								
							end
						
						end
					
					end
				
				end
			
			end

-- clear out all bans if its all gone

			if ( not t.dis ) and ( not t.gag ) and ( not t.ban ) then t=nil end
			
		end
		
		data.status["*"][idstr]=t
			
	end
	
	
	apply_status_to_users(idstr)
	
	return used_cookies
	
end

-----------------------------------------------------------------------------
--
-- return any band global status as a string
--
-----------------------------------------------------------------------------
function get_banedfor_string(victim_name)

	local idstr=get_idstring(victim_name)
	
	local edup={ ["dis"]="dissed" , ["gag"]="gagged" , ["ban"]="banned" }
	
	if idstr~="*" then -- this is a user we can effect
		
		local t=data.status["*"][idstr]
		local tim=os.time() -- now tim
		
		if t then
		
			for i,v in ipairs({"ban","dis","gag"}) do
			
				if t[v] then
				
					if t[v].time then
					
						if t[v].time>=tim then -- active
						
						local timfor=t[v].time-tim
						
							if timfor<60 then
							
								return "is "..edup[v].." for "..timfor.." more seconds"
							
							end
							
							timfor=math.ceil(timfor/60)
						
							if timfor<60 then
							
								return "is "..edup[v].." for "..timfor.." more minutes"
								
							end
						
							timfor=math.ceil(timfor/60)
							
							if timfor<24 then
							
								return "is "..edup[v].." for "..timfor.." more hours"
								
							end
							
							timfor=math.ceil(timfor/24)
							
							return "is "..edup[v].." for "..timfor.." more days"
							
						end
					
					end
				
				end
			
			end

-- clear out all bans if its all gone

			if ( not t.dis ) and ( not t.gag ) and ( not t.ban ) then t=nil end
			
		end
			
	end
	
	return "is not banned"
	
end


-----------------------------------------------------------------------------
--
-- set a status effec on a user for a set amount of time over a certain range
--
-- stat_type is a ban , gag or dis(emvowel)
-- stat_time is time stamp to ban until  (0) unbans if you have the power, -1 bans for evah
--
-- admins can global ban ips or names from public
-- users can apply local bans to their room
--
-- forum bans need to be used for more perminant actions.		
--
-----------------------------------------------------------------------------
function set_status(user,stat_type,victim_name,stat_time)

	vuser_check_and_set_god_act(user,victim_name)
	
--dbg(user.name," : ",stat_type," : ",victim_name," : ",stat_time,"\n")

	local idstr=get_idstring(victim_name)
		
	local uv,v,t
	
	if is_god(victim_name) then return end -- super special, can not be messed with at all
	if is_admin(victim_name) and user==nil then return end -- admin can not be messed with by using cookies
	
	if ( user and (data.admin_names[ string.lower(user.name) ]) ) and (stat_time~=0) then -- admin can also destroy a room and kick everyone into public
	
		local room=get_room(string.lower(victim_name))
		
		if room then
		
			del_room(room)
		
		end
	end

	if idstr~="*" then -- this is a user we can effect
	
	local admin_ban=false
	
		if ( not user ) or data.admin_names[ string.lower(user.name) ] then -- admin is performing status change (this is global)
		
			uv=nil
			v=data.status["*"][idstr] or {}
			t=v[stat_type] or {}
			
			if ( user ) or ( not t.time ) or ( stat_time > t.time ) then -- cookie bans can only make things worse...
				if user then
					t.admin=string.lower(user.name)
				else
					t.admin="*"
				end
				t.time=stat_time
			end
			
			data.status["*"][idstr]=v
			v[stat_type]=t
			
			admin_ban=true
			
		elseif is_room_owner(user.room,user.name) then --
	
			uv=data.status[ user.room.owners[1] ] or {}
			v=uv[idstr] or {}
			t=v[stat_type] or {}
			
-- the above code gets or creates
			
			t.admin=string.lower(user.name)
			t.time=stat_time

-- the below code sets

			uv[idstr]=v
			data.status[ user.room.owners[1] ]=uv
			v[stat_type]=t
			
		end
		
		
		apply_status_to_users(idstr) -- update the victim to reflect the ban change
		
		
		if admin_ban then --admin tell any room they are in
		
			apply_status_to_logs(stat_type,victim_name)
			
			if user then -- need a user to be passed in
			
				roomcast(user.room,{cmd="note",note=stat_type,arg1=user.name,arg2=victim_name,arg3=stat_time})
			
			end
		
		else -- normal user, only tell their owned room
		
			if is_room_owner(user.room,user.name) then
			
				roomcast(user.room,{cmd="note",note=stat_type,arg1=user.name,arg2=victim_name,arg3=stat_time})
			
			end
			
		end

	end

end

-----------------------------------------------------------------------------
--
-- set status on everyone associated
--
-----------------------------------------------------------------------------
function set_status_all(user,stat_type,victim_name,stat_time)

	local tab=get_shared_names_by_ip(victim_name) -- hit all people of the same ip
	if not tab then tab={victim_name} end
	for i,v in ipairs(tab) do
		set_status(user,stat_type,v,stat_time)
	end
end
			


-----------------------------------------------------------------------------
--
-- update the stored status in the given user
-- then
-- check that the user is allowed to be where they are
--
-----------------------------------------------------------------------------
function update_and_check_user_status(user,room)

	if not room then room=user.room end
	
	local status={}
		
	local function build_status(status,from)
			
		if from then
			
			for i,v in ipairs({"dis","gag","ban"}) do
			
				if from[v] then
				
					status[v]={ admin=from[v].admin , time=from[v].time }
					status[1]=true
					
				else
				
					status[v]=nil
					
				end
				
			end
			
		end
	
	end
	
	build_status( status, data.status["*"][user_idstring(user)] ) -- start with global admin
	
	
	if room then -- use admin from the room we are about to move into
		
		if room.name=="swearbox" then -- allow swearbox people to speak and not be gaged, dis however continues
		
			for i,v in ipairs({"gag","ban"}) do
			
				if status[v] then
					status[v].time = status[v].time - (60*60*24) -- reduced bans in swearbox room by 24 hours
				end
				
			end
			
		elseif is_room_owner(room,user.name) then -- own room (admin here) so some global bans are auto reduced, long bans will still be in effect
			
			for i,v in ipairs({"dis","gag","ban"}) do
			
				if status[v] then
					status[v].time = status[v].time - (60*60*24*365) -- reduced bans in own room by 1 year
				end
				
			end
			
--			status[1]=false
			
		else -- local admin can not effect self
		
			local			check=room
			if check then	check=check.owners[1]									end		
			if check then	check=data.status[check]								end		
			if check then	build_status( status, check[user_idstring(user)] )		end
			
		end
		
	end
	

	if status[1] then
		
		user.status=status
		
	else -- setting status to nil lets us shortcut most of the checks from now on, most people are not banned after all
	
		user.status=nil

	end
	
	check_user_status(user)
	
end


-----------------------------------------------------------------------------
--
-- check that the user is allowed to be where they are
--
-----------------------------------------------------------------------------
function check_user_status(user)
	
	if user.status then
	
		if     user.status.ban and ( user.status.ban.time > os.time() ) then
		
			user.status.active="ban"
			
		elseif user.status.gag and ( user.status.gag.time > os.time() ) then
			
			user.status.active="gag"
			
		elseif user.status.dis and ( user.status.dis.time > os.time() ) then
			
			user.status.active="dis"
			
		else
			
			user.status.active=nil
			
		end
		
		
		if user.status.active == "ban" then -- put them in swearbox
		
			if user.room.name~="swearbox" then
			
				join_room(user,get_room("swearbox"))			
				user.newmsg=nil -- delete the msg
				return
			end
		
		end
		
		if user.status.active and user.newmsg then -- process msg before it gets sent
		
			if apply_status_to_msg(user.newmsg,user.status.active)=="" then
			
				user.newmsg=nil -- delete the msg
				
			end
				
		end
		
	end
	
	if user.newmsg and ( not user_confirmed(user) ) and (user.room) and (user.room.brain) then -- censor grunts of retarded guests
	
		if user.newmsg.cmd=="say" then -- filter
		
			if user.room.hush_super and user.room.hush_time and user.room.hush_time>=os.time() then
			
				-- bot is super hushed, not even a filter gets applied
			
			else
	
				user.newmsg.txt=guest_filter(user.newmsg.txt)
			end
		end
	end
	
end


-----------------------------------------------------------------------------
--
-- apply change into any current users that match the idstr for the victims name
-- possibly multiple guests
--
-----------------------------------------------------------------------------
function apply_status_to_users(idstr)
	
	if idstr~="*" then

		for v,b in pairs(data.users) do
		
			if user_idstring(v) == idstr then
			
				update_and_check_user_status(v)
			
			end
	
		end
	
	end
	
end

-----------------------------------------------------------------------------
--
-- apply change retro activly to all logs in all public rooms
--
-----------------------------------------------------------------------------
function apply_status_to_logs(stat_type,victim_name)

--[[	stop doing this?
	for i,v in pairs(data.rooms) do
	
		apply_status_to_room(v,stat_type,victim_name)
		
	end
]]

end

-----------------------------------------------------------------------------
--
-- apply change retro activly to logs in a given room
--
-----------------------------------------------------------------------------
function apply_status_to_room(room,stat_type,victim_name)

--[[ stop doing this?
local docompact=false

	for i,v in ipairs(room.history) do

--dbg(v.cmd," : ",v.frm," : ",victim_name,"\n");

		if v.cmd=="say" or v.cmd=="act" then -- filter
		
			if string.lower(v.frm)==string.lower(victim_name) then
			
--dbg(v.txt,"\n")			
			
				if apply_status_to_msg(v,stat_type)=="" then docompact=true end
				
			end
			
		end
		
	end
	
	if docompact then
	
		compact_history(room)
		
	end
]]

end

-----------------------------------------------------------------------------
--
-- apply a change to a given message, returns possibly modified msg or nil to delete entire msg
--
-----------------------------------------------------------------------------
function apply_status_to_msg(msg,stat_type)
	
	if msg.cmd=="say" or msg.cmd=="act" then -- filter
	
		if     stat_type=="dis" then
		
			msg.txt=string.gsub(msg.txt, "[aeiouAEIOU]+", "" )
			return msg.txt
			
		elseif stat_type=="gag" then
		
			msg.txt=string.gsub(msg.txt, "[^aeiouAEIOU]+", "" )
			return msg.txt
		
		elseif stat_type=="ban" then
		
			msg.txt=""
			return msg.txt
		
		end
	
	end
	
	return "*"

end
