--http://www.wowhead.com/guide=1949/wow-addon-writing-guide-part-one-how-to-make-your-first-addon

--API REREFENCE: http://wowprogramming.com/docs/api_categories.html

print("WQ Report active! Will only work for Horde to begin");

--Prints if quest is completed
--[[
print("KIBOKU: ", IsQuestFlaggedCompleted(50869));
print("DOMINUS: ", IsQuestFlaggedCompleted(51081));
--WQ output:
--quest available but not complete: false
--quest completed that day: true
--quest not available that day: false
]]--


