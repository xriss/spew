


-----------------------------------------------------------------------------
--
-- check a local file for msgs from the php side of the server...
--
-----------------------------------------------------------------------------
local function check_localmsgs(pulse)

	if ( pulse.next_check_localmsgs ) and ( pulse.next_check_localmsgs >= os.time() )  then return end -- wait for it
	pulse.next_check_localmsgs = os.time()+30 -- check again in 30 secs
	
local fp
local msg

--dbg("checking comms file\n")

	fp=io.open(cfg.temp_chat_file,"r")
	if fp then
	
		while true do
			local line = fp:read()
			if line == nil then break end

			if line ~= "" then
			
				msg=str_to_msg(line)
				
				for _,r in pairs(data.rooms) do -- all bots say this
					roomcast(r,msg)
				end
			end
		end		
		fp:close()	
	end
	
-- remove all data from the file		

	fp=io.open(cfg.temp_chat_file,"w")
	if fp then
		fp:close()
	end
	
-- look for active arena games and broadcast who is playing in them

	for n,t in pairs(data.arena_activity or {}) do
	
		if t then
		
			msg=nil
		
			if t[2] then
			
				msg={cmd="note",note="act",
				arg1=str_join_english_list(t).." are playing "..n.." and earning cookies right now!!"}
			
			elseif t[1] then

				msg={cmd="note",note="act",
				arg1=t[1].." is playing "..n.." and earning cookies right now!!"}
			
			end
			
			if msg then
			
				for _,r in pairs(data.rooms) do -- broadcast to all rooms
				
					if r.brain and ( not r.hush_time or r.hush_time<os.time() ) then
						roomcast(r,msg)
					end
				end
			
			end
		
		end
		
	end
	data.arena_activity={}
	
end



-----------------------------------------------------------------------------
--
-- check the tagged status and broadcast the hour
--
-----------------------------------------------------------------------------
local function check_tagged(pulse)

	if ( pulse.next_check_tagged ) and ( pulse.next_check_tagged >= os.time() ) then return end -- wait for it	
	pulse.next_check_tagged = (force_floor(os.time()/(60*60))+1)*(60*60) -- check again next hour, on the hour

local msg=nil
local tim=os.date("%H:%M:%S %a %d %b GMT")
local num=0
local winners
local tab

	msg={cmd="note",note="act",
	arg1="The time is now "..tim..", no clan has won the hourly prize and dumbo is sad ;_;"}
	
dbg("The time is now "..tim.."\n")

	data.tag_crowns={} -- clear old winners
				
	if data.tagged_name then -- someone is it
	
		local u=get_user(data.tagged_name)
		
		if u and u.gametype and u.gametype=="WetVille" then -- we need someone to be it and in ville
		
			winners=nil
		
			if     u.form==nil    and u.room.name=="public.vip"  then winners="humans"
			elseif u.form=="zom"  and u.room.name=="public.zom"  then winners="zombies"
			elseif u.form=="wolf" and u.room.name=="public.wolf" then winners="werewolfs"
			elseif u.form=="vamp" and u.room.name=="public.vamp" then winners="vampires"
			end
		
			tab={}
			
			if winners then
			
				for v,b in pairs(u.room.users) do
				
						if v~=u and v.name~="me" and not v.brain and v.gametype and v.gametype=="WetVille" then
						
							v.cookies=v.cookies+10000
							num=num+10000
							
							table.insert(tab,v.name)
						end
				end
				
				num=num+10000
				u.cookies=u.cookies+num
				
				if tab[2] then
				
					roomqueue(u.room,{cmd="note",note="act",	arg1=str_join_english_list(tab).." have won 10000 cookies and a crown each!"})
					
--dbg( str_join_english_list(tab) .. " wins 100\n")

				elseif tab[1] then
				
					roomqueue(u.room,{cmd="note",note="act",	arg1=str_join_english_list(tab).." has won 10000 cookies and a crown!"})
					
