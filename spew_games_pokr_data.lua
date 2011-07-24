
local gtab=data.gametypes["pokr"] or {}




-----------------------------------------------------------------------------
--
-- worst to best
--
-----------------------------------------------------------------------------
local hand_names_caps=
{
	"High Cards",
	"Pair",
	"Two Pair",
	"Three of a kind",
	"Straight",
	"Flush",
	"Full House",
	"Four of a kind",
	"Straight Flush",
}
local hand_names={}

for i,v in ipairs(hand_names_caps) do
	hand_names_caps[string.lower(v)]=v
	hand_names[i]=string.lower(v)
end
for i,v in ipairs(hand_names) do
	hand_names[v]=i
end


-----------------------------------------------------------------------------
--
-- awards given for having each hand
--
-----------------------------------------------------------------------------
local hands_to_awards=
{
	["high cards"]="pokr_high_cards",
	["pair"]="pokr_pair",
	["two pair"]="pokr_two_pair",
	["three of a kind"]="pokr_three_of_a_kind",
	["straight"]="pokr_straight",
	["flush"]="pokr_flush",
	["full house"]="pokr_full_house",
	["four of a kind"]="pokr_four_of_a_kind",
	["straight flush"]="pokr_straight_flush",
}
local function pokr_award_hand(user,dat)

	local award_name=hands_to_awards[dat.best_hand]
	
	if not award_name then return end -- feck up
	
	if not user.client then return end -- only award real users
	
	return feats_award(user,award_name)
	
end

-----------------------------------------------------------------------------
--
-- worst to best
--
-----------------------------------------------------------------------------
local card_ranks_str="23456789XJQKA" -- aces high

local card_ranks={} -- number to letter or letter to number
for i=1,string.len(card_ranks_str) do

	local c=string.sub(card_ranks_str,i,i)
	
	card_ranks[i]=c
	card_ranks[c]=i

end


-----------------------------------------------------------------------------
--
-- worst to best
--
-----------------------------------------------------------------------------
local card_straight_str="A23456789XJQK" -- aces low

local card_straight={} -- number to letter or letter to number
for i=1,string.len(card_straight_str) do

	local c=string.sub(card_straight_str,i,i)
	
	card_straight[i]=c
	card_straight[c]=i

end


-----------------------------------------------------------------------------
--
-- dismonds spades clubs hearts
--
-----------------------------------------------------------------------------
local card_suits_str="dsch"

local card_suits={} -- number to letter or letter to number
for i=1,string.len(card_suits_str) do

	local c=string.sub(card_suits_str,i,i)
	
	card_suits[i]=c
	card_suits[c]=i

end


-----------------------------------------------------------------------------
--
-- put 52 cards in a pack
--
-----------------------------------------------------------------------------

local function build_pack() -- build a full pack of cards, non shuffled

local pack={}

	for j=1,#card_suits do
	
		for i=1,#card_ranks do
	
			table.insert( pack , card_ranks[i]..card_suits[j] ) -- two character string for each card
	
		end
	
	end

--dbg( "newpack : " , table.concat(pack) , "\n" )

	return pack
end

-----------------------------------------------------------------------------
--
-- shuffle a pack of cards (effect the passed in table)
--
-----------------------------------------------------------------------------
local function shuffle_pack(pack) -- randomize order of cards in pack

local tpack={}

