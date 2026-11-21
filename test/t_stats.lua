-- Tâche 3 : compteur et historique
local M = dofile("test/mock.lua")
M.locale = "frFR"; M.reset()
dofile("HookAndHarvest/Locales/enUS.lua"); dofile("HookAndHarvest/Locales/frFR.lua"); dofile("HookAndHarvest/Locales/esES.lua")
dofile("HookAndHarvest/Core.lua"); dofile("HookAndHarvest/Stats.lua")
HH.Config:Init()
local S, char = HH.Stats, HH.Config:Char()

S:Record(6303, 1, 1000, 12); S:Record(6303, 2, 1001, 12); S:Record(6358, 1, 1002, 12)
ok(char.totals[6303] == 3 and char.count == 4, "totaux par objet et total")
local top = S:Top(10); ok(top[1].id == 6303 and top[1].n == 3 and top[2].id == 6358 and #top == 2, "top trié")
S:Record(6299, 1, 1002, 12)
top = S:Top(10); ok(top[2].id == 6299 and top[3].id == 6358, "égalité -> id croissant")
ok(#S:Top(1) == 1, "top limité à n")
ok(#char.history == 4 and char.history[4].id == 6299 and char.history[1].map == 12, "historique dans l'ordre")
HH.Config:Set("historySize", 2); S:Trim()
ok(#char.history == 2 and char.history[1].t == 1002, "taille réduite -> plus anciennes retirées")
HH.Config:Set("history", false); S:Record(6303, 1, 1003, 12)
ok(#char.history == 2 and char.totals[6303] == 4, "historique coupé, totaux comptés")
HH.Config:Set("historySize", 0); HH.Config:Set("history", true); S:Record(6303, 1, 1004, 12)
ok(#char.history == 0, "taille 0 -> aucun historique")
S:Cast(); S:Cast(); ok(char.casts == 2, "lancers comptés")

-- butin simulé, avec emote à la prise
local caught
HH.RP = { OnCatch = function(_, name) caught = name end }
M.loot = { fishing = true, items = {
    { link = "|cff9d9d9d|Hitem:6303::::::::|h[Raw Slitherskin Mackerel]|h|r", name = "Raw Slitherskin Mackerel", qty = 1 },
    { link = nil, name = "12 Copper", qty = 0 } } }
S:OnLootOpened(); ok(char.totals[6303] == 6, "butin de pêche compté, argent ignoré")
ok(caught == "Raw Slitherskin Mackerel", "emote : nom de la prise transmis")
M.loot.fishing = false; S:OnLootOpened(); ok(char.totals[6303] == 6, "butin hors pêche ignoré")
HH.RP = nil; M.loot.fishing = true; S:OnLootOpened(); ok(char.totals[6303] == 7, "sans module RP : pas d'erreur")
S:Reset(); ok(char.count == 0 and char.casts == 0 and next(char.totals) == nil and #char.history == 0, "remise à zéro")
