

-----------------------------------------------------------------------------
--
-- check all ville data is valid on server load or reload
--
-----------------------------------------------------------------------------
function ville_data_setup()

local function dd(nam,dat)
	if not data.ville[nam] then data.ville[nam]=dat end
end

	dd("vobjs",{}) -- array of all vobjs live on server, indexed by full id a str
	dd("rooms",{}) -- array of all data related to each named active ville room indexed by name of room (a room is a vobj and a collection of corners)
	dd("users",{}) -- array of all data related to each named active ville user indexed by name of user (a user is a vobj and a collection of owned vobjs)

	dd("avatars",{}) -- array of name to avatar url look up, built from disc or changed by users

	dd("changes",{}) -- array of recently changed ids, id->true, clear vobjs when changes have been broadcast
	
	dd("idcount",1) -- temporary vobj id counter
	
	-- save ville objects
	-- every room/door/user/whatever in ville is an object
	-- only persistant objects are saved in the database, some are just built locally to rooms as they manifest themselves
	spew_mysql_table_create("ville_vobjs",
	{
		--	name		type			NULL	nil,	default		extra
		{	"id",		"int(11)",		"NO",	"PRI",	nil,		"auto_increment"	},
		{	"type",		"int(11)",		"NO",	"MUL",	nil,		nil					},
		{	"owner",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- forum user id
		{	"group",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- group vobj id
		{	"url",		"varchar(255)",	"NO",	"MUL",	nil,		nil					}, -- xml file containing client only info, the server doesn't care
		{	"data",		"text",			"NO",	nil,	nil,		nil					}, -- serialised server object data
		
	})
	
	data.ville.types={"user","room"}
	for i,v in ipairs(data.ville.types) do
		data.ville.types[v]=i
	end
	
	data.ville.set 			= data.ville.set or {}

	data.ville.set.user		=vuser_set_vobj
	data.ville.set.bot		=vuser_set_vobj
	
	data.ville.set.ball		=vobj_ball_set_vobj
--	data.ville.set.door		=vobj_door_set_vobj
	
	
	if not vobj_get_vobj(0,0) then -- create master object id 0 
	
		vobj_create({mid=0,cid=0})
	
	end
	
end



-----------------------------------------------------------------------------
--
-- incoming ville msg
--
-----------------------------------------------------------------------------
function ville_msg(user,msg)

--dbg("VILLE:"..dbg_msg(msg))

	if     msg.vcmd=="ret" then -- this is a returned response (from the client), could happen but just ignore for now
		
	elseif msg.vcmd=="setup" then -- user is joining the ville, send it initial data
	
		ville_msg_setup(user,msg)
	
	elseif msg.vcmd=="vupd" then -- user is updating props of one of its objects
	
		ville_msg_vupd(user,msg)
		
	end


	return nil
		
end



-----------------------------------------------------------------------------
--
-- recieve a join msg, send initial information about the room to the user
-- the user joins the ville in their current room, ( a new setup msg should be sent every time we change rooms )
-- or if the client wants to reset its state with a new blank data
-- after setups any changes to the room/corner will be broadcast to this ville client even after they leave the room in chat
-- any incoming msgs will go to the room where they joined. So the ville works as an alternative presence to the chat
-- you may keep them together or split them apart.
--
-----------------------------------------------------------------------------
function ville_msg_setup(user,msg)

local room
local vuser,vroom,m

		
	vuser=vuser_obtain(user)
	room=user.room
	
	vroom=vobj_get_vroom(vuser)
	
	if not vroom then
		vroom=vroom_obtain(user.room)
	end
	
	if room and room.ville_game then -- talk to the ville game
		if room.ville_game.vroom_which then vroom=room.ville_game.vroom_which(room,user) end
	end
	
	user.vobj=vuser.id -- map the user to the id and use as flag to show we are logged into ville
	
	vroom_join( vroom , vuser )
	
end


-----------------------------------------------------------------------------
--
-- update props of a vobj and broadcast the change
--
-----------------------------------------------------------------------------
function ville_msg_vupd(user,msg)

local vuser
local vobj
local aa

	vuser=vuser_obtain(user)
	
--	vroom=vroom_obtain(user.room)
	
	vobj=data.ville.vobjs[ msg.vobj ]
	
	if vobj then -- got an object to update
	
		aa=str_split(",",msg.vprops)
		
		for i=1,#aa,2 do
		
			vobj_set( vobj , aa[i] , aa[i+1] , user)
		
		end
	
	end
	
end


-----------------------------------------------------------------------------
--
-- broadcast all the cahnged objects
--
-----------------------------------------------------------------------------
function ville_broadcast_changes()

local vobj
local vroom

	for n,b in pairs(data.ville.changes or {}) do
	
		vobj=data.ville.vobjs[n]
		
		if vobj then
		
			vroom=data.ville.vobjs[vobj.parent]
			
			if vroom then
			
				vroom_cast(vroom, vobj_build_update_msg(vobj) )
			
			end
		
		end

	end

end


-----------------------------------------------------------------------------
--
-- clear all data and rebuild
--
-----------------------------------------------------------------------------
function ville_deville()

	co_wrap_and_wait(function()

		allcast( {cmd="say",frm="cthulhu",txt="Ville is being devilled, please remain calm."} )
		
		for i,v in pairs(data.ville.rooms) do

			if v then
			
				vroom_destroy(v)
			end
		end

		reload_brains({nocrowns=true})

		data.ville={}
		data.items={}

		data.ville.deville=true

		item_data_setup()
		ville_data_setup()

		for n,u in pairs(data.names) do -- load all item data	
			item_load_all(n)	
			coroutine.yield()
		end	
		
		for n,b in pairs(data.bot_names) do -- load all bot owned item data	
			item_load_all(n)
			coroutine.yield()
		end	


		reload_brains({nocrowns=true})

		data.ville.deville=false

		for u,v in pairs(data.users) do -- force all users to reload
			if u.vobj then -- tell this user to reload the room
				ville_msg_setup(u)
				coroutine.yield()
			end
		end

		allcast( {cmd="say",frm="cthulhu",txt="Ville has been rebootededededted"} )
	end)

end


