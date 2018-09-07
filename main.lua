--http://www.wowhead.com/guide=1949/wow-addon-writing-guide-part-one-how-to-make-your-first-addon

--API REREFENCE: http://wowprogramming.com/docs/api_categories.html

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(f, event)
    if event == "PLAYER_LOGIN" then
		if(UnitLevel("player") == 120) then
			if(UnitFactionGroup("player") == "Horde") then
				print("CHARACTER CONFIRMED HORDE, ZUG ZUG");
				ParseHordeWQs();
				CheckContracts();
				OutputHordeRepSums();
				print("Num WQs active :", numWQs);
			elseif(UnitFactionGroup("player") == "Alliance") then
				print("CHARACTER CONFIRMED ALLIANCE ....ew");
				ParseAllianceWQs();
				CheckContracts();
				OutputAllianceRepSums();
				print("Num WQs active :", numWQs);
			end
		else
			print("Level up scrub");
		end
    end
end)


print("WQ Report active!");

--[[
GetNumQuestLogRewards:
Gold reward: returns 0
Gear reward: returns 1
Rep token reward: 0
Pet charm reward: 1

GetNumQuestLogRewardCurrencies(QuestID) returns a non-zero number if the quest reward is a rep token
GetQuestLogRewardMoney(QuestID) returns the amount of money a WQ rewards (in copper)
-EXAMPLE: if it retursn 842500, that's 84 gold, 25 silver
gold = money/10000;
silver = (money - (gold * 10000)) / 100;
print("Reward= ", gold, " gold, ", silver, " silver");)
--therefore, 100 copper = 1 silver, 10,000 copper = 1 gold

Azerite currency ID = 1553
]]


--Counter for number of World Quests currently active
numWQs = 0;

--Horde Rep total initialization and ID indices 
CoA = 0; --Champions of Azeroth rep (ID = 2164)
TE = 0;  --Talanji's Expedition rep (ID = 2156)
HB = 0;  --The Honorbound rep 		(ID = 2157)
TS = 0;  --Tortollan Seekers rep 	(ID = 2163)
Vol = 0; --Voldunai rep				(ID = 2158)
ZE = 0;  --Zandalari Empire rep 	(ID = 2103)

--Alliance Rep total initialization and ID indices 
OoE = 0; --Order of Embers rep	    (ID = 2161)
SL = 0; --7th Legion rep 			(ID = 2159)
PA = 0; --Proudmoore Admiralty rep  (ID = 2160)
SW = 0; --Storm's Wake rep 			(ID = 2162)

--**NOTE: Alliance and Horde both use the same rep ID's for Champions of Azeroth and Tortollan Seekers


--Scout Skrasniss quest has ID 50512 and gives 75 rep for Talanji (repID 2156)
--Kiboku quest has ID 50869 and gives 75 rep for Zandalari Empire (repID 2103)
--Scrolls and Scales has ID 50581 and gives 75 rep for Zandalari Empire (repID 2103)
--Lo'kuno has ID 50509 and gives 75 rep for Talanji (repID 2156)
--local worldQuestReps = {[50512]=2156, [50869]=2103, [50581]=2103, [50509]=2156, [50592]=2103, [50877]=2103, [52858]={2103, 2159, 2164}, [50885]=2103, [52862]={2164, 2157}, [52862]={2164, 2161, 2157}, [52858]={2164, 2159, 2157}}


