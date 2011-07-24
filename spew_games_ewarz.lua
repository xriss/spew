
local gtab={}
data.gametypes=data.gametypes or {}
data.gametypes["ewarz"]=gtab


-----------------------------------------------------------------------------
--
-- Build and check environment
--
-- called by the main game after a spew: reload to make sure mysql tables etc exist
--
-----------------------------------------------------------------------------
gtab.build_and_check_environment = function()

dbg("checking ewarz data\n")

	spew_mysql_table_create("spew_ewarz",
	{
		--	name		type			NULL	nil,	default		extra
		{	"owner",	"int(11)",		"NO",	"PRI",	nil,		nil					}, -- forum user id, must be real user
		{	"bandwidth","int(11)",		"NO",	"MUL",	nil,		nil					}, -- size of bandwidth		air			send/recv faster
		{	"storage",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- size of storage		earth		defence / inbox size
		{	"spam",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- size of spam			water		chance to hit
		{	"sex",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- size of cock or tits	meta		control ability
		{	"virus",	"int(11)",		"NO",	"MUL",	nil,		nil					}, -- size of virus			fire		attack dammage
		{	"acts",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- available actions / replenished by amount of bandwidth
		{	"bux",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- your moneys
		{	"time",		"bigint(20)",	"NO",	"MUL",	nil,		nil					}, -- unix time of last replenishment act
		{	"data",		"text",			"NO",	nil,	nil,		nil					}, -- json serialised extra object data
		
	})

	spew_mysql_table_create("spew_ewarz_mail",
	{
		--	name		type			NULL	nil,	default		extra
		{	"from",		"int(11)",		"NO",	"PRI",	nil,		nil					}, -- forum user id, must be real user
		{	"to",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- forum user id, must be real user
		{	"size",		"int(11)",		"NO",	"MUL",	nil,		nil					}, -- size of mail, how much space it takes up
		{	"sent",		"bigint(20)",	"NO",	"MUL",	nil,		nil					}, -- unix time of send
		{	"read",		"bigint(20)",	"NO",	"MUL",	nil,		nil					}, -- unix time of read
		{	"data",		"text",			"NO",	nil,	nil,		nil					}, -- json serialised extra object data, content + title, etc
		
	})

end

--[[

     bandwidth
    /         \
virus         storage
    \         /
     sex--spam

bandwidth evades spam and storage
storage absorbs sex and spam
spam smothers virus and sex
sex controls bandwidth and virus
virus burns storage and bandwidth

bandwidth evades spam smothers virus burns storage absorbs sex controls virus burns bandwidth evades storage absorbs spam smothers sex controls 

]]

-----------------------------------------------------------------------------
-- 
-- we have recieved a game msg from a client, reply to it
-- 
-----------------------------------------------------------------------------
gtab.recv = function(user,msg)

dbg(msg.ewarz,"\n")

	if msg.ewarz=="connect" then
	
		local m={}
		
		m.cmd="ewarz"
		m.eid=0
		m.ewarz="display"
		m.xhtml="<img src='http://swf.wetgenes.com/swf/wetlinks/wetgenes.png' />Testing 1<b>2</b>3 <h1>Poop</h1>"
		usercast(user, m)
	
	end

end
