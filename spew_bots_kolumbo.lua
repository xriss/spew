
local function set_prop_use(brain,prop,val,user)

dbg("kolumbo prop use ",val," = ","brain.user.name\n")

local s=string.lower(val)

	if s=="base enter kolumbo" then -- enter kolumbo

		join_room_str(user,brain.user.name)

	end
	
end


local function brain_update(brain)

local vo=brain.user.vobj -- get id
	vo=data.ville.vobjs[vo] -- turn id into object
	
	if vo then
	
		vobj_set(vo,"menu","base/cancel/Enter Kolumbo")
		
--dbg(vo.owner," ",vo.props.menu,"\n")
	
	end

end

local function brain_msg(brain,msg,user)

local newmsg
	
	if msg.cmd=="say" then -- respond to everything

	end

end

local function del_brain(brain)

	if brain then
	
		if brain.user then
			brain.user.brain=nil
			del_user(brain.user)
			brain.user=nil
		end
	
		remove_update(brain) -- in case it has been added
	end
	
end


new_brain.kolumbo = function(opts)
local brain={}

	brain.user=opts.user
	brain.user.brain=brain
	
	brain.msg=brain_msg
	brain.update=brain_update
	brain.delete=del_brain
	
	brain.set_prop_use=set_prop_use
	
	brain.saywait=5

	return brain
end


new_brain.kolumbo_bob = function(opts)
local brain={}

	brain.user=opts.user
	brain.user.brain=brain
	
	brain.msg=brain_msg
	brain.update=brain_update
	brain.delete=del_brain
	
	brain.set_prop_use=set_prop_use
	
	brain.saywait=5

	return brain
end


