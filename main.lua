--USEFUL COMMAND: /dump C_TaskQuest.GetQuestsForPlayerByMapID(862)

local frame = CreateFrame("Frame");
local timer = 0;
local queryAttempts = 0
local mapQuests = {}

SLASH_WORLDQUESTREPORT1 = '/wqr';
function SlashCmdList.WORLDQUESTREPORT(msg, editBox)
	--check if Warmode is active on the character
	if(AuraUtil.FindAuraByName("Enlisted", "player") ~= nil) then
		WM = true
	else
		WM = false
	end

    if(msg == 'show') then
		-- print("HH LEE GOLD:", GetQuestLogRewardMoney(50846));
		-- temp = GetNumQuestLogRewardCurrencies(51043);
		-- print("Literally the first thing I'm doing:", temp);
	
		if(UnitFactionGroup("player") == "Horde") then
			print("|cFFFF0000 CHARACTER CONFIRMED HORDE, ZUG ZUG");
			ParseQuests(875);
			ParseQuests(876);
			ParseQuests(1355);
			CheckContracts();
			AddTokens();
			OutputHordeRepSums();
			OutputGoldTotal();
			OutputCurrencyTotals();
			--print("Num WQs active :", numWQs);
		--Alliance
		elseif(UnitFactionGroup("player") == "Alliance") then
			print("|cFF1f81f2 CHARACTER CONFIRMED ALLIANCE ....ew");
			ParseQuests(875);
			ParseQuests(876);
			ParseQuests(1355);
			CheckContracts();
			AddTokens();
			OutputAllianceRepSums();
			OutputGoldTotal();
			OutputCurrencyTotals();
			--print("Num WQs active :", numWQs);
		end
	elseif(msg == 'az') then
		OnlyCurrencies(875);
		OnlyCurrencies(876);
		OnlyCurrencies(1355);
		OutputAzeriteTotal();
	elseif(msg == 'reps' or msg == 'r') then
		print("SHOWING REPS");
	elseif(msg == 'gold' or msg == 'g') then
		print("SHOWING GOLD");
		OnlyGold(875);
		OnlyGold(876);
		OnlyGold(1355);
		OutputGoldTotal();
	elseif(msg == 'currencies' or msg == 'c') then
		print("SHOWING CURRENCIES");
		OnlyCurrencies(875);
		OnlyCurrencies(876);
		OnlyCurrencies(1355);
		OutputCurrencyTotals();
	elseif(msg == 'help' or msg == 'h') then
		print("'/wqr show' will display reps, gold, azerite, and war resources");
		print("'/wqr c' will (eventually) display azerite and war resources (WIP)");
		print("'/wqr g' will (eventually) display gold (WIP)");
	end
	
	ResetVariables();
end


function ResetVariables()
	numWQs = 0;
	current_QID = 0;
	--Counters for each zone
	zQuests = 0;
	vQuests = 0;
	nQuests = 0;
	dQuests = 0;
	sQuests = 0;
	tQuests = 0;
	contract_rep = 0;
	magni = 0;
	--initialization of currency total variables
	totalAzerite = 0;
	totalMoney = 0;
	totalWarResources = 0;

	--Horde Rep total initialization and ID indices 
	CoA = 0; --Champions of Azeroth rep (ID = 2164)
	tokenCoA = 0;
	TE = 0;  --Talanji's Expedition rep (ID = 2156)
	tokenTE = 0;
	HB = 0;  --The Honorbound rep 		(ID = 2157)
	tokenHB = 0;
	TS = 0;  --Tortollan Seekers rep 	(ID = 2163)
	tokenTS = 0;
	Vol = 0; --Voldunai rep				(ID = 2158)
	tokenVol = 0;
	ZE = 0;  --Zandalari Empire rep 	(ID = 2103)
	tokenZE = 0;
	Uns = 0;
			
	--Alliance Rep total initialization and ID indices 
	OoE = 0; --Order of Embers rep	    (ID = 2161)
	tokenOoE = 0;
	SL = 0; --7th Legion rep 			(ID = 2159)
	tokenSL = 0;
	PA = 0; --Proudmoore Admiralty rep  (ID = 2160)
	tokenPA = 0;
	SW = 0; --Storm's Wake rep 			(ID = 2162)		
	tokenSW = 0;
	Ank = 0;
end


--***INITIALIZATION************************************************************************
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(f, event)
    if event == "PLAYER_LOGIN" then
		if(UnitLevel("player") == 120) then
			--Counter for number of World Quests currently active
			numWQs = 0;
			current_QID = 0;
			--Counters for each zone
			zQuests = 0;
			vQuests = 0;
			nQuests = 0;
			dQuests = 0;
			sQuests = 0;
			tQuests = 0;
			contract_rep = 0;
			magni = 0;
			--initialization of currency total variables
			totalAzerite = 0;
			totalMoney = 0;
			totalWarResources = 0;
			--Warmode boolean
			WM = false;
			
			CurrenciesDone = false;

			--Horde Rep total initialization and ID indices 
			CoA = 0; --Champions of Azeroth rep (ID = 2164)
			tokenCoA = 0;
			TE = 0;  --Talanji's Expedition rep (ID = 2156)
			tokenTE = 0;
			HB = 0;  --The Honorbound rep 		(ID = 2157)
			tokenHB = 0;
			TS = 0;  --Tortollan Seekers rep 	(ID = 2163)
			tokenTS = 0;
			Vol = 0; --Voldunai rep				(ID = 2158)
			tokenVol = 0;
			ZE = 0;  --Zandalari Empire rep 	(ID = 2103)
			tokenZE = 0;
			Uns = 0; --Unshackled rep			(ID = 2373)
			
			
			--Alliance Rep total initialization and ID indices 
			OoE = 0; --Order of Embers rep	    (ID = 2161)
			tokenOoE = 0;
			SL = 0; --7th Legion rep 			(ID = 2159)
			tokenSL = 0;
			PA = 0; --Proudmoore Admiralty rep  (ID = 2160)
			tokenPA = 0;
			SW = 0; --Storm's Wake rep 			(ID = 2162)		
			tokenSW = 0;
			Ank = 0; --Ankoan Waveblade rep 	(ID = 2400)
			
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
			NAZJATAR = 1355 (tentative)
			]]
			--[[
			--CheckAzerite(52169);
			--Horde
			-- if(UnitFactionGroup("player") == "Horde") then
				-- print("|cFFFF0000 CHARACTER CONFIRMED HORDE, ZUG ZUG");
				-- ParseQuests(875);
				-- ParseQuests(876);
				-- CheckContracts();
				-- AddTokens();
				-- OutputHordeRepSums();
				-- print("Num WQs active :", numWQs);
				-- OutputGoldTotal();
				-- OutputCurrencyTotals();
			-- --Alliance
			-- elseif(UnitFactionGroup("player") == "Alliance") then
				-- print("|cFF1f81f2 CHARACTER CONFIRMED ALLIANCE ....ew");
				-- ParseQuests(875);
				-- ParseQuests(876);
				-- CheckContracts();
				-- AddTokens();
				-- OutputAllianceRepSums();
				-- print("Num WQs active :", numWQs);
				-- OutputGoldTotal();
				-- OutputCurrencyTotals();
			-- end
			]]
		else
			print("Level up scrub");
		end
    end
end)


print("WQ Report active! Type '/wqr show' to display all info or '/wqr help' to show a list of commands.");
print("If gold, azerite, or war resources output looks off, input '/wqr show' again (highly suggest just using a macro).");

function ParseQuests(mID)
	if mID == 1355 then
		print("Processing map: ", mapname, " MapID: ", mID);
	end
	--end
	mapname = C_Map.GetMapInfo(mID).name;
	--print("Processing map: ", mapname, " MapID: ", mID);
	mapQuests = C_TaskQuest.GetQuestsForPlayerByMapID(mID);

	
	if mapQuests then
		for i, info in ipairs(mapQuests) do
				current_QID = info.questId;
				if HaveQuestData(current_QID) and QuestUtils_IsQuestWorldQuest(current_QID) then
					--print(GetQuestLink(info.questId), ", questID: ", info.questId, ", mapID: ", info.mapID);
					GetQuestReps(current_QID, info.mapID);
					CheckMoney(current_QID);
					--frame:SetScript("OnUpdate", frame.GetGold);
					CheckCurrencies(current_QID);
					--CheckItemReward(info.questId);
				end
		end
	end
	contract_rep = numWQs * 10;
	CurrenciesDone = true;
	--print("DONE PARSING MAP");
