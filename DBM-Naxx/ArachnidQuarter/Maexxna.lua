local mod	= DBM:NewMod("Maexxna", "DBM-Naxx", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2943 $"):sub(12, -3))
mod:SetCreatureID(15952)

mod:RegisterCombat("combat")

mod:EnableModel()

mod:RegisterEvents(
	"SPELL_AURA_APPLIED"
	--"SPELL_CAST_SUCCESS"
)

local warnWebWrap		= mod:NewTargetAnnounce(28622, 2)
local warnWebSpraySoon	= mod:NewSoonAnnounce(54125, 1)
local warnWebSprayNow	= mod:NewSpellAnnounce(54125, 3)
local warnSpidersSoon	= mod:NewAnnounce("WarningSpidersSoon", 2, 17332)
local warnSpidersNow	= mod:NewAnnounce("WarningSpidersNow", 4, 17332)

local timerCocoon		= mod:NewNextTimer(25, 28622)
local timerWebSpray		= mod:NewNextTimer(40, 54125)
local timerSpider		= mod:NewTimer(40, "TimerSpider", 17332)

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 679, "Maexxna")
	warnWebSpraySoon:Schedule(35.5 - delay)
	timerWebSpray:Start(40.5 - delay)
	warnSpidersSoon:Schedule(25 - delay)
	warnSpidersNow:Schedule(30 - delay)
	timerSpider:Start(30 - delay)
	timerCocoon:Start(20 - delay)
	self:ScheduleMethod(30 - delay, "Spiderlings")
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 679, "Maexxna", wipe)
	if not wipe then
		if DBM.Bars:GetBar(L.ArachnophobiaTimer) then
			DBM.Bars:CancelBar(L.ArachnophobiaTimer) 
		end	
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(28622) then -- Web Wrap
		warnWebWrap:Show(args.destName)
		if mod:IsDifficulty("heroic25") then
			timerCocoon:Start()
		else
			timerCocoon:Start(40)
		end
		if args.destName == UnitName("player") then
			SendChatMessage(L.YellWebWrap, "YELL")
		end
	elseif args:IsSpellID(29484, 54125) then --Web Spray
		if mod:IsDifficulty("heroic25") then
			timerWebSpray:Start()
		else
			timerWebSpray:Start(40)
		end
	end
end

function mod:Spiderlings()
	timerSpider:Start()
	self:ScheduleMethod(40, "Spiderlings")
end