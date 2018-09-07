--Rep total initialization and ID indices
CoA = 0; --Champions of Azeroth rep (ID = 2164)
TE = 0;  --Talanji's Expedition rep (ID = 2156)
HB = 0;  --The Honorbound rep 		(ID = 2157)
TS = 0;  --Tortollan Seekers rep 	(ID = 2163)
Vol = 0; --Voldunai rep				(ID = 2158)
ZE = 0;  --Zandalari Empire rep 	(ID = 2103)

--Alliance Rep total initialization and ID indices 
OoE = 0; --Order of Embers rep 		(ID = 2161)
SL = 0; --7th Legion rep			(ID = 2159)
PA = 0; --Proudmoore Admiralty rep 	(ID = 2160)
SW = 0; --Storm's Wake rep 			(ID = 2162)

--multiple reps per quest template: [43437]={1894,1948}
--See AngryWorldQuests' Data.lua line 33 for how to parse multiple reps per quest

--*****REMINDER THAT DUNGEON WQS COME FROM THE DUNGEON, NOT THE SURROUNDING ZONE
--Triple asterisk at the end of a comment means that the rep gain needs to be confirmed - wowhead doesn't state.
--Unless stated otherwise, everything that gives ZE rep (2103) also gives the same amount for SL (2159)
--***NEED TO ADD "SUPPLIES NEEDED" AND "WORK ORDER" QUESTS FOR ZULDAZAR AND VOL'DUN
--Need to confirm Horde/Alliance only quests and adjust their data to reflect so
--Also need to adjust data to include 7th Legion rep ID (2159) for their respective quests
local worldQuestReps = {
--Zuldazar Quests
[52923]=2103, 		  --Add More to the Collection -- Gives 75 ZE rep
[49800]=2103,		  --Atal'Dazar: Spiders! -- Gives 75 ZE rep
[50864]=2103, 		  --Atal'Zul Gotaka  -- Gives 75 ZE rep ***
[50863]=2103,		  --Avatar of Xolotal -- Gives 75 ZE rep
[52858]={2103, 2164}, --Azerite Empowerment(Hex Priest Haraka) -- Gives 125 CoA rep and 75 ZE rep 
[51444]={2103, 2164}, --Azerite Empowerment(Zu'shin the Infused) -- Gives 125 CoA rep and 75  ZE rep
[51179]={2103, 2164}, --Azerite Madness -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[52877]={2103, 2164}, --Azerite Mining -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[51450]={2103, 2164}, --Azerite Mining -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[52877]={2103, 2164}, --Azerite Mining -- Gives 125 CoA rep and 75  ZE rep **NOTE: Appears to be same rep ID for all zones
[51175]={2103, 2164}, --Azerite Wounds -- Gives 125 CoA rep and 75  ZE rep
[51642]={2103, 2163}, --Beachhead -- Gives 175 TS rep and 75 ZE rep (Southern coast of Zuldazar)
[50527]={2103},		  --Behind Mogu Lines -- Gives 75 ZE rep **NOTE: According to wowhead, this is Alliance only
[50652]={2103},		  --Biting The Hand that Feeds Them -- Give 75 ZE rep **NOTE: According to wowhead, this is Horde only
[50862]={2103},		  --Bloodbulge -- gives 75 ZE rep
[50868]={2103},		  --Bramblewing -- gives 75 ZE rep
[50848]={2158},		  --Brgl-Lrgl the Basher *** says it's a Zuldazar quest despite being in Vol'dun, rep unconfirmed
[50578]={2103},		  --Bring Ruin AGain -- gives 75 ZE rep
[51475]={2103},		  --Brutal Escort -- gives 75 ZE rep
[50966]={2103},		  --Cleanup Crew -- gives 75 ZE rep
[52251]={2103},		  --Compromised Reconnaissance -- gives 75 ZE rep **no info whatsoever on wowhead page, doublecheck
[50854]={2103},		  --Crimsonclaw (Umbra'jin) -- gives 75 ZE rep
[52892]={2103},		  --Critters are Friends, Not Food -- gives 75 ZE rep
[50651]={2103},		  --Cut Off Potential -- gives 75 ZE rep
[50871]={2103},		  --Daggerjaw -- gives 75 ZE rep
[51084]={2103},		  --Dark Chronicler -- gives 75 ZE rep
[50875]={2103},		  --Darkspeaker Jo'la - gives 75 ZE rep
[48862]={2103},		  --Disarming the Competetion -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[51373]={2103},		  --Ears Everywhere -- gives 75 ZE rep
[51815]={2103},		  --Eggstermination -- gives 75 ZE rep  (Appears to be Alliance version)
[50571]={2103},		  --Eggstermination -- gives 75 ZE rep (Appears to be Horde version)
[50969]={2103},		  --Emergency Management -- gives 75 ZE rep **NOTE: According to wowhead, this is Alliance only
[50548]={2103},		  --Enforcing the Will of the King -- gives 75 ZE rep **NOTE: According to wowhead, this is Horde only
[50870]={2103},		  --G'Naat -- gives 75 ZE rep
[50877]={2103},		  --Gahz'ralka -- gives 75 ZE rep
[50857]={2103},		  --Golrakahn -- gives 75 ZE rep
[50874]={2103},		  --Hakbi the Risen -- gives 75 ZE rep
[50846]={2103},		  --Headhunter Lee'za -- gives 75 ZE rep
[50765]={2103},		  --Herding Children -- gives 75 ZE rep
[51497]={2103},		  --Hex Education -- gives 75 ZE rep
[51178]={2103},		  --Hundred Troll Holdout -- gives 75 ZE rep
[51305]={2103},		  --Jelly Clouds -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[50859]={2103},		  --Kandak -- gives 75 ZE rep
[50869]={2103},		  --Kiboku -- gives 75 ZE rep
[50547]={2103},		  --Knives of Zul -- gives 75 ZE rep
[50845]={2103},		  --Kul'krazahn -- gives 75 ZE rep
[50852]={2103},		  --Lady Seirine -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[50885]={2103},		  --Lei-zhi -- gives 75 ZE rep
[51496]={2103},		  --Loa Your Standards -- gives 75 ZE rep
[51636]={2103, 2163}, --Make Loh Go -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[50851]={2103},		  --Mor'fani the Exile *** says it's a Zuldazar quest despite being in Vol'dun, rep unconfirmed
[50876]={2103},		  --Murderbeak -- gives 75 ZE rep
[50747]={2103},		  --No Good Amani -- gives 75 ZE rep
[50855]={2103},		  --Old R'gal -- gives 75 ZE rep
[51495]={2103},		  --Old Rotana -- gives 75 ZE rep
[50574]={2103},		  --Preservation Methods -- gives 75 ZE rep
[51816]={2103},		  --Pterrible Ingredients -- gives 75 ZE rep, although wowhead says it's Alliance
[50633]={2103},		  --Pterrible Ingredients -- appears to be a copy of the previous one? Might be unused, wowhead page is blank
[50524]={2103},		  --Purify the Temple -- gives 75 ZE rep -- wowhead says Horde only
[51821]={2103},		  --Quelling the Cove -- gives 75 ZE rep -- wowhead says Alliance only
[49068]={2103},		  --Quelling the Cove -- gives 75 ZE rep -- appears to be Horde version
[50540]={2103},		  --Rally the Rastari -- gives 75 ZE rep -- wowhead says Horde only
[51814]={2103},		  --Ravoracious -- gives 75 ZE rep -- wowhead says Alliance only
[50636]={2103},		  --Ravoracious -- gives 75 ZE rep -- appears to be Horde version
[50744]={2103},		  --Refresh Their Memory -- gives 75 ZE rep -- wowhead says Horde only
[50964]={2103},		  --Ritual Combat -- gives 75 ZE rep -- wowhead says Horde only
[52250]={2103},		  --Saving Xibala -- gives 75 ZE rep -- wowhead says Alliance only
[49413]={2103},		  --Scamps with Scrolls -- gives 75 ZE rep -- wowhead says Horde only
[51822]={2103},		  --Scrolls and Scales -- gives 75 ZE rep -- wowhead says Alliance only
[50581]={2103},		  --Scrolls and Scales -- gives 75 ZE rep -- wowhead says Horde only
[51630]={2103, 2163}, --Shell Game -- gives 175 TS rep and 75 ZE rep - Southwestern Zuldazar
[50737]={2103},		  --Silence the Speakers -- gives 75 ZE rep -- wowhead says Alliance only
[50858]={2103},		  --Sky Queen -- gives 75 ZE rep -- wowhead says Alliance only
[52938]={2103},		  --Small Beginnings -- gives 75 ZE rep -- pet battle (Zujai)
[53165]={2103},		  --Stopping Antiquities Theft -- gives 75 ZE rep -- wowhead says Alliance only
[50873]={2103},		  --Strange Egg -- gives 75 ZE rep
[50756]={2103},		  --Subterranean Evacuation -- gives 75 ZE rep -- wowhead says Alliance only
[51081]={2103},		  --Syrawon the Dominus -- gives 75 ZE rep
[50867]={2103},		  --Tambano -- gives 75 ZE rep
[51494]={2103},		  --The Blood Gate -- gives 75 ZE rep
[52249]={2103},		  --The Shores of Xibala -- gives 75 ZE rep -- wowhead says Alliance only
[52248]={2103},		  --The Shores of Xibala -- gives 75 ZE rep -- wowhead says Horde only
[50850]={2103},		  --Tia'Kawan -- gives 75 ZE rep
[50592]={2103},		  --Tiny Terror -- gives 75 ZE rep -- wowhead says Horde only
[50861]={2103},		  --Torraske the Eternal -- gives 75 ZE rep
[50847]={2103},		  --Twisted Child of Rezan -- gives 75 ZE rep
[50853]={2103},		  --Umbra'rix -- gives 75 ZE rep
[49444]={2103},		  --Underfoot -- gives 75 ZE rep -- wowhead says Horde only
[50287]={2103},		  --Unending Gorilla Warfare -- gives 75 ZE rep -- wowhead says Horde only
[51374]={2103},		  --Unending Gorilla Warfare -- gives 75 ZE rep -- wowhead says Alliance only
[50872]={2103},		  --Warcrawler Karkithiss -- gives 75 ZE rep
[50619]={2103},		  --What Goes Up -- gives 75 ZE rep -- wowhead says Horde only
[50849]={2103},		  --Witch Doctor Habra'du -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[50782]={2103},		  --Word on the Streets -- gives 75 ZE rep -- wowhead says Alliance only
[50957]={2103},		  --Wrath of Rezan -- ***Unconfirmed rep **no info whatsoever on wowhead page, doublecheck
[51824]={2103},		  --You're Grounded -- gives 75 ZE rep -- wowhead says Alliance only
[52937]={2103},		  --You've Never Seen Jammer Upset -- gives 75 ZE rep -- pet battle (Jammer)
[50866]={2103},		  --Zayoos -- gives 75 ZE rep
}


