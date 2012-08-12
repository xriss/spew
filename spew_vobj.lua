


-----------------------------------------------------------------------------
--
-- create a new vobj
--
-- a vobj is an object inside a ville, everything in a ville is a vobj
--
-- each room has an unlimited number of corners, each corner is a vobj
-- each player is a vobj
-- each manipulatable item is a vobj, some master with database persistance, some local without
--
-- every vobj has an id, every master vobj sits in the data.ville.vobjs table under this key
-- this key is used client and server side to to reference a vobj, everything else is a property tied to this number
--
-----------------------------------------------------------------------------
function vobj_create(tab)

local vobj={}

	vobj.mid=tab.mid or 0 -- the unique master id of this vobj, this is the id used in the data store
	vobj.cid=tab.cid -- the unique child id of this vobj if 0 then this is a master object not a child
	
	if not vobj.cid then -- child auto id object
	
		local master = assert( vobj_get_vobj( vobj.mid ) ) -- master must exist first
		
		vobj.cid=master.children_id		
		master.children_id=master.children_id+1
	
		master.children[ vobj.cid ]=vobj
	end
	
	vobj.id=vobj_ids_to_str(vobj.mid,vobj.cid) -- full id str
	
	data.ville.vobjs[ vobj.id ]=vobj
	
	vobj.type=tab.type or "vobj" -- the type of vobj
	
	vobj.owner=tab.owner or nil -- user forum name who owns this vobj the master user vobj
	vobj.group=tab.group or nil -- group name vobj who owns this vobj, any user in this group is a secondary owner of this object
		
	vobj.url=tab.url or nil -- url to an xml file containing clientside graphical information
	
	vobj.edit_lock=tab.edit_lock or "owner" -- who has basic rights to modify this vobj props
	vobj.read_lock=tab.read_lock or "all"   -- who has basic rights to read this vobjs props
	
-- these lock states are sugestions, actual access is up to the vobj itself, eg a music player,
-- could be put into a state by its owner where anyone can change the current playing music, but not anything else
-- each vobj for instance needs to stop clients from setting random properties that it doesnt understand
-- so these locks just become part of each vobjs logic
	
	vobj.props=tab.props or {} -- the public properties of this vobj
	vobj.changes={} -- the public property changes since last delta broadcast

	vobj.parent=tab.parent or nil -- the id of the vobj (probably a room) that this vobj currently exists in
	
	vobj.children={} -- local vobjs to this vobj, indexed by their child id
	vobj.children_id=1


	return vobj
		
end

-----------------------------------------------------------------------------
--
-- destroy a vobj
--
-----------------------------------------------------------------------------
function vobj_destroy(vobj)

local vroom

	remove_update(vobj) -- make sure if we where updating this object we no longer will

	if vobj.parent then
	
		vroom=data.ville.vobjs[ vobj.parent ]
		
		if vroom then

			vroom_send_del(vroom,vobj)
		
		end
		
	end

	data.ville.vobjs[ vobj.id ]=nil
	
end

-----------------------------------------------------------------------------
--
-- get a vroom from a vobj in the room
--
-----------------------------------------------------------------------------
function vobj_get_vroom(vobj)

local vroom
local id=vobj.parent

	if id then vroom=data.ville.vobjs[ id ] end

	return vroom
end

-----------------------------------------------------------------------------
--
-- get a vobj by mid and cid
--
-----------------------------------------------------------------------------
function vobj_get_vobj(mid,cid)
	
	return data.ville.vobjs[ vobj_ids_to_str(mid or 0,cid or 0) ]

end
function vobj_get_vobj_str(s)
	
	return data.ville.vobjs[ s or "" ]

end

-----------------------------------------------------------------------------
--
-- create a persistant database object with the given defaults and return it
--
-- only the logged in owner should go around creating new owned objects
-- so there is a semaphore system setup to stop this from happening multiple times
-- hopefully :)
--
-----------------------------------------------------------------------------
function vobj_data_create(tab)

-- fake it till i wire up mysql

	tab.mid=data.ville.idcount
	data.ville.idcount=data.ville.idcount+1
	tab.cid=0
	
-- fake it till i wire up mysql

	
	tab.url=""
	tab.data=""

	return tab
end

-----------------------------------------------------------------------------
--
-- load a persistant database object and return it
--
-----------------------------------------------------------------------------
function vobj_data_load(tab)

	return nil
end