end

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
[53328]={2103, 2159},		  --Dense Storm Silver -- Gives 75 ZE  or 7th L rep
[50875]={2103, 2159},		  --Darkspeaker Jo'la - Gives 75 ZE  or 7th L rep
[48862]={2103, 2159},		  --Disarming the Competetion -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[51373]={2159},		  		  --Ears Everywhere -- gives 75 7th L rep (Alliance only)
[51815]={2159},		  		  --Eggstermination -- gives 75 7th L rep (Alliance only)
[50571]={2103},				  --Eggstermination -- gives 75 ZE rep (Horde only)
[50969]={2159},		 		  --Emergency Management -- gives 75 7th L rep (Alliance only)
[50548]={2103},		 		  --Enforcing the Will of the King -- gives 75 ZE rep (Horde only)
[53302]={2103, 2159},		  --Flourishing Riverbud -- Gives 75 ZE  or 7th L rep
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
[51500]={2103, 2159},		  --Kings' Rest: The Weaponmaster Walks Again -- Gives 75 ZE  or 7th L rep
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
[54166]={2103},		 		  --Set Sail -- gives 75 ZE rep (Horde only)
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
[52169]={2103, 2159},		  --The Matriarch -- Gives 75 ZE  or 7th L rep  -- World Boss(Ji'arak)
[52295]={2103, 2159},		  --The MOTHERLODE!!: Elementals on the Payroll -- Gives 75 ZE  or 7th L rep
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
[52335]={2157},		 		  --Work Order: Demitri's Draught of Deception -- gives 75 HB rep (Horde only)
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
[51105]={2158, 2159},		  --Ak'tar -- gives 75 Vol or 7th L rep
[51095]={2158, 2159},	   	  --Ashmane -- gives 75 Vol or 7th L rep
[51096]={2158, 2159},		  --Azer'tor -- gives 75 Vol or 7th L rep
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
[53299]={2158, 2159},		  --Blooming Siren's Sting -- gives 75 Vol or 7th L rep
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
[51174]={2158},		 		  --Instructions Not Included -- gives 75 Vol rep (Horde only) 
[51928]={2159},		 		  --Instructions Not Included -- gives 75 7th L rep (Alliance only)
[51933]={2159},		 		  --Instructions Not Included -- gives 75 7th L rep (Alliance only)
[51100]={2158, 2159},		  --Jumbo Sandsnapper -- gives 75 Vol or 7th L rep
[51125]={2158, 2159},		  --Jungleweb Hunter -- gives 75 Vol or 7th L rep
[51102]={2158, 2159},		  --Kamid the Trapper -- gives 75 Vol or 7th L rep
[52850]={2158, 2159},		  --Keeyo's Champions of Vol'dun -- gives 75 Vol or 7th L rep -- Battle pet (Keeyo)
[51429]={2158, 2159},		  --King Clickyclack -- gives 75 Vol or 7th L rep
[51252]={2158, 2159},		  --Kiro's Desert Flower -- gives 75 Vol or 7th L rep
[51635]={2103, 2159, 2163},   --Make Loh Go -- Gives 175 TS rep and 75 ZE rep (Northeastern coast of Vol'dun)
[51153]={2158, 2159},		  --Mor'fani the Exile -- gives 75 Vol rep
[51103]={2158, 2159},		  --Nez'ara -- gives 75 Vol or 7th L rep
[51834]={2159},		 		  --No Negotiations -- gives 75 7th L rep (Alliance only)
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
[51379]={2158, 2159},		  --Temple of Sethraliss: Navigating Currents -- gives 75 Vol or 7th L rep
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
[51856]={2156, 2159},		  --The Underrot: Rotmaw -- gives 75 TE or 7th L rep
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
[52862]={2161, 2157, 2164},   --Azerite Empowerment (Rotbough) -- Gives 125 CoA rep and 75 OoE or HB rep
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
[52297]={2161, 2157},		  --What's the Buzz? -- gives 75 Order of Embers or Honorbound rep -- Battle pet (Edwin Malus)
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

local StormsongValleyQuests = {
[52180]={2162},		  		  --A Brennadam Shame -- gives 75 SW rep (Alliance only)
[52935]={2162},		  		  --A New Era -- gives 75 SW rep (Alliance only)
[51855]={2162},		  		  --A Pirate's Life for Me -- gives 75 SW rep (Alliance only)
[52236]={2157},		  		  --A Thorny Problem -- gives 75 Honorbound rep (Horde only)
[52140]={2162},		  		  --A Thorny Problem -- gives 75 SW rep (Alliance only)
[52986]={2157},		  		  --A Wicked Vessel -- gives 75 Honorbound rep (Horde only)
[52940]={2157},		  		  --Arms Deal -- gives 75 Honorbound rep (Horde only)
[52165]={2162, 2157},		  --Automated Chaos -- gives 75 SW or Honorbound rep -- Battle Pet (Eddie Fixit)
[51617]={2162, 2157, 2164},   --Azerite Empowerment (Tidesage Morris) -- Gives 125 CoA rep and 75 SW or HB rep
[52871]={2162, 2157, 2164},   --Azerite Empowerment (Herald Zaxuthril) -- Gives 125 CoA rep and 75 SW or HB rep
[51618]={2162, 2157, 2164},   --Azerite Madness -- Gives 125 CoA rep and 75 SW or HB rep
[51644]={2162, 2157, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75 SW or HB rep
[52873]={2162, 2157, 2164},   --Azerite Mining -- Gives 125 CoA rep and 75 SW or HB rep
[51623]={2162, 2157, 2164},   --Azerite Wounds -- Gives 125 CoA rep and 75 SW or HB rep
[51639]={2162, 2157, 2163},   --Beachhead -- Gives 175 TS rep and 75 SW or HB rep (Western Stormsong Valley)
[52330]={2162, 2157},   	  --Beehemoth -- Gives 75 SW or HB rep
[52865]={2162},		  		  --Blockade Runner -- gives 75 SW rep (Alliance only)
[52063]={2157},		  		  --Boarder Patrol -- gives 75 Honorbound rep (Horde only)
[52045]={2162},		  		  --Boarder Patrol -- gives 75 SW rep (Alliance only)
[52071]={2162},		  		  --Briarback Mountain -- gives 75 SW rep (Alliance only)
[52117]={2157},		  		  --Briarback Mountain -- gives 75 Honorbound rep (Horde only)
[51828]={2157},		  		  --Burning the Legion -- gives 75 Honorbound rep (Horde only)
[51782]={2162, 2157},   	  --Captain Razorspine -- Gives 75 SW or HB rep
[52325]={2162, 2157},   	  --Captured Evil -- Gives 75 SW or HB rep -- Battle pet (Leana Darkwind)
[53106]={2162},		  		  --Censership -- gives 75 SW rep (Alliance only)
[53343]={2157},		  		  --Censership -- gives 75 Honorbound rep (Horde only)
[52882]={2157},		  		  --Controlled Burn -- gives 75 Honorbound rep (Horde only)
[52310]={2162, 2157},   	  --Corrupted Tideskipper -- Gives 75 SW or HB rep
[52004]={2157},		  		  --Counter Intelligence -- gives 75 Honorbound rep (Horde only)
[52306]={2162, 2157},   	  --Croaker -- Gives 75 SW or HB rep
[51901]={2162, 2157},   	  --Crushtacean -- Gives 75 SW or HB rep
[51777]={2162, 2157},   	  --Dagrus the Scorned -- Gives 75 SW or HB rep
[51778]={2162, 2157},   	  --Deepfang -- Gives 75 SW or HB rep
[53317]={2162, 2157},   	  --Dense Storm Silver -- Gives 75 SW or HB rep
[51996]={2157},		  		  --Earthcaller's Abode -- gives 75 Honorbound rep (Horde only)
[51981]={2162},		  		  --Earthcaller's Abode -- gives 75 SW rep (Alliance only)
[53027]={2162, 2157},   	  --Edge of Glory -- Gives 75 SW or HB rep
[52947]={2162},		  		  --Ettin Outta Here -- gives 75 SW rep (Alliance only)
[52011]={2162},		  		  --Fiendish Fields -- gives 75 SW rep (Alliance only)
[52064]={2157},		  		  --Fiendish Fields -- gives 75 Honorbound rep (Horde only)
[51781]={2162, 2157},   	  --Foreman Scripps -- Gives 75 SW or HB rep
[52179]={2162},		  		  --Fortified Resistance -- gives 75 SW rep (Alliance only)
[51776]={2162, 2157},   	  --Galestorm -- Gives 75 SW or HB rep
[52133]={2162, 2157},   	  --Good Boy! -- Gives 75 SW or HB rep
[51779]={2162, 2157},   	  --Grimscowl the Hairbrained -- Gives 75 SW or HB rep
[52463]={2162, 2157},   	  --Haegol the Hammer -- Gives 75 SW or HB rep
[52988]={2162},		  		  --House Cleaning -- gives 75 SW rep (Alliance only)
[51854]={2162},		  		  --I am the Shark -- gives 75 SW rep (Alliance only)
[52328]={2162, 2157},   	  --Ice Sickle -- Gives 75 SW or HB rep
[53108]={2162},		  		  --Iconoclasm -- gives 75 SW rep (Alliance only)
[53344]={2157},		  		  --Iconoclasm -- gives 75 Honorbound rep (Horde only)
[52115]={2157},		  		  --In the Shadow of the Kracken -- gives 75 Honorbound rep (Horde only)
[52168]={2162},		  		  --It's Lit -- gives 75 SW rep (Alliance only)
[52321]={2162, 2157},   	  --Kickers -- Gives 75 SW or HB rep
[52987]={2162},		  		  --Let's Burn! -- gives 75 SW rep (Alliance only)
[52941]={2162},		  		  --Light in the Darkness -- gives 75 SW rep (Alliance only)
[52794]={2162},		  		  --Lizards and Ledgers -- gives 75 SW rep (Alliance only)
[52239]={2157},		  		  --Loose Change -- gives 75 Honorbound rep (Horde only)
[52230]={2162},		  		  --Loose Change -- gives 75 SW rep (Alliance only)
[51633]={2162, 2157, 2163},   --Make Loh Go -- Gives 175 TS rep and 75 SW or HB rep (Western Stormsong Valley)
[52924]={2162},		  		  --Mead Some Help? -- gives 75 SW rep (Alliance only)
[52880]={2162, 2157},   	  --Milden Mud Snout -- Gives 75 SW or HB rep
[52982]={2162},		  		  --Mine or Trouble -- gives 75 SW rep (Alliance only)
[51840]={2157},		  		  --Oily Mess -- gives 75 Honorbound rep (Horde only)
[51820]={2162},		  		  --Oily Mess -- gives 75 SW rep (Alliance only)
[52939]={2162},		  		  --Ordnance Orders -- gives 75 SW rep (Alliance only)
[52464]={2162, 2157},   	  --Osca the Bloodied -- Gives 75 SW or HB rep
[52964]={2162},		  		  --Pest Problem -- gives 75 SW rep (Alliance only)
[51806]={2162, 2157},   	  --Pest Remover Mk II -- Gives 75 SW or HB rep
[51886]={2162, 2157},   	  --Pinku'shon -- Gives 75 SW or HB rep
[52936]={2157},		  		  --Plagued Earth Policy -- gives 75 Honorbound rep (Horde only)
[53107]={2162},		  		  --Plunder and Provisions -- gives 75 SW rep (Alliance only)
[53345]={2157},		  		  --Plunder and Provisions -- gives 75 Honorbound rep (Horde only)
[52474]={2162, 2157},   	  --Poacher Zane -- Gives 75 SW or HB rep
[53012]={2162},		  		  --Put Away Your Toys -- gives 75 SW rep (Alliance only)
[51774]={2162, 2157},   	  --Ragna -- Gives 75 SW or HB rep
[52211]={2162},		  		  --Red Sunrise -- gives 75 SW rep (Alliance only)
[51905]={2162, 2157},   	  --Reinforced Hullbreaker -- Gives 75 SW or HB rep
[52142]={2162},		  		  --Restocking -- gives 75 SW rep (Alliance only)
[52160]={2157},		  		  --Restocking -- gives 75 Honorbound rep (Horde only)
[52979]={2162},		  		  --Ritual Cleansing -- gives 75 SW rep (Alliance only)
--[52199]={2162, 2157},   	  --Rum-Paaaage! -- Gives 75 SW or HB rep -- COMMENTING OUT BECAUSE THIS APPEARS TO BE DEFUNCT
[52164]={2162},   			  --Rum-Paaaage! -- Gives 75 SW rep (Alliance only)
[51976]={2162, 2157},   	  --Sabertron -- Gives 75 SW or HB rep
[51978]={2162, 2157},   	  --Sabertron -- Gives 75 SW or HB rep
[51977]={2162, 2157},   	  --Sabertron -- Gives 75 SW or HB rep
[53008]={2157},		  		  --Sage Wisdom -- gives 75 Honorbound rep (Horde only)
[52309]={2162, 2157},   	  --Sandfang -- Gives 75 SW or HB rep
[52889]={2162, 2157},   	  --Sandscour -- Gives 75 SW or HB rep
[52316]={2162, 2157},   	  --Sea Creatures Are Weird -- Gives 75 SW or HB rep -- Battle pet (Ellie Vern)
[52271]={2162},		  		  --Sea Salt Flavored -- gives 75 SW rep (Alliance only)
[52280]={2157},		  		  --Sea Salt Flavored -- gives 75 Honorbound rep (Horde only)
[51759]={2162, 2157},   	  --Seabreaker Skoloth -- Gives 75 SW or HB rep
[52315]={2162, 2157},   	  --Severus the Outcast -- Gives 75 SW or HB rep
[51627]={2162, 2157, 2163},   --Shell Game -- Gives 175 TS rep and 75 SW or HB rep (Northwestern Stormsong Valley)
[51453]={2162, 2157},   	  --Shrine of the Storm: Behold, Pure Water -- Gives 75 SW or HB rep
[52446]={2162, 2157},   	  --Sister Absinthe -- Gives 75 SW or HB rep
[51921]={2162, 2157},   	  --Slickspill -- Gives 75 SW or HB rep
[52174]={2162},		  		  --Snakes in the Shallows -- gives 75 SW rep (Alliance only)
[50591]={2162},		  		  --Son of a Bee -- gives 75 SW rep (Alliance only)
[52452]={2162, 2157},   	  --Song Mistress Dadalea -- Gives 75 SW or HB rep -- no wowhead info, might be defunct?
[53040]={2162},		  		  --Squall Squelching -- gives 75 SW rep (Alliance only)
[52507]={2162, 2157},   	  --Sticky Mess -- Gives 75 SW or HB rep -- no wowhead info, might be defunct?
[52879]={2162},		  		  --Stiff Policy -- gives 75 SW rep (Alliance only)
[51982]={2162, 2157},   	  --Storm's Rage -- Gives 75 SW or HB rep
[53042]={2157},		  		  --Stormcaller -- gives 75 Honorbound rep (Horde only)
--[52380]={2162, 2157},   	  --Supplies Neded: Frenzied Fangtooth -- Gives 75 SW or HB rep -- COMMENTING OUT DUE TO STRONG POSSIBILITY OF BEING DEFUNCT
[52322]={2162, 2157},   	  --Taja the Tidehowler -- Gives 75 SW or HB rep
[52198]={2162, 2157},   	  --Tank and Spank -- Gives 75 SW or HB rep
[53025]={2162, 2157},   	  --The Culling -- Gives 75 SW or HB rep
[52166]={2162, 2157},   	  --The Faceless Herald -- Gives 75 SW or HB rep -- World Boss
[52476]={2162, 2157},   	  --The Lichen King -- Gives 75 SW or HB rep
[51827]={2157},		  		  --They Came from Behind! -- gives 75 Honorbound rep (Horde only)
[52126]={2162, 2157},   	  --This Little Piggy has Sharp Tusks -- Gives 75 SW or HB rep -- Battle pet (Bristlespine)
[52968]={2157},		  		  --Time for a Little Blood -- gives 75 Honorbound rep (Horde only)
[52054]={2162},		  		  --Too Much to Bear -- gives 75 SW rep (Alliance only)
[52229]={2157},		  		  --Too Much to Bear -- gives 75 Honorbound rep (Horde only)
[51817]={2162},		  		  --Trapped Tortollans -- gives 75 SW rep (Alliance only)
[51811]={2157},		  		  --Trapped Tortollans -- gives 75 Honorbound rep (Horde only)
[52200]={2162},		  		  --Turtle Tactics -- gives 75 SW rep (Alliance only)
[52209]={2157},		  		  --Turtle Tactics -- gives 75 Honorbound rep (Horde only)
[52432]={2162, 2157},   	  --Unrelenting Squall -- Gives 75 SW or HB rep
[52301]={2162, 2157},   	  --Vinespeaker Ratha -- Gives 75 SW or HB rep
[52300]={2162, 2157},   	  --Wagga Snarltusk -- Gives 75 SW or HB rep
[52891]={2162},		  		  --Wendigo To Sleep -- gives 75 SW rep (Alliance only)
[52299]={2162, 2157},   	  --Whiplash -- Gives 75 SW or HB rep
[52459]={2162, 2157},   	  --Whirlwing -- Gives 75 SW or HB rep
[50993]={2162},		  		  --Work Order: Coarse Leather -- gives 75 SW rep (Alliance only)
[52415]={2162},		  		  --Work Order: Coarse Leather Barding -- gives 75 SW rep (Alliance only)
[52367]={2162},		  		  --Work Order: Electroshock Mount Motivator -- gives 75 SW rep (Alliance only)
[52353]={2162},		  		  --Work Order: Enchant Ring - Seal of Haste -- gives 75 SW rep (Alliance only)
[52347]={2162},		  		  --Work Order: Honey-Glazed Haunches -- gives 75 SW rep (Alliance only)
[52344]={2162},		  		  --Work Order: Kul Tiramisu -- gives 75 SW rep (Alliance only)
[52332]={2162},		  		  --Work Order: Lightfoot Potion -- gives 75 SW rep (Alliance only)
[50996]={2162},		  		  --Work Order: Mistscale -- gives 75 SW rep (Alliance only)
[52345]={2162},		  		  --Work Order: Ravenberry Tarts -- gives 75 SW rep (Alliance only)
[50981]={2162},		  		  --Work Order: Riverbud -- gives 75 SW rep (Alliance only)
[52346]={2162},		  		  --Work Order: Sailor's Pie -- gives 75 SW rep (Alliance only)
[50982]={2162},		  		  --Work Order: Star Moss -- gives 75 SW rep (Alliance only)
[50989]={2162},		  		  --Work Order: Storm Silver Ore -- gives 75 SW rep (Alliance only)
[50997]={2162},		  		  --Work Order: Tidespray Linen -- gives 75 SW rep (Alliance only)
[52352]={2162, 2157}   	 	  --Zeritarj -- Gives 75 SW or HB rep
}

local TiragardeSoundQuests = {
[50322]={2160},		  	  	  --A Feathery Fad -- gives 75 PA rep (Alliance only)
[51385]={2160},		  	  	  --A Supply of Stingers -- gives 75 PA rep (Alliance only)
[51610]={2160, 2157},     	  --Adhara White -- Gives 75 PA or HB rep
[52047]={2160},		  	  	  --Against the Storm -- gives 75 PA rep (Alliance only)
[52057]={2157},		  	 	  --Against the Storm -- gives 75 Honorbound rep (Horde only)
[51225]={2160},		  		  --Albatrocity -- gives 75 PA rep (Alliance only)
[51653]={2160, 2157},   	  --Auditor Dolp -- Gives 75 PA or HB rep
[52869]={2160, 2157, 2164},   --Azerite Empowerment (Alchemist Pitts) -- Gives 125 CoA rep and 75 PA or HB rep
[51586]={2160, 2157, 2164},   --Azerite Empowerment (Tidesage Bankson) -- Gives 125 CoA rep and 75 PA or HB rep
[51584]={2160, 2157, 2164},   --Azerite Madness -- Gives 125 CoA rep and PA SW or HB rep
[52874]={2160, 2157, 2164},   --Azerite Mining -- Gives 125 CoA rep and PA SW or HB rep
[51581]={2160, 2157, 2164},   --Azerite Mining -- Gives 125 CoA rep and PA SW or HB rep
[51583]={2160, 2157, 2164},   --Azerite Wounds -- Gives 125 CoA rep and PA SW or HB rep
[51652]={2160, 2157},   	  --Barman Bill -- Gives 75 PA or HB rep
[51666]={2160, 2157},   	  --Bashmu -- Gives 75 PA or HB rep
[51638]={2160, 2157, 2163},   --Beachhead -- Gives 175 TS rep and 75 PA or HB rep (Southeast Tiragarde Sound)
[50296]={2160},		  	  	  --Billy Goat Barber -- gives 75 PA rep (Alliance only)
[51671]={2157},		  	 	  --Billy Goat Barber -- gives 75 Honorbound rep (Horde only)
[51669]={2160, 2157},   	  --Black-Eyed Bart -- Gives 75 PA or HB rep
[51841]={2160, 2157},   	  --Blackthorne -- Gives 75 PA or HB rep
[51613]={2160, 2157},   	  --Bloodmaw -- Gives 75 PA or HB rep
[52755]={2157},		  	 	  --Bringing the Heat -- gives 75 Honorbound rep (Horde only)
[51665]={2160, 2157},   	  --Broodmother Razora -- Gives 75 PA or HB rep
[51848]={2160, 2157},   	  --Captain Wintersail -- Gives 75 PA or HB rep
[51842]={2160, 2157},   	  --Carla Smirk -- Gives 75 PA or HB rep
[51405]={2160},		  	  	  --Corruption in the Bay -- gives 75 PA rep (Alliance only)
[50234]={2160},		  	  	  --Crews of Freehold -- gives 75 PA rep (Alliance only)
[51647]={2157},		  	 	  --Crews of Freehold -- gives 75 Honorbound rep (Horde only)
[51579]={2160},		  	  	  --Dark Ranger Clea -- gives 75 PA rep (Alliance only)
[51577]={2160},		  	  	  --Defending the Academy -- gives 75 PA rep (Alliance only)
[51311]={2160},		  	  	  --Energizing Extract -- gives 75 PA rep (Alliance only)
[51284]={2160},		  	  	  --Falcon Hunt -- gives 75 PA rep (Alliance only)
[50776]={2160},		  	  	  --False Prophets -- gives 75 PA rep (Alliance only)
[52144]={2160},		  	  	  --Foundry Meltdown -- gives 75 PA rep (Alliance only)
[53076]={2157},		  	 	  --Foundry Meltdown -- gives 75 Honorbound rep (Horde only)
[51654]={2160, 2157},   	  --Fowlmouth -- Gives 75 PA or HB rep
[51662]={2160, 2157},   	  --Foxhollow Skyterror -- Gives 75 PA or HB rep
[53188]={2160},		  		  --Frozen Freestyle -- gives 75 PA rep (Alliance only)
[51611]={2160, 2157},   	  --Ghost of the Deep -- Gives 75 PA or HB rep
[52120]={2160},		  		  --Gnomish Azerite Extraction -- gives 75 PA rep (Alliance only)
[52119]={2157},		  		  --Goblin Azerite Extraction -- gives 75 Honorbound rep (Horde only)
[52757]={2157},		  		  --Grimestone Crimes -- gives 75 Honorbound rep (Horde only)
[51317]={2160},		  		  --Grounding the Grimestone -- gives 75 PA rep (Alliance only)
[50299]={2160},		  		  --Gryphon Wranglin' -- gives 75 PA rep (Alliance only)
[51844]={2160, 2157},   	  --Gulliver -- Gives 75 PA or HB rep
[52167]={2160},		  		  --Hardcore Raiders -- gives 75 PA rep (Alliance only)
[52145]={2160},		  		  --Heave-Ho! -- gives 75 PA rep (Alliance only)
[51245]={2160},		  		  --I'm a Lumberjack and I'm Okay -- gives 75 PA rep (Alliance only)
[51664]={2160, 2157},   	  --Kulett the Ornery -- Gives 75 PA or HB rep
[52760]={2157},		  		  --Like Fish in a Barrel -- gives 75 Honorbound rep (Horde only)
[50295]={2160},		  		  --Like Pulling Teeth -- gives 75 PA rep (Alliance only)
[52805]={2157},		  		  --Like Pulling Teeth -- gives 75 Honorbound rep (Horde only)
[52124]={2157},		  		  --Losers Weepers -- gives 75 Honorbound rep (Horde only)
[51670]={2160, 2157},   	  --Lumbergrasp Sentinel -- Gives 75 PA or HB rep
[51895]={2160, 2157},   	  --Maison the Portable -- Gives 75 PA or HB rep
[51632]={2160, 2157, 2163},   --Make Loh Go -- Gives 175 TS rep and 75 PA or HB rep (Northern Tiragarde Sound)
[51659]={2160, 2157},   	  --Merianae -- Gives 75 PA or HB rep
[50315]={2160},		  		  --Not on the Itinerary -- gives 75 PA rep (Alliance only)
[52430]={2160, 2157},   	  --Not So Bad Down Here -- Gives 75 PA or HB rep -- Battle pet (Kwint)
[51843]={2160, 2157},   	  --P4-N73R4 -- Gives 75 PA or HB rep
[51660]={2160, 2157},   	  --Pack Leader Asenya -- Gives 75 PA or HB rep
[51462]={2157},		  		  --Paratroopers -- gives 75 Honorbound rep (Horde only)
[51092]={2160},		  		  --Picturesque Boralus -- gives 75 PA rep (Alliance only)
[50324]={2160},		  		  --Picturesque Fizzsprings Resort -- gives 75 PA rep (Alliance only)
[51090]={2160},		  		  --Picturesque Norwington Estate -- gives 75 PA rep (Alliance only)
[51646]={2157},		  		  --Polly Want a Cracker? -- gives 75 Honorbound rep (Horde only)
[50164]={2160},		  		  --Polly Want a Cracker? -- gives 75 PA rep (Alliance only)
[51661]={2160, 2157},   	  --Raging Swell -- Gives 75 PA or HB rep
[51890]={2160, 2157},   	  --Ranja the Last Chillpaw -- Gives 75 PA or HB rep
[51580]={2157},		  		  --Rear Admiral Hainsworth -- gives 75 Honorbound rep (Horde only)
[51566]={2160, 2157},   	  --Resurgence of the Beast -- Gives 75 PA or HB rep -- MIGHT be Alliance only?
[51656]={2160, 2157},   	  --Saurolisk Tamer Mugg -- Gives 75 PA or HB rep
[51893]={2160, 2157},   	  --Sawtooth -- Gives 75 PA or HB rep
[51626]={2160, 2157, 2163},   --Shell Game -- Gives 175 TS rep and 75 PA or HB rep (Central Tiragarde Sound)
[51892]={2160, 2157},   	  --Shiverscale the Toxic -- Gives 75 PA or HB rep
[53331]={2160},		  		  --Show-Off -- gives 75 PA rep (Alliance only)
[51463]={2157},		  		  --Sky Drop Rescue -- gives 75 Honorbound rep (Horde only)
[53189]={2160},		  		  --Slippery Slopes -- gives 75 PA rep (Alliance only)
[52143]={2160},		  		  --Smaller Haulers -- gives 75 PA rep (Alliance only)
[50977]={2160},		  		  --Smuggler Shakedown -- gives 75 PA rep (Alliance only)
[52756]={2157},		  		  --Snow Way Out -- gives 75 Honorbound rep (Horde only)
[52804]={2157},		  		  --Something Stirs in the Depths -- gives 75 Honorbound rep (Horde only)
[50421]={2160},		  		  --Sparring on the Spar -- gives 75 PA rep (Alliance only)
[51651]={2160, 2157},   	  --Squacks -- Gives 75 PA or HB rep
[51839]={2160, 2157},   	  --Squirgle of the Depths -- Gives 75 PA or HB rep
[51388]={2160},		  		  --Stopping the Infestation -- gives 75 PA rep (Alliance only)
[52751]={2160, 2157},   	  --Strange Looking Dogs -- Gives 75 PA or HB rep -- Battle pet (Burly)
[51024]={2159},		  		  --Supplies Needed: Akunda's Bite -- gives 75 7L rep (Alliance only)
[51028]={2159},		  		  --Supplies Needed: Blood-Stained Bone -- gives 75 7L rep (Alliance only)
[51029]={2159},		  		  --Supplies Needed: Calcified Bone -- gives 75 7L rep (Alliance only)
[51030]={2159},		  		  --Supplies Needed: Coarse Leather -- gives 75 7L rep (Alliance only)
[51035]={2159},		  		  --Supplies Needed: Deep Sea Satin -- gives 75 7L rep (Alliance only)
[52375]={2159},		  		  --Supplies Needed: Great Sea Catfish -- gives 75 7L rep (Alliance only)
[51033]={2159},		  		  --Supplies Needed: Mistscale -- gives 75 7L rep (Alliance only)
[51017]={2159},		  		  --Supplies Needed: Monelite Ore -- gives 75 7L rep (Alliance only)
[52379]={2159},		  		  --Supplies Needed: Redtail Loach -- gives 75 7L rep (Alliance only)
[51022]={2159},		  		  --Supplies Needed: Riverbud -- gives 75 7L rep (Alliance only)
[52376]={2159},		  		  --Supplies Needed: Sand Shifter -- gives 75 7L rep (Alliance only)
[51027]={2159},		  		  --Supplies Needed: Sea Stalk -- gives 75 7L rep (Alliance only)
[51032]={2159},		  		  --Supplies Needed: Shimmerscale -- gives 75 7L rep (Alliance only)
[51026]={2159},		  		  --Supplies Needed: Siren's Pollen -- gives 75 7L rep (Alliance only)
[52378]={2159},		  		  --Supplies Needed: Slimy Mackerel -- gives 75 7L rep (Alliance only)
[51023]={2159},		  		  --Supplies Needed: Star Moss -- gives 75 7L rep (Alliance only)
[51021]={2159},		  		  --Supplies Needed: Storm Silver Ore -- gives 75 7L rep (Alliance only)
[51031]={2159},		  		  --Supplies Needed: Tempest Hide -- gives 75 7L rep (Alliance only)
[51034]={2159},		  		  --Supplies Needed: Tidespray Linen -- gives 75 7L rep (Alliance only)
[52377]={2160},		  		  --Supplies Needed: Tiragarde Perch -- gives 75 PA rep (Alliance only) --DOUBLE CHECK WHEN POSSIBLE
[51025]={2159},		  		  --Supplies Needed: Winter's Kiss -- gives 75 7L rep (Alliance only)
[52159]={2160},		  		  --Swab This! -- gives 75 PA rep (Alliance only)
[53196]={2157},		  		  --Swab This! -- gives 75 Honorbound rep (Horde only)
[51891]={2160, 2157},   	  --Sythian the Swift -- Gives 75 PA or HB rep
[50792]={2160},		  		  --Taking Bribes -- gives 75 PA rep (Alliance only)
[51849]={2160, 2157},   	  --Tempestria -- Gives 75 PA or HB rep
[51894]={2160, 2157},   	  --Tentulos the Drifter -- Gives 75 PA or HB rep
[51655]={2160, 2157},   	  --Teres -- Gives 75 PA or HB rep
[52471]={2160, 2157},   	  --That's a Big Carcass -- Gives 75 PA or HB rep -- Battle pet (Delia Hanako)
[51241]={2160},		  		  --The Bear Witch Project -- gives 75 PA rep (Alliance only)
[51406]={2160},		  		  --The Lord's Hunt -- gives 75 PA rep (Alliance only)
[50767]={2160},		  		  --The Scrimshaw Gang -- gives 75 PA rep (Alliance only)
[51578]={2157},		  		  --The Sea Runs Red -- gives 75 Honorbound rep (Horde only)
[52010]={2160},		  		  --The Tendrils of Fate -- gives 75 PA rep (Alliance only)
[52056]={2157},		  		  --The Tendrils of Fate -- gives 75 Honorbound rep (Horde only)
[52163]={2160, 2157},   	  --The Winged Typhoon -- Gives 75 PA or HB rep -- World Boss (Azurethos)
[51622]={2157},		  		  --Tidal Teachings -- gives 75 Honorbound rep (Horde only)
[51621]={2160},		  		  --Tidal Teaching -- gives 75 PA rep (Alliance only)
[51847]={2160, 2157},   	  --Tort Jaw -- Gives 75 PA or HB rep
[53078]={2157},		  		  --Treasure in the Tides -- gives 75 Honorbound rep (Horde only)
[52155]={2160},		  		  --Treasure in the Tides -- gives 75 PA rep (Alliance only)
[53346]={2160},		  		  --Trogg Tromping -- gives 75 PA rep (Alliance only)
[51657]={2160, 2157},   	  --Twin-Hearted Construct -- Gives 75 PA or HB rep
[52455]={2160, 2157},   	  --Unbreakable -- Gives 75 PA or HB rep -- Battle pet (Chitara)
[52752]={2157},		  		  --Vigilant Lookouts -- gives 75 Honorbound rep (Horde only)
[50958]={2160},		  		  --Watch Your Wallets -- gives 75 PA rep (Alliance only)
[51758]={2160},		  		  --Weapons Shipment -- gives 75 PA rep (Alliance only)
[50983]={2160},		  		  --Work Order: Akunda's Bite -- gives 75 PA rep (Alliance only)
[52423]={2160},		  		  --Work Order: Battle Flag: Phalanx Defense -- gives 75 PA rep (Alliance only)
[50992]={2160},		  		  --Work Order: Calcified Bone -- gives 75 PA rep (Alliance only)
[52389]={2160},		  		  --Work Order: Contract: Proudmoore Admiralty -- gives 75 PA rep (Alliance only)
[52368]={2159},		  		  --Work Order: Crow's Nest Scope -- gives 75 7L rep (Alliance only)
[50998]={2160},		  		  --Work Order: Deep Sea Satin -- gives 75 PA rep (Alliance only)
[52331]={2159},		  		  --Work Order: Demitri's Draught of Deception -- gives 75 7L rep (Alliance only)
[52355]={2160},		  		  --Work Order: Enchant Weapon: Coastal Surge -- gives 75 PA rep (Alliance only)
[52356]={2160},		  		  --Work Order: Enchant Weapon: Torrent of Elements -- gives 75 PA rep (Alliance only)
[52363]={2159},		  		  --Work Order: Incendiary Ammunition -- gives 75 7L rep (Alliance only)
[52405]={2160},		  		  --Work Order: Kubiline -- gives 75 PA rep (Alliance only)
[52340]={2159},		  		  --Work Order: Monelite-Hardened Hoofplates -- gives 75 7L rep (Alliance only)
[52339]={2159},		  		  --Work Order: Monelite-Hardened Stirrups -- gives 75 7L rep (Alliance only)
[52333]={2160},		  		  --Work Order: Sea Mist Potion -- gives 75 PA rep (Alliance only)
[52417]={2160},		  		  --Work Order: Shimmerscale Diving Helmet -- gives 75 PA rep (Alliance only)
[52416]={2160},		  		  --Work Order: Shimmerscale Diving Suit -- gives 75 PA rep (Alliance only)
[52404]={2160},		  		  --Work Order: Solstone -- gives 75 PA rep (Alliance only)
[52392]={2159},		  		  --Work Order: Ultramarine Pigment -- gives 75 7L rep (Alliance only)
[50984]={2160}		  		  --Work Order: Winter's Kiss -- gives 75 PA rep (Alliance only)
}

local NazjatarQuests = {
--Ankoan Waveblade (Alliance) profession turn-ins
[56795]={2400},				  --Work Order: Abyssal-Fried Rissole -- gives 75 Ankoan rep (Alliance Only)
[56794]={2400},				  --Work Order: Baked Port Tato -- gives 75 Ankoan rep (Alliance Only)
[56797]={2400},				  --Work Order: Bil'Tong -- gives 75 Ankoan rep (Alliance Only)
[56796]={2400},				  --Work Order: Fragrant Kakavia -- gives 75 Ankoan rep (Alliance Only)
[56793]={2400},				  --Work Order: Mech-Dowel's "Big Mech" -- gives 75 Ankoan rep (Alliance Only)
[56826]={2400},				  --Work Order: Enchant Weapon - Force Multiplier -- gives 75 Ankoan rep (Alliance Only)
[56824]={2400},				  --Work Order: Enchant Weapon - Machinist's Brilliance -- gives 75 Ankoan rep (Alliance Only)
[56827]={2400},				  --Work Order: Enchant Weapon - Naga Hide -- gives 75 Ankoan rep (Alliance Only)
[56825]={2400},				  --Work Order: Enchant Weapon - Oceanic Restoration -- gives 75 Ankoan rep (Alliance Only)
[56767]={2400},				  --Work Order: Greater Flask of Endless Fathoms -- gives 75 Ankoan rep (Alliance Only)
[56570]={2400},				  --Work Order: Greater Flask of the Currents -- gives 75 Ankoan rep (Alliance Only)
[56768]={2400},				  --Work Order: Greater Flask of the Undertow -- gives 75 Ankoan rep (Alliance Only)
[56769]={2400},				  --Work Order: Greater Flask of the Vast Horizon -- gives 75 Ankoan rep (Alliance Only)
--Unshackled (Horde) profession turn-ins
[56800]={2373},				  --Work Order: Abyssal-Fried Rissole -- gives 75 Unshackled rep (Horde Only)
[56801]={2373},				  --Work Order: Baked Port Tato -- gives 75 Unshackled rep (Horde Only)
[56798]={2373},				  --Work Order: Bil'Tong -- gives 75 Unshackled rep (Horde Only)
[56799]={2373},				  --Work Order: Fragrant Kakavia -- gives 75 Unshackled rep (Horde Only)
[56802]={2373},				  --Work Order: Mech-Dowel's "Big Mech" -- gives 75 Unshackled rep (Horde Only)
[56820]={2373},				  --Work Order: Enchant Weapon - Force Multiplier -- gives 75 Unshackled rep (Horde Only)
[56821]={2373},				  --Work Order: Enchant Weapon - Machinist's Brilliance -- gives 75 Unshackled rep (Horde Only)
[56818]={2373},				  --Work Order: Enchant Weapon - Naga Hide -- gives 75 Unshackled rep (Horde Only)
[56819]={2373},				  --Work Order: Enchant Weapon - Oceanic Restoration -- gives 75 Unshackled rep (Horde Only)
[56772]={2373},				  --Work Order: Greater Flask of Endless Fathoms -- gives 75 Unshackled rep (Horde Only)
[56770]={2373},				  --Work Order: Greater Flask of the Currents -- gives 75 Unshackled rep (Horde Only)
[56774]={2373},				  --Work Order: Greater Flask of the Undertow -- gives 75 Unshackled rep (Horde Only)
[56773]={2373},				  --Work Order: Greater Flask of the Vast Horizon -- gives 75 Unshackled rep (Horde Only)
--World Bosses
[56057]={2373, 2400},		  --The Soulbinder -- gives 75 Unshackled or Ankoan rep
[56056]={2373, 2400},		  --Terror of the Depths -- gives 75 Unshackled or Ankoan rep
--"Champion" World Quests
[55888]={2373, 2400},		  --Champion Qalina, Spear of Ice -- gives 75 Unshackled or Ankoan rep 
[55889]={2373, 2400},		  --Champion Kyx'zhul, the Deepspeaker -- gives 75 Unshackled or Ankoan rep 
[55892]={2373, 2400},		  --Champion Eldanar, Shield of Her Glory -- gives 75 Unshackled or Ankoan rep 
[55890]={2373, 2400},		  --Champion Vyz'olgo the Mind-Taker -- gives 75 Unshackled or Ankoan rep 
[55887]={2373, 2400},		  --Champion Alzana, Arrow of Thunder -- gives 75 Unshackled or Ankoan rep 
[55891]={2373, 2400},		  --Champion Aldrantiss, Defender of Her Kingdom -- gives 75 Unshackled or Ankoan rep 
--Leylocked Chest World Quests
[56023]={2373, 2400},		  --Leylocked Chest -- gives 75 Unshackled or Ankoan rep
[56024]={2373, 2400},		  --Leylocked Chest -- gives 75 Unshackled or Ankoan rep
[56025]={2373, 2400},		  --Leylocked Chest -- gives 75 Unshackled or Ankoan rep
--Runelocked Chest World Quests
[56022]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56013]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56003]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56021]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56017]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56011]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56007]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56006]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56008]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56009]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56016]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56012]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56015]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56010]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56019]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56020]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56018]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
[56014]={2373, 2400},		  --Runelocked Chest -- gives 75 Unshackled or Ankoan rep
--Battle Pet World Quests
[56382]={2373, 2400},		  --Chomp -- gives 75 Unshackled or Ankoan rep
[56386]={2373, 2400},		  --Elderspawn of Nalaada -- gives 75 Unshackled or Ankoan rep
[56391]={2373, 2400},		  --Frenzied Knifefang -- gives 75 Unshackled or Ankoan rep
[56392]={2373, 2400},		  --Giant Opaline Conch -- gives 75 Unshackled or Ankoan rep
[56389]={2373, 2400},		  --Kelpstone -- gives 75 Unshackled or Ankoan rep
[56388]={2373, 2400},		  --Mindshackle -- gives 75 Unshackled or Ankoan rep
[56385]={2373, 2400},		  --Pearlhusk Crawler -- gives 75 Unshackled or Ankoan rep
[56381]={2373, 2400},		  --Prince Wiggletail -- gives 75 Unshackled or Ankoan rep
[56387]={2373, 2400},		  --Ravenous Scalespawn -- gives 75 Unshackled or Ankoan rep
[56384]={2373, 2400},		  --Shadowspike Lurker -- gives 75 Unshackled or Ankoan rep
[56383]={2373, 2400},		  --Silence -- gives 75 Unshackled or Ankoan rep
[56390]={2373, 2400},		  --Voltgorger -- gives 75 Unshackled or Ankoan rep
--"Neutral" World Quests
[55900]={2373, 2400},		  --Kassar, Wielder of Dark Blades -- gives 75 Unshackled or Ankoan rep
[55896]={2373, 2400},		  --Undana, Chilling Assassin -- gives 75 Unshackled or Ankoan rep
[55893]={2373, 2400},		  --Azanz, the Slitherblade -- gives 75 Unshackled or Ankoan rep
[55899]={2373, 2400},		  --Starseeker of the Shirakess -- gives 75 Unshackled or Ankoan rep
[55886]={2373, 2400},		  --The Zanj'ir Brutalizer -- gives 75 Unshackled or Ankoan rep
[55898]={2373, 2400},		  --Tempest-Speaker Shalan'ali -- gives 75 Unshackled or Ankoan rep
[55894]={2373, 2400},		  --Zoko, Her Iron Defender -- gives 75 Unshackled or Ankoan rep
[55895]={2373, 2400},		  --Frozen Winds of Zhiela -- gives 75 Unshackled or Ankoan rep
[55897]={2373, 2400},		  --Szun, Breaker of Slaves -- gives 75 Unshackled or Ankoan rep
[56078]={2373, 2400},		  --Time to Krill -- gives 75 Unshackled or Ankoan rep
[55997]={2373, 2400},		  --Hungry Hungry Hydras -- gives 75 Unshackled or Ankoan rep
[55982]={2373, 2400},		  --The Lords of Water -- gives 75 Unshackled or Ankoan rep
[57353]={2373, 2400},		  --Deepcoil Cleansing -- gives 75 Unshackled or Ankoan rep
[55973]={2373, 2400},		  --Deepcoil Experiments -- gives 75 Unshackled or Ankoan rep
[56048]={2373, 2400},		  --The Drowned Oracles -- gives 75 Unshackled or Ankoan rep
[56121]={2373, 2400},		  --Jumping Jellies -- gives 75 Unshackled or Ankoan rep
[57330]={2373, 2400},		  --Time for Revenge -- gives 75 Unshackled or Ankoan rep
[57354]={2373, 2400},		  --Overdue -- gives 75 Unshackled or Ankoan rep
[57333]={2373, 2400},		  --Terrace Terrors -- gives 75 Unshackled or Ankoan rep
[57334]={2373, 2400},		  --Cave of Murlocs -- gives 75 Unshackled or Ankoan rep
[56032]={2373, 2400},		  --Dirty Dozen -- gives 75 Unshackled or Ankoan rep
[56041]={2373, 2400},		  --Give 'Em Shell -- gives 75 Unshackled or Ankoan rep
[56036]={2373, 2400},		  --A Steamy Situation -- gives 75 Unshackled or Ankoan rep
[57336]={2373, 2400},		  --Putting the Past to Rest -- gives 75 Unshackled or Ankoan rep
[57340]={2373, 2400},		  --Fathrom Ray Feast -- gives 75 Unshackled or Ankoan rep
[57335]={2373, 2400},		  --Murloc Mayhem -- gives 75 Unshackled or Ankoan rep
[57338]={2373, 2400},		  --Depopulation Effort -- gives 75 Unshackled or Ankoan rep
[55884]={2373, 2400},		  --Infestation of Madness -- gives 75 Unshackled or Ankoan rep
[55970]={2373, 2400},		  --Attrition -- gives 75 Unshackled or Ankoan rep
[57331]={2373, 2400}		  --Salvage Operations -- gives 75 Unshackled or Ankoan rep
}


