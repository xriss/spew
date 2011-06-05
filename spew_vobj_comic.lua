

local vobj_type = "comic"

-----------------------------------------------------------------------------
--
-- create a user vobj
--
-----------------------------------------------------------------------------
local function vobj_local_create(tab)

--dbg("creating ",vobj_type,"\n")
--dbg(tab.props.brain,"\n")

	tab.type=vobj_type

local vobj=vobj_create(tab)

	propdata_create(vobj)
	
	if vobj.props.brain == "vback" then -- the users room background panel thingy
	
		vobj.props.menu="base/cancel"
		
		vobj.props.image="http://4lfa.com/pms/cheese.png"
		
	else
	
		vobj.props.menu="base/cancel/next/last/first/prev"
	
		vobj.props.image="http://4lfa.com/pms/cheese.png"
		
	end
	
	
	return vobj
	
end

-----------------------------------------------------------------------------
--
-- check if we should change anything about this vobj, called when a player enters a room for all the rooms contents
--
-----------------------------------------------------------------------------
local function vobj_local_check(vobj)

--local user=get_user(vobj.owner)
--local vuser=get_vuser(vobj.owner)
	
	if vobj.props.brain == "vback" then -- the users room background panel thingy

		local room=get_room(vobj.owner)
		
		if room and room.vback then

			vobj_set(vobj,"image",room.vback)
			
--dbg("image"," : ",room.vback,"\n")

		end
	
	end

end


-----------------------------------------------------------------------------
--
-- get the oldest comic younger than the given time, or the oldest comic if none given
-- sort in direction of d, default is -1
--
-----------------------------------------------------------------------------
local function get_a_comic(t,d)

local max_time=""
local orderby="DESC"

	if t then
		if d and d>0 then
			max_time=" AND time>"..t.." "		
			orderby="ASC"
		else
			max_time=" AND time<"..t.." "
		end
	end

	local ret=lanes_sql(
	" SELECT * from alfa_pages "..
	" WHERE time>0 "..max_time.." AND type='PMS' AND png!='NULL' "..
	" ORDER BY time "..orderby..
	" LIMIT 1 " )
	
	if ret and ret[1] then
		return sql_named_tab(ret,1)
	end
	
	return nil

end

-----------------------------------------------------------------------------
--
-- set a prop value and broadcast the change to anyone listening
--
-----------------------------------------------------------------------------
local function vobj_local_set_vobj(vobj,prop,val)

	if not vobj or not prop or not val then return end
	
	if type(vobj.props[prop])~=type(val) or vobj.props[prop]~=val then -- setting a prop to the same value does nothing

		if vobj.props.brain == "vback" then -- the users room background panel thingy

			vobj.props[prop]=val

			vobj.changes[prop]=val	-- changed flags
			data.ville.changes[vobj.id]=true
				
		else
		
			if prop=="use" then -- custom menu act

--dbg(vobj.id," comic use ",val,"\n")

				if not vobj.propdata.comic_now then -- grab one first
				
					vobj.propdata.comic_now=get_a_comic()
					
					if vobj.propdata.comic_now then
						
--	dbg( serialize(vobj.propdata.comic_now) )
		
						vobj.propdata.comic_next = get_a_comic( vobj.propdata.comic_now.time ,  1 )
						vobj.propdata.comic_prev = get_a_comic( vobj.propdata.comic_now.time , -1 )
					
						vobj_set(vobj,"image",vobj.propdata.comic_now.png..".png")
					end
					
				end
					
				if     val=="base next" then
				
					if vobj.propdata.comic_next then
					
						vobj.propdata.comic_prev=vobj.propdata.comic_now
						vobj.propdata.comic_now=vobj.propdata.comic_next
					
						vobj.propdata.comic_next = get_a_comic( vobj.propdata.comic_now.time ,  1 )
						
						vobj_set(vobj,"image",vobj.propdata.comic_now.png..".png")
					end
											
				elseif val=="base prev" then
				
					if vobj.propdata.comic_prev then
					
						vobj.propdata.comic_next=vobj.propdata.comic_now
						vobj.propdata.comic_now=vobj.propdata.comic_prev
					
						vobj.propdata.comic_prev = get_a_comic( vobj.propdata.comic_now.time , -1 )
						
						vobj_set(vobj,"image",vobj.propdata.comic_now.png..".png")
					end
											
				elseif val=="base first" then
				
					vobj.propdata.comic_now=get_a_comic(0,1)
					
					if vobj.propdata.comic_now then
		
						vobj.propdata.comic_next = get_a_comic( vobj.propdata.comic_now.time ,  1 )
						vobj.propdata.comic_prev = get_a_comic( vobj.propdata.comic_now.time , -1 )
					
						vobj_set(vobj,"image",vobj.propdata.comic_now.png..".png")
					end
					
				elseif val=="base last" then
				
					vobj.propdata.comic_now=get_a_comic()
					
					if vobj.propdata.comic_now then
		
						vobj.propdata.comic_next = get_a_comic( vobj.propdata.comic_now.time ,  1 )
						vobj.propdata.comic_prev = get_a_comic( vobj.propdata.comic_now.time , -1 )
					
						vobj_set(vobj,"image",vobj.propdata.comic_now.png..".png")
					end
					
				end
			
			else
		
				vobj.props[prop]=val

				vobj.changes[prop]=val	-- changed flags
				data.ville.changes[vobj.id]=true
			
			end
		
		end
		
	end

end

-- store pointers to these functions in data tabs, creating them if we need to, so a reload updates the pointers

data.ville 						= data.ville or {}

data.ville.create 				= data.ville.create or {}
data.ville.create[vobj_type]	= vobj_local_create

data.ville.check 				= data.ville.check or {}
data.ville.check[vobj_type]		= vobj_local_check

data.ville.set 					= data.ville.set or {}
data.ville.set[vobj_type]		= vobj_local_set_vobj
