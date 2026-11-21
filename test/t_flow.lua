-- Tâche 8 : invite à l'écran et câblage des événements (tous les fichiers, ordre du .toc)
local M = dofile("test/mock.lua")
M.locale = "frFR"; M.reset()
for _, f in ipairs({ "Locales/enUS", "Locales/frFR", "Locales/esES", "Core", "Nodes", "Context", "Stats", "Sound", "RP", "Binding", "Prompt" }) do
    dofile("HookAndHarvest/" .. f .. ".lua")
end
local function fire(e, ...) HH.events.scripts.OnEvent(HH.events, e, ...) end
local P = function() return HH.Prompt end

fire("PLAYER_LOGIN")
ok(HH.mode == "native" and M.cvars.SoftTargetInteract == "3", "connexion : mode natif, CVar posée")
ok(HookAndHarvestDB.softSaved == "0", "ancienne valeur de la CVar gardée")
ok(M.bindings.F == "CLICK HookAndHarvestCastButton:LeftButton" and P().frame.shown, "rien autour : F lance, invite visible")
ok(P().label.txt == "Lancer la ligne" and P().keyText.txt == "F", "libellé FR et touche affichée")
ok(P().art.tex:find("fish", 1, true), "illustration poisson")

M.channel = "Pêche"; M.soft = true; fire("UNIT_SPELLCAST_CHANNEL_START", "player")
ok(M.bindings.F == "INTERACTTARGET" and P().label.txt == "Ferrer !", "bouchon : F ferre")
M.soft = false; fire("PLAYER_SOFT_INTERACT_CHANGED")
ok(M.bindings.F == "INTERACTTARGET", "pêche en cours sans cible douce : F ne relance pas")
M.channel = nil; fire("UNIT_SPELLCAST_CHANNEL_STOP", "player")
ok(M.bindings.F:find("CLICK", 1, true), "fin de pêche : retour au lancer")

-- son et compteur : seulement quand la pêche démarre vraiment (relecture, point 1)
local c0 = HH.Config:Char().casts
M.cvars.Sound_SFXVolume = "0.4"; HH.Binding.button.scripts.PreClick(HH.Binding.button, "LeftButton", true)
ok(M.cvars.Sound_SFXVolume == "0.4" and HH.Config:Char().casts == c0, "lancer raté (pas de canal) : son et compteur inchangés")
M.channel = "Pêche"; fire("UNIT_SPELLCAST_CHANNEL_START", "player")
ok(M.cvars.Sound_SFXVolume == "1" and HH.Config:Char().casts == c0 + 1, "pêche démarrée : son renforcé, lancer compté")
M.channel = "Drain de vie"; fire("UNIT_SPELLCAST_CHANNEL_START", "player"); ok(HH.Config:Char().casts == c0 + 1, "autre canal ignoré")
M.channel = nil; fire("UNIT_SPELLCAST_CHANNEL_STOP", "player"); ok(M.cvars.Sound_SFXVolume == "0.4", "fin de pêche : son remis")

-- combat : invite cachée dès l'entrée en combat (relecture, point 2)
fire("PLAYER_REGEN_DISABLED"); ok(not P().frame.shown, "entrée en combat : invite cachée")
M.combat = true; M.soft = true; M.softLines = { "Feuillargent", "Herboristerie" }; fire("PLAYER_SOFT_INTERACT_CHANGED")
ok(not P().frame.shown, "en combat : l'invite ne revient pas")
M.combat = false; M.soft = false; M.softLines = nil; fire("PLAYER_REGEN_ENABLED"); ok(P().frame.shown, "sortie de combat : invite revenue")
fire("UNIT_SPELLCAST_CHANNEL_STOP", "target"); ok(true, "autre unité ignorée sans erreur")

M.soft = true; M.softLines = { "Feuillargent", "Herboristerie" }; fire("PLAYER_SOFT_INTERACT_CHANGED")
ok(M.bindings.F == "INTERACTTARGET" and P().label.txt == "Cueillir", "herbe visée")
M.profs = { 186 }; fire("SKILL_LINES_CHANGED"); ok(P().label.txt == "Lancer la ligne", "herbo inconnue : pas de « Cueillir »")
M.profs = { 182, 186, 393 }; fire("SKILL_LINES_CHANGED")
ok(P().art.tex:find("flower", 1, true) and P().sway:IsPlaying(), "fleur qui se balance")
M.softLines = { "Filon de cuivre", "Minage" }; fire("PLAYER_SOFT_INTERACT_CHANGED")
ok(P().label.txt == "Miner" and not P().sway:IsPlaying(), "filon : pas de balancement")