function OnlyGold(mID)
	mapname = C_Map.GetMapInfo(mID).name;
	--print("Processing map: ", mapname, " MapID: ", mID);
	mapQuests = C_TaskQuest.GetQuestsForPlayerByMapID(mID);
	
	if mapQuests then
		for i, info in ipairs(mapQuests) do
				if HaveQuestData(info.questId) and QuestUtils_IsQuestWorldQuest(info.questId) then
					CheckMoney(info.questId);
				end
		end
	end
end

function CheckMoney(questID)
	--print("SPAM:", GetQuestLink(questID));
	questMoney = GetQuestLogRewardMoney(questID);
	if(questMoney ~= 0) then
		totalMoney = totalMoney + questMoney;
		--print("ADDING MANNIES, NEW TOTAL:", totalMoney);
	end
end

--[[
function frame:GetGold(elapsed)
	timer = timer + elapsed
		
	if (timer >= 0.1) then -- 0.1 sec delay
		timer = 0
		rewardMoney = GetQuestLogRewardMoney(current_QID)
		print("ATTEMPT");
		if(rewardMoney > 0)	then
			print("QUEST DOES GIVE MONEY");
		end
		queryAttempts = queryAttempts + 1;
	end
	
	if(rewardMoney > 0 or queryAttempts > 10) then
		print("REWARD MONEY:", rewardMoney);
		print("NUM ATTEMPTS:", queryAttempts);
		frame:SetScript("OnUpdate", nil);
		if(rewardMoney > 0)	then
			print("QUEST GIVES:", rewardMoney);
		elseif(queryAttempts > 10) then
			print("Done checking, no gold found");
		end
		print("GET GOLD COMPLETE");
	end
	
end
]]

