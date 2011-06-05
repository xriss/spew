

local match_length=10*60


-----------------------------------------------------------------------------
--
-- create a user vobj
--
-----------------------------------------------------------------------------
function vobj_ball_create(tab)

	tab.type="ball"

local vobj=vobj_create(tab)

	propdata_create(vobj)

	
	local d={} -- keep some object dependent state information in this table
	vobj.data=d
		
	if vobj.props.game=="kickabout" then -- running a game
	
		vobj.update=function(vb) vobj_ball_update(vb) end  -- set update hook to fetch a global function
		queue_update(vobj)
		
		
		d.players={} -- id -> tab of each player object in this room, this table contains all extra game data
		
		d.score_home = 0 -- the score for the left side team
		d.score_away = 0 -- the score for the right side team
		
		d.kickoff=0
		d.match_start=lanes.now_secs()
		d.match_pulse=0
	
	end
	
	return vobj
		
end

-----------------------------------------------------------------------------
--
-- set a prop value and broadcast the change to anyone listening
--
-----------------------------------------------------------------------------
function vobj_ball_set_vobj(vobj,prop,val)

	if not vobj or not prop or not val then return end
	
	if type(vobj.props[prop])~=type(val) or vobj.props[prop]~=val then -- setting a prop to the same value does nothing

	
		if prop=="xyz" then
					
			local aa=str_split(":",val)
			aa[1]=tonumber(aa[1]) or 0
			aa[2]=tonumber(aa[2]) or 0
			aa[3]=tonumber(aa[3]) or 0
			aa[4]=tonumber(aa[3])
			
--dbg( aa[1] .. " : " .. aa[2] .." : ".. aa[3] )

			if aa[4] and aa[4]=="0" then
			
				propdata_set_xyzt(vobj,{x=aa[1],y=aa[2],z=aa[3]},0) -- instant set
			
			else

				propdata_set_xyzt(vobj,{x=aa[1],y=aa[2],z=aa[3]},250) -- speed of 250 a sec? thats 10 a frame at 25fps
			
			end
			
		end

		vobj.props[prop]=val

		vobj.changes[prop]=val	-- changed flags
		data.ville.changes[vobj.id]=true
		
	end

end



-----------------------------------------------------------------------------
--
-- kick a ball, need
--
-- vb ball
-- vu user
-- vr room
--
-- p1 user pos
-- p2 ball pos
--
-- the ball is then kicked depending primarily on the users velocity
--
-----------------------------------------------------------------------------
function vobj_ball_kick(vb,vu,vr,p1,p2)

	local p={}
	
	-- strat with player velocity, longer the "run up" harder the kick
	
	local dx=p2.x-p1.x
	local dz=p2.z-p1.z
	local dxz=math.sqrt(dx*dx + dz*dz)
	
	if dxz>0 then
		dx=dx/dxz
		dz=dz/dxz
	end
	
	p.x= ( ( p1.x - vu.propdata.xyzt_pos.x )*0.5 ) + (dx*150) + ((math.random()-0.5)*10)
	p.y=0
	p.z= ( ( p1.z - vu.propdata.xyzt_pos.z )*0.5 ) + (dz*150) + ((math.random()-0.5)*10)
	
	if p.x==0 and p.z==0 then -- must have some movement, if the above didnt work just randomize it
	
		p.x=(math.random()-0.5)*100
		p.y=0
		p.z=(math.random()-0.5)*100
		
		if p.x==0 then p.x=50 end -- make really really sure
		if p.z==0 then p.z=50 end
	
	end
	
-- ok, now mkae sure the vector is not too short or too long

	local dd=p.x*p.x + p.z*p.z
	local d=math.sqrt(dd)
	local s=1

--dbg("KICK "..d.."\n")
	
	if d<50 then -- must be a minimum distance of 50
	
		s=50/d
	
	elseif d>250 then -- and a maximum of 200
	
		s=250/d
		
	end
	
	p.x=p.x*s + p2.x
	p.y=0
	p.z=p.z*s + p2.z	
-- velocity has been built, now we add the actual position of the ball and tell it to move

	local s=vr.zone.size

--dbg( "K ".. p.x .. " : " .. p.z .."\n")

	vb.data.kicker=vu.id
	
	if vb.props.game=="kickabout" then -- running a game
	
		if p.x < s.x_min or p.x > s.x_max then -- flag this as a possible goal scoring kick, so add us to the updates till it is or it isnt
		
			vb.data.check_goal=true
			
		else -- dont bother checking
		
			vb.data.check_goal=false
		
		end
		
	end

	
	vobj_set(vb,"xyz", p.x ..":0:".. p.z )
	
	

end



