-- Tâche 4 : liaison de F et bouton de pêche
local M = dofile("test/mock.lua")
M.locale = "frFR"; M.reset()
dofile("HookAndHarvest/Locales/enUS.lua"); dofile("HookAndHarvest/Locales/frFR.lua"); dofile("HookAndHarvest/Locales/esES.lua")
dofile("HookAndHarvest/Core.lua"); dofile("HookAndHarvest/Context.lua"); dofile("HookAndHarvest/Binding.lua")
HH.Config:Init()
local B = HH.Binding

B:Create()
ok(M.drivers.HookAndHarvestOwner == "[combat] 1; 0", "pilote d'état combat enregistré")
ok(B.owner.template:find("SecureHandlerStateTemplate", 1, true), "propriétaire sécurisé")
ok(B.owner:GetAttribute("_onstate-combat"):find("ClearBindings", 1, true), "en combat : ClearBindings")
ok(B.button.template:find("SecureActionButtonTemplate", 1, true), "bouton sécurisé")
ok(B.button:GetAttribute("type") == "spell" and B.button:GetAttribute("spell") == "Pêche", "bouton sort Pêche")

B:Apply("cast", "native"); ok(M.bindings.F == "CLICK HookAndHarvestCastButton:LeftButton", "lancer -> bouton")
B:Apply("herb", "native"); ok(M.bindings.F == "INTERACTTARGET", "natif -> interagir cible")
B:Apply("herb", "mouse"); ok(M.bindings.F == "INTERACTMOUSEOVER", "souris -> interagir survol")
B:Apply("bobber", "native"); ok(M.bindings.F == "INTERACTTARGET", "bouchon -> interagir")
B:Apply(nil, "native"); ok(M.bindings.F == nil, "rien -> F libre")
M.combat = true; B:Apply("cast", "native"); ok(M.bindings.F == nil, "aucune liaison en combat")
M.combat = false; B:Apply("cast", "native"); M.clearCount = 0; B:Apply("cast", "native")
ok(M.clearCount == 0, "même contexte -> rien n'est refait")
HH.Config:Set("key", "G"); B:Refresh()
ok(M.bindings.F == nil and M.bindings.G == "CLICK HookAndHarvestCastButton:LeftButton", "nouvelle touche, ancienne libérée")

-- PreClick : RP, compteur, son
local calls = {}
HH.RP = { OnCast = function() calls[#calls + 1] = "rp" end }
HH.Stats = { Cast = function() calls[#calls + 1] = "stats" end }
HH.Sound = { Boost = function() calls[#calls + 1] = "sound" end }
B.button.scripts.PreClick(B.button, "LeftButton", true)
ok(#calls == 1 and calls[1] == "rp", "PreClick : RP seulement (son et compteur au début réel de la pêche)")
calls = {}; B.button.scripts.PreClick(B.button, "LeftButton", false)
ok(#calls == 0, "relâchement de touche : rien en double")

-- sort mis à jour
M.known = {}; B:UpdateSpell(); ok(B.button:GetAttribute("spell") == nil, "Pêche oubliée -> bouton vide")
M.combat = true; M.known = { ["Pêche"] = 1 }; B:UpdateSpell(); ok(B.button:GetAttribute("spell") == nil, "pas de changement en combat")