-----------------------------------------------------------------------------
--
-- save a persistant database object
--
-----------------------------------------------------------------------------
function vobj_data_save(tab)

end

-----------------------------------------------------------------------------
--
-- set a prop value and broadcast the change to anyone listening
--
-- uses any custom prop setter available for the object type
--
-----------------------------------------------------------------------------
function vobj_set(vobj,prop,val,user)

--	if prop=="use" then
--dbg("use?\n"..vobj.type.."\n")
--	end
	
	if not vobj or not prop or not val then return end
	
	if vobj.set then -- use callback hook

		return vobj.set(vobj,prop,val,user)
		
	elseif data.ville.set[vobj.type] then -- use custom prop setter
	
		return data.ville.set[vobj.type](vobj,prop,val,user)
	end
	
	vobj_set_vobj(vobj,prop,val,user)

end


-----------------------------------------------------------------------------
--
-- set a prop value and broadcast the change to anyone listening
--
-----------------------------------------------------------------------------
function vobj_set_vobj(vobj,prop,val,user)

	if not vobj or not prop or not val then return end
	
	if type(vobj.props[prop])~=type(val) or vobj.props[prop]~=val then -- setting a prop to the same value does nothing

		vobj.props[prop]=val

		vobj.changes[prop]=val	-- changed flags
		data.ville.changes[vobj.id]=true
		
	end

end

-----------------------------------------------------------------------------
--
-- set a prop value as a trigger and always broadcast the change to anyone listening but never remember it
-- listeners should never remember it either
-- if you miss the broadcast you dont need to know this, its a one time effect or possible a return value
-- again these are queued and overwrite so can easily get lost
--
-----------------------------------------------------------------------------
function vobj_trigger(vobj,prop,val,user)

	if not vobj or not prop or not val then return end
	
	vobj.changes[prop]=val	-- changed flags
	data.ville.changes[vobj.id]=true
	

end

-----------------------------------------------------------------------------
--
-- set a prop value as a trigger and always broadcast the change to this vuser only
-- so only 1 client gets this msg, telling them to do something
--
-- vobj must be a vuser for this to work
--
-----------------------------------------------------------------------------
function vobj_trigger_user(vobj,prop,val,user)

	if not vobj or not prop or not val then return end
	
local msg={}

	msg.cmd="ville"
	msg.vcmd="vupd"
	msg.vid=0

	msg.vobj=vobj_ids_to_str(vobj.mid,vobj.cid)
	
	msg.vprops=prop..","..val
	
	vuser_cast(vobj,msg)

end

-----------------------------------------------------------------------------
--
-- set a prop value as a trigger and always broadcast the change to this vuser only
-- so only 1 client gets this msg, telling them to do something
--
-- vobj may be any but the info is only sent to one vuser
--
-----------------------------------------------------------------------------
function vobj_trigger_vuser(vuser,vobj,prop,val,user)

	if not vobj or not prop or not val then return end
	
local msg={}

	msg.cmd="ville"
	msg.vcmd="vupd"
	msg.vid=0

	msg.vobj=vobj_ids_to_str(vobj.mid,vobj.cid)
	
	msg.vprops=prop..","..val
	
	vuser_cast(vuser,msg)

end

-----------------------------------------------------------------------------
--
-- get a prop value
--
-----------------------------------------------------------------------------
function vobj_get(vobj,prop)

	return vobj.props[prop]

end

-----------------------------------------------------------------------------
--
-- is nam owner of this vobj
--
-----------------------------------------------------------------------------
function vobj_owner(vobj,nam)

	if string.lower(nam)==string.lower(vobj.owner) then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- test the basic edit lock for access by nam
--
-----------------------------------------------------------------------------
function vobj_edit_lock(vobj,nam)

	if vobj.edit_lock=="all" then return true end
	if vobj.edit_lock=="owner" and vobj_owner(vobj,nam) then return true end
	
	return false
end

-----------------------------------------------------------------------------
--
-- test the basic look lock for access by nam
--
-----------------------------------------------------------------------------
function vobj_look_lock(vobj,nam)

	if vobj.look_lock=="all" then return true end
	if vobj.look_lock=="owner" and vobj_owner(vobj,nam) then return true end

	return false
end


-----------------------------------------------------------------------------
--
-- objectida are a fedcba98.7654321 string, two 32bit hex numbers (lowercase leters) seperated by a dot
-- and without any leading 0s
--
-- first number is master database id, second number is child data id (0 means you are refering to the master)
--
-- so, 24.0 is master object 36 and 32.32 is child 50 of master object 50
--
-----------------------------------------------------------------------------
function vobj_ids_to_str(a,b)

	return string.format("%x.%x",a or 0,b or 0)