-----------------------------------------------------------------------------
--
-- keep checking this balls position for goals until it comes to rest, then stop
--
-----------------------------------------------------------------------------
function vobj_ball_update(vb)

-- some basic checks to make sure the world has not been deleted around us

	if not data.ville.vobjs[vb.id] then return remove_update(vb) end -- check we still exist	
	local vr=data.ville.vobjs[vb.parent] -- check we still have a room
	if not vr then return remove_update(vb) end
	
-- check for end of match

	local t=lanes.now_secs()
	
	local match_time = t - vb.data.match_start
	
	if match_time > match_length then -- each match lasts five minutes
	
		vobj_ball_match_over(vb) -- award cookies
		return	
	end
	
	if match_time > vb.data.match_pulse then -- every 60 secs say something
	
	
		vb.data.match_pulse = vb.data.match_pulse + 60
	
		local room=get_room(vr.owner)
		
		if room then
		
			local h,a = vobj_ball_get_home_away_scores(vb)
			
			if h~=0 or a~=0 then -- if no game active do nothing
			
				local remaining = force_floor(match_length-match_time)
				
				if h > a then

					roomqueue(room,{cmd="note",note="act",arg1="home team leads away team by "..h.." to "..a.." goals. ("..remaining.." secs remain)" })
				
				elseif h < a then
				
					roomqueue(room,{cmd="note",note="act",arg1="away team leads home team by "..a.." to "..h.." goals. ("..remaining.." secs remain)"})
					
				else
					
					roomqueue(room,{cmd="note",note="act",arg1="home and away team are tied with "..h.." goals each. ("..remaining.." secs remain)" })
					
				end
			end
		
		end
	
	end
	
	if vb.data.kickoff > t then -- cant score again yet, resetting ball
		return
	end
			
	if not vb.data.check_goal then return end -- no possibility of scoring

-- if we are past the end of movement time then dont need to check anything else

	local p=vb.propdata.xyzt_pos
	local v=vb.propdata.xyzt_vel

	if p.t + v.t < t then -- no more movement

		vb.data.check_goal=false -- so no need to check again after this check
		
	end
	
	local vu=data.ville.vobjs[vb.data.kicker or "" ] -- get the last user to kick us
	if not vu then return end

	
-- ok, now check if we have hit a goal

	local p=propdata_get_xyzt(vb,t)

	local s=vr.zone.size
	
	
--dbg( "U ".. p.x .. " : " .. p.z .." "..t.."\n")
	
	if ( p.x < s.x_min ) or ( p.x > s.x_max ) then -- check for hit

		local dz=(s.z_max-s.z_min)
		local dx=(s.x_max-s.x_min)
		
		if ( p.z > ( s.z_min + (dz*1/3) ) ) and ( p.z < ( s.z_min + (dz*2/3) ) ) then
		
			vobj_set(vb,"xyz", (s.x_min+dx*(0.5+((math.random()-0.5)*0.2))) ..":0:".. (s.z_min+dz*(0.5+((math.random()-0.5)*0.4)) ) .. ":0" )			
			vb.data.kickoff=t+5 -- wait five secs before we can kick the ball again
			
			if ( p.x < s.x_min ) then -- away has scored
			
				vobj_ball_score(vb,vu,-1)
			
			else -- home has scored
			
				vobj_ball_score(vb,vu,1)
				
			end
			
			vb.data.check_goal=false -- dont check again until it is kicked again
			
--dbg(vb.propdata.kicker .. "\n")

		end
	
--		remove_update(vb)
	end
	

end


-----------------------------------------------------------------------------
--
-- obtain game user data, create if it doesnt exist
--
-----------------------------------------------------------------------------
function vobj_ball_obtain_user_data(vb,vu)

	local ud=vb.data.players[vu.id]
	
	if not ud then -- create
	
		ud={}
		
		ud.score=0
		
		vb.data.players[vu.id]=ud
		
	end

	return ud

end


-----------------------------------------------------------------------------
--
-- work out the current score , return two numbers home , away
--
-----------------------------------------------------------------------------
function vobj_ball_get_home_away_scores(vb)

local h=0
local a=0

	for i,v in pairs(vb.data.players) do
	
		if v.score > 0 then -- they are playing for the home team
		
			h=h+v.score
		
		else -- for the away team
		
			a=a-v.score
		
		end
		
	end

	return h,a

end

-----------------------------------------------------------------------------
--
-- this player has scred a goal fro the home side +1 or awayside -1
--
-----------------------------------------------------------------------------
function vobj_ball_score(vb,vu,side)

