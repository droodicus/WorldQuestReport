--http://www.wowhead.com/guide=1949/wow-addon-writing-guide-part-one-how-to-make-your-first-addon

--API REREFENCE: http://wowprogramming.com/docs/api_categories.html

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(f, event)
    if event == "PLAYER_LOGIN" then
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
    end
end)


print("WQ Report active!");

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
OoE = 0; --Order of Embers rep (ID = 2161)
SL = 0; --7th Legion rep (ID = 2159)
PA = 0; --Proudmoore Admiralty rep (ID = 2160)
SW = 0; --Storm's Wake rep (ID = 2162)

--**NOTE: Alliance and Horde both use the same rep ID's for Champions of Azeroth and Tortollan Seekers


--Scout Skrasniss quest has ID 50512 and gives 75 rep for Talanji (repID 2156)
--Kiboku quest has ID 50869 and gives 75 rep for Zandalari Empire (repID 2103)
--Scrolls and Scales has ID 50581 and gives 75 rep for Zandalari Empire (repID 2103)
--Lo'kuno has ID 50509 and gives 75 rep for Talanji (repID 2156)
local worldQuestReps = {[50512]=2156, [50869]=2103, [50581]=2103, [50509]=2156, [50592]=2103, [50877]=2103, [52858]={2103, 2159, 2164}, [50885]=2103, [52862]={2164, 2157}, [52862]={2164, 2161, 2157}, [52858]={2164, 2159, 2157}}


function ParseHordeWQs()
	for q, r in pairs(worldQuestReps) do
		if(GetQuestLink(q) ~= nil) then
			if(IsQuestFlaggedCompleted(q)) then
				print(GetQuestLink(q), " has been completed");
			else
				if(C_TaskQuest.IsActive(q)) then
					print(GetQuestLink(q), " IS A VALID WQ");
					numWQs = numWQs + 1;
					--if a WQ gives rep for multiple factions, call AddHordeRepToSum for each of them
					if(type(r) == "table") then
						for k, v in pairs(r) do
							AddHordeRepToSum(v);
						end
						print(GetQuestLink(q), " gives rep for multiple factions");
					else
					--if a WQ gives rep for one faction, just call AddHordeRepToSum for it
						AddHordeRepToSum(r);
					end
				else
					print(GetQuestLink(q), " is NOT available at the moment");
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
	else
		print(re, "'s reputation does not apply");
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
		print("Voldunai potential contract rep: ", Vol);
	end
	if(ZE > 0) then
		print("Zandalari Empire potential rep: ", ZE);
	end
end


function ParseAllianceWQs()
	for q, r in pairs(worldQuestReps) do
		if(GetQuestLink(q) ~= nil) then
			if(IsQuestFlaggedCompleted(q)) then
				print(GetQuestLink(q), " has been completed");
			else
				if(C_TaskQuest.IsActive(q)) then
					print(GetQuestLink(q), " IS A VALID WQ");
					numWQs = numWQs + 1;
					--if a WQ gives rep for multiple factions, call AddAllianceRepToSum for each of them
					if(type(r) == "table") then
						for k, v in pairs(r) do
							AddAllianceRepToSum(v);
						end
						print(GetQuestLink(q), " gives rep for multiple factions");
					else
					--if a WQ gives rep for one faction, just call AddAllianceRepToSum for it
						AddAllianceRepToSum(r);
					end
				else
					print(GetQuestLink(q), " is NOT available at the moment");
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
	else
		print(re, "'s reputation does not apply");
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
	else
		print("NO VALID CONTRACT DETECTED");
	end
end
