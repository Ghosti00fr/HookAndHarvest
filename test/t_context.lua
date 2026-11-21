-- Tâche 2 : choix du contexte
local M = dofile("test/mock.lua")
local function load(locale)
    M.locale = locale; M.reset()
    dofile("HookAndHarvest/Locales/enUS.lua"); dofile("HookAndHarvest/Locales/frFR.lua"); dofile("HookAndHarvest/Locales/esES.lua")
    dofile("HookAndHarvest/Core.lua"); dofile("HookAndHarvest/Nodes.lua"); dofile("HookAndHarvest/Context.lua")
    HH.Config:Init()
    return HH.Context
end

-- Classify (anglais)
local C = load("enUS")
ok(C.Classify({ "Fishing Bobber" }) == "bobber", "bouchon EN")
ok(C.Classify({ "Peacebloom", "Herbalism" }) == "herb", "herbe EN")
ok(C.Classify({ "Copper Vein", "Requires Mining 1" }) == "ore", "filon")
ok(C.Classify({ "Young Wolf", "Level 2", "Skinnable" }) == "skin", "corps dépeçable")
ok(C.Classify({ "Mailbox" }) == nil, "objet sans intérêt")
ok(C.Classify(nil) == nil and C.Classify({}) == nil, "aucune ligne")
ok(C.FishingSpell() == "Fishing", "sort Pêche EN trouvé")

-- Classify (français, espagnol)
C = load("frFR")
ok(C.Classify({ "Flotteur" }) == "bobber", "bouchon FR")
ok(C.Classify({ "Feuillargent", "Herboristerie" }) == "herb", "herbe FR")
ok(C.Classify({ "Filon de cuivre", "Minage" }) == "ore", "filon FR")
ok(C.Classify({ "Jeune loup", "Dépeçable" }) == "skin", "peau FR")
ok(C.FishingSpell() == "Pêche", "sort Pêche FR trouvé")
local Ces = load("esES")
ok(Ces.Classify({ "Corcho de pesca" }) == "bobber" and Ces.Classify({ "Filón de cobre", "Minería" }) == "ore", "ES")
C = load("frFR")

-- Resolve
ok(C.Resolve({ kind = "herb", fishingKnown = true }) == "herb", "herbe visée")
ok(C.Resolve({ kind = nil, fishingKnown = true }) == "cast", "rien visé -> lancer")
HH.Config:Set("herbalism", false)
ok(C.Resolve({ kind = "herb", fishingKnown = true }) == "cast", "herbo désactivée -> retombe sur lancer")
ok(C.Resolve({ kind = nil, fishingKnown = false }) == nil, "Pêche inconnue -> rien")
HH.Config:Set("fishing", false)
ok(C.Resolve({ kind = "bobber", fishingKnown = true }) == nil, "pêche désactivée -> ni bouchon ni lancer")
ok(C.Resolve({ kind = "ore", fishingKnown = true }) == "ore", "minage seul encore actif")
HH.Config:Set("enabled", false)
ok(C.Resolve({ kind = "ore", fishingKnown = true }) == nil, "addon désactivé")

-- DetectMode
M.cvars.SoftTargetInteract = "0"; ok(C.DetectMode() == "native", "CVar présente -> natif")
M.cvars.SoftTargetInteract = nil; ok(C.DetectMode() == "mouse", "CVar absente -> souris")
HH.Config:Set("mode", "native"); ok(C.DetectMode() == "native", "mode forcé natif")
M.cvars.SoftTargetInteract = "0"; HH.Config:Set("mode", "mouse"); ok(C.DetectMode() == "mouse", "mode forcé souris")

-- Pêche inconnue
M.known = {}; ok(C.FishingSpell() == nil, "Pêche inconnue -> nil")

-- relecture : métier inconnu du personnage (vigilance 3)
C = load("frFR")
ok(C.Resolve({ kind = "skin", fishingKnown = true, known = { herb = true } }) == "cast", "dépeçage inconnu -> pas de « Dépecer »")
ok(C.Resolve({ kind = "herb", fishingKnown = true, known = { herb = true } }) == "herb", "herbo connue -> « Cueillir »")
ok(C.Resolve({ kind = "bobber", fishingKnown = true, known = {} }) == "bobber", "bouchon : seul Pêche compte")
ok(C.Resolve({ kind = "ore", fishingKnown = true }) == "ore", "liste des métiers indisponible -> pas de filtre")
M.profs = { 182 }; local k = C.KnownProfessions()
ok(k.herb and not k.ore and not k.skin, "métiers connus lus par ligne de compétence")
GetProfessions = nil; ok(C.KnownProfessions() == nil, "API absente -> nil (pas de filtre)")