local msg

	vb.changes["goal"]=side	-- send a goal msg via props next chance we get
	data.ville.changes[vb.id]=true
		
		
	local ud=vobj_ball_obtain_user_data(vb,vu)
	
	ud.score = ud.score + side
	
	local match_time = lanes.now_secs() - vb.data.match_start
	local remaining = force_floor(match_length-match_time)

	local u=get_user(vu.owner)
	if u then
	
		if side > 0 then
		
			roomqueue(u.room,{cmd="note",note="act",arg1=u.name.." has scored a goal for the home team!"})
			
			msg = game_name_award_cookies("kickabout",u,500,16000)
			if msg then roomqueue(u.room,msg) end
								
			if ud.score==1 then
			
				roomqueue(u.room,{cmd="note",note="act",arg1=u.name.." is now playing for the home team!"})
			
			end
		else
			roomqueue(u.room,{cmd="note",note="act",arg1=u.name.." has scored a goal for the away team!"})
			
			msg = game_name_award_cookies("kickabout",u,500,16000)
			if msg then roomqueue(u.room,msg) end
			
			if ud.score==-1 then
			
				roomqueue(u.room,{cmd="note",note="act",arg1=u.name.." is now playing for the away team!"})
			
			end
		end
		
		local h,a = vobj_ball_get_home_away_scores(vb)
	
		if h > a then

			roomqueue(u.room,{cmd="note",note="act",arg1="home team now leads away team by "..h.." to "..a.." goals. ("..remaining.." secs remain)" })
		
		elseif h < a then
		
			roomqueue(u.room,{cmd="note",note="act",arg1="away team now leads home team by "..a.." to "..h.." goals. ("..remaining.." secs remain)"})
			
		else
			
			roomqueue(u.room,{cmd="note",note="act",arg1="home and away team are tied with "..h.." goals each. ("..remaining.." secs remain)" })
			
		end
		
	end
	
end


-----------------------------------------------------------------------------
--
-- work out the current score , return two numbers home , away
--
-----------------------------------------------------------------------------
function vobj_ball_match_over(vb)

local t=lanes.now_secs()

	local h,a = vobj_ball_get_home_away_scores(vb)
	
	local vb_data=vb.data -- remember old data as we are about to reset it

	local d={} -- keep some object dependent state information in this table
	vb.data=d	
	d.players={} -- id -> tab of each player object in this room, this table contains all extra game data
	d.score_home = 0 -- the score for the left side team
	d.score_away = 0 -- the score for the right side team
	d.kickoff=0
	d.match_start=0
	d.match_pulse=0
	
	local vr=data.ville.vobjs[vb.parent] -- check we still have a room
	if not vr then return end
	
	local room=get_room(vr.owner)
	if not room then return end -- our room has gone missing
	
	local s=vr.zone.size
	
	local dz=(s.z_max-s.z_min)
	local dx=(s.x_max-s.x_min)
		
	vobj_set(vb,"xyz", (s.x_min+dx*(0.5+((math.random()-0.5)*0.2))) ..":0:".. (s.z_min+dz*(0.5+((math.random()-0.5)*0.4)) ) .. ":0" )			
	
	vb.data.kickoff=t+10 -- wait ten secs before we can kick the ball again
	vb.data.match_start=t+10 -- wait ten secs before we can kick the ball again


	
	
	
	local award=0
	local side=0

	
	if h > a then
	
		award=a*500
		side=1
		roomqueue(room,{cmd="note",note="act",arg1="home team has won by "..h.." to "..a.." goals. All home team members get "..award.." cookies!"})
	
	elseif h < a then
	
		award=h*500
		side=-1		
		roomqueue(room,{cmd="note",note="act",arg1="away team has won by "..a.." to "..h.." goals. All away team members get "..award.." cookies!"})
		
	else -- nothing in this game for two in a bed
	
		award=0
		side=0
		roomqueue(room,{cmd="note",note="act",arg1="home and away team are tied with "..h.." goals each. Sadly no one gets any cookies."})
		
	end
		
local h=0
local a=0

	if award == 0 then
	
		roomqueue(room,{cmd="note",note="act",arg1="No cookies awarded, the winners would be given 500 times the score of the losers."})
		
	else
		for i,v in pairs(vb_data.players) do
		
			local vu=data.ville.vobjs[i]
			
			local msg
			
			if vu then -- player is still logged in
			
				if vu.parent == vb.parent then -- and in same room

					local u=get_user(vu.owner)				
					if u then
					
						if v.score > 0 then -- they are playing for the home team
						
							if side > 0 then -- winner
							
								msg = game_name_award_cookies("kickabout",u,award,16000)
								if msg then roomqueue(room,msg) end
								
							end
						
						else -- playing for the away team
						
							if side < 0 then -- winner
							
								msg = game_name_award_cookies("kickabout",u,award,16000)
								if msg then roomqueue(room,msg) end
							
							end
						
						end
						
					end
				
				end
			
			end
		
		end
	end

end



