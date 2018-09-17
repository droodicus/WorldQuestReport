--http://www.wowhead.com/guide=1949/wow-addon-writing-guide-part-one-how-to-make-your-first-addon

--API REREFENCE: http://wowprogramming.com/docs/api_categories.html
--USEFUL COMMAND: /dump C_TaskQuest.GetQuestsForPlayerByMapID(862)

--***INITIALIZATION************************************************************************
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(f, event)
    if event == "PLAYER_ENTERING_WORLD" then
		if(UnitLevel("player") == 120) then
			--Counter for number of World Quests currently active
			numWQs = 0;
			--Counters for each zone
			zQuests = 0;
			vQuests = 0;
			nQuests = 0;
			contract_rep = 0;
			--initialization of currency total variables
			totalAzerite = 0;
			totalMoney = 0;

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
			
			--[[ MAP ID'S:
			AZEROTH = 947
			ZANDALAR = 875
			VOLDUN = 864
			NAZMIR = 863
			ZULDAZAR = 862
			KUL_TIRAS = 876
			STORMSONG_VALLEY = 942
			DRUSTVAR = 896
			TIRAGARDE_SOUND = 895
			]]
			mapID = 947;

			--mapname = C_Map.GetMapInfo(mapID).name;
			--print("Map: ", mapname, ". MapID: ", mapID);
			--mapQuests = C_TaskQuest.GetQuestsForPlayerByMapID(mapID);
			
			--Horde
			if(UnitFactionGroup("player") == "Horde") then
				print("|cFFFF0000 CHARACTER CONFIRMED HORDE, ZUG ZUG");
				ParseQuests(875);
				ParseQuests(876);
				CheckContracts();
				OutputHordeRepSums();
				print("Num WQs active :", numWQs);
			--Alliance
			elseif(UnitFactionGroup("player") == "Alliance") then
				print("|cFF1f81f2 CHARACTER CONFIRMED ALLIANCE ....ew");
				ParseQuests(mapID);
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

--[[ QUEST REWARDS
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
print("Reward= ", gold, " gold, ", silver, " silver");
--therefore, 100 copper = 1 silver, 10,000 copper = 1 gold

Azerite currency ID = 1553

QID = 51890
local numQuestCurrencies = GetNumQuestLogRewardCurrencies(QID)
if numQuestCurrencies > 0 then
	for currencyNum = 1, numQuestCurrencies do 
		local name, texture, numItems, currencyID = GetQuestLogRewardCurrencyInfo(currencyNum, QID)
		if currencyID == 1553 then
			print(numItems);
		end
	end
end


function CheckMoney()
	questMoney = GetQuestLogRewardMoney(51405);
	print("Unprocessed money= ", questMoney);
	gold = questMoney/10000;
	--print("Gold: ", gold);
	gold = math.floor(gold);
	silver = (questMoney - (gold * 10000)) / 100;
	print("Gold: ", gold);
	print("Silver: ", silver);
	print("Reward= ", gold, " gold, ", silver, " silver");
end
]]

--mapQuests = C_TaskQuest.GetQuestsForPlayerByMapID(mapID);
--[[ MAP ID'S:
			AZEROTH = 947
			ZANDALAR = 875
			VOLDUN = 864
			NAZMIR = 863
			ZULDAZAR = 862
			KUL_TIRAS = 876
			STORMSONG_VALLEY = 942
			DRUSTVAR = 896
			TIRAGARDE_SOUND = 895
			]]
function ParseQuests(mID)
	mapname = C_Map.GetMapInfo(mID).name;
	print("Processing map: ", mapname, ". MapID: ", mID);
	mapQuests = C_TaskQuest.GetQuestsForPlayerByMapID(mID);


	if mapQuests then
		for i, info in ipairs(mapQuests) do
				if HaveQuestData(info.questId) and QuestUtils_IsQuestWorldQuest(info.questId) then
					--print(i, "'s Quest ID: ", info.questId);
					numWQs = numWQs + 1;
					--print(GetQuestLink(info.questId), ", questID: ", info.questId, ", mapID: ", info.mapID);
					GetQuestReps(info.questId, info.mapID); --See function below for details
				--else
				--	print(info.questId, " did not pass correctly");
				end
		end
	end
	contract_rep = numWQs * 10;
	--print("ZULDAZAR QUEST COUNT: ", zQuests);
	--print("VOLDUN QUEST COUNT: ", vQuests);
	--print("NAZMIR QUEST COUNT: ", nQuests);
end

-- local ZuldazarQuests = {
-- [52923]={2103, 2159}		  --Add More to the Collection -- Gives 75 ZE  or 7th L rep
-- }