end
function vobj_str_to_ids(str)

local aa=str_split(".",str)

	return tonumber(aa[1] or 0,16),tonumber(aa[2] or 0,16)

end


-----------------------------------------------------------------------------
--
-- dump all props into a single string
--
-----------------------------------------------------------------------------
function vobj_build_propstr(props)

local tab={}

	for i,v in pairs(props) do
	
		table.insert(tab,tostring(i))
		table.insert(tab,tostring(v))
	
	end
	
	return table.concat(tab,",")

end


-----------------------------------------------------------------------------
--
-- build a msg to make an object say something
--
-- broadcast the returned msg to all listeners in a vroom, or just the vuser
--
-----------------------------------------------------------------------------
function vobj_build_say_msg(vobj,txt)

local msg={}

	msg.cmd="ville"
	msg.vcmd="say"
	msg.vid=0
	msg.vobj=vobj_ids_to_str(vobj.mid,vobj.cid)
	msg.txt=txt

	return msg
	
end

-----------------------------------------------------------------------------
--
-- build a msg to make an object say something
--
-- broadcast the returned msg to all listeners in a vroom, or just the vuser
--
-----------------------------------------------------------------------------
function vobj_build_act_msg(vobj,txt)

local msg={}

	msg.cmd="ville"
	msg.vcmd="act"
	msg.vid=0
	msg.vobj=vobj_ids_to_str(vobj.mid,vobj.cid)
	msg.txt=txt

	return msg
	
end

-----------------------------------------------------------------------------
--
-- build a msg to tell a room that the object has left the room
--
-- after this msg is built the vobj changes array and flags are reset so you
-- must make sure to broadcast the returned msg to all listeners to keep them in sync
--
-----------------------------------------------------------------------------
function vobj_build_del_msg(vobj)

local msg={}

	msg.cmd="ville"
	msg.vcmd="vdel"
	msg.vid=0
	msg.vobj=vobj_ids_to_str(vobj.mid,vobj.cid)

	vobj.changes={} -- forget
	data.ville.changes[vobj.id]=nil -- mark as broadcast
	
	return msg
	
end

-----------------------------------------------------------------------------
--
-- build a msg containing full information about a given vobject
--
-- this can then be broadcast to whomever needs to know,
-- eg everyone when a new object is created
--
-----------------------------------------------------------------------------
function vobj_build_full_msg(vobj)

local msg={}

	msg.cmd="ville"
	msg.vcmd="vobj"
	msg.vid=0

	msg.vobj=vobj_ids_to_str(vobj.mid,vobj.cid)

	msg.vparent=vobj.parent or "-"
	msg.vtype=vobj.type or "-"
	msg.vowner=vobj.owner or "-"
	msg.vurl=vobj.url or "-"
	msg.vlock="-" -- say its a default lock of "-" which means owner
	msg.vprops=vobj_build_propstr(vobj.props)
	
	return msg
	
end

-----------------------------------------------------------------------------
--
-- build a msg containing changed information about a given vobject
--
-- this can then be broadcast to whomever is watching the object
--
-- after this msg is built the vobj changes array and flags are reset so you
-- must make sure to broadcast the returned msg to all listeners to keep them in sync
--
-----------------------------------------------------------------------------
function vobj_build_update_msg(vobj)

local msg={}

	msg.cmd="ville"
	msg.vcmd="vupd"
	msg.vid=0

	msg.vobj=vobj_ids_to_str(vobj.mid,vobj.cid)
	
	msg.vprops=vobj_build_propstr(vobj.changes)
	
	vobj.changes={} -- forget
	data.ville.changes[vobj.id]=nil -- mark as broadcast

	return msg
	
end

-----------------------------------------------------------------------------
--
-- build a msg containing extra propdata information about a given vobject
--
-----------------------------------------------------------------------------
function vobj_build_propdata_msg(vobj)

	if not vobj.propdata then return nil end

local msg={}

	msg.cmd="ville"
	msg.vcmd="vupd"
	msg.vid=0

	msg.vobj=vobj_ids_to_str(vobj.mid,vobj.cid)
	msg.vprops=propdata_get_props_str(vobj, lanes.now_secs() )
	

	return msg
	
end

