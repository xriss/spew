
--
-- handle data live currancy conversion rates, relative to the euro
--


local tlds={
--"CKE",--	Cookie
"EUR",--	Euro
"USD",--	US dollar
"JPY",--	Japanese yen
"BGN",--	Bulgarian lev
"CZK",--	Czech koruna
"DKK",--	Danish krone
"EEK",--	Estonian kroon
"GBP",--	Pound sterling
"HUF",--	Hungarian forint
"LTL",--	Lithuanian litas
"LVL",--	Latvian lats
"PLN",--	Polish zloty
"RON",--	New Romanian leu
"SEK",--	Swedish krona
"CHF",--	Swiss franc
"NOK",--	Norwegian krone
"HRK",--	Croatian kuna
"RUB",--	Russian rouble
"TRY",--	Turkish lira
"AUD",--	Australian dollar
"BRL",--	Brasilian real
"CAD",--	Canadian dollar
"CNY",--	Chinese yuan renminbi
"HKD",--	Hong Kong dollar
"IDR",--	Indonesian rupiah
"INR",--	Indian rupee
"KRW",--	South Korean won
"MXN",--	Mexican peso
"MYR",--	Malaysian ringgit
"NZD",--	New Zealand dollar
"PHP",--	Philippine peso
"SGD",--	Singapore dollar
"THB",--	Thai baht
"ZAR",--	South African rand
}

local tld_names={
--["CKE"]="Cookie",
["EUR"]="Euro",
["USD"]="US dollar",
["JPY"]="Japanese yen",
["BGN"]="Bulgarian lev",
["CZK"]="Czech koruna",
["DKK"]="Danish krone",
["EEK"]="Estonian kroon",
["GBP"]="Pound sterling",
["HUF"]="Hungarian forint",
["LTL"]="Lithuanian litas",
["LVL"]="Latvian lats",
["PLN"]="Polish zloty",
["RON"]="New Romanian leu",
["SEK"]="Swedish krona",
["CHF"]="Swiss franc",
["NOK"]="Norwegian krone",
["HRK"]="Croatian kuna",
["RUB"]="Russian rouble",
["TRY"]="Turkish lira",
["AUD"]="Australian dollar",
["BRL"]="Brasilian real",
["CAD"]="Canadian dollar",
["CNY"]="Chinese yuan renminbi",
["HKD"]="Hong Kong dollar",
["IDR"]="Indonesian rupiah",
["INR"]="Indian rupee",
["KRW"]="South Korean won",
["MXN"]="Mexican peso",
["MYR"]="Malaysian ringgit",
["NZD"]="New Zealand dollar",
["PHP"]="Philippine peso",
["SGD"]="Singapore dollar",
["THB"]="Thai baht",
["ZAR"]="South African rand",
}

local tlds_test={}

for i,v in ipairs(tlds) do

	tlds_test[v]=true

end



-----------------------------------------------------------------------------
--
-- get a string of available currencies
--
-----------------------------------------------------------------------------
function vest_available_tlds()

	return str_join_english_list(tlds)

end

-----------------------------------------------------------------------------
--
-- check the tld is valid, return it (possiibly now in uppercase if it is) or nil if it is invalid
--
-----------------------------------------------------------------------------
function vest_valid_tld(tld)

	if not tld then return nil end

	tld=string.upper(tld)
	
	if tlds_test[tld] then return tld end
	
	return nil

end

-----------------------------------------------------------------------------
--
-- check the rate of a tld, 0 is invalid or something broke
--
-----------------------------------------------------------------------------
function vest_rate_tld(tld)

	tld=vest_valid_tld(tld)

	return data.vest[tld] or 0

end

-----------------------------------------------------------------------------
--
-- return the name of a currency code
--
-----------------------------------------------------------------------------
function vest_name_tld(tld)

	tld=vest_valid_tld(tld)
	
	if tld then return tld_names[tld] end
	
	return "ERROR"

end
-----------------------------------------------------------------------------
--
-- read data from ecb, if the read fails rates may be set to 0
--
-----------------------------------------------------------------------------
function vest_load_rates()

-- check for rate==0 before you try and sel or use...

	for i,v in ipairs(tlds) do

		data.vest[v] = data.vest[v] or 0

	end
	
	data.vest["EUR"] = 1 -- always 1:1
	data.vest["EEK"]=  60000000/os.time() -- no longer exists...
		
--	data.vest["CKE"] = 100000 -- fixed number of cookies to 1 euro? nope, keep numbers scaled up and integers

-- pull in live data

dbg( "Check vest.\n")

	local ret={}--lanes_url("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml") -- pull in feed
	
	local gain
	local gain_num
	
	local loss
	local loss_num
	
	local old={}
	
	
	
-- old data
	
	for i,v in pairs(data.vest) do
	
		old[i]=v
	
	end

	ret=lanes_url("https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xmls") -- pull in feed
	
	if ret.body then
	
--dbg(ret.body)

		local dat=xml_parse(ret.body)
		
		if dat then 
		for n,v in ipairs(dat[1]) do
		
			if v and string.lower(v[0])=="cube" then
			
				for n,v in ipairs(v[1]) do
				
					local currency=v.currency
					local rate=v.rate
					
					rate=tonumber(rate)
					
					currency=vest_valid_tld(currency)
					
					if currency and rate>0 then
					
						if old[currency] > 0 then -- measure change
						
							local change = rate / old[currency]
							
							if not gain or change > gain_num then
							
								gain=currency
								gain_num=change
							
							end
						
							if not loss or change < loss_num then
							
								loss=currency
								loss_num=change
							
							end
							
						end
						
						data.vest[currency]=rate
						
dbg( currency , "\t" , rate , "\t", tld_names[currency] , "\n")


					end

				end

			end
		
		end
		end
		
		if loss and gain and loss~=gain then
		
dbg( "The vest has changed and the biggest gain is "..gain.." and the biggest loss is "..loss.."\n")

		else
		
dbg( "The vest has loaded.\n")

		end
		
	
	end
	

end


-----------------------------------------------------------------------------
--
-- convert a currency n value using the current exchange rates
-- from currency a to currency b
--
-- probably want to force_floor the result
--
-- returns 0 if bad data
--
-----------------------------------------------------------------------------
function vest_convert(n,a,b)

	a=vest_valid_tld(a)
	b=vest_valid_tld(b)
	
	if not a or not b then return 0 end
	
	local ax=data.vest[a] or 0
	local bx=data.vest[b] or 0
	
	if ax<=0 or bx<=0 then return 0 end
	
	return (n/ax)*bx


end