--dbg( str_join_english_list(tab) .. " wins 100\n")

				end
				roomqueue(u.room,{cmd="note",note="act",	arg1=u.name.." has won "..num.." cookies and a crown+3!"})
				
log(u.name,"wontag")
				
--dbg( "on ".. tim.." "..u.name .. " wins 500 for the "..winners.."\n")
			
				msg={cmd="note",note="act",
				arg1="The time is now "..tim.." and "..u.name.." has led the "..winners.." to a "..num.." cookies victory over all other clans!"}
				
				-- extra info for crowns
				for i,v in ipairs(tab) do
					data.tag_crowns[ string.lower(v) ]=1
				end
				data.tag_crowns[ string.lower(u.name) ]=3
				
			end
		end
		
	end

	if msg then
	
		for _,r in pairs(data.rooms) do -- broadcast this to all rooms
		
			if r.brain and ( not r.hush_time or r.hush_time<os.time() ) then
				roomqueue(r,msg)
			end
		end
	
	end

end



-----------------------------------------------------------------------------
--
-- call this function whenever we get a chance
--
-----------------------------------------------------------------------------
local function update(pulse)

	if os.time()<=pulse.timestamp then return end -- do not bother checking more than once a sec	
	pulse.timestamp=os.time()
		
	check_localmsgs(pulse)
	check_tagged(pulse)
	
	day_flags_reset_check() -- check day flags
	
	if ( pulse.next_check_minute ) and ( pulse.next_check_minute >= os.time() ) then -- wait
	else
		pulse.next_check_minute = (force_floor(os.time()/(60))+1)*(60) -- check again next minute on the minute
		save_posix_data()
	end
	
	if ( pulse.next_check_hour ) and ( pulse.next_check_hour >= os.time() ) then -- wait
	else
		pulse.next_check_hour = (force_floor(os.time()/(60*60))+1)*(60*60) -- check again next hour, on the hour
		
		local tab={}
		for i,v in pairs(data.gametypes) do tab[v]=true end
		for v,b in pairs(tab) do
			if v.hour_tick then v.hour_tick() end
		end
		
		save_data() -- write full state once an hour, so restarts wont lose much
		
		game_crowns() -- check for game weaners on the hour
		
		kolumbo_relocate() -- he moves in mysterious ways
		
		setup_room_protction() -- some rooms are re-protected on the hour
		
		co_wrap_and_wait( vest_load_rates ) -- check the money market
	end
	
	if ( pulse.next_check_day ) and ( pulse.next_check_day >= os.time() ) then -- wait
	else
		pulse.next_check_day = (force_floor(os.time()/(60*60*24))+1)*(60*60*24) -- check again next day, on the day
		local tab={}
		for i,v in pairs(data.gametypes) do tab[v]=true end
		for v,b in pairs(tab) do
			if v.day_tick then v.day_tick() end
		end
		
		save_posix_data()
		
		spew_setup_stars() -- are the stars aligned?
		
		data.crowns_birthdays=nil -- a new day dawns
		data.crowns_furry_birthdays=nil -- a new day dawns
				
		wetv_log_most_played() -- store in yesterdays log file

		game_thorns() -- check for the real weaners
		
		ville_deville() -- reset all ville data and rebuild , this is 4lfa ville after all
				
	end
		
end


-----------------------------------------------------------------------------
--
-- prepare
--
-----------------------------------------------------------------------------
function setup_pulse()
	
local pulse=data.pulse or {} -- use old or create new

	pulse.timestamp=os.time()
	pulse.update=update
	
	queue_update( pulse ) -- queueing again will just replace the old one so its safe
	data.pulse=pulse
	
	pulse.next_check_minute = (force_floor(os.time()/(60))+1)*(60) -- check again next minute on the minute
	pulse.next_check_hour = (force_floor(os.time()/(60*60))+1)*(60*60) -- check again next hour, on the hour
	pulse.next_check_day = (force_floor(os.time()/(60*60*24))+1)*(60*60*24) -- check again next day, on the day

		
end