function OutputGoldTotal()
	--print("Unprocessed money= ", totalMoney);
	
	if(WM == true) then
		totalMoney = totalMoney * 1.1;
	end
	
	gold = totalMoney/10000;
	--print("Gold: ", gold);
	gold = math.floor(gold);
	silver = (totalMoney - (gold * 10000)) / 100;
	silver = math.floor(silver);
	
	
	print(gold, "gold,", silver, "silver available from WQs");
end



function OnlyCurrencies(mID)
	mapname = C_Map.GetMapInfo(mID).name;
	--print("Processing map: ", mapname, " MapID: ", mID);
	mapQuests = C_TaskQuest.GetQuestsForPlayerByMapID(mID);
	
	if mapQuests then
		for i, info in ipairs(mapQuests) do
				if HaveQuestData(info.questId) and QuestUtils_IsQuestWorldQuest(info.questId) then
					CheckCurrencies(info.questId);
				end
		end
	end
end

function CheckCurrencies(questID)
	local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID)

	if numQuestCurrencies > 0 then
		for currencyNum = 1, numQuestCurrencies do 
			
			local name, texture, numItems, currencyID = GetQuestLogRewardCurrencyInfo(currencyNum, questID)
			--Azerite currency ID = 1553
			if currencyID == 1553 then
				--print(GetQuestLink(questID), " HAS AZERITE REWARD: ", numItems);
				totalAzerite = totalAzerite + numItems;
			--War Resources currency ID = 1560
			elseif currencyID == 1560 then
				--print(GetQuestLink(questID), " HAS WAR RESOURCES REWARD: ", numItems);
				totalWarResources = totalWarResources + numItems;
			
			--Tortollan Seekers rep token ID = 1598
			elseif currencyID == 1598 then
				tokenTS = tokenTS + numItems;
			--Champions of Azeroth rep token ID = 1579
			elseif currencyID == 1579 then
				tokenCoA = tokenCoA + numItems;
			--Horde rep tokens
			elseif(UnitFactionGroup("player") == "Horde") then
				--Talanji's Expedition rep token ID = 1595
				if currencyID == 1595 then
					tokenTE = tokenTE + numItems;
				--Honorbound rep token ID = 1600
				elseif currencyID == 1600 then
					tokenHB = tokenHB + numItems;
				--Voldunai rep token ID = 1596
				elseif currencyID == 1596 then
					tokenVol = tokenVol + numItems;
				--Zandalari Empire rep token ID = 1597
				elseif currencyID == 1597 then
					tokenZE = tokenZE + numItems;
				end
			elseif(UnitFactionGroup("player") == "Alliance") then
				--Order of Embers rep token ID = 1592
				if currencyID == 1592 then
					tokenOoE = tokenOoE + numItems;
				--7th Legion rep token ID = 1599
				elseif currencyID == 1599 then
					tokenSL = tokenSL + numItems;
				--Proudmoore Admiralty rep token ID = 1593
				elseif currencyID == 1593 then
					tokenPA = tokenPA + numItems;
				--Storm's Wake rep token ID = 1594
				elseif currencyID == 1594 then
					tokenSW = tokenSW + numItems;
				end
			end
		end
	end
	CurrenciesDone = true;
