-- Tâche 6 : phrases RP et anti-spam
local M = dofile("test/mock.lua")
local function load(locale)
    M.locale = locale; M.reset()
    dofile("HookAndHarvest/Locales/enUS.lua"); dofile("HookAndHarvest/Locales/frFR.lua"); dofile("HookAndHarvest/Locales/esES.lua")
    dofile("HookAndHarvest/Core.lua"); dofile("HookAndHarvest/RP.lua")
    HH.Config:Init()
    return HH.RP
end
for _, loc in ipairs({ "enUS", "frFR", "esES" }) do
    load(loc)
    ok(type(HH.L.rp_say) == "table" and #HH.L.rp_say >= 40 and #HH.L.rp_catch >= 15, "assez de phrases " .. loc)
    local okFmt = true
    for _, e in ipairs(HH.L.rp_catch) do if not e:find("%s", 1, true) then okFmt = false end end
    ok(okFmt, "chaque emote contient %s " .. loc)
end

local R = load("frFR")
ok(R:ShouldSpeak(100, 20) and not R:ShouldSpeak(100, 21), "chance 20 %")
R.lastSay = 100; ok(not R:ShouldSpeak(159, 1) and R:ShouldSpeak(160, 1), "délai 60 s")
R.lastSay = nil; M.instance = "party"; ok(not R:ShouldSpeak(500, 1), "silence en donjon")
M.instance = "none"; M.raid = true; ok(not R:ShouldSpeak(500, 1), "silence en raid")
HH.Config:Set("rpSilentInGroup", false); ok(R:ShouldSpeak(500, 1), "groupe autorisé si option coupée")
M.raid = false; HH.Config:Set("rpSay", false); ok(not R:ShouldSpeak(500, 1), "RP coupé")
HH.Config:Set("rpSay", true); HH.Config:Set("rpChance", 0); ok(not R:ShouldSpeak(500, 1), "chance 0 -> jamais")
HH.Config:Set("rpChance", 20)

local a = R:Pick(HH.L.rp_say, 0.5); local b = R:Pick(HH.L.rp_say, 0.5)
ok(a ~= b and a >= 1 and b <= #HH.L.rp_say, "jamais deux fois la même")
ok(R:Pick({ "seule" }, 0.5) == 1 and R:Pick({ "seule" }, 0.5) == 1, "liste d'une phrase")
ok(R:Pick(HH.L.rp_say, 0.9999) <= #HH.L.rp_say, "tirage en bord de liste")

M.now = 1000; M.random = 1; R:OnCast()
ok(#M.said == 1 and M.said[1][2] == "SAY", "phrase envoyée en /dire")
M.now = 1010; R:OnCast(); ok(#M.said == 1, "pas de deuxième phrase avant 60 s")
R:OnCatch("Truite arc-en-ciel"); ok(#M.said == 1, "emote coupée par défaut")
HH.Config:Set("rpEmoteCatch", true); R:OnCatch("Truite arc-en-ciel")
ok(M.said[2][2] == "EMOTE" and M.said[2][1]:find("Truite arc-en-ciel", 1, true), "emote à la prise")
