local mod	= DBM:NewMod("Gluth", "DBM-Naxx", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 2869 $"):sub(12, -3))
mod:SetCreatureID(15932)

mod:RegisterCombat("combat")

mod:EnableModel()

mod:RegisterEvents(
	"SPELL_DAMAGE",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS"
)


local warnDecimateSoon	= mod:NewSoonAnnounce(54426, 2)
local warnDecimateNow	= mod:NewSpellAnnounce(54426, 3)
local warnEnraged		= mod:NewSpellAnnounce(54427, 3)

local timerDecimate		= mod:NewCDTimer(105, 54426)
local timerEnrage		= mod:NewCDTimer(30, 54427, nil, mod:CanRemoveEnrage())
local timerEnraged		= mod:NewTimer(8, "TimerEnraged", 54427, mod:CanRemoveEnrage())
local timerWound		= mod:NewCDTimer(8, 25646, nil, mod:IsTank())

local lastEnrage

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 698, "Gluth")
	lastEnrage = nil
	timerDecimate:Start(105 - delay)
	warnDecimateSoon:Schedule(95 - delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 698, "Gluth", wipe)
end

local decimateSpam = 0
function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(28375) and (GetTime() - decimateSpam) > 20 then
		decimateSpam = GetTime()
		warnDecimateNow:Show()
		timerDecimate:Start()
		warnDecimateSoon:Schedule(96)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(54427, 28371) then
		warnEnraged:Show()
		lastEnrage = GetTime()
		timerEnraged:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(54427, 28371) then
		timerEnraged:Stop()
		timerEnrage:Start(30-(GetTime()-lastEnrage))
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(25646) then
		timerWound:Start()
	end
end