local ZuldazarQuests = {
[52923]={2103, 2159},		  --Add More to the Collection -- Gives 75 ZE  or 7th L rep
[49809]={2103, 2159},		  --Atal'Dazar: From the Shadows -- Gives 75 ZE or 7th L rep
[49800]={2103, 2159},		  --Atal'Dazar: Spiders! -- Gives 75 ZE or 7th L rep
[50864]={2103, 2159},		  --Atal'Zul Gotaka  -- Gives 75 ZE rep or 7th L rep
[50863]={2103, 2159},		  --Avatar of Xolotal -- Gives 75 ZE or 7th L rep
[52858]={2103, 2159, 2164},   --Azerite Empowerment(Hex Priest Haraka) -- Gives 125 CoA rep and 75 ZE or 7th L rep 
[51444]={2103, 2159, 2164},   --Azerite Empowerment(Zu'shin the Infused) -- Gives 125 CoA rep and 75  ZE or 7th L rep
[51179]={2103, 2159, 2164},   --Azerite Madness (Zuldazar) -- Gives 125 CoA rep and 75  ZE or 7th L rep
[52877]={2103, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75  ZE or 7th L rep
[51450]={2103, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75  ZE or 7th L rep
[52877]={2103, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75  ZE or 7th L rep
[51175]={2103, 2159, 2164},   --Azerite Wounds -- Gives 125 CoA rep and 75  ZE rep
[51642]={2103, 2159, 2163},   --Beachhead -- Gives 175 TS rep and 75 ZE or 7th L rep (Southern coast of Zuldazar)
[50527]={2159},		 		  --Behind Mogu Lines -- gives 75 7th L rep (Alliance only)
[50652]={2103},		  		  --Biting The Hand that Feeds Them -- Give 75 ZE rep (Horde only)
[50862]={2103, 2159},		  --Bloodbulge -- Gives 75 ZE  or 7th L rep
[50868]={2103, 2159},		  --Bramblewing -- Gives 75 ZE  or 7th L rep
[50578]={2103},				  --Bring Ruin AGain -- gives 75 ZE rep (Horde only)
[51475]={2103},				  --Brutal Escort -- gives 75 ZE rep (Horde only)
[50966]={2103},				  --Cleanup Crew -- gives 75 ZE rep (Horde only)
[52251]={2103, 2159},		  --Compromised Reconnaissance -- gives 75 ZE rep **no info whatsoever on wowhead page, doublecheck
[50854]={2103, 2159},		  --Crimsonclaw (Umbra'jin) -- Gives 75 ZE  or 7th L rep
[52892]={2103, 2159},		  --Critters are Friends, Not Food -- Gives 75 ZE  or 7th L rep
[50651]={2159},		  		  --Cut Off Potential -- gives 75 7th L rep (Alliance only)
[50871]={2103, 2159},		  --Daggerjaw -- Gives 75 ZE  or 7th L rep
[51084]={2103, 2159},		  --Dark Chronicler -- Gives 75 ZE  or 7th L rep
[50875]={2103, 2159},		  --Darkspeaker Jo'la - Gives 75 ZE  or 7th L rep
[48862]={2103, 2159},		  --Disarming the Competetion -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[51373]={2159},		  		  --Ears Everywhere -- gives 75 7th L rep (Alliance only)
[51815]={2159},		  		  --Eggstermination -- gives 75 7th L rep (Alliance only)
[50571]={2103},				  --Eggstermination -- gives 75 ZE rep (Horde only)
[50969]={2159},		 		  --Emergency Management -- gives 75 7th L rep (Alliance only)
[50548]={2103},		 		  --Enforcing the Will of the King -- gives 75 ZE rep (Horde only)
[50870]={2103, 2159},		  --G'Naat -- Gives 75 ZE  or 7th L rep
[50877]={2103, 2159},		  --Gahz'ralka -- Gives 75 ZE  or 7th L rep
[50857]={2103, 2159},		  --Golrakahn -- Gives 75 ZE  or 7th L rep
[50874]={2103, 2159},		  --Hakbi the Risen -- Gives 75 ZE  or 7th L rep
[50846]={2103, 2159},		  --Headhunter Lee'za -- Gives 75 ZE  or 7th L rep
[50765]={2103},		 		  --Herding Children -- gives 75 ZE rep (Horde only)
[51497]={2103},		 		  --Hex Education -- gives 75 ZE rep (Horde only)
[51178]={2159},		  		  --Hundred Troll Holdout -- gives 75 7th L rep (Alliance only)
[51232]={2103},		 		  --Hundred Troll Holdout -- gives 75 ZE rep (Horde only)
--[51305]={2103, 2159},		  --Jelly Clouds -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck  ** COMMENTING OUT DUE TO QUEST BEING BUGGED
[50859]={2103, 2159},		  --Kandak -- Gives 75 ZE  or 7th L rep
[50869]={2103, 2159},		  --Kiboku -- Gives 75 ZE  or 7th L rep
[51501]={2103, 2159},		  --Kings' Rest: Malfunction Junction -- Gives 75 ZE  or 7th L rep
[50547]={2103},		  		  --Knives of Zul -- gives 75 ZE rep (Horde only)
[50845]={2103, 2159},		  --Kul'krazahn -- Gives 75 ZE  or 7th L rep
--[50852]={2103, 2159},		  --Lady Seirine -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck  ** COMMENTING OUT DUE TO QUEST BEING BUGGED
[50885]={2103, 2159},		  --Lei-zhi -- Gives 75 ZE  or 7th L rep
[51496]={2103},		 		  --Loa Your Standards -- gives 75 ZE rep (Horde only)
[51636]={2103, 2159, 2163},   --Make Loh Go -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[50876]={2103, 2159},		  --Murderbeak -- Gives 75 ZE  or 7th L rep
[50747]={2103, 2159},		  --No Good Amani -- Gives 75 ZE  or 7th L rep
[50855]={2103, 2159},		  --Old R'gal -- gives 75 7th L rep (Alliance only)
[51495]={2103},				  --Old Rotana -- gives 75 ZE rep (Horde only)
[50574]={2103},				  --Preservation Methods -- gives 75 ZE rep (Horde only)
[51816]={2159},				  --Pterrible Ingredients -- gives 75 7th L rep (Alliance only)
[50633]={2103},				  --Pterrible Ingredients -- gives 75 ZE rep (Horde only)
[50524]={2103},				  --Purify the Temple -- gives 75 ZE rep (Horde only)
[51821]={2159},				  --Quelling the Cove -- gives 75 7th L rep (Alliance only)
[49068]={2103},				  --Quelling the Cove -- gives 75 ZE rep (Horde only)
[50540]={2103},				  --Rally the Rastari -- gives 75 ZE rep (Horde only)
[51814]={2159},				  --Ravoracious -- gives 75 7th L rep (Alliance only)
[50636]={2103},				  --Ravoracious -- gives 75 ZE rep (Horde only)
[50744]={2103},		   		  --Refresh Their Memory -- gives 75 ZE rep (Horde only)
[50964]={2103},				  --Ritual Combat -- gives 75 ZE rep (Horde only)
[52250]={2159},		  		  --Saving Xibala -- gives 75 7th L rep (Alliance only)
[49413]={2103, 2159},		  --Scamps with Scrolls -- Gives 75 ZE  or 7th L rep
[51822]={2159},		  		  --Scrolls and Scales -- gives 75 7th L rep (Alliance only)
[50581]={2103},		 		  --Scrolls and Scales -- gives 75 ZE rep (Horde only)
[51630]={2103, 2159, 2163},   --Shell Game -- gives 175 TS rep and 75 ZE or 7th L rep - Southwestern Zuldazar
[50737]={2159},		 		  --Silence the Speakers -- gives 75 7th L rep (Alliance only)
[50858]={2159},		  		  --Sky Queen -- gives 75 7th L rep (Alliance only)
[52938]={2103, 2159},		  --Small Beginnings -- gives 75 ZE rep -- pet battle (Zujai)
[53165]={2159},		 		  --Stopping Antiquities Theft -- gives 75 7th L rep (Alliance only)
[50873]={2103, 2159},		  --Strange Egg -- Gives 75 ZE  or 7th L rep
[50756]={2159},		  		  --Subterranean Evacuation -- gives 75 7th L rep (Alliance only)
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
[51081]={2103, 2159},		  --Syrawon the Dominus -- Gives 75 ZE  or 7th L rep
[50867]={2103, 2159},		  --Tambano -- Gives 75 ZE  or 7th L rep
[51494]={2103},		  		  --The Blood Gate -- gives 75 ZE rep (Horde only)
[52249]={2159},		  		  --The Shores of Xibala -- gives 75 7th L rep (Alliance only)
[52248]={2103},		  		  --The Shores of Xibala -- gives 75 ZE rep (Horde only)
[50850]={2103, 2159},		  --Tia'Kawan -- Gives 75 ZE  or 7th L rep
[50592]={2103},		 		  --Tiny Terror -- gives 75 ZE rep (Horde only)
[50861]={2103, 2159},		  --Torraske the Eternal -- Gives 75 ZE  or 7th L rep
[50847]={2103, 2159},		  --Twisted Child of Rezan -- Gives 75 ZE  or 7th L rep
[50853]={2103, 2159},		  --Umbra'rix -- Gives 75 ZE  or 7th L rep
[49444]={2103},		 		  --Underfoot -- gives 75 ZE rep (Horde only)
[50287]={2103},		  		  --Unending Gorilla Warfare -- gives 75 ZE rep (Horde only)
[51374]={2159},		  		  --Unending Gorilla Warfare -- gives 75 7th L rep (Alliance only)
[50872]={2103, 2159},		  --Warcrawler Karkithiss -- Gives 75 ZE  or 7th L rep
[50619]={2103},		  		  --What Goes Up -- gives 75 ZE rep (Horde only)
--[50849]={2103, 2159},		  --Witch Doctor Habra'du -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck  ** COMMENTING OUT DUE TO QUEST BEING BUGGED
[50782]={2159},		 		  --Word on the Streets -- gives 75 7th L rep (Alliance only)
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
[51824]={2159},		  		  --You're Grounded -- gives 75 7th L rep (Alliance only)
[52937]={2103, 2159},		  --You've Never Seen Jammer Upset -- Gives 75 ZE  or 7th L rep -- pet battle (Jammer)
[50866]={2103, 2159}		  --Zayoos -- Gives 75 ZE  or 7th L rep
}

local VoldunQuests = {
[52798]={2158},				  --A few More Charges -- gives 75 Vol rep (Horde only)
[49013]={2158},				  --A Jolt of Power -- gives 75 Vol rep (Horde only)
[51238]={2158},		  		  --Abandoned  in the Burrows -- gives 75 Vol rep (Horde only)
[51105]={2158, 2159, 2164},	  --Ak'tar -- gives 75 Vol or 7th L rep
[51095]={2158, 2159, 2164},	  --Ashmane -- gives 75 Vol or 7th L rep
[51096]={2158, 2159, 2164},	  --Azer'tor -- gives 75 Vol or 7th L rep
[52849]={2158, 2159, 2164},	  --Azerite Empowerment (Warlord Dagu) -- Gives 125 CoA rep and 75 Vol or 7th L rep
[51185]={2158, 2159, 2164},	  --Azerite Empowerment (Skithis the Infused) -- Gives 125 CoA rep and 75 Vol or 7th L rep
[51422]={2158, 2159, 2164},   --Azerite Madness(Vol'dun) -- Gives 125 CoA rep and 75  ZE rep 
[50975]={2158, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75  ZE rep
[52875]={2158, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75  ZE rep 
[51428]={2158, 2159, 2164},   --Azerite Wounds -- Gives 125 CoA rep and 75  ZE rep
[51117]={2158, 2159},		  --Bajiani the Slick -- gives 75 Vol or 7th L rep
[51641]={2158, 2159, 2163},   --Beachhead -- Gives 175 TS rep and 75 ZE rep (Northeastern coast of Vol'dun)
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
[51239]={2158},		 		  --Instructions Not Included -- gives 75 Vol rep (Horde only) 
[51181]={2158},		 		  --Instructions Not Included -- gives 75 Vol rep (Horde only) 
[51928]={2159},		 		  --Instructions Not Included -- gives 75 7th L rep (Alliance only)
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
[51315]={2158, 2159},		  --Wild Flutterbies 
[51322]={2158},		 		  --Wings and Stingers -- gives 75 Vol rep (Horde only)
[51763]={2158},		 		  --Zem'lan Rescue -- gives 75 Vol rep (Horde only)
[51783]={2159},		 		  --Zem'lan Rescue -- gives 75 7th L rep (Alliance only)
[51115]={2158, 2159}		  --Zunashi the Exile -- gives 75 Vol or 7th L rep
}

local NazmirQuests = {
[50478]={2156, 2159},		  --A'yame -- gives 75 TE or 7th L rep
[51131]={2159},		 		  --Absolutely Barbaric -- gives 75 7th L rep (Alliance only)
[50549]={2156},		 		  --Absolutely Barbaric -- gives 75 TE rep (Horde only)
[52803]={2156, 2159},		  --Accidental Dread -- gives 75 TE or 7th L rep -- Battle pet (Korval Darkbeard)
[50718]={2156},		 		  --Agent of Death -- gives 75 TE rep (Horde only)
[50487]={2156, 2159},		  --Aiji the Accursed -- gives 75 TE or 7th L rep
[50488]={2156, 2159},		  --Ancient Jawbreaker -- gives 75 TE or 7th L rep
[51412]={2156, 2159, 2164},	  --Azerite Empowerment (Chaka the Infused) -- Gives 125 CoA rep and 75 TE or 7th L rep
[52832]={2156, 2159, 2164},	  --Azerite Empowerment (Zebast the Everliving) -- Gives 125 CoA rep and 75 TE or 7th L rep
[50570]={2156, 2159},		  --Aazerite Infused Elemental -- gives 75 TE or 7th L rep
[50564]={2156, 2159},		  --Azerite Infused Slag -- gives 75 TE or 7th L rep
[51415]={2156, 2159, 2164},   --Azerite Madness(Nazmir) -- Gives 125 CoA rep and 75 TE  or 7th L rep
[51411]={2156, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75 TE or 7th L rep
[52808]={2156, 2159, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75 TE rep  ***WOWHEAD PAGE BLANK, MIGHT BE DEFUNCT
[52884]={2156, 2159, 2164},   --Azerite Wounds -- Gives 125 CoA rep and 75 TE or 7th L rep
[51064]={2156, 2159, 2164},   --Azerite Wounds -- Gives 125 CoA rep and 75 TE or 7th L rep
[50511]={2156, 2159},		  --Bajiatha -- gives 75 TE or 7th L rep
[51640]={2156, 2159, 2163},   --Beachhead -- Gives 175 TS rep and 75 or 7th L rep (Northeastern coast of Nazmir)
[50572]={2156},		 		  --Bloody Intrusion -- gives 75 TE rep (Horde only)
[51550]={2159},		 		  --Bubbles and Trouble -- gives 75 7th L rep (Alliance only)
[50648]={2156},		 		  --Bubbles and Trouble -- gives 75 TE rep (Horde only)
[50735]={2156},		 		  --Burial Detail -- gives 75 TE rep (Horde only)
[50665]={2156},		 		  --Cancel the Troll Apocalypse -- gives 75 TE rep (Horde only)
[50962]={2159},		 		  --Cargo Reclamation -- gives 75 7th L rep (Alliance only)
[50813]={2156},		 		  --Cargo Reclamation -- gives 75 TE rep (Horde only)
[50568]={2156, 2159},		  --Chag's Challenge -- gives 75 TE or 7th L rep
[50491]={2156, 2159},		  --Corpse Bringer Yal'kar -- gives 75 TE or 7th L rep
[52779]={2156, 2159},		  --Crawg in the Bog -- gives 75 TE or 7th L rep -- Battle pet (Bloodtusk)
[50492]={2156, 2159},		  --Cursed Chest -- gives 75 TE or 7th L rep
[50717]={2156},		 		  --Don't Stalk Me, Troll -- gives 75 TE rep (Horde only)
[50899]={2159},		 		  --Don't Stalk Me, Troll -- gives 75 7th L rep (Alliance only)
[51166]={2159},		 		  --Down to the Roots -- gives 75 7th L rep (Alliance only)
[50443]={2156},		 		  --Down to the Roots -- gives 75 TE rep (Horde only)
[50475]={2156, 2159},		  --Drukengu -- gives 75 TE or 7th L rep ***WOWHEAD PAGE BLANK, MIGHT BE DEFUNCT
[52007]={2156},		 		  --Engines of War -- gives 75 TE rep (Horde only)
[51172]={2159},		 		  --Forked Lightning -- gives 75 7th L rep (Alliance only)
[50545]={2156},		 		  --Forked Lightning -- gives 75 TE rep (Horde only)
[50559]={2156},		 		  --Getting Out of Hand -- gives 75 TE rep (Horde only)
[51127]={2159},		 		  --Getting Out of Hand -- gives 75 7th L rep (Alliance only)
[50496]={2156, 2159},		  --Glompmaw -- gives 75 TE or 7th L rep
[50464]={2156, 2159},		  --Golanar -- gives 75 TE or 7th L rep
[50498]={2156, 2159},		  --Gutrip -- gives 75 TE or 7th L rep
[50499]={2156, 2159},		  --Gwugnug -- gives 75 TE or 7th L rep
[50695]={2156},		 		  --It's Never Time for Cannibalism -- gives 75 TE rep (Horde only)
[50689]={2156},		 		  --It's the Pits -- gives 75 TE rep (Horde only)
[51546]={2159},		 		  --It's the Pits -- gives 75 7th L rep (Alliance only)
[50502]={2156, 2159},		  --Jax'teb the Reanimated -- gives 75 TE or 7th L rep
[50503]={2156, 2159},		  --Juba the Scarred -- gives 75 TE or 7th L rep
[50505]={2156, 2159},		  --Kal'draxa -- gives 75 TE or 7th L rep
[50506]={2156, 2159},		  --King Kooba -- gives 75 TE or 7th L rep
[50497]={2156},		 		  --Krag'wa's Favor -- gives 75 TE rep (Horde only)
[50507]={2156, 2159},		  --Krubbs -- gives 75 TE or 7th L rep
[50509]={2156, 2159},		  --Lo'kuno -- gives 75 TE or 7th L rep
[50566]={2156, 2159},		  --Lost Scroll -- gives 75 TE or 7th L rep
[50517]={2156, 2159},		  --Mala'kili and Rohnkor -- gives 75 TE or 7th L rep
[52754]={2156, 2159},		  --Marshdwellers -- gives 75 TE or 7th L rep -- Battle pet (Lozu)
[51548]={2159},		 		  --Nagative Feedback -- gives 75 7th L rep (Alliance only)
[50587]={2156},		 		  --Nagative Feedback -- gives 75 TE rep (Horde only)
[50510]={2156, 2159},		  --Overstuffed Saurolisk -- gives 75 TE or 7th L rep
[52799]={2156, 2159},		  --Pack Leader -- gives 75 TE or 7th L rep -- Battle pet (Grady Prett)
[51154]={2159},		 		  --Past Due -- gives 75 7th L rep (Alliance only)
[50667]={2156},		 		  --Past Due -- gives 75 TE rep (Horde only)
[52006]={2156},		 		  --Preemptive Assault -- gives 75 TE rep (Horde only)
[50501]={2156, 2159},		  --Queen Tzxi'kik -- gives 75 TE or 7th L rep
[50463]={2156, 2159},		  --Razorjaw -- gives 75 TE or 7th L rep
[50786]={2156},		 		  --Revenge of Krag'wa -- gives 75 TE rep (Horde only)
[50676]={2156},		 		  --River Toll -- gives 75 TE rep (Horde only)
[50961]={2159},		 		  --Save Our Scrolls! -- gives 75 7th L rep (Alliance only)
[50634]={2156},		 		  --Save Our Scrolls! -- gives 75 TE rep (Horde only)
[50521]={2156},		 		  --Scorched Earth -- gives 75 TE rep (Horde only)
[51109]={2159},		 		  --Scorched Earth -- gives 75 7th L rep (Alliance only)
[50512]={2156, 2159},		  --Scout Skrasniss -- gives 75 TE or 7th L rep
[51628]={2156, 2159, 2163},   --Shell Game -- Gives 175 TS rep and 75 or 7th L rep (Northeastern Nazmir)
[50468]={2156, 2159},		  --Shul-Nagruth -- gives 75 TE or 7th L rep
[52785]={2159},		 		  --Smashing Zalamar -- gives 75 7th L rep (Alliance only)
[50650]={2156},		 		  --Smashing Zalamar -- gives 75 TE rep (Horde only)
[52181]={2156, 2159},		  --Smoke and Shadow -- gives 75 TE or 7th L rep -- World Boss
[52385]={2156},		 		  --Supplies Needed: Slimy Mackerel -- gives 75 TE rep (Horde only)
[50660]={2156},		 		  --Survival Strategy -- gives 75 TE rep (Horde only)
[50936]={2159},		 		  --Survival Strategy -- gives 75 7th L rep (Alliance only)
[50513]={2156, 2159},		  --Tainted Guardian -- gives 75 TE or 7th L rep
[50474]={2156},		 		  --The Other Side -- gives 75 TE rep (Horde only)
[50529]={2156},		 		  --The Spirits Within -- gives 75 TE rep (Horde only)
[50514]={2156, 2159},		  --Totem Maker Jash'ga -- gives 75 TE or 7th L rep
[50577]={2156},		 		  --Unaccounted For -- gives 75 TE rep (Horde only)
[51176]={2159},		 		  --Unaccounted For -- gives 75 7th L rep (Alliance only)
[50483]={2156, 2159},		  --Underlord Xerxiz -- gives 75 TE or 7th L rep
[50490]={2156, 2159},		  --Uroku the Bound -- gives 75 TE or 7th L rep
[50515]={2156, 2159},		  --Venomjaw -- gives 75 TE or 7th L rep
[50459]={2156, 2159},		  --Vugthuth -- gives 75 TE or 7th L rep
[50516]={2156, 2159},		  --Wardrummer Zurula -- gives 75 TE or 7th L rep
[52426]={2156},		 		  --Work Order: Battle Flag: Phalanx Defense -- gives 75 TE rep (Horde only)
[51009]={2156},		 		  --Work Order: Calcified Bone -- gives 75 TE rep (Horde only)
[52396]={2156},		 		  --Work Order: Contract: Talanji's Expedition -- gives 75 TE rep (Horde only)
[51015]={2156},		 		  --Work Order: Deep Sea Satin -- gives 75 TE rep (Horde only)
[52418]={2156},		 		  --Work Order: Drums of the Maelstrom -- gives 75 TE rep (Horde only)
[52360]={2156},		 		  --Work Order: Enchant Weapon - Coastal Surge -- gives 75 TE rep (Horde only)
[52361]={2156},		 		  --Work Order: Enchant Weapon - Torret of Elements -- gives 75 TE rep (Horde only)
[52411]={2156},		 		  --Work Order: Kubiline -- gives 75 TE rep (Horde only)
[51006]={2156},		 		  --Work Order: Monelite Ore -- gives 75 TE rep (Horde only)
[52337]={2156},		 		  --Work Order: Sea Mist Potion -- gives 75 TE rep (Horde only)
[51005]={2156},		 		  --Work Order: Sea Stalk -- gives 75 TE rep (Horde only)
[51012]={2156},		 		  --Work Order: Shimmerscale -- gives 75 TE rep (Horde only)
[52410]={2156},		 		  --Work Order: Solstone -- gives 75 TE rep (Horde only)
[52372]={2156},		 		  --Work Order: XA-1000 Surface Skimmer -- gives 75 TE rep (Horde only)
[50489]={2156, 2159},		  --Xu'ba -- gives 75 TE or 7th L rep
[50519]={2156, 2159},		  --Za'amar -- gives 75 TE or 7th L rep
[50518]={2156, 2159},		  --Zanxib -- gives 75 TE or 7th L rep
[50461]={2156, 2159}		  --Zujothgul -- gives 75 TE or 7th L rep
}

local DrustvarQuests = {
[52157]={2161, 2157},		  --A Chilling Encounter -- gives 75 Order of Embers or Honorbound rep -- World boss
[51616]={2161},		  		  --A Final Rest -- gives 75 Order of Embers rep (Alliance only)
[51719]={2157},		  		  --A Glaive Mistake -- gives 75 Honorbound rep (Horde only)
[51727]={2157},		  		  --A Shot at the Dark Iron -- gives 75 Honorbound rep (Horde only)
[51745]={2157},		  		  --A Smelly Solution -- gives 75 Honorbound rep (Horde only)
[51687]={2161},		  		  --A Smelly Solution -- gives 75 Order of Embers rep (Alliance only)
[53294]={2161, 2157},		  --Akunda's Bite Cluster -- gives 75 Order of Embers or Honorbound rep
[51576]={2161},		  		  --Any Witch Way but Dead -- gives 75 Order of Embers rep (Alliance only)
[51541]={2161, 2157},		  --Arclight -- gives 75 Order of Embers or Honorbound rep
[51466]={2161, 2157},		  --Arvon the Betrayed -- gives 75 Order of Embers or Honorbound rep
[51542]={2161, 2157},		  --Avalanche -- gives 75 Order of Embers or Honorbound rep
[51179]={2161, 2157, 2164},   --Azerite Empowerment (Rotbough) -- Gives 125 CoA rep and 75 OoE or HB rep
[51612]={2161, 2157, 2164},   --Azerite Empowerment (Sister Hilga) -- Gives 125 CoA rep and 75 OoE or HB rep
[51608]={2161, 2157, 2164},   --Azerite Madness (Central Drustvar) -- Gives 125 CoA rep and 75 OoE or HB rep
[51615]={2161, 2157, 2164},   --Azerite Mining (Central Drustvar) -- Gives 125 CoA rep and 75 OoE or HB rep
[52872]={2161, 2157, 2164},   --Azerite Mining (Central Drustvar) -- Gives 125 CoA rep and 75 OoE or HB rep
[51609]={2161, 2157, 2164},   --Azerite Wounds -- Gives 125 CoA rep and 75 OoE or HB rep
[51491]={2161, 2157},		  --Balethorn -- gives 75 Order of Embers or Honorbound rep
[51506]={2161, 2157},		  --Barbthorn Queen -- gives 75 Order of Embers or Honorbound rep
[51681]={2161},		  		  --Basic Witch -- gives 75 Order of Embers rep (Alliance only)
[51637]={2161, 2157, 2163},   --Beachhead -- Gives 175 TS rep and 75 OoE or HB rep (Northwest Drustvar)
[50000]={2161},		  		  --Beastly Dealings -- gives 75 Order of Embers rep (Alliance only)
[51832]={2157},		  		  --Beat ARound the Bush -- gives 75 Honorbound rep (Horde only)
[51917]={2161, 2157},		  --Beshol -- gives 75 Order of Embers or Honorbound rep
[51469]={2161, 2157},		  --Betsy -- gives 75 Order of Embers or Honorbound rep
[51512]={2161, 2157},		  --Bilefang Mother -- gives 75 Order of Embers or Honorbound rep
[51699]={2161, 2157},		  --Blighted Monstrosity -- gives 75 Order of Embers or Honorbound rep
--***Blooming Siren's Sting appears to have 6 IDs?
[53280]={2161, 2157},		  --Blooming Siren's Sting -- gives 75 Order of Embers or Honorbound rep
[53286]={2161, 2157},		  --Blooming Siren's Sting -- gives 75 Order of Embers or Honorbound rep
[53304]={2161, 2157},		  --Blooming Siren's Sting -- gives 75 Order of Embers or Honorbound rep
[53292]={2161, 2157},		  --Blooming Siren's Sting -- gives 75 Order of Embers or Honorbound rep
[53299]={2161, 2157},		  --Blooming Siren's Sting -- gives 75 Order of Embers or Honorbound rep
[53272]={2161, 2157},		  --Blooming Siren's Sting -- gives 75 Order of Embers or Honorbound rep
--***Blooming Star Moss appears to have 6 IDs?
[53271]={2161, 2157},		  --Blooming Star Moss -- gives 75 Order of Embers or Honorbound rep
[53303]={2161, 2157},		  --Blooming Star Moss -- gives 75 Order of Embers or Honorbound rep
[53279]={2161, 2157},		  --Blooming Star Moss -- gives 75 Order of Embers or Honorbound rep
[53291]={2161, 2157},		  --Blooming Star Moss -- gives 75 Order of Embers or Honorbound rep
[53298]={2161, 2157},		  --Blooming Star Moss -- gives 75 Order of Embers or Honorbound rep
[53285]={2161, 2157},		  --Blooming Star Moss -- gives 75 Order of Embers or Honorbound rep
[51709]={2161},		  		  --Bombardment -- gives 75 Order of Embers rep (Alliance only)
[51741]={2157},		  		  --Bombardment -- gives 75 Honorbound rep (Horde only)
[51468]={2161, 2157},		  --Bonesquall -- gives 75 Order of Embers or Honorbound rep
[51989]={2161, 2157},		  --Braedan Whitewall -- gives 75 Order of Embers or Honorbound rep
[51737]={2157},		  		  --Bruin Potions -- gives 75 Honorbound rep (Horde only)
[50369]={2161},		  		  --Bruin Potions -- gives 75 Order of Embers rep (Alliance only)
[53323]={2161, 2157},		  --Burnished Platinum -- gives 75 Order of Embers or Honorbound rep
[53312]={2161, 2157},		  --Burnished Platinum -- gives 75 Order of Embers or Honorbound rep
[51528]={2161, 2157},		  --Captain Leadfist -- gives 75 Order of Embers or Honorbound rep
[53314]={2161, 2157},		  --Coarse Storm Silver -- gives 75 Order of Embers or Honorbound rep
[53325]={2161, 2157},		  --Coarse Storm Silver -- gives 75 Order of Embers or Honorbound rep
[51920]={2161, 2157},		  --Cottontail Matron -- gives 75 Order of Embers or Honorbound rep
[52009]={2161, 2157},		  --Crab People -- gives 75 Order of Embers or Honorbound rep -- Battle pet (Capt. Hermes)
[51706]={2161},		  		  --Deadwood -- gives 75 Order of Embers rep (Alliance only)
[51461]={2161, 2157},		  --Deathcap -- gives 75 Order of Embers or Honorbound rep
[53317]={2161, 2157},		  --Dense Storm Silver -- gives 75 Order of Embers or Honorbound rep
[51754]={2157},		  		  --Dogged Tenacity -- gives 75 Honorbound rep (Horde only)
[53329]={2161, 2157},		  --Ductile Platinum -- gives 75 Order of Embers or Honorbound rep
[51747]={2157},		  		  --Early Warning -- gives 75 Honorbound rep (Horde only)
[51919]={2161, 2157},		  --Emily Mayville -- gives 75 Order of Embers or Honorbound rep
[51527]={2161, 2157},		  --Executioner Blackwell -- gives 75 Order of Embers or Honorbound rep
[51761]={2157},		  		  --Familiar Foes -- gives 75 Honorbound rep (Horde only)
[51588]={2161},		  		  --Familiar Foes -- gives 75 Order of Embers rep (Alliance only)
--***Flourishiong Riverbud appears to have 6 IDs?
[53297]={2161, 2157},		  --Flourishing Riverbud -- gives 75 Order of Embers or Honorbound rep
[53270]={2161, 2157},		  --Flourishing Riverbud -- gives 75 Order of Embers or Honorbound rep
[53278]={2161, 2157},		  --Flourishing Riverbud -- gives 75 Order of Embers or Honorbound rep
[53290]={2161, 2157},		  --Flourishing Riverbud -- gives 75 Order of Embers or Honorbound rep
[53302]={2161, 2157},		  --Flourishing Riverbud -- gives 75 Order of Embers or Honorbound rep
[53284]={2161, 2157},		  --Flourishing Riverbud -- gives 75 Order of Embers or Honorbound rep
--***Flourishiong Sea Stalks appears to have 6 IDs?
[53296]={2161, 2157},		  --Flourishing Sea Stalks -- gives 75 Order of Embers or Honorbound rep
[53289]={2161, 2157},		  --Flourishing Sea Stalks -- gives 75 Order of Embers or Honorbound rep
[53283]={2161, 2157},		  --Flourishing Sea Stalks -- gives 75 Order of Embers or Honorbound rep
[53266]={2161, 2157},		  --Flourishing Sea Stalks -- gives 75 Order of Embers or Honorbound reps
[53301]={2161, 2157},		  --Flourishing Sea Stalks -- gives 75 Order of Embers or Honorbound rep
[53277]={2161, 2157},		  --Flourishing Sea Stalks -- gives 75 Order of Embers or Honorbound rep
[51658]={2161},		  		  --Fly the Coop! -- gives 75 Order of Embers rep (Alliance only)
[51887]={2161, 2157},		  --Fungi Trio -- gives 75 Order of Embers or Honorbound rep
[53311]={2161, 2157},		  --Gleaming Storm Silver -- gives 75 Order of Embers or Honorbound rep
[51507]={2161, 2157},		  --Gorehorn -- gives 75 Order of Embers or Honorbound rep
[51874]={2161, 2157},		  --Gorged Boar -- gives 75 Order of Embers or Honorbound rep
[51909]={2161, 2157},		  --Grozgore -- gives 75 Order of Embers or Honorbound rep
[53316]={2161, 2157},		  --Hardened Monelite -- gives 75 Order of Embers or Honorbound rep
[53327]={2161, 2157},		  --Hardened Monelite -- gives 75 Order of Embers or Honorbound rep
[51884]={2161, 2157},		  --Haywire Golem -- gives 75 Order of Embers or Honorbound rep
[51604]={2161},		  		  --Hunters Hunted -- gives 75 Order of Embers rep (Alliance only)
[51764]={2157},		  		  --Hunters Hunted -- gives 75 Honorbound rep (Horde only)
[51697]={2161},		  		  --Hunting for Truffle Hunters -- gives 75 Order of Embers rep (Alliance only)
[51740]={2157},		  		  --Hunting for Truffle Hunters -- gives 75 Honorbound rep (Horde only)
[51467]={2161, 2157},		  --Hyo'gi -- gives 75 Order of Embers or Honorbound rep
[51693]={2161},		  		  --Intercepting the Irontide -- gives 75 Order of Embers rep (Alliance only)
[51742]={2157},		  		  --Intercepting the Irontide -- gives 75 Honorbound rep (Horde only)
[51972]={2161, 2157},		  --Lost Goat -- gives 75 Order of Embers or Honorbound rep
[53321]={2161, 2157},		  --Luminous Monelite -- gives 75 Order of Embers or Honorbound rep
[53308]={2161, 2157},		  --Luminous Monelite -- gives 75 Order of Embers or Honorbound rep
[51433]={2161, 2157},		  --Matron Morana -- gives 75 Order of Embers or Honorbound rep
[51707]={2161},		  		  --More Valuable than Gold -- gives 75 Order of Embers rep (Alliance only)
[51743]={2157},		  		  --More Valuable than Gold -- gives 75 Honorbound rep (Horde only)
[51620]={2161},		  		  --Natural Resources -- gives 75 Order of Embers rep (Alliance only)
[51768]={2157},		  		  --Natural Resources -- gives 75 Honorbound rep (Horde only)
[51908]={2161, 2157},		  --Nevermore -- gives 75 Order of Embers or Honorbound rep
[52218]={2161, 2157},		  --Night Horrors -- gives 75 Order of Embers or Honorbound rep -- Battle pet (Dilbert McClint)
[51454]={2161},		  		  --Once More Into Battle -- gives 75 Order of Embers rep (Alliance only)
[53282]={2161, 2157},		  --Overgrown Anchor Weed -- gives 75 Order of Embers or Honorbound rep
[53293]={2161, 2157},		  --Overgrown Anchor Weed -- gives 75 Order of Embers or Honorbound rep
[53288]={2161, 2157},		  --Overgrown Anchor Weed -- gives 75 Order of Embers or Honorbound rep
[53274]={2161, 2157},		  --Overgrown Anchor Weed -- gives 75 Order of Embers or Honorbound rep
[53305]={2161, 2157},		  --Overgrown Anchor Weed -- gives 75 Order of Embers or Honorbound rep
[51505]={2161, 2157},		  --Quillrat Matriarch -- gives 75 Order of Embers or Honorbound rep
[51585]={2161},		  		  --Quit Your Witchin' -- gives 75 Order of Embers rep (Alliance only)
[51897]={2161, 2157},		  --Rimestone -- gives 75 Order of Embers or Honorbound rep
[51710]={2161},		  		  --Rise of the Yetis -- gives 75 Order of Embers rep (Alliance only)
[51739]={2157},		  		  --Rise of the Yetis -- gives 75 Honorbound rep (Horde only)
[52278]={2161, 2157},		  --Night Horrors -- gives 75 Order of Embers or Honorbound rep -- Battle pet (Fizzie Sparkwhistle)
[53324]={2161, 2157},		  --Rough Monelite -- gives 75 Order of Embers or Honorbound rep
[49397]={2161},		  		  --Sausage Party -- gives 75 Order of Embers rep (Alliance only)
[51625]={2161, 2157, 2163},   --Shell Game -- Gives 175 TS rep and 75 OoE or HB rep (Northwest Drustvar)
[51906]={2161, 2157},		  --Sister Martha -- gives 75 Order of Embers or Honorbound rep
[51683]={2161},		  		  --Slash and Burn Tactics -- gives 75 Order of Embers rep (Alliance only)
[53326]={2161, 2157},		  --Smooth Platinum -- gives 75 Order of Embers or Honorbound rep
[51431]={2161, 2157},		  --Soul Goliath -- gives 75 Order of Embers or Honorbound rep
[51434]={2161, 2157},		  --Stone Golem -- gives 75 Order of Embers or Honorbound rep
[52381]={2161},		  		  --Supplies Needed: Lane Snapper -- gives 75 Order of Embers rep (Alliance only)
[51529]={2161, 2157},		  --Talon -- gives 75 Order of Embers or Honorbound rep
[51765]={2157},		  		  --Tangled Webs -- gives 75 Honorbound rep (Horde only)
[51672]={2161},		  		  --Tangled Webs -- gives 75 Order of Embers rep (Alliance only)
[51970]={2161, 2157},		  --The Caterer -- gives 75 Order of Embers or Honorbound rep
[51690]={2161},		  		  --The Shadows of Corlain -- gives 75 Order of Embers rep (Alliance only)
[51746]={2157},		  		  --The Shadows of Corlain -- gives 75 Honorbound rep (Horde only)
[51667]={2161},		  		  --This Bird You Cannot Change -- gives 75 Order of Embers rep (Alliance only)
[51767]={2157},		  		  --Trapline -- gives 75 Honorbound rep (Horde only)
[51619]={2161},		  		  --Trapline -- gives 75 Order of Embers rep (Alliance only)
[51397]={2161},		  		  --Up in your Drill -- gives 75 Order of Embers rep (Alliance only)
[51508]={2161, 2157},		  --Vicemaul -- gives 75 Order of Embers or Honorbound rep
[51530]={2161},		  		  --Wedding Crashers -- gives 75 Order of Embers rep (Alliance only)
[51457]={2161, 2157},		  --Whargarble the Ill-Tempered -- gives 75 Order of Embers or Honorbound rep
[51769]={2157},		  		  --What a Gull Wants -- gives 75 Honorbound rep (Horde only)
[51676]={2161},		  		  --What a Gull Wants -- gives 75 Order of Embers rep (Alliance only)
[51508]={2161, 2157},		  --What's the Buzz? -- gives 75 Order of Embers or Honorbound rep -- Battle pet (Edwin Malus)
[51686]={2161},		  		  --Where my Witches at? -- gives 75 Order of Embers rep (Alliance only)
[51694]={2161},		  		  --Which Witch? -- gives 75 Order of Embers rep (Alliance only)
[51988]={2161, 2157},		  --Whitney "Steelclaw" Ramsay -- gives 75 Order of Embers or Honorbound rep
[53273]={2161, 2157},		  --Winter's Kiss Cluster -- gives 75 Order of Embers or Honorbound rep
[53287]={2161, 2157},		  --Winter's Kiss Cluster -- gives 75 Order of Embers or Honorbound rep
[53281]={2161, 2157},		  --Winter's Kiss Cluster -- gives 75 Order of Embers or Honorbound rep
[51738]={2157},		  		  --Witches by the Dozen -- gives 75 Honorbound rep (Horde only)
[51682]={2161},		  		  --Witches by the Dozen -- gives 75 Order of Embers rep (Alliance only)

[52424]={2161},		  		  --Work Order: Battle Flag: Rallying Swiftness -- gives 75 Order of Embers rep (Alliance only)
[50991]={2161},		  		  --Work Order: Blood-Stained Bone -- gives 75 Order of Embers rep (Alliance only)
[52390]={2161},		  		  --Work Order: Contract: Order of Embers -- gives 75 Order of Embers rep (Alliance only)
[52414]={2161},		  		  --Work Order: Drums of the Malestrom -- gives 75 Order of Embers rep (Alliance only)
[52357]={2161},		  		  --Work Order: Enchant Weapon: Quick Navigation -- gives 75 Order of Embers rep (Alliance only)
[52365]={2161},		  		  --Work Order: F.R.I.E.D. -- gives 75 Order of Embers rep (Alliance only)
[52407]={2161},		  		  --Work Order: Golden Beryl -- gives 75 Order of Embers rep (Alliance only)
[50987]={2161},		  		  --Work Order: Monelite Ore -- gives 75 Order of Embers rep (Alliance only)
[52334]={2161},		  		  --Work Order: Potion of Concealment -- gives 75 Order of Embers rep (Alliance only)
[52406]={2161},		  		  --Work Order: Rubellite -- gives 75 Order of Embers rep (Alliance only)
[50986]={2161},		  		  --Work Order: Sea Stalk -- gives 75 Order of Embers rep (Alliance only)
[50985]={2161},		  		  --Work Order: Siren's Pollen -- gives 75 Order of Embers rep (Alliance only)
[50994]={2161},		  		  --Work Order: Tempest Hide -- gives 75 Order of Embers rep (Alliance only)
[52364]={2161}		  		  --Work Order: Themo-accelerated Plague Spreader -- gives 75 Order of Embers rep (Alliance only)
}

function GetQuestReps(qID, mID)
	if(UnitFactionGroup("player") == "Horde") then
		if(mID == 862) then	--Zuldazar
			for q, reps in pairs(ZuldazarQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddHordeRepToSum(v);
						end
					end
					zQuests = zQuests + 1;
				end
			end
		elseif(mID == 864) then	--Vol'dun
			for q, reps in pairs(VoldunQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddHordeRepToSum(v);
						end
					end
					vQuests = vQuests + 1;
				end
			end
		elseif(mID == 863) then	--Nazmir
			for q, reps in pairs(NazmirQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddHordeRepToSum(v);
						end
					end
					nQuests = nQuests + 1;
				end
			end
		elseif(mID == 896) then	--Drustvar
			for q, reps in pairs(DrustvarQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddHordeRepToSum(v);
						end
					end
					nQuests = nQuests + 1;
				end
			end
		end
	elseif(UnitFactionGroup("player") == "Alliance") then
		if(mID == 862) then	--Zuldazar
			for q, reps in pairs(ZuldazarQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddAllianceRepToSum(v);
						end
					end
					zQuests = zQuests + 1;
				end
			end
		elseif(mID == 864) then	--Vol'dun
			for q, reps in pairs(VoldunQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddAllianceRepToSum(v);
						end
					end
					vQuests = vQuests + 1;
				end
			end
		elseif(mID == 863) then	--Nazmir
			for q, reps in pairs(NazmirQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddAllianceRepToSum(v);
						end
					end
					nQuests = nQuests + 1;
				end
			end
		elseif(mID == 896) then	--Drustvar
			for q, reps in pairs(DrustvarQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddAllianceRepToSum(v);
						end
					end
					nQuests = nQuests + 1;
				end
			end
		end
	end
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

function AddAllianceRepToSum(re)
	if(re == 2164) then
		CoA = CoA + 125;
	elseif(re == 2161) then
		OoE = OoE + 75;
	elseif(re == 2159) then
		SL = SL + 75;
	elseif(re == 2160) then
		PA = PA + 175;
	elseif(re == 2162) then
		SW = SW + 75;
	elseif(re == 2163) then
		TS = TS + 75;
	--else
		--print(re, "'s reputation does not apply");
	end
end


function OutputHordeRepSums()	
	if(CoA > 0) then
		print("|cFF5DE7FC Champions of Azeroth potential rep: ", CoA);
	end
	if(TE > 0) then
		print("|cFFFF8411 Talanji's Expedition potential rep: ", TE);
	end
	if(HB > 0) then
		print("|cFFBA0707 The Honorbound potential rep: ", HB);
	end
	if(TS > 0) then
		print("|cFF31702A Tortollan Seekers potential rep: ", TS);
	end
	if(Vol > 0) then
		print("|cFF9B8204 Voldunai potential rep: ", Vol);
	end
	if(ZE > 0) then
		print("|cFF16027A Zandalari Empire potential rep: ", ZE);
	end
end

function OutputAllianceRepSums()
	if(CoA > 0) then
		print("|cFF5DE7FC Champions of Azeroth potential rep: ", CoA);
	end
	if(OoE > 0) then
		print("|cFFFF8411 Order of Embers potential rep: ", OoE);
	end
	if(SL > 0) then
		print("|cFFBA0707 7th Legion potential rep: ", SL);
	end
	if(TS > 0) then
		print("|cFF31702A Tortollan Seekers potential rep: ", TS);
	end
	if(PA > 0) then
		print("|cFF9B8204 Proudmoore Admiralty potential rep: ", PA);
	end
	if(SW > 0) then
		print("|cFF16027A Storm's Wake potential rep: ", SW);
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