end

function OutputCurrencyTotals()
	if(CurrenciesDone == true) then
		if(WM == true) then
			totalAzerite = totalAzerite * 1.1;
			totalWarResources = totalWarResources * 1.1;
		end
		totalAzerite = math.floor(totalAzerite);
		totalWarResources = math.floor(totalWarResources);
		
		print(totalAzerite, "Azerite available from WQs");
		print(totalWarResources, "War Resources available from WQs");
	else
		print("CURRENCIES NOT COMPLETED IN TIME");
	end
end

function OutputAzeriteTotal()
	if(CurrenciesDone == true) then
		if(WM == true) then
			totalAzerite = totalAzerite * 1.1;
		end
		totalAzerite = math.floor(totalAzerite);
		
		print(totalAzerite, "Azerite available from WQs");
	else
		print("CURRENCIES NOT COMPLETED IN TIME");
	end
end



function CheckItemReward(questID)
	local numQuestRewards = GetNumQuestLogRewards(questID)
	if numQuestRewards > 0 then
		local itemName, itemTexture, quantity, quality, isUsable, itemID = GetQuestLogRewardInfo(1, questID)
		local _, itemLink, _, itemLevel, _, _, _, _, _, _, _, _, _ = GetItemInfo(itemID)
		
		i = Item:CreateFromItemID(itemID);
		effectiveILvl, _, _ = GetDetailedItemLevelInfo(itemID);
		
		linkString = gsub(itemLink, "\124", "\124\124");
		
		local _, itemID, enchantID, gemID1, gemID2, gemID3, gemID4, suffixID, uniqueID, linkLevel, specializationID, upgradeTypeID, instanceDifficultyID, numBonusIDs = strsplit(":", linkString);
		--local tempString, unknown1, unknown2, unknown3 = strmatch(itemString, "item:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:([-:%d]+):([-%d]-):([-%d]-):([-%d]-)|")
		--local bonusIDs, upgradeValue;
		
		-- if upgradeTypeID and upgradeTypeID ~= "" then
			-- upgradeValue = tempString:match("[-:%d]+:([-%d]+)")
			-- bonusIDs = {strsplit(":", tempString:match("([-:%d]+):"))}
		-- else
			-- bonusIDs = {strsplit(":", tempString)}
		-- end
				
		--print(itemName, " numBonusIds:", numBonusIds);
	end

