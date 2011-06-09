
-----------------------------------------------------------------------------
--
-- setup item related data
--
-----------------------------------------------------------------------------
function item_data_setup()

	data.items = data.items or {}
	
	data.items.users = data.items.users or {} -- users that have had their items loaded into the world
	
	data.items.ids = data.items.ids or {}
	data.items.home = data.items.home or {}

	data.items.ids_idx = -1 -- a tempory item id index, sub 1 for next, real items are positive
	
	-- available item types, linking bothways, string to number or number to string
	data.items.types={"balloon"}
	for i,v in ipairs(data.items.types) do
		data.items.types[v]=i
	end
	

	-- an item is something owned by a user, eg something in their inventory
	-- it may manifest in the world but it is not of the world
	spew_mysql_table_create("spew_items",
	{
		--	name		type			NULL	nil,	default		extra
		{	"id",		"bigint(20)",	"NO",	"PRI",	nil,		"auto_increment"	}, -- unique object ID
		{	"time",		"bigint(20)",	"NO",	"MUL",	nil,		nil					}, -- last time this item was updated
		{	"type",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- the type of item, 1==balloon
		{	"owner",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- forum user id, the current owner, 0 if no longer owned
		{	"home",		"varchar(255)",	"NO",	"MUL",	nil,		nil					}, -- where in the world this object is located"
		{	"log",		"varchar(255)",	"NO",	"MUL",	nil,		nil					}, -- log of previous owners -> ":id:"
		{	"data",		"text",			"NO",	nil,	nil,		nil					}, -- serialised server object data
		
	})
	
	
end


-----------------------------------------------------------------------------
--
-- create a new item locally
--
-- a item is a server side object, bound to a registered user
-- it may be a ville object, it may exist in another world, these are intended to be more generic and more persistant.
--
-- items also keep a log record string of previous owners, so we can check up on item trading
-- even kill any item that has ever been near a player that has been caught cheating
-- a major reputation encouragement
--
-- initially the object is created locally only with a negative id, if it needs to be saved its id will be converted into a positive number
-- and its data written to the database
--
-----------------------------------------------------------------------------
function item_create(tab)

local item={}

	if tab.id then -- use passed in id
	
		item.id=tonumber(tab.id) -- make sure it is a number
		
	else -- assign a temp id
	
		data.items.ids_idx=data.items.ids_idx-1 -- a temporary ID
		item.id=data.items.ids_idx
	
	end
	data.items.ids[ item.id ]=item
	
	
	item.type=tab.type or "item" -- the type of vobj
	
	item.time=tab.time -- last saved time, if saved
	
	item.owner=tab.owner or nil -- lower case user forum name of who owns this item
		
	item.home=tab.home or "." -- a string indicating where the item should physically manifest if anywhere, this is dependent on object type
	
	item.log=tab.log -- a string of who has owned this object and in what order it has been transfered, object may only have had at max 10 owners
	
	item.props=tab.props or {} -- the public properties of this vobj
	
	-- set to true whenever we modify this item so we know we have to save it again
	item.modified = false

	data.items.home[ item.home ]=item.id -- so we can find objects that have unique locations, no need to clean this up since it is just weak linked by id
	
dbg("new item ",item.home,"\n")
	
	return item
		
end

-----------------------------------------------------------------------------
--
-- destroy an item locally
--
-----------------------------------------------------------------------------
function item_destroy(item)

	data.items.ids[ item.id ]=nil
	data.items.home[ item.home ]=nil
	
end


-----------------------------------------------------------------------------
--
-- load all items belonging to this user
--
-----------------------------------------------------------------------------
function item_reload_all(name)

	name=string.lower(name)

	data.items.users[ name ]=false -- flag forced reload
	item_load_all(name)

end

-----------------------------------------------------------------------------
--
-- load all items belonging to this user
--
-----------------------------------------------------------------------------
function item_load_all(name)

	name=string.lower(name)
	
local owner=get_user_forum_id(name)

	if owner then owner=tonumber(owner) end

	if not owner or owner<2 then return end -- not a real user
	if data.items.users[ name ] then return end -- already loaded, do not reload
	
	data.items.users[ name ]=true -- dont do again

local d=lanes_sql( " SELECT * FROM spew_items WHERE owner="..owner)

	for i,v in ipairs(d) do -- expand all items in table

		local dat={}
				
		dat.id = tonumber(v[1])
		dat.time = tonumber(v[2])
		dat.type = data.items.types[ tonumber(v[3]) ]
		dat.owner = get_user_name_from_forum_id( tonumber(v[4]) )
		dat.home = v[5]
		dat.log = v[6]
		dat.props = str_to_msg(v[7])
		
		item_create(dat)
	
	end
	
end

-----------------------------------------------------------------------------
--
-- change an items owner to none and save it
--
-----------------------------------------------------------------------------
function item_discard(item)
	
	item.owner=nil -- no longer belongs to anyone
	item_rehome(item,".")  -- no longer lives anywhere
	item_save(item)

end

-----------------------------------------------------------------------------
--
-- take a discarded item and place it back in a users hand
--
-----------------------------------------------------------------------------
function item_undiscard(item, vuser)
	
	item.owner=vuser.owner -- retain ownership
	item_rehome(item,vuser.owner.."/balloon")  -- place in hand
	item_save(item)

end

-----------------------------------------------------------------------------
--
-- change an items home
--
-----------------------------------------------------------------------------
function item_rehome(item,newhome)
	
	data.items.home[ item.home ]=nil
	
	item.home=newhome
	
	data.items.home[ item.home ]=item.id

end

-----------------------------------------------------------------------------
--
-- change an items home
--
-----------------------------------------------------------------------------
function item_home_swap(it1,it2)

	local hm1=it1.home
	local hm2=it2.home
	
	data.items.home[ it1.home ]=nil
	data.items.home[ it2.home ]=nil
	
	it1.home=hm2
	it2.home=hm1
	
	data.items.home[ it1.home ]=it1.id
	data.items.home[ it2.home ]=it2.id

end

-----------------------------------------------------------------------------
--
-- change an items id
--
-----------------------------------------------------------------------------
function item_reid(item,newid)
	
	data.items.ids[ item.id ]=nil
	
	item.id=newid
	
	data.items.ids[ item.id ]=item
	data.items.home[ item.home ]=item.id

end

-----------------------------------------------------------------------------
--
-- save an item into the database, if it was a local object it becomes a real one at this point
-- its id will  be changed if this happens
--
-----------------------------------------------------------------------------
function item_save(item)

--dbg("item_save\n")

local dat={}
	
	dat.time  = os.time()	
	dat.type  = data.items.types[ item.type ] -- string to number
	
	if item.owner then
		dat.owner = get_user_forum_id( item.owner ) -- string to number
	else
		dat.owner=0 -- a deleted item
	end
	
	dat.home  = item.home
	dat.log   = item.log
	dat.data  = msg_to_str( item.props ) -- use &name=num& style encoding

-- exit if we are missing important data, build other data if we need to

	if not dat.type  then return nil end
	if not dat.owner then dat.owner=0 end
	if not dat.home  then dat.home="." end
	if not dat.log   then dat.log=":"..dat.owner..":" end
	
	item.log=dat.log -- remember log
		
	if item.id < 0 then -- create new item
		
-- dbg("item_save create\n")

		local q=spew_mysql_make_insert("spew_items", spew_mysql_tab_to_row(dat) )
		
		local ret=lanes_sql( q , "lastid" )
		
		if ret and ret~=0 then -- success
		
			item_reid(item,tonumber(ret))
			
			return item
		
		end
	
	else -- update
	
-- dbg("item_save update\n")

		local q=spew_mysql_make_update("spew_items", spew_mysql_tab_to_row(dat) , "id="..item.id )

		local ret=lanes_sql( q )
		
		if ret and ret~=0 then -- success
			
			return item
		
		end
		
	end
end

-----------------------------------------------------------------------------
--
-- turn an item id into an item
--
-----------------------------------------------------------------------------
function get_item_by_id(id)

	if not id then return nil end
	
	return data.items.ids[ id ]

end
-----------------------------------------------------------------------------
--
-- turn an item loc into an item
--
-----------------------------------------------------------------------------
function get_item_by_home(home)

--dbg("searching ",home,"\n")

	if not home then return nil end

	local id=data.items.home[ home ]
	
	if id then
	
		return data.items.ids[ id ]
		
	else
	
		return nil
		
	end
	
end


-----------------------------------------------------------------------------
--
-- balloons lookup table
--
-----------------------------------------------------------------------------
local balloons=
{
	["godloons"]=
	{
	},
	["items1"]=
	{
		"sprout",
		"bluewater",
		"cookie",
		"speed",
		"pumpkin",
		"head",
		"skull",
		"slime",
		"chav",
		"cake",
		"patron",
		"zombie",
		"human",
		"werewolf",
		"vampire",
		"hankhillpropane",
	},
	["items2"]=
	{
		"silverbullet",
		"holystake",
		"candycorn",
		"spiderfan",
		"hoewitch",
		"batbat",
		"candybowl",
	},
	["abc"]=
	{
		"A",
		"B",
		"C",
		"D",
		"E",
		"F",
		"G",
		"H",
		"I",
		"J",
		"K",
		"L",
		"M",
		"N",
		"O",
		"P",
		"Q",
		"R",
		"S",
		"T",
		"U",
		"V",
		"W",
		"X",
		"Y",
		"Z",
	},
	["0"]=
	{
	},
	["zeegrind"]=
	{
		"chicken",
		"umbrella",
		"fryingpan",
		"hammer",
		"record",
		"pistol",
		"chainsaw",
		"boomstick",
		"brick",
		"forearm",
		"fishy",
		"banana",
		"slipper",
		"newspaper",
		"baseballbat",
		"tentonnes",
	}
}

for i,v in pairs(balloons) do

	for ii,vv in ipairs(v) do
	
		v[vv]=ii -- also point back to number
	
	end

end


-----------------------------------------------------------------------------
--
-- turn balloon props into a type name, for printing and testing
--
-----------------------------------------------------------------------------
function item_name_balloon(props)

local s="none"

	if not props then return s end

local tab=balloons[ props.type ]

	if tab then
	
		s=tab[ tonumber(props.idx) + 1 ] or s
		
	end
	
	return s
end

-----------------------------------------------------------------------------
--
-- set a balloon type from its basic name
--
-----------------------------------------------------------------------------
function item_setname_balloon(props,name)

local idx

	idx=balloons.items1[name]	
	if idx then -- we have an item1
	
		props.type="items1"
		props.idx=idx-1
		return
	end

	idx=balloons.items2[name]	
	if idx then -- we have an item2
	
		props.type="items2"
		props.idx=idx-1
		return
	end
	
	idx=balloons.zeegrind[name]
	if idx then -- we have an item
	
		props.type="zeegrind"
		props.idx=idx-1
		return
	end
	
end
		
-----------------------------------------------------------------------------
--
-- turn balloon props into a printable string
--
-----------------------------------------------------------------------------
function item_info_balloon(props)

local s="no balloon"

local name,pct,price

	name=item_name_balloon(props)
	
	if name~="none" then
	
		pct=tonumber(props.size)
		price=tonumber(props.price or props.size or 0)
		
		if props.grow and (tonumber(props.grow)~=100) then
		
			s="a "..props.grow.."% ripe "..pct.."% full "..name.." balloon"
			
			if props.grow_spell then s=s.." spell("..props.grow_spell..")" end
			if props.grow_soil then s=s.." soil("..props.grow_soil..")" end
			
		else
	
			s="a "..pct.."% full "..name.." balloon worth "..price.." cookies"
			
		end

	end


	return s

end

-----------------------------------------------------------------------------
--
-- create a new balloon item, to be held by the given user
--
-----------------------------------------------------------------------------
function item_create_balloon(user,bstr)

local tab={}
local b=str_split(":",bstr)

	tab.props={}
	
	tab.props.type=b[2] or "0"
	tab.props.idx=tonumber(b[3] or 0)
	tab.props.size=tonumber(b[4] or 0)
	tab.props.string=tonumber(b[5] or b[4] or 0) -- inherit string length from size
	
	if b[6] then tab.props.title=b[6] end

	tab.type="balloon"
	tab.owner=string.lower(user.name)		
	tab.home=tab.owner.."/balloon" -- we are holding it
	
local item=item_create(tab)

	return item

end

-----------------------------------------------------------------------------
--
-- turn a balloon item into a balloon str for use in sending as a prop
--
-----------------------------------------------------------------------------
function item_props_to_balloon_str(props)

local size
local len
	
	if props.grow then -- a growing balloon
	
		local grow=tonumber(props.grow)
		
		if grow < 25 then
	
			size=force_floor( ( tonumber(props.size) * grow ) / 100 )
			len=1
			
		else
		
			size=force_floor( ( tonumber(props.size) * grow ) / 100 )
			len=force_floor( ( tonumber(props.string) * grow ) / 100 )
		end
		
	else
	
		size=props.size
		len=props.string
	end

local xtra=""

	if props.title then
		xtra=":"..props.title
	end

	return props.type..":"..props.idx..":"..size..":"..len..xtra
	
end

-----------------------------------------------------------------------------
--
-- turn a balloon item into a balloon str for use in sending as a prop
--
-----------------------------------------------------------------------------
function item_balloon_to_props(str)

local props={}

	local b=str_split(":",str or "0:0:0:0:0")
	
	props.type=b[2] or "0"
	props.idx=tonumber(b[3] or 0)
	props.size=tonumber(b[4] or 0)
	props.string=tonumber(b[5] or b[4] or 0) -- inherit string length from size
	
	if b[6] then props.title=b[6] end
	
	return props

end

-----------------------------------------------------------------------------
--
-- turn a balloon item into a balloon str for use in sending as a prop
--
-----------------------------------------------------------------------------
function item_to_balloon_str(item)

	if not item then return "0:0:0:0:0" end
	
	return item.id..":"..item_props_to_balloon_str(item.props)

end



-----------------------------------------------------------------------------
--
-- turn a balloon item into a balloon str for use in sending as a prop
--
-----------------------------------------------------------------------------
function item_reload_all_items_from_db()

	data.items=nil -- flag a reset
	item_data_setup()
	for n,u in pairs(data.names) do -- load all item data	
dbg(n,"\n")
		item_load_all(n)
		local vuser=get_vuser(n)
		if vuser then
			vobj_set(vuser,"balloon", item_to_balloon_str(nil) ) -- clearhand first
			vuser_check_balloon(vuser) -- so if this gives a balloon it wobbles
		end
	end	

end