--***NEED TO ADD "WORK ORDER" QUESTS FOR VOL'DUN
local worldQuestReps = {
--Zuldazar Quests******************************************************************************************
[52923]={2103, 2159},		  --Add More to the Collection -- Gives 75 ZE rep
[49800]={2103, 2159},		  --Atal'Dazar: Spiders! -- Gives 75 ZE rep
[50864]={2103, 2159},		  --Atal'Zul Gotaka  -- Gives 75 ZE rep ***
[50863]={2103, 2159},		  --Avatar of Xolotal -- Gives 75 ZE rep
[52858]={2103, 2159, 2164},   --Azerite Empowerment(Hex Priest Haraka) -- Gives 125 CoA rep and 75 ZE rep 
[51444]={2103, 2159, 2164},   --Azerite Empowerment(Zu'shin the Infused) -- Gives 125 CoA rep and 75  ZE rep
[51179]={2103, 2159, 2164},   --Azerite Madness (Zuldazar) -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[52877]={2103, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[51450]={2103, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[52877]={2103, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[51175]={2103, 2159, 2164},   --Azerite Wounds -- Gives 125 CoA rep and 75  ZE rep
[51642]={2103, 2159, 2163},   --Beachhead -- Gives 175 TS rep and 75 ZE rep (Southern coast of Zuldazar)
[50527]={2103, 2159},		  --Behind Mogu Lines -- Gives 75 ZE rep **NOTE: According to wowhead, this is Alliance only
[50652]={2103, 2159},		  --Biting The Hand that Feeds Them -- Give 75 ZE rep **NOTE: According to wowhead, this is Horde only
[50862]={2103, 2159},		  --Bloodbulge -- gives 75 ZE rep
[50868]={2103, 2159},		  --Bramblewing -- gives 75 ZE rep
[50578]={2103, 2159},		  --Bring Ruin AGain -- gives 75 ZE rep
[51475]={2103, 2159},		  --Brutal Escort -- gives 75 ZE rep
[50966]={2103, 2159},		  --Cleanup Crew -- gives 75 ZE rep
[52251]={2103, 2159},		  --Compromised Reconnaissance -- gives 75 ZE rep **no info whatsoever on wowhead page, doublecheck
[50854]={2103, 2159},		  --Crimsonclaw (Umbra'jin) -- gives 75 ZE rep
[52892]={2103, 2159},		  --Critters are Friends, Not Food -- gives 75 ZE rep
[50651]={2103, 2159},		  --Cut Off Potential -- gives 75 ZE rep
[50871]={2103, 2159},		  --Daggerjaw -- gives 75 ZE rep
[51084]={2103, 2159},		  --Dark Chronicler -- gives 75 ZE rep
[50875]={2103, 2159},		  --Darkspeaker Jo'la - gives 75 ZE rep
[48862]={2103, 2159},		  --Disarming the Competetion -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[51373]={2103, 2159},		  --Ears Everywhere -- gives 75 ZE rep
[51815]={2103, 2159},		  --Eggstermination -- gives 75 ZE rep  (Appears to be Alliance version)
[50571]={2103, 2159},		  --Eggstermination -- gives 75 ZE rep (Appears to be Horde version)
[50969]={2103, 2159},		  --Emergency Management -- gives 75 ZE rep **NOTE: According to wowhead, this is Alliance only
[50548]={2103, 2159},		  --Enforcing the Will of the King -- gives 75 ZE rep **NOTE: According to wowhead, this is Horde only
[50870]={2103, 2159},		  --G'Naat -- gives 75 ZE rep
[50877]={2103, 2159},		  --Gahz'ralka -- gives 75 ZE rep
[50857]={2103, 2159},		  --Golrakahn -- gives 75 ZE rep
[50874]={2103, 2159},		  --Hakbi the Risen -- gives 75 ZE rep
[50846]={2103, 2159},		  --Headhunter Lee'za -- gives 75 ZE rep
[50765]={2103, 2159},		  --Herding Children -- gives 75 ZE rep
[51497]={2103, 2159},		  --Hex Education -- gives 75 ZE rep
[51178]={2103, 2159},		  --Hundred Troll Holdout -- gives 75 ZE rep
--[51305]={2103, 2159},		  --Jelly Clouds -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck  ** COMMENTING OUT DUE TO QUEST BEING BUGGED
[50859]={2103, 2159},		  --Kandak -- gives 75 ZE rep
[50869]={2103, 2159},		  --Kiboku -- gives 75 ZE rep
[50547]={2103, 2159},		  --Knives of Zul -- gives 75 ZE rep
[50845]={2103, 2159},		  --Kul'krazahn -- gives 75 ZE rep
--[50852]={2103, 2159},		  --Lady Seirine -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck  ** COMMENTING OUT DUE TO QUEST BEING BUGGED
[50885]={2103, 2159},		  --Lei-zhi -- gives 75 ZE rep
[51496]={2103, 2159},		  --Loa Your Standards -- gives 75 ZE rep
[51636]={2103, 2159, 2163},   --Make Loh Go -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[50876]={2103, 2159},		  --Murderbeak -- gives 75 ZE rep
[50747]={2103, 2159},		  --No Good Amani -- gives 75 ZE rep
[50855]={2103, 2159},		  --Old R'gal -- gives 75 ZE rep
[51495]={2103, 2159},		  --Old Rotana -- gives 75 ZE rep
[50574]={2103, 2159},		  --Preservation Methods -- gives 75 ZE rep
[51816]={2103, 2159},		  --Pterrible Ingredients -- gives 75 ZE rep, although wowhead says it's Alliance
[50633]={2103, 2159},		  --Pterrible Ingredients -- appears to be a copy of the previous one? Might be unused, wowhead page is blank
[50524]={2103, 2159},		  --Purify the Temple -- gives 75 ZE rep -- wowhead says Horde only
[51821]={2103, 2159},		  --Quelling the Cove -- gives 75 ZE rep -- wowhead says Alliance only
[49068]={2103, 2159},		  --Quelling the Cove -- gives 75 ZE rep -- appears to be Horde version
[50540]={2103, 2159},		  --Rally the Rastari -- gives 75 ZE rep -- wowhead says Horde only
[51814]={2103, 2159},		  --Ravoracious -- gives 75 ZE rep -- wowhead says Alliance only
[50636]={2103, 2159},		  --Ravoracious -- gives 75 ZE rep -- appears to be Horde version
[50744]={2103, 2159},		  --Refresh Their Memory -- gives 75 ZE rep -- wowhead says Horde only
[50964]={2103, 2159},		  --Ritual Combat -- gives 75 ZE rep -- wowhead says Horde only
[52250]={2103, 2159},		  --Saving Xibala -- gives 75 ZE rep -- wowhead says Alliance only
[49413]={2103, 2159},		  --Scamps with Scrolls -- gives 75 ZE rep -- wowhead says Horde only
[51822]={2103, 2159},		  --Scrolls and Scales -- gives 75 ZE rep -- wowhead says Alliance only
[50581]={2103, 2159},		  --Scrolls and Scales -- gives 75 ZE rep -- wowhead says Horde only
[51630]={2103, 2159, 2163},   --Shell Game -- gives 175 TS rep and 75 ZE rep - Southwestern Zuldazar
[50737]={2103, 2159},		  --Silence the Speakers -- gives 75 ZE rep -- wowhead says Alliance only
[50858]={2103, 2159},		  --Sky Queen -- gives 75 ZE rep -- wowhead says Alliance only
[52938]={2103, 2159},		  --Small Beginnings -- gives 75 ZE rep -- pet battle (Zujai)
[53165]={2103, 2159},		  --Stopping Antiquities Theft -- gives 75 ZE rep -- wowhead says Alliance only
[50873]={2103, 2159},		  --Strange Egg -- gives 75 ZE rep
[50756]={2103, 2159},		  --Subterranean Evacuation -- gives 75 ZE rep -- wowhead says Alliance only
--Supplies Needed quests give Honorbound rep, NOT ZE
[51038]={2157},		 		  --Supplies Needed: Akunda's Bite -- gives 75 HB rep (Horde only)
[51044]={2157},		 		  --Supplies Needed: Blood-Stained Bone -- gives 75 HB rep (Horde only)
[51045]={2157},		 		  --Supplies Needed: Calcified Bone -- gives 75 HB rep (Horde only)
[51046]={2157},		 		  --Supplies Needed: Coarse Leather -- gives 75 HB rep (Horde only)
[51051]={2157},		 		  --Supplies Needed: Deep Sea Satin -- gives 75 HB rep (Horde only)
[52387]={2157},		 		  --Supplies Needed: Frenzied Fangtooth -- gives 75 HB rep (Horde only)
[52382]={2157},		 		  --Supplies Needed: Great Sea Catfish -- gives 75 HB rep (Horde only)
[52388]={2157},		 		  --Supplies Needed: Lane Snapper -- gives 75 HB rep (Horde only)
[51049]={2157},		 		  --Supplies Needed: Mistscale -- gives 75 HB rep (Horde only)
[51042]={2157},		 		  --Supplies Needed: Monelite Ore -- gives 75 HB rep (Horde only)
[51036]={2157},		 		  --Supplies Needed: Riverbud -- gives 75 HB rep (Horde only)
[52383]={2157},		 		  --Supplies Needed: Sand Shifter -- gives 75 HB rep (Horde only) ****wowhead says ZE rep too?
[51041]={2157},		 		  --Supplies Needed: Sea Stalk -- gives 75 HB rep (Horde only)
[51048]={2157},		 		  --Supplies Needed: Shimmerscale -- gives 75 HB rep (Horde only)
[51040]={2157},		 		  --Supplies Needed: Siren's Pollen -- gives 75 HB rep (Horde only)
[51037]={2157},		 		  --Supplies Needed: Star Moss -- gives 75 HB rep (Horde only)
[51043]={2157},		 		  --Supplies Needed: Storm Silver Ore -- gives 75 HB rep (Horde only)
[51047]={2157},		 		  --Supplies Needed: Tempest Hide -- gives 75 HB rep (Horde only) ****wowhead says ZE rep too?
[51050]={2157},		 		  --Supplies Needed: Tidespray Linen -- gives 75 HB rep (Horde only)
[52384]={2157},		 		  --Supplies Needed: Tiragarde Perch -- gives 75 HB rep (Horde only)
[51039]={2157},		 		  --Supplies Needed: Winter's Kiss -- gives 75 HB rep (Horde only)
[51081]={2103, 2159},		  --Syrawon the Dominus -- gives 75 ZE rep
[50867]={2103, 2159},		  --Tambano -- gives 75 ZE rep
[51494]={2103, 2159},		  --The Blood Gate -- gives 75 ZE rep
[52249]={2103, 2159},		  --The Shores of Xibala -- gives 75 ZE rep -- wowhead says Alliance only
[52248]={2103, 2159},		  --The Shores of Xibala -- gives 75 ZE rep -- wowhead says Horde only
[50850]={2103, 2159},		  --Tia'Kawan -- gives 75 ZE rep
[50592]={2103, 2159},		  --Tiny Terror -- gives 75 ZE rep -- wowhead says Horde only
[50861]={2103, 2159},		  --Torraske the Eternal -- gives 75 ZE rep
[50847]={2103, 2159},		  --Twisted Child of Rezan -- gives 75 ZE rep
[50853]={2103, 2159},		  --Umbra'rix -- gives 75 ZE rep
[49444]={2103, 2159},		  --Underfoot -- gives 75 ZE rep -- wowhead says Horde only
[50287]={2103, 2159},		  --Unending Gorilla Warfare -- gives 75 ZE rep -- wowhead says Horde only
[51374]={2103, 2159},		  --Unending Gorilla Warfare -- gives 75 ZE rep -- wowhead says Alliance only
[50872]={2103, 2159},		  --Warcrawler Karkithiss -- gives 75 ZE rep
[50619]={2103, 2159},		  --What Goes Up -- gives 75 ZE rep -- wowhead says Horde only
--[50849]={2103, 2159},		  --Witch Doctor Habra'du -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck  ** COMMENTING OUT DUE TO QUEST BEING BUGGED
[50782]={2103, 2159},		  --Word on the Streets -- gives 75 ZE rep -- wowhead says Alliance only

[52425]={2103},		 		  --Work Order: Battle Flag: Spirit of Freedom -- gives 75 ZE rep (Horde only)
[51010]={2103},		 		  --Work Order: Coarse Leather -- gives 75 ZE rep (Horde only)
[52393]={2103},		 		  --Work Order: Contract: Tortollan Seekers -- gives 75 ZE rep (Horde only)
[52395]={2103},		 		  --Work Order: Contract: Zandalari Empire -- gives 75 ZE rep (Horde only)
[52374]={2103},		 		  --Work Order: Contract: Crow's Nest Scope -- gives 75 ZE rep (Horde only)
[52335]={2103},		 		  --Work Order: Contract: Demitri's Draught of Deception -- gives 75 ZE rep (Horde only)
[52373]={2103},		 		  --Work Order: Electroshock Mount Motivator -- gives 75 ZE rep (Horde only)
[52358]={2103},		 		  --Work Order: Enchant Ring: Seal of Haste -- gives 75 ZE rep (Horde only)
[52359]={2103},		 		  --Work Order: Enchant Ring: Seal of Mastery -- gives 75 ZE rep (Horde only)
[52369]={2103},		 		  --Work Order: Incendiary Ammunition -- gives 75 ZE rep (Horde only)
[52408]={2103},		 		  --Work Order: Kyanite -- gives 75 ZE rep (Horde only)
[52336]={2103},		 		  --Work Order: Lightfoot Potion -- gives 75 ZE rep (Horde only)
[52349]={2163},		 		  --Work Order: Loa Loaf -- gives 175 TS rep (wowhead says TS rep for both sides)
[51013]={2103},		 		  --Work Order: Mistscale -- gives 75 ZE rep (Horde only)
[52359]={2163},		 		  --Work Order: Mon'Dazi -- gives 175 TS rep (wowhead says TS rep for both sides)
[52342]={2157},		 		  --Work Order: Monel-Hardened Hoofplates -- gives 75 HB rep (Horde only)
[52341]={2157},		 		  --Work Order: Monel-Hardened Stirrups -- gives 75 HB rep (Horde only)
[50957]={2103, 2159},		  --Wrath of Rezan -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[51824]={2103, 2159},		  --You're Grounded -- gives 75 ZE rep -- wowhead says Alliance only
[52937]={2103, 2159},		  --You've Never Seen Jammer Upset -- gives 75 ZE rep -- pet battle (Jammer)
[50866]={2103, 2159},		  --Zayoos -- gives 75 ZE rep

--Vol'dun quests*****************************************************************************************
[52798]={2158},				  --A few More Charges -- gives 75 Vol rep (Horde only)
[49013]={2158},				  --A Jolt of Power -- gives 75 Vol rep (Horde only)
[51238]={2158},		  		  --Abandoned  in the Burrows -- gives 75 Vol rep (Horde only)
[51105]={2158, 2159, 2164},	  --Ak'tar -- gives 75 Vol or 7th L rep
[51095]={2158, 2159, 2164},	  --Ashmane -- gives 75 Vol or 7th L rep
[51096]={2158, 2159, 2164},	  --Azer'tor -- gives 75 Vol or 7th L rep
[52849]={2158, 2159, 2164},	  --Azerite Empowerment (Warlord Dagu) -- Gives 125 CoA rep and 75 Vol or 7th L rep
[51185]={2158, 2159, 2164},	  --Azerite Empowerment (Skithis the Infused) -- Gives 125 CoA rep and 75 Vol or 7th L rep
[51422]={2103, 2159, 2164},   --Azerite Madness(Vol'dun) -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[50975]={2103, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[52875]={2103, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[51428]={2103, 2159, 2164},   --Azerite Wounds -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[51117]={2158, 2159},		  --Bajiani the Slick -- gives 75 Vol or 7th L rep
[51641]={2103, 2159, 2163},   --Beachhead -- Gives 175 TS rep and 75 ZE rep (Northeastern coast of Vol'dun)
[51210]={2158},		  		  --Blast Back the Siege -- gives 75 Vol rep (Horde only)
[51097]={2158, 2159},		  --Bloated Ruincrawler -- gives 75 Vol or 7th L rep
[51118]={2158, 2159},		  --Bloodwing Bonepicker -- gives 75 Vol or 7th L rep
[51155]={2158, 2159},		  --Brgl-Lrgl the Basher -- gives 75 Vol rep
[51793]={2159},		  		  --Bubbling Totem Testing -- gives 75 7th L rep (Alliance only)
[51791]={2158},		  		  --Bubbling Totem Testing -- gives 75 Vol rep (Horde only)
[49345]={2158},				  --Buried Treasure -- gives 75 Vol rep (Horde only)
[51250]={2158},		 		  --Buzz off! -- gives 75 Vol rep (Horde only)
[51098]={2158, 2159},		  --Commodore Calhoun -- gives 75 Vol or 7th L rep
[51559]={2158},		 		  --Damaged Goods -- gives 75 Vol rep (Horde only)
[51562]={2159},		 		  --Damaged Goods -- gives 75 7th L rep (Alliance only)
[52878]={2158, 2159},		  --Desert Survivors -- gives 75 Vol or 7th L rep -- Battle pet(Kusa)
[51780]={2158},		 		  --Dinner for Dolly and Dot -- gives 75 Vol rep (Horde only)
[51121]={2158, 2159},		  --Enraged Krolusk -- gives 75 Vol or 7th L rep
[51792]={2158},		 		  --Erupting Totem Testing -- gives 75 Vol rep (Horde only)
[51794]={2159},		 		  --Erupting Totem Testing -- gives 75 7th L rep (Alliance only)
[51924]={2158, 2159},		  --Faithless Follow-Through -- gives 75 Vol or 7th L rep ***APPEARS TO BE A DUPLICATE
[51900]={2158, 2159},		  --Faithless Follow-Through -- gives 75 Vol or 7th L rep ***APPEARS TO BE A DUPLICATE
[51156]={2158, 2159},		  --Fangcaller Xorreth -- gives 75 Vol or 7th L rep
[51565]={2159},		 		  --Feeding Frenzy -- gives 75 7th L rep (Alliance only)
[51285]={2158},		 		  --Feeding Frenzy -- gives 75 Vol rep (Horde only)
[51564]={2159},		 		  --Fertilizer Duty -- gives 75 7th L rep (Alliance only)
[51198]={2158},		 		  --Fertilizer Duty -- gives 75 Vol rep (Horde only)
[51157]={2158, 2159},		  --Golanar -- gives 75 Vol or 7th L rep
[51099]={2158, 2159},		  --Gut-Gut the Glutton -- gives 75 Vol or 7th L rep
[51108]={2158, 2159},		  --Hivemother Kraxi -- gives 75 Vol or 7th L rep
[51228]={2158},		 		  --Instant Meat, Ready to Eat -- gives 75 Vol rep (Horde only)
[51239]={2158},		 		  --Instructions Not Included -- gives 75 Vol rep (Horde only) *****OTHER VERSIONS DON'T WORK
[51928]={2159},		 		  --Instructions Not Included -- gives 75 7th L rep (Alliance only) *****OTHER VERSIONS DON'T WORK
[51100]={2158, 2159},		  --Jumbo Sandsnapper -- gives 75 Vol or 7th L rep
[51125]={2158, 2159},		  --Jungleweb Hunter -- gives 75 Vol or 7th L rep
[51102]={2158, 2159},		  --Kamid the Trapper -- gives 75 Vol or 7th L rep
[52850]={2158, 2159},		  --Keeyo's Champions of Vol'dun -- gives 75 Vol or 7th L rep -- Battle pet (Keeyo)
[51429]={2158, 2159},		  --King Clickyclack -- gives 75 Vol or 7th L rep
[51252]={2158, 2159},		  --Kiro's Desert Flower -- gives 75 Vol or 7th L rep
[51635]={2103, 2159, 2163},   --Make Loh Go -- Gives 175 TS rep and 75 ZE rep (Northeastern coast of Vol'dun)
[51153]={2158, 2159},		  --Mor'fani the Exile -- gives 75 Vol rep
[51103]={2158, 2159},		  --Nez'ara -- gives 75 Vol or 7th L rep
[51934]={2159},		 		  --No Negotiations -- gives 75 7th L rep (Alliance only)
[53300]={2158, 2159},		  --Overgrown Anchor Weed -- gives 75 Vol or 7th L rep
[51853]={2159},		 		  --Preserve the Oasis -- gives 75 7th L rep (Alliance only)
[51853]={2158},		 		  --Preserve the Oasis -- gives 75 Vol rep (Horde only)
[51760]={2159},		 		  --Ranishu Feeding Frenzy -- gives 75 7th L rep (Alliance only)
[47704]={2158},		 		  --Ranishu Feeding Frenzy -- gives 75 Vol rep (Horde only)
[51124]={2158, 2159},		  --Relic Hunter Hazaak -- gives 75 Vol or 7th L rep
[51330]={2158},		 		  --Resilient Seeds -- gives 75 Vol rep (Horde only)
[51804]={2159},		 		  --Running Interference -- gives 75 7th L rep (Alliance only)
[51173]={2158},		 		  --Sandfishing -- gives 75 Vol rep (Horde only)
[52196]={2158, 2159},		  --Sandswept Bones -- gives 75 Vol or 7th L rep -- World Boss
[51107]={2158, 2159},		  --Scaleclaw Broodmother -- gives 75 Vol or 7th L rep
[51122]={2158, 2159},		  --Scorpox -- gives 75 Vol or 7th L rep
[51629]={2158, 2159, 2163},   --Shell Game -- gives 175 TS rep and 75 ZE rep - Western Vol'dun
[51123]={2158, 2159},		  --Sirokar -- gives 75 Vol or 7th L rep
[51104]={2158, 2159},		  --Skycaller Teskris -- gives 75 Vol or 7th L rep
[51116]={2158, 2159},		  --Skycarver Krakit -- gives 75 Vol or 7th L rep
[52856]={2158, 2159},		  --Snakes on a Terrace -- gives 75 Vol or 7th L rep -- Battle pet (Sizzik)
[51106]={2158, 2159},		  --Songstress Nahjeen -- gives 75 Vol or 7th L rep
[51836]={2159},		 		  --Sourcing Resources -- gives 75 7th L rep (Alliance only)
[51558]={2158},		 		  --Spider Scorching -- gives 75 Vol rep (Horde only) ***APPEARS TO BE A DUPLICATE
[51561]={2158},		 		  --Spider Scorching -- gives 75 Vol rep (Horde only) ***APPEARS TO BE A DUPLICATE
[51120]={2158, 2159},		  --Stef "Marrow" Quin -- gives 75 Vol or 7th L rep
[51831]={2158, 2159},		  --Swift Strike -- gives 75 Vol or 7th L rep
[52059]={2159},		 		  --Thar She Sinks -- gives 75 7th L rep (Alliance only)
[51997]={2158},		 		  --Thar She Sinks -- gives 75 Vol rep (Horde only)
[51957]={2158},		 		  --The Wrath of Vorrik -- gives 75 Vol rep (Horde only)
[51963]={2159},		 		  --The Wrath of Vorrik -- gives 75 7th L rep (Alliance only)
[51119]={2158, 2159},		  --Vathikur -- gives 75 Vol or 7th L rep
[51983]={2158},		 		  --Vorrik's Vengeance -- gives 75 Vol rep (Horde only)
[51995]={2159},		 		  --Vorrik's Vengeance -- gives 75 7th L rep (Alliance only)
[51316]={2158},		 		  --Walking in a Spiderweb -- gives 75 Vol rep (Horde only)
[51223]={2158},		 		  --Walking on Broken Glass -- gives 75 Vol rep (Horde only)
[51112]={2158, 2159},		  --Warbringer Hozzik -- gives 75 Vol or 7th L rep
[51113]={2158, 2159},		  --Warlord Zothix -- gives 75 Vol or 7th L rep
[51114]={2158, 2159},		  --Warmother Captive -- gives 75 Vol or 7th L rep
[52864]={2158, 2159},		  --What Do you Mean, Mind Controlling Plants -- gives 75 Vol or 7th L rep -- Battle pet (Spineleaf)
[51315]={2103, 2159},		  --Wild Flutterbies -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[51322]={2158},		 		  --Wings and Stingers -- gives 75 Vol rep (Horde only)
[51763]={2158},		 		  --Zem'lan Rescue -- gives 75 Vol rep (Horde only)
[51783]={2159},		 		  --Zem'lan Rescue -- gives 75 7th L rep (Alliance only)
[51115]={2158, 2159}		  --Zunashi the Exile -- gives 75 Vol or 7th L rep

--Nazmir quests***************************************************************************************************
}


function ParseHordeWQs()
	for q, r in pairs(worldQuestReps) do
		if(GetQuestLink(q) ~= nil) then
			--if(IsQuestFlaggedCompleted(q)) then
			-- if(IsQuestComplete(q)) then
				-- print(GetQuestLink(q), " has been completed");
			-- else
			if(IsQuestComplete(q) == false) then
				--if(C_TaskQuest.IsActive(q) and C_TaskQuest.GetQuestTimeLeftMinutes(q) > 0) then
				if(C_TaskQuest.GetQuestTimeLeftMinutes(q) > 0) then
					print(GetQuestLink(q), " IS A VALID WQ");
					numWQs = numWQs + 1;
					--if a WQ gives rep for multiple factions, call AddHordeRepToSum for each of them
					if(type(r) == "table") then
						for k, v in pairs(r) do
							AddHordeRepToSum(v);
						end
						--print(GetQuestLink(q), " gives rep for multiple factions");
					else
					--if a WQ gives rep for one faction, just call AddHordeRepToSum for it
						AddHordeRepToSum(r);
					end
				else
					--print(GetQuestLink(q), " is NOT available at the moment");
				end;
			end
		end
	end
	
	contract_rep = numWQs * 10;
end


function AddHordeRepToSum(re)
	if(re == 2164) then
		CoA = CoA + 125;
	elseif(re == 2156) then
		TE = TE + 75;
	elseif(re == 2157) then
		HB = HB + 75;
	elseif(re == 2163) then
		TS = TS + 175;
	elseif(re == 2158) then
		Vol = Vol + 75;
	elseif(re == 2103) then
		ZE = ZE + 75;
	--else
		--print(re, "'s reputation does not apply");
	end
end


function OutputHordeRepSums()	
	if(CoA > 0) then
		print("Champions of Azeroth potential rep: ", CoA);
	end
	if(TE > 0) then
		print("Talanji's Expedition potential rep: ", TE);
	end
	if(HB > 0) then
		print("The Honorbound potential rep: ", HB);
	end
	if(TS > 0) then
		print("Tortollan Seekers potential rep: ", TS);
	end
	if(Vol > 0) then
		print("Voldunai potential rep: ", Vol);
	end
	if(ZE > 0) then
		print("Zandalari Empire potential rep: ", ZE);
	end
end


function ParseAllianceWQs()
	for q, r in pairs(worldQuestReps) do
		if(GetQuestLink(q) ~= nil) then
			-- if(IsQuestFlaggedCompleted(q)) then
				-- print(GetQuestLink(q), " has been completed");
			-- else
			if(IsQuestComplete(q) == false) then
				if(C_TaskQuest.IsActive(q)) then
					print(GetQuestLink(q), " IS A VALID WQ");
					numWQs = numWQs + 1;
					--if a WQ gives rep for multiple factions, call AddAllianceRepToSum for each of them
					if(type(r) == "table") then
						for k, v in pairs(r) do
							AddAllianceRepToSum(v);
						end
						--print(GetQuestLink(q), " gives rep for multiple factions");
					else
					--if a WQ gives rep for one faction, just call AddAllianceRepToSum for it
						AddAllianceRepToSum(r);
					end
				--else
					--print(GetQuestLink(q), " is NOT available at the moment");
				end;
			end
		end
	end
	contract_rep = numWQs * 10;
end


function AddAllianceRepToSum(re)
	if(re == 2164) then
		CoA = CoA + 125;
	elseif(re == 2161) then
		OoE = OoE + 75;
	elseif(re == 2159) then
		SL = SL + 75;
	elseif(re == 2163) then
		TS = TS + 175;
	elseif(re == 2160) then
		PA = PA + 75;
	elseif(re == 2162) then
		SW = SW + 75;
	--else
	--	print(re, "'s reputation does not apply");
	end
end


function OutputAllianceRepSums()
	if(CoA > 0) then
		print("Champions of Azeroth potential rep: ", CoA);
	end
	if(OoE > 0) then
		print("Order of Embers potential rep: ", OoE);
	end
	if(SL > 0) then
		print("7th Legion potential rep: ", SL);
	end
	if(TS > 0) then
		print("Tortollan Seekers potential rep: ", TS);
	end
	if(PA > 0) then
		print("Proudmoore Admiralty potential rep: ", PA);
	end
	if(SW > 0) then
		print("Storm's Wake potential rep: ", SW);
	end
end


function CheckContracts()
--Horde + Neutral contracts
	if(AuraUtil.FindAuraByName("Contract: Zandalari Empire", "player") ~= nil) then
		print("Zandloople Empurr potential contract rep: ", contract_rep);
		ZE = ZE + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Voldunai", "player") ~= nil) then
		print("Voldunguy potential contract rep: ", contract_rep);
		Vol = Vol + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Tortollan Seekers", "player") ~= nil) then
		print("Turtles that made it to the water potential contract rep: ", contract_rep);
		TS = TS + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Talanji's Expedition", "player") ~= nil) then
		print("Team Talanji potential contract rep: ", contract_rep);
		TE = TE + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Champions of Azeroth", "player") ~= nil) then
		print("Magni's Magnanimous Minutemen potential contract rep: ", contract_rep);
		CoA = CoA + contract_rep;
--Alliance contracts		
	elseif(AuraUtil.FindAuraByName("Contract: Proudmoore Admiralty", "player") ~= nil) then
		print("Making Proudmoores More Proud potential contract rep: ", contract_rep);
		PA = PA + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Order of Embers", "player") ~= nil) then
		print("Order of Burning Stuff potential contract rep: ", contract_rep);
		OoE = OoE + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Storm's Wake", "player") ~= nil) then
		print("Anti-Hentai Patrol potential contract rep: ", contract_rep);
		SW = SW + contract_rep;
	else
		print("NO VALID CONTRACT DETECTED");
	end
end