end


function AddTokens()
	if(UnitFactionGroup("player") == "Horde") then
		if(tokenTE ~= 0) then
			TE = TE + tokenTE;
		end	
		if(tokenHB ~= 0) then
			HB = HB + tokenHB;
		end
		if(tokenVol ~= 0) then
			Vol = Vol + tokenVol;
		end		
		if(tokenZE ~= 0) then
			ZE = ZE + tokenZE;
		end	
	elseif(UnitFactionGroup("player") == "Alliance") then
		if(tokenOoE ~= 0) then
			OoE = OoE + tokenOoE;
		end
		if(tokenSL ~= 0) then
			SL = SL + tokenSL;
		end
		if(tokenPA ~= 0) then
			PA = PA + tokenPA;
		end
		if(tokenSW ~= 0) then
			SW = SW + tokenSW;
		end		
	end
	--Neutral reps
	if(tokenCoA ~= 0) then
			CoA = CoA + tokenCoA;
			--print("Champions of Azeroth rep from tokens:", tokenCoA);
	end	
	if(tokenTS ~= 0) then
		TS = TS + tokenTS;
		--print("Tortollan Seekers rep from tokens:", tokenTS);
	end
end



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
					--print(GetQuestLink(qID), "'s quest ID: ", qID);
					numWQs = numWQs + 1;
					zQuests = zQuests + 1;
				end
			end
		elseif(mID == 864) then	--Vol'dun
			for q, reps in pairs(VoldunQuests) do
				if(q == qID) then
					--print(GetQuestLink(qID));
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddHordeRepToSum(v, qID);
						end
					end
					--print(GetQuestLink(qID), "'s quest ID: ", qID);
					numWQs = numWQs + 1;
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
					--print(GetQuestLink(qID), "'s quest ID: ", qID);
					numWQs = numWQs + 1;
					nQuests = nQuests + 1;
				end
			end
		elseif(mID == 896) then	--Drustvar
			for q, reps in pairs(DrustvarQuests) do
				if(q == qID) then
					--print(GetQuestLink(qID));
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddHordeRepToSum(v);
						end
					end
					numWQs = numWQs + 1;
					dQuests = dQuests + 1;
				end
			end
		elseif(mID == 942) then	--Stormsong Valley
			for q, reps in pairs(StormsongValleyQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddHordeRepToSum(v);
						end
					end
					numWQs = numWQs + 1;
					sQuests = sQuests + 1;
				end
			end
		elseif(mID == 895) then	--Tiragarde Sound
			for q, reps in pairs(TiragardeSoundQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddHordeRepToSum(v);
						end
					end
					numWQs = numWQs + 1;
					tQuests = tQuests + 1;
				end
			end
		elseif(mID == 1355) then	--Nazjatar
			for q, reps in pairs(NazjatarQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddHordeRepToSum(v);
						end
					end
					numWQs = numWQs + 1;
					tQuests = tQuests + 1;
				end
			end
		end
	--*******************************ALLIANCE SIDE************************************
	elseif(UnitFactionGroup("player") == "Alliance") then
		if(mID == 862) then	--Zuldazar
			for q, reps in pairs(ZuldazarQuests) do
				if(q == qID) then
					--print(GetQuestLink(qID));
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddAllianceRepToSum(v);
						end
					end
					numWQs = numWQs + 1;
					zQuests = zQuests + 1;
				end
			end
		elseif(mID == 864) then	--Vol'dun
			for q, reps in pairs(VoldunQuests) do
				if(q == qID) then
					--print(GetQuestLink(qID));
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddAllianceRepToSum(v);
						end
					end
					numWQs = numWQs + 1;
					vQuests = vQuests + 1;
				end
			end
		elseif(mID == 863) then	--Nazmir
			for q, reps in pairs(NazmirQuests) do
				if(q == qID) then
					--print(GetQuestLink(qID));
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddAllianceRepToSum(v);
						end
					end
					numWQs = numWQs + 1;
					nQuests = nQuests + 1;
				end
			end
		elseif(mID == 896) then	--Drustvar
			for q, reps in pairs(DrustvarQuests) do
				if(q == qID) then
					--print(GetQuestLink(qID));
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddAllianceRepToSum(v);
						end
					end
					numWQs = numWQs + 1;
					dQuests = dQuests + 1;
				end
			end
		elseif(mID == 942) then	--Stormsong Valley
			for q, reps in pairs(StormsongValleyQuests) do
				if(q == qID) then
					--print(GetQuestLink(qID), "ID:", qID);
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddAllianceRepToSum(v);
						end
					end
					numWQs = numWQs + 1;
					sQuests = sQuests + 1;
				end
			end
		elseif(mID == 895) then	--Tiragarde Sound
			for q, reps in pairs(TiragardeSoundQuests) do
				if(q == qID) then
					if(type(reps) == "table") then
						for k, v in pairs(reps) do
							AddAllianceRepToSum(v);
						end
					end
					numWQs = numWQs + 1;
					tQuests = tQuests + 1;
				end
			end
		end
	end
end

function AddHordeRepToSum(re)
	if(re == 2164) then
		CoA = CoA + 125;
		magni = magni + 1;
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
	elseif(re == 2373) then
		Uns = Uns + 75;
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
		PA = PA + 75;
	elseif(re == 2162) then
		SW = SW + 75;
	elseif(re == 2163) then
		TS = TS + 175;
	elseif(re == 2400) then
		Ank = Ank + 75;
	--else
		--print(re, "'s reputation does not apply");
	end
end


function OutputHordeRepSums()	
	if(CoA > 0) then
		if(tokenCoA ~= 0)then
			print("|cFF5DE7FC Champions of Azeroth potential rep: ", CoA, "(", tokenCoA, "from tokens)");
		else
			print("|cFF5DE7FC Champions of Azeroth potential rep: ", CoA);
		end
	end
	if(TE > 0) then
		if(tokenTE ~= 0) then
			print("|cFFFF8411 Talanji's Expedition potential rep: ", TE, "(", tokenTE, "from tokens)");
		else
			print("|cFFFF8411 Talanji's Expedition potential rep: ", TE);
		end
	end
	if(HB > 0) then
		if(tokenHB ~= 0) then
			print("|cFFBA0707 The Honorbound potential rep: ", HB, "(", tokenHB, "from tokens)");
		else
			print("|cFFBA0707 The Honorbound potential rep: ", HB);
		end
	end
	if(TS > 0) then
		if(tokenTS ~= 0) then
			print("|cFF00FC04 Tortollan Seekers potential rep: ", TS, "(", tokenTS, "from tokens)");
		else
			print("|cFF00FC04 Tortollan Seekers potential rep: ", TS);
		end
	end
	if(Vol > 0) then
		if(tokenVol ~= 0) then
			print("|cFFF8FC00 Voldunai potential rep: ", Vol, "(", tokenVol, "from tokens)");
		else
			print("|cFFF8FC00 Voldunai potential rep: ", Vol);
		end
	end
	if(ZE > 0) then
		if(tokenZE ~= 0) then
			print("|cFFC007FB Zandalari Empire potential rep: ", ZE, "(", tokenZE, "from tokens)");
		else
			print("|cFFC007FB Zandalari Empire potential rep: ", ZE);
		end
	end
	--if(Uns > 0) then
	print("|cFFff70f3 Unshaquilled potential rep: ", Uns);
	--end
end

function OutputAllianceRepSums()
	if(CoA > 0) then
		if(tokenCoA ~= 0)then
			print("|cFF5DE7FC Champions of Azeroth potential rep: ", CoA, "(", tokenCoA, "from tokens)");
		else
			print("|cFF5DE7FC Champions of Azeroth potential rep: ", CoA);
		end
	end
	if(OoE > 0) then
		if(tokenOoE ~= 0) then
			print("|cFFFF8411 Order of Embers potential rep: ", OoE, "(", tokenOoE, "from tokens)");
		else
			print("|cFFFF8411 Order of Embers potential rep: ", OoE);
		end
	end
	if(SL > 0) then
		if(tokenSL ~= 0) then
			print("|cFFBA0707 7th Legion potential rep: ", SL, "(", tokenSL, "from tokens)");
		else
			print("|cFFBA0707 7th Legion potential rep: ", SL);
		end
	end
	if(TS > 0) then
		if(tokenTS ~= 0) then
			print("|cFF00FC04 Tortollan Seekers potential rep: ", TS, "(", tokenTS, "from tokens)");
		else
			print("|cFF00FC04 Tortollan Seekers potential rep: ", TS);
		end
	end
	if(PA > 0) then
		if(tokenPA ~= 0) then
			print("|cFF9B8204 Proudmoore Admiralty potential rep: ", PA, "(", tokenPA, "from tokens)");
		else
			print("|cFF9B8204 Proudmoore Admiralty potential rep: ", PA);
		end
	end
	if(SW > 0) then
		if(tokenSW ~= 0) then
			print("|cFFE0D500 Storm's Wake potential rep: ", SW, "(", tokenSW, "from tokens)");
		else
			print("|cFFE0D500 Storm's Wake potential rep: ", SW);
		end
	end
	if(Ank > 0) then
			print("|cFFC007FB Ankoan Waveblade potential rep: ", Ank);
	end
end

function CheckContracts()
--Horde + Neutral contracts
	if(AuraUtil.FindAuraByName("Contract: Zandalari Empire", "player") ~= nil) then
		print("Zandalari Empire potential contract rep: ", contract_rep);
		ZE = ZE + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Voldunai", "player") ~= nil) then
		print("Voldunai potential contract rep: ", contract_rep);
		Vol = Vol + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Tortollan Seekers", "player") ~= nil) then
		print("Tortollan Seekers potential contract rep: ", contract_rep);
		TS = TS + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Talanji's Expedition", "player") ~= nil) then
		print("Talanji's Expedition potential contract rep: ", contract_rep);
		TE = TE + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Champions of Azeroth", "player") ~= nil) then
		print("Champions of Azeroth potential contract rep: ", contract_rep);
		CoA = CoA + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: The Honorbound", "player") ~= nil) then
		print("Honorbound potential contract rep: ", contract_rep);
		HB = HB + contract_rep;
--Alliance contracts		
	elseif(AuraUtil.FindAuraByName("Contract: Proudmoore Admiralty", "player") ~= nil) then
		print("Proudmoore Admiralty potential contract rep: ", contract_rep);
		PA = PA + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Order of Embers", "player") ~= nil) then
		print("Order of Embers potential contract rep: ", contract_rep);
		OoE = OoE + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: Storm's Wake", "player") ~= nil) then
		print("Storm's Wake potential contract rep: ", contract_rep);
		SW = SW + contract_rep;
	elseif(AuraUtil.FindAuraByName("Contract: 7th Legion", "player") ~= nil) then
		print("7th Legion potential contract rep: ", contract_rep);
		SL = SL + contract_rep;
	else
		print("NO VALID CONTRACT DETECTED");
	end
end