-- canne à pêche : sans canne, F ne lance pas la pêche (Forever l'exige)
C = load("frFR")
ok(C.Resolve({ kind = nil, fishingKnown = true, pole = false }) == nil, "sans canne : pas de « Lancer la ligne »")
ok(C.Resolve({ kind = "herb", fishingKnown = true, pole = false }) == "herb", "sans canne : la récolte marche")
ok(C.Resolve({ kind = nil, fishingKnown = true, pole = true }) == "cast", "canne équipée : lancer")
ok(C.PoleEquipped() == true, "canne détectée (arme, sous-classe 20)")
M.mainhand = { id = 25, class = 2, sub = 7 }; ok(C.PoleEquipped() == false, "épée : pas une canne")
M.mainhand = nil; ok(C.PoleEquipped() == false, "main vide : pas de canne")
local gii = GetItemInfoInstant
GetItemInfoInstant = nil; ok(C.PoleEquipped() == true, "API absente : pas de filtre")
GetItemInfoInstant = gii

-- objets du monde : Forever ne donne pas leur bulle d'aide, seulement nom et GUID
C = load("frFR")
ok(C.ObjectID("GameObject-0-6867-1-48-1617-8B58AE6C93") == 1617, "numéro d'objet lu dans le GUID")
ok(C.ObjectID("Creature-0-6867-1-48-299-0000") == nil and C.ObjectID(nil) == nil, "pas un objet -> nil")
ok(C.ClassifyObject(1617, "Feuillargent") == "herb", "Feuillargent (1617) -> herbe")
ok(C.ClassifyObject(176589, "Lotus noir") == "herb", "Lotus noir -> herbe")
ok(C.ClassifyObject(1731, "Filon de cuivre") == "ore", "Filon de cuivre (1731) -> minerai")
ok(C.ClassifyObject(999001, "Gisement de mithril") == "ore", "nom « Gisement » -> minerai")
ok(C.ClassifyObject(999002, "Filon de thorium") == "ore", "nom « Filon » -> minerai")
ok(C.ClassifyObject(999003, "Boîte aux lettres") == nil, "objet sans intérêt")
ok(C.ClassifyObject(999003, "Herbe inconnue", { [999003] = "herb" }) == "herb", "objet appris")
ok(C.LootKind({ 765 }) == "herb" and C.LootKind({ 2589, 2770 }) == "ore" and C.LootKind({ 2589 }) == nil, "type de butin : herbe, minerai, autre")
C = load("enUS"); ok(C.ClassifyObject(999004, "Small Thorium Vein") == "ore" and C.ClassifyObject(999005, "Iron Deposit") == "ore", "noms anglais")
C = load("esES"); ok(C.ClassifyObject(999006, "Filón de cobre") == "ore" and C.ClassifyObject(999007, "Depósito de hierro") == "ore", "noms espagnols")

-- coffres au sol et butin des corps
C = load("frFR")
ok(C.ClassifyObject(999010, "Coffre usé") == "chest", "« Coffre » -> coffre")
ok(C.Resolve({ kind = "chest", fishingKnown = true, known = {} }) == "chest", "coffre : aucun métier requis")
ok(C.Resolve({ kind = "loot", fishingKnown = true, known = {} }) == "loot", "butin : aucun métier requis")
HH.Config:Set("chests", false); HH.Config:Set("looting", false)
ok(C.Resolve({ kind = "chest", fishingKnown = true, pole = false }) == nil and C.Resolve({ kind = "loot", fishingKnown = true, pole = false }) == nil, "options coupées : rien")
C = load("enUS"); ok(C.ClassifyObject(999011, "Battered Chest") == "chest", "coffre EN")
C = load("esES"); ok(C.ClassifyObject(999012, "Cofre maltrecho") == "chest", "coffre ES")

-- capture du 2026-11-10 : mot repère en minuscule au milieu du nom
C = load("frFR")
ok(C.ClassifyObject(75293, "Grand coffre endommagé") == "chest", "« Grand coffre endommagé » -> coffre")
ok(C.ClassifyObject(999020, "Petit filon de thorium") == "ore", "« Petit filon de thorium » -> minerai")
C = load("enUS"); ok(C.ClassifyObject(999021, "Large battered chest") == "chest", "« chest » en minuscule -> coffre")
