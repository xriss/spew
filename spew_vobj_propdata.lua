



-----------------------------------------------------------------------------
--
-- initialize serverside propdata, for vobjs that we take a special interest in
-- this represents serverside knoledge derived from prop changes of a vobj
-- from this the server can for example work out where things are at a given time
--
-----------------------------------------------------------------------------
function propdata_create(vobj)

local aa=str_split(":",vobj.props.xyz or "0:0:0")

local pd={}

-- old and new positions with appropriate timestamps, simple integration can then find a point during this time period
	pd.xyzt_pos={x=tonumber(aa[1]) or 0,y=tonumber(aa[2]) or 0,z=tonumber(aa[3]) or 0,t=lanes.now_secs()}
	pd.xyzt_vel={x=0,y=0,z=0,t=0}
	
	pd.root=0 -- cant move, unless time is higher than this
	
-- vel is relative to pos, including its time
	
	vobj.propdata=pd
end


-----------------------------------------------------------------------------
--
-- get the current positions etc as a props string
--
-----------------------------------------------------------------------------
function propdata_get_props_str(vobj,t)

local t=propdata_get_xyzt(vobj,t)

	return "xyz,"..t.x..":"..t.y..":"..t.z..":now"

end

-----------------------------------------------------------------------------
--
-- get the location of an object, at the given time (time is in seconds serverside, eg lanes.now_secs() )
--
-----------------------------------------------------------------------------
function propdata_get_xyzt(vobj,t)

if not vobj.propdata then -- no propdata so get from props or return 0

	local aa=str_split(":",vobj.props.xyz or "0:0:0")
	return { x=aa[1] , y=aa[2] , z=aa[3] , t=t}

end

local p=vobj.propdata.xyzt_pos
local v=vobj.propdata.xyzt_vel


	if t >= p.t + v.t then -- movement has ended
	
		return { x=p.x+v.x , y=p.y+v.y , z=p.z+v.z , t=t }
	
	elseif t <= p.t then -- movement has not even started?
	
		return { x=p.x , y=p.y , z=p.z , t=t }
	
	elseif v.t<=0 then -- catch strangeness
	
		return { x=p.x , y=p.y , z=p.z , t=t }
		
	else -- still moving

local s= (t-p.t) / v.t
	
		return { x=p.x+(v.x*s) , y=p.y+(v.y*s) , z=p.z+(v.z*s) , t=t }

	end

end

-----------------------------------------------------------------------------
--
-- get the location of an object, at the given time (time is in seconds serverside, eg lanes.now_secs() )
--
-- and bounce off of the walls
--
-----------------------------------------------------------------------------
function propdata_get_xyzt_bounce(vobj,t)

local p=vobj.propdata.xyzt_pos
local v=vobj.propdata.xyzt_vel

	if t >= p.t + v.t then -- movement has ended
	
		return mirror_bounce(vobj,{ x=p.x+v.x , y=p.y+v.y , z=p.z+v.z , t=t })
	
	elseif t <= p.t then -- movement has not even started?
	
		return mirror_bounce(vobj,{ x=p.x , y=p.y , z=p.z , t=t })
	
	elseif v.t<=0 then -- catch strangeness
	
		return mirror_bounce(vobj,{ x=p.x , y=p.y , z=p.z , t=t })
		
	else -- still moving

local s= (t-p.t) / v.t
	
		return mirror_bounce(vobj,{ x=p.x+(v.x*s) , y=p.y+(v.y*s) , z=p.z+(v.z*s) , t=t })

	end

end

-----------------------------------------------------------------------------
--
-- set a moving object, to goto the given location , from where ever it is now, at the given speed per second
--
-- propdata will be updated with this new data
--
-----------------------------------------------------------------------------
function propdata_set_xyzt(vobj,dest,speed)

local t=lanes.now_secs()

	if vobj.propdata.root>t then return end -- cant make a new movement while rooted

local p=propdata_get_xyzt(vobj,t)

local dx,dy,dz,d

	dx=dest.x-p.x
	dy=dest.y-p.y
	dz=dest.z-p.z
	
	d=math.sqrt(dx*dx + dy*dy + dz*dz)
	
	
	vobj.propdata.xyzt_pos=p
	
	if speed==0 then	
		vobj.propdata.xyzt_vel={x=dx,y=dy,z=dz,t=0} -- instant
	else
		vobj.propdata.xyzt_vel={x=dx,y=dy,z=dz,t=d/speed}
	end

end

-----------------------------------------------------------------------------
--
-- set/send the xyz prop for the current propdata destination
-- this is queued so multiple sequental calls will overwrite and only the last change will be sent
--
-----------------------------------------------------------------------------
function propdata_send_xyzt(vobj,movetype)

local val

	val=	(vobj.propdata.xyzt_pos.x + vobj.propdata.xyzt_vel.x) .. ":" ..
			(vobj.propdata.xyzt_pos.y + vobj.propdata.xyzt_vel.y) .. ":" ..
			(vobj.propdata.xyzt_pos.z + vobj.propdata.xyzt_vel.z)
			
	if movetype then 
	
		val=val..":"..movetype
	
	end

	vobj.props.xyz=val
	vobj.changes.xyz=val	-- changed flags
	data.ville.changes[vobj.id]=true

end

-----------------------------------------------------------------------------
--
-- check if two points are close enough, pass in the square of the distance you want to check for
--
-----------------------------------------------------------------------------
function xyzt_check_distance(p1,p2,dxd)

	local dx=p1.x-p2.x
	local dy=p1.y-p2.y
	local dz=p1.z-p2.z
	
	if dx*dx + dy*dy + dz*dz < dxd then return true end
	
	return false

end

-----------------------------------------------------------------------------
--
-- get distance squared (good enough for many checks) between two points
--
-----------------------------------------------------------------------------
function xyzt_get_distance2(p1,p2)

	local dx=p1.x-p2.x
	local dy=p1.y-p2.y
	local dz=p1.z-p2.z
	
	return  dx*dx + dy*dy + dz*dz

end

-----------------------------------------------------------------------------
--
-- get distance squared (good enough for many checks) between two vobjs at the given time
--
-----------------------------------------------------------------------------
function xyzt_get_distance2_vobj(v1,v2,t)

	local p1=propdata_get_xyzt(v1,t)
	local p2=propdata_get_xyzt(v2,t)

	local dx=p1.x-p2.x
	local dy=p1.y-p2.y
	local dz=p1.z-p2.z
	
	return  dx*dx + dy*dy + dz*dz

end

-----------------------------------------------------------------------------
--
-- check and bounce this objects current pos off of the bounds of the room
--
-- only works as long as each movememnt is not more than the size of the room
--
-----------------------------------------------------------------------------
function mirror_bounce(vobj,p)

	local vroom=data.ville.vobjs[vobj.parent]
	if not vroom then return p end
			
	local s=vroom.zone.size
	
	if p.x < s.x_min then
	
		p.x = s.x_min - ( p.x - s.x_min )
		
	end
	
	if p.x > s.x_max then
	
		p.x = s.x_max - ( p.x - s.x_max )
		
	end
	
	if p.z < s.z_min then
	
		p.z = s.z_min - ( p.z - s.z_min )
		
	end
	
	if p.z > s.z_max then
	
		p.z = s.z_max - ( p.z - s.z_max )
		
	end
	
	return p

end