-- randomize to tempory array
	while #pack>0 do
	
		table.insert(tpack, table.remove(pack , math.random(#pack) ) )
	
	end

-- and randomize back into input array
	while #tpack>0 do
	
		table.insert(pack, table.remove(tpack , math.random(#tpack) ) )
	
	end


--dbg( "shufflepack : " , table.concat(pack) , "\n" )

	return pack
end

-----------------------------------------------------------------------------
--
-- deal one card from the pack
--
-----------------------------------------------------------------------------
local function deal_pack(pack)

local card

	card = table.remove(pack,1) -- this jiggles the pack order around
	table.insert(pack,card)

	
	return card
end

-----------------------------------------------------------------------------
--
-- compare two hand strings of cards that are of the same type and sorted high to low
--
-- compare two hands of the *same* type, return ( -1 , 0 , +1 )for ( hand1 wins , draw , hand2 wins )
--
-----------------------------------------------------------------------------
local function compare_5cards( hand1 , hand2 )

	if not hand1 then return -1 end -- sanity
	if not hand2 then return  1 end
	
	if string.len(hand1) > string.len(hand2) then return -1 end -- sanity
	if string.len(hand2) > string.len(hand1) then return  1 end

	for i=1,9,2 do
	
		local rank1=card_ranks[ string.sub(hand1,i,i) ]
		local rank2=card_ranks[ string.sub(hand2,i,i) ]
		
		if rank1 > rank2 then return -1 end
		if rank2 > rank1 then return  1 end

	end
	
	return 0
end

-----------------------------------------------------------------------------
--
-- compare two hand dats
--
-- return ( -1 , 0 , +1 ) for ( hand1 wins , draw , hand2 wins )
--
-----------------------------------------------------------------------------
local function compare_cards( dat1 , dat2 )

	local i1=hand_names[ dat1.best_hand ]
	local i2=hand_names[ dat2.best_hand ]
	
	if i1 > i2 then return -1 end
	if i2 > i1 then	return  1 end
		
	return compare_5cards( dat1.best_5cards , dat2.best_5cards )
end

-----------------------------------------------------------------------------
--
-- build the best hand we can from 5 or more cards
--
-- return a table containing lots of information we used to work this out
--
-----------------------------------------------------------------------------
local function get_hand_data(hand) -- look at available cards and build information about the best 5 cards

	local dat={}

	dat.a={} -- any suit
	dat.d={} -- diamonds
	dat.s={} -- spades
	dat.c={} -- clubs
	dat.h={} -- hearts
	dat.t={0,0,0,0,0,0,0,0,0,0,0,0,0,0} -- total cards of this rank
	
	dat.best_hand="none" -- type of hand we found
	dat.best_5cards=nil
	
	local l=string.len(hand)
	
	for i=1,l,2 do
	
		local cc=string.sub(hand,i,i+1)
		
		local suit=string.sub(hand,i+1,i+1) -- get card suit as letter
		local rank=card_straight[ string.sub(hand,i,i) ] -- get card rank as number, aces low
		
		dat[suit][rank]=cc -- remember in suit data
		dat["a"][rank]=cc -- remember in any data
		
		dat["t"][rank]=( dat["t"][rank] or 0 ) + 1
		
		if rank==1 then -- aces high as well
		
			rank=14
			
			dat[suit][rank]=cc -- remember in suit data
			dat["a"][rank]=cc -- remember in any data
			
			dat["t"][rank]=( dat["t"][rank] or 0 ) + 1
		
		end
	
	end
	
	for _,suit in ipairs({"a","d","s","c","h"}) do
		local t=dat[suit]
		
		for i=14,5,-1 do
	
			if t[i] and t[i-1] and t[i-2] and t[i-3] and t[i-4] then -- found the highest straight
			
				t.straight=t[i]..t[i-1]..t[i-2]..t[i-3]..t[i-4] -- build a five card hand
				break
			end
		end
		
		t.flush=""
		for i=14,2,-1 do
	
			if t[i] then
			
				t.flush=t.flush..t[i]
				if string.len(t.flush)== 10 then break end -- found 5 cards
			end
		end
		if string.len(t.flush)~= 10 then t.flush=nil end -- ignore <5 cards
		
	end
	
	local function printable() -- make english readable string of the hand

		local t={}
		for i=1,string.len(dat.best_5cards),2 do
			table.insert(t,string.sub(dat.best_5cards,i,i+1))
		end
		dat.best_hand_english=table.concat(t," ").." ("..hand_names_caps[dat.best_hand]..") "
		
		dat.best_hand_caps=hand_names_caps[dat.best_hand]
		
		return dat.best_hand_english
	end

	local function get_group( num, skip ) -- get best group of num cards, returns a string of num cards
		local t=dat.t
		for i=14,2,-1 do
		
			if i~=skip then -- ignore these cards
			
				if t[i] and t[i]>=num then -- found num cards all the same
				
					local s=""
					
					if dat.d[i] then s=s..dat.d[i] end
					if dat.s[i] then s=s..dat.s[i] end
					if dat.c[i] then s=s..dat.c[i] end
					if dat.h[i] then s=s..dat.h[i] end
					
					return string.sub(s,1,2*num) , i
				end
			end
		end
		
		return nil -- failed to find
	end
	
	local function get_best( num, skip, skip2 ) -- get best single cards, returns a string of num cards
		local t=dat.t
		local s=""
		for i=14,2,-1 do
			if i~=skip and i~=skip2 then -- ignore these cards
			
				for _,suit in ipairs({"d","s","c","h"}) do
				
					if dat[suit][i] then s=s..dat[suit][i] end
					
					if string.len(s)==num*2 then -- found all needed cards
					
						return s
					end
				end
			end
		end
		
		return nil -- failed to find
	end

	
-- look for straight flush
	
	for _,suit in ipairs({"d","s","c","h"}) do
	
		if dat[suit].straight then -- we have a straight flush
		
			if dat.best_5cards then -- is it better than another straight flush we found
			
				if compare_5cards( dat.best_5cards , dat[suit].straight ) > 0 then -- yes it is
				
					dat.best_5cards=dat[suit].straight
					dat.best_hand="straight flush"
					
				end
			else
				dat.best_5cards=dat[suit].straight
				dat.best_hand="straight flush"
			end
		
		end
		
	end
	if dat.best_5cards then printable(dat) return dat end  -- found the best hand
	
	local cards,found
	
-- look for four of a kind

	cards,found=get_group( 4, 0 )
	
	if found then -- found 4, now find the fith
	
		local extra_cards=get_best( 1, found )
		
		dat.best_5cards=cards .. extra_cards
		dat.best_hand="four of a kind"
		printable(dat)
		return dat
	end

-- look for full house
	cards,found=get_group( 3, 0 )
	if found then -- found 3, now find a pair
	
		local extra_cards=get_group( 2, found )
		
		if extra_cards then
			dat.best_5cards=cards .. extra_cards
			dat.best_hand="full house"
			printable(dat)
			return dat
		end
	end

-- look for flush
	
	for _,suit in ipairs({"d","s","c","h"}) do
	
		if dat[suit].flush then -- we have a flush
		
			if dat.best_5cards then -- is it better than another flush we found
			
				if compare_5cards( dat.best_5cards , dat[suit].flush ) > 0 then -- yes it is
				
					dat.best_5cards=dat[suit].flush
					dat.best_hand="flush"
					
				end
			else
				dat.best_5cards=dat[suit].flush
				dat.best_hand="flush"
			end
		
		end
		
	end
	if dat.best_5cards then printable(dat) return dat end  -- found the best hand
	
	
-- check for straight

	if dat["a"].straight then
	
		dat.best_5cards=dat["a"].straight
		dat.best_hand="straight"
		printable(dat)
		return dat
	
	end
	
-- check for three of a kind
	
	cards,found=get_group( 3, 0 )
	
	if found then -- found 3, now find another 2
	
		local extra_cards=get_best( 2, found )
		
		dat.best_5cards=cards .. extra_cards
		dat.best_hand="three of a kind"
		printable(dat)
		return dat
	end
	
-- check for two pair
	
	cards,found=get_group( 2, 0 )
	
	if found then -- found 2, now find another 2
	
		local cards2,found2=get_group( 2, found )
		
		if found2 then -- ok got 4 now find the last one
		
			local extra_cards=get_best( 1, found, found2 )
			dat.best_5cards=cards .. cards2 .. extra_cards
			dat.best_hand="two pair"
			printable(dat)
			return dat
		end
	end
	
-- check for one pair

	cards,found=get_group( 2, 0 )
	
	if found then -- found 2, now find another 3
	
		local extra_cards=get_best( 3, found )
		dat.best_5cards=cards .. extra_cards
		dat.best_hand="pair"
		printable(dat)
		return dat
		
	end
	
-- finaly just find the top 5 cards
	
	dat.best_5cards=get_best( 5, 0 )
	dat.best_hand="high cards"
	printable(dat)
	return dat
end


local function dbg_check_chance()

	local pack=shuffle_pack( build_pack() )

	local stats={}
	local total=20000

	for i=1,total do

		shuffle_pack( pack )
		
		local hand=pack[1]..pack[2]..pack[3]..pack[4]..pack[5]..pack[6]..pack[7]
		local dat=get_hand_data(hand)
		
		local h1=hand
		local h2=dat.best_5cards

		local t={}
		for i=1,string.len(h1),2 do
			table.insert(t,string.sub(h1,i,i+1))
		end
		h1=table.concat(t," ")
		
		local t={}
		for i=1,string.len(h2),2 do
			table.insert(t,string.sub(h2,i,i+1))
		end
		h2=table.concat(t," ")
		
	--dbg( h1 , " : " , h2 , " : " , dat.best_hand , "\n" )

		stats[dat.best_hand] = ( stats[dat.best_hand] or 0 ) + 1

	end

	for s,n in pairs(stats) do

		local pct=(n/total)*100
		
		dbg( string.format("%02.5f",pct) , "% : " , s , " : " , n , "\n" )

	end

end

--dbg_check_chance()


gtab.compare_cards=compare_cards

gtab.get_hand_data=get_hand_data

gtab.pokr_award_hand=pokr_award_hand

gtab.pack=gtab.pack or shuffle_pack(build_pack()) -- make a shuffled pack or keep the current one
gtab.pack_idx=gtab.pack_idx or 1 -- index of next card to be dealt from the pack

gtab.shuffle=function() shuffle_pack(gtab.pack) end
gtab.deal=function() return deal_pack(gtab.pack) end



