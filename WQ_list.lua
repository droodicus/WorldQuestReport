--Rep total initialization and ID indices
CoA = 0; --Champions of Azeroth rep (ID = 2164)
TE = 0;  --Talanji's Expedition rep (ID = 2156)
HB = 0;  --The Honorbound rep 		(ID = 2157)
TS = 0;  --Tortollan Seekers rep 	(ID = 2163)
Vol = 0; --Voldunai rep				(ID = 2158)
ZE = 0;  --Zandalari Empire rep 	(ID = 2103)

--multiple reps per quest template: [43437]={1894,1948}
--See AngryWorldQuests' Data.lua line 33 for how to parse multiple reps per quest


--[[
local worldQuestReps = {
--Zandalari Empire rep quests (All seem to also give matching amount of 7th Legion rep for Alliance)
[52923]=2103, --Add More to the Collection (75 rep)
[49800]=2103, --Atal'Dazar: Spiders! (75)
[50863]=2103, --Avatar of Xolotal (75)
[52858]={2103, 2164}, --Azerite Empowerment(Hex Priest Haraka) -- Gives 125 CoA rep and 75 Zandalari rep
[51444]={2103, 2164}, --Azerite Empowerment(Zu'shin the Infused) -- Gives 125 CoA rep and 75 Zandalari rep
[51444]={2103, 2164}, --Azerite Madness -- Gives 125 CoA rep and 75 Zandalari rep
[54150]={2103, 2164}, --Azerite Mining -- Gives 125 CoA rep and 75 Zandalari rep
[52877]={2103, 2164}, --Azerite Mining -- Gives 125 CoA rep and 75 Zandalari rep
[51175]={2103, 2164} --Azerite Wounds -- Gives 125 CoA rep and 75 Zandalari rep

}
]]