-- combat : rien ne bouge, puis reprise
M.combat = true; M.softLines = { "Jeune loup", "Dépeçable" }; fire("PLAYER_SOFT_INTERACT_CHANGED")
ok(M.bindings.F == "INTERACTTARGET", "en combat : pas de nouvelle liaison")
M.combat = false; fire("PLAYER_REGEN_ENABLED"); ok(P().label.txt == "Dépecer", "sortie de combat : contexte recalculé")

M.known = {}; M.soft = false; fire("SPELLS_CHANGED")
ok(M.bindings.F == nil and not P().frame.shown, "Pêche inconnue : rien")

-- herbe et filon réels sur Forever : exists=false, pas de bulle, seulement nom + GUID (capture du 2026-11-09)
M.known = { ["Pêche"] = 131474 }; M.soft = false; M.softLines = nil; M.softName = "Feuillargent"; M.softGUID = "GameObject-0-6867-1-48-1617-8B58AE6C93"
fire("PLAYER_SOFT_INTERACT_CHANGED"); ok(M.bindings.F == "INTERACTTARGET" and P().label.txt == "Cueillir", "Feuillargent visé (Forever) : F cueille")
M.softName, M.softGUID = "Filon de cuivre", "GameObject-0-6867-1-48-1731-0000000001"
fire("PLAYER_SOFT_INTERACT_CHANGED"); ok(M.bindings.F == "INTERACTTARGET" and P().label.txt == "Miner", "Filon visé (Forever) : F mine")
-- herbe absente de la liste : apprise au premier butin
M.softName, M.softGUID = "Herbe des marais", "GameObject-0-6867-1-48-999003-0000000002"
fire("PLAYER_SOFT_INTERACT_CHANGED"); ok(P().label.txt == "Lancer la ligne", "herbe inconnue : pas encore reconnue")
M.loot = { fishing = false, items = { { link = "|Hitem:765::|h[Feuillargent]|h", name = "Feuillargent", qty = 1 } } }
fire("LOOT_OPENED"); ok(HookAndHarvestDB.learned[999003] == "herb", "butin d'herbe : objet appris")
fire("PLAYER_SOFT_INTERACT_CHANGED"); ok(P().label.txt == "Cueillir", "herbe apprise : F cueille")
-- coffre au sol : un clic l'ouvre (crochetage automatique)
M.softName, M.softGUID = "Coffre usé", "GameObject-0-6867-1-48-2843-0000000003"
fire("PLAYER_SOFT_INTERACT_CHANGED"); ok(M.bindings.F == "INTERACTTARGET" and P().label.txt == "Ouvrir" and P().art.tex:find("chest", 1, true), "coffre visé : F ouvre")
-- corps avec du butin : passe avant le dépeçage
M.softName, M.softGUID, M.canLoot = "Jeune loup", "Creature-0-6867-1-48-299-0000000004", true
M.soft = true; M.softLines = { "Jeune loup", "Dépeçable" }
fire("PLAYER_SOFT_INTERACT_CHANGED"); ok(M.bindings.F == "INTERACTTARGET" and P().label.txt == "Fouiller" and P().art.tex:find("bag", 1, true), "corps avec butin : F fouille")
M.canLoot = false; fire("PLAYER_SOFT_INTERACT_CHANGED"); ok(P().label.txt == "Dépecer", "butin pris : F dépèce")
M.soft = false; M.softLines = nil
M.softName, M.softGUID = nil, nil; fire("PLAYER_SOFT_INTERACT_CHANGED")

-- valeurs secrètes (erreur Lua du 2026-11-10, Mortemines) : jamais d'erreur
M.softName, M.softGUID = "Jeune loup", SECRET
local okSecret = pcall(fire, "PLAYER_SOFT_INTERACT_CHANGED")
ok(okSecret and M.bindings.F == "INTERACTTARGET" and P().label.txt == "Interagir" and P().art.tex:find("bag", 1, true),
   "cible cachée par le jeu : invite générique « Interagir », F interagit")
M.softName, M.softGUID = SECRET, "GameObject-0-7099-36-8-1617-CFC64B616E"
okSecret = pcall(fire, "PLAYER_SOFT_INTERACT_CHANGED")
ok(okSecret and P().label.txt == "Cueillir", "nom secret : herbe reconnue par son numéro")
M.softName, M.softGUID, M.soft, M.softLines = nil, nil, true, { SECRET, "Herboristerie" }
okSecret = pcall(fire, "PLAYER_SOFT_INTERACT_CHANGED")
ok(okSecret and P().label.txt == "Cueillir", "ligne de bulle secrète ignorée")
M.soft, M.softLines = false, nil
-- pendant la pêche, le bouchon passe avant l'invite générique
M.softName, M.softGUID, M.channel = SECRET, SECRET, "Pêche"
fire("UNIT_SPELLCAST_CHANNEL_START", "player"); ok(P().label.txt == "Ferrer !", "pêche en cours + cible cachée : « Ferrer ! »")
M.channel = nil; fire("UNIT_SPELLCAST_CHANNEL_STOP", "player")
M.softName, M.softGUID = nil, nil; fire("PLAYER_SOFT_INTERACT_CHANGED")

-- canne à pêche retirée puis remise
M.known = { ["Pêche"] = 131474 }; M.soft = false; M.softLines = nil
M.mainhand = { id = 25, class = 2, sub = 7 }; fire("PLAYER_EQUIPMENT_CHANGED", 16)
ok(M.bindings.F == nil and not P().frame.shown, "sans canne : F libre, pas d'invite")
M.mainhand = { id = 6256, class = 2, sub = 20 }; fire("PLAYER_EQUIPMENT_CHANGED", 16)
ok(M.bindings.F and M.bindings.F:find("CLICK", 1, true) and P().label.txt == "Lancer la ligne", "canne équipée : F lance")

-- butin
M.loot = { fishing = true, items = { { link = "|Hitem:6303::|h[Maquereau]|h", name = "Maquereau", qty = 2 } } }
fire("LOOT_OPENED"); ok(HH.Config:Char().totals[6303] == 2, "butin de pêche compté")

HH.Config:Set("enabled", false); HH:Update()
ok(M.cvars.SoftTargetInteract == "0" and HookAndHarvestDB.softSaved == nil, "désactivé : CVar d'origine remise")
HH.Config:Set("enabled", true); HH:Update(); ok(M.cvars.SoftTargetInteract == "3", "réactivé : CVar reposée")
HH.mode = "mouse"; HH:Update(); ok(M.cvars.SoftTargetInteract == "0" and HookAndHarvestDB.softSaved == nil, "passage en mode souris : CVar d'origine remise (relecture, point 4)")

-- mode souris (CVar absente)
M.reset()
for _, f in ipairs({ "Locales/enUS", "Locales/frFR", "Locales/esES", "Core", "Nodes", "Context", "Stats", "Sound", "RP", "Binding", "Prompt" }) do
    dofile("HookAndHarvest/" .. f .. ".lua")
end
M.cvars.SoftTargetInteract = nil
fire("PLAYER_LOGIN"); ok(HH.mode == "mouse" and M.cvars.SoftTargetInteract == nil, "mode souris, aucune CVar écrite")
ok(GameTooltip.hooks.OnShow and GameTooltip.hooks.OnHide, "bulle d'aide suivie")
M.tipLines = { "Filon de cuivre", "Minage" }; M.tipShown = true; GameTooltip.hooks.OnShow(GameTooltip)
ok(M.bindings.F == "INTERACTMOUSEOVER" and P().label.txt == "Miner", "survol d'un filon")
M.tipShown = false; GameTooltip.hooks.OnHide(GameTooltip)   -- lignes restées en mémoire, comme en jeu
ok(M.bindings.F:find("CLICK", 1, true), "bulle cachée : retour au lancer malgré les lignes restantes (relecture, point 5)")
M.tipShown = true; M.tipOwner = {}; M.tipLines = { "Pioche de mineur", "Minage" }; GameTooltip.hooks.OnShow(GameTooltip)
ok(M.bindings.F:find("CLICK", 1, true), "bulle d'un objet du sac : ignorée")
