-- Tâche 9 : options et commandes /hh
local M = dofile("test/mock.lua")
M.locale = "frFR"; M.reset()
for _, f in ipairs({ "Locales/enUS", "Locales/frFR", "Locales/esES", "Core", "Nodes", "Context", "Stats", "Sound", "RP", "Binding", "Prompt", "Options", "Commands" }) do
    dofile("HookAndHarvest/" .. f .. ".lua")
end
HH.events.scripts.OnEvent(HH.events, "PLAYER_LOGIN")
ok(SLASH_HOOKANDHARVEST1 == "/hh" and SLASH_HOOKANDHARVEST2 == "/hookandharvest", "commandes enregistrées")
ok(HH.Options.panel and not HH.Options.panel.shown, "fenêtre d'options créée, cachée")

local S = HH.Stats
for i = 1, 12 do S:Record(6000 + i, i, 1000, 12) end   -- 12 sortes, 78 prises
S:Cast(); S:Cast(); S:Cast()
M.printed = {}
SlashCmdList.HOOKANDHARVEST("stats")
ok(M.printed[1]:find("78", 1, true) and M.printed[1]:find("3", 1, true), "stats : total et lancers")
ok(#M.printed == 11, "stats : en-tête + top 10")
ok(M.printed[2]:find("6012", 1, true) and M.printed[2]:find("x12", 1, true), "objet absent du cache : ID affiché, plus grosse prise en tête")

M.printed = {}; S:Reset(); SlashCmdList.HOOKANDHARVEST("stats")
ok(#M.printed == 2, "stats vides : en-tête + « aucune prise »")

S:Record(6303, 1, 1000, 12)
SlashCmdList.HOOKANDHARVEST("reset")
ok(M.popup == "HOOKANDHARVEST_RESET" and HH.Config:Char().count == 1, "reset : confirmation d'abord")
M.confirmPopup(); ok(HH.Config:Char().count == 0, "reset confirmé")

M.printed = {}; SlashCmdList.HOOKANDHARVEST("mode")
ok(M.printed[1]:find("natif", 1, true), "mode affiché")

SlashCmdList.HOOKANDHARVEST(""); ok(HH.Options.panel.shown, "/fa ouvre les options")
SlashCmdList.HOOKANDHARVEST(""); ok(not HH.Options.panel.shown, "/fa referme les options")

-- relecture, point 7 : GetItemInfo global absent sur Forever -> pas d'erreur
GetItemInfo = nil; C_Item = { GetItemInfo = function() return nil end }
S:Record(6303, 1, 1, 1); M.printed = {}; SlashCmdList.HOOKANDHARVEST("stats")
ok(M.printed[2] and M.printed[2]:find("6303", 1, true), "objet hors cache sans GetItemInfo global : ID affiché")

-- réglages appliqués depuis les options
HH.Options:SetKey("g"); ok(HH.Config:Get("key") == "G" and M.bindings.G and M.bindings.F == nil, "nouvelle touche appliquée")
HH.Options:SetKey(""); ok(HH.Config:Get("key") == "G", "touche vide refusée")
HH.Options:SetHistorySize(1); S:Record(1, 1, 1, 1); S:Record(2, 1, 1, 1)
ok(#HH.Config:Char().history == 1, "taille d'historique appliquée")
M.printed = {}; HH.Options:CycleMode(); ok(HH.Config:Get("mode") == "native" and M.printed[1]:find("/reload", 1, true), "mode changé : /reload demandé")
HH.Options:CycleMode(); HH.Options:CycleMode(); ok(HH.Config:Get("mode") == "auto", "auto -> natif -> souris -> auto")

-- position de l'invite réglable en jeu
local fr = HH.Prompt.frame
HH.Options:SetPos(nil, 120); ok(HH.Config:Get("y") == 120 and fr.point[5] == 120, "position verticale appliquée")
HH.Options:SetPos(-50, nil); ok(HH.Config:Get("x") == -50 and fr.point[4] == -50 and fr.point[5] == 120, "position horizontale appliquée")
HH.Options:SetPos(5000, -5000); ok(HH.Config:Get("x") == 800 and HH.Config:Get("y") == -600, "position bornée à l'écran")
HH.Options:ResetPos(); ok(HH.Config:Get("x") == 0 and HH.Config:Get("y") == -180 and fr.point[5] == -180, "position par défaut")
-- glisser avec une taille ≠ 1 : la position sauvée doit être dans l'échelle de l'invite
fr.scale = 2; fr.cx, fr.cy = 530, 300                     -- centre à l'écran : 1060, 600
fr.scripts.OnDragStop(fr); ok(HH.Config:Get("x") == 50 and HH.Config:Get("y") == 30, "glisser : pas de décalage au rechargement")
-- aperçu pendant que les options sont ouvertes
M.known = {}; HH:Update(); ok(not fr.shown, "sans Pêche : invite cachée")
HH.Options:Toggle(); HH.Options.panel.scripts.OnShow(HH.Options.panel); ok(fr.shown, "options ouvertes : aperçu de l'invite")
HH.Options:Toggle(); HH.Options.panel.scripts.OnHide(HH.Options.panel); ok(not fr.shown, "options fermées : aperçu retiré")

-- /hh diag : infos de détection sans autoriser les scripts
local function printedAll() return table.concat(M.printed, "\n") end
UnitName = function(u) if u == "softinteract" then return M.soft and "Feuillargent" or nil end; return "Ghosti" end
UnitGUID = function(u) if u == "softinteract" and M.soft then return "GameObject-0-1-2-3-1617-0000" end end
M.known = { ["Pêche"] = 131474 }
M.soft = true; M.softLines = { "Feuillargent", "Herboristerie" }; M.printed = {}
SlashCmdList.HOOKANDHARVEST("diag"); local d = printedAll()
ok(d:find("SoftTargetInteract", 1, true) and d:find("natif", 1, true), "diag : mode et CVar")
ok(d:find("Feuillargent", 1, true) and d:find("GameObject", 1, true), "diag : nom et GUID de la cible douce")
ok(d:find("Herboristerie", 1, true) and d:find("herb", 1, true), "diag : lignes de bulle et type reconnu")
ok(d:find("Pêche", 1, true), "diag : sort Pêche trouvé")
ok(d:find("objet 1617 -> herb", 1, true), "diag : numéro d'objet et type reconnu")
ok(d:find("182", 1, true), "diag : lignes de compétence des métiers")
M.soft = false; M.softLines = nil; M.printed = {}
SlashCmdList.HOOKANDHARVEST("diag"); d = printedAll()
ok(d:find("softinteract", 1, true) and d:find("nil", 1, true), "diag : rien de visé -> nil affiché")
C_TooltipInfo = nil; GetProfessions = nil; M.printed = {}
SlashCmdList.HOOKANDHARVEST("diag"); d = printedAll()
ok(d:find("C_TooltipInfo", 1, true) and d:find("GetProfessions", 1, true), "diag : API absentes signalées sans erreur")
-- diag sur un corps : état du butin
UnitGUID = function(u) if u == "softinteract" then return "Creature-0-6867-1-48-299-0000000004" end end
CanLootUnit = function() return true, true end
M.printed = {}; SlashCmdList.HOOKANDHARVEST("diag")
ok(table.concat(M.printed, "\n"):find("CanLootUnit=true", 1, true), "diag : butin du corps affiché")

-- diag avec des valeurs secrètes : pas d'erreur
UnitGUID = function(u) if u == "softinteract" then return SECRET end end
UnitName = function(u) if u == "softinteract" then return SECRET end; return "Ghosti" end
M.printed = {}; local okd = pcall(SlashCmdList.HOOKANDHARVEST, "diag")
ok(okd and table.concat(M.printed, " "):find("secret", 1, true), "diag : valeurs secrètes affichées sans erreur")
