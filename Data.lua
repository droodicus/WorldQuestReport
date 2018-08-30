--[questId]=repID
--[questId]={repID1, repID2} if multiple rep rewards

--Rep total initialization and ID indices
CoA = 0; --Champions of Azeroth rep (ID = 2164)
TE = 0;  --Talanji's Expedition rep (ID = 2156)
HB = 0;  --The Honorbound rep 		(ID = 2157)
TS = 0;  --Tortollan Seekers rep 	(ID = 2163)
Vol = 0; --Voldunai rep				(ID = 2158)
ZE = 0;  --Zandalari Empire rep 	(ID = 2103)


--print("Scrolls n scales (inactive): ", HaveQuestData(50581));
--print("Gwugnug (active): ", HaveQuestData(50499));

--Scout Skrasniss quest has ID 50512 and gives 75 rep for Talanji (repID 2156)
--Kiboku quest has ID 50869 and gives 75 rep for Zandalari Empire (repID 2103)
--Scrolls and Scales has ID 50581 and gives 75 rep for Zandalari Empire (repID 2103)
--Lo'kuno has ID 50509 and gives 75 rep for Talanji (repID 2156)
local worldQuestReps = {[50512]=2156, [50869]=2103, [50581]=2103, [50509]=2156, [50592]=2103, [50877]=2103, [52858]={2103, 2164}, [50885]=2103}


function ParseHordeWQs()
	for q, r in pairs(worldQuestReps) do
		--quest with ID "q" has been completed today
		if(GetQuestLink(q) ~= nil) then
			if(IsQuestFlaggedCompleted(q)) then
				print(GetQuestLink(q), " has been completed");
			else
				if(C_TaskQuest.IsActive(q)) then
					print(GetQuestLink(q), " IS A VALID WQ");
					--if a WQ gives rep for multiple factions, call AddRepToSum for each of them
					if(type(r) == "table") then
						for k, v in pairs(r) do
							print(v);
							AddRepToSum(v);
						end
						print(GetQuestLink(q), " gives rep for multiple factions");
					else
						AddRepToSum(r);
					end
				else
					print(GetQuestLink(q), " is NOT available at the moment");
				end;
			end
		end
	end
end



function AddRepToSum(re)
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
		print(GetQuestLink(q), " ERROR, INVALID REP ID");
	end
end
	
	
	--*****Not sure where I was going with this, but I feel like it's relevant to seeing if the quest is currently "active"
	-- if(HaveQuestData(q)) then
		-- print("I apparently have quest data for: ", GetQuestLink(q));
	-- else 
		-- print("I DO NOT have quest data for: ", GetQuestLink(q));
	-- end
--print("KIBOKU: ", IsQuestFlaggedCompleted(50869));



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



if(UnitFactionGroup("player") == "Horde") then
	ParseHordeWQs();
	OutputHordeRepSums();
end






