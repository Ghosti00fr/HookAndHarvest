-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Context.lua
--  Logique pure : que doit faire F ? (bouchon, herbe, filon,
--  peau, lancer, ou rien) et quel mode de détection utiliser.
-- ============================================================

HH.Context = {}
local Context = HH.Context

-- métier qui doit être activé pour chaque type d'objet
local PROFESSION = { bobber = "fishing", herb = "herbalism", ore = "mining", skin = "skinning",
                     chest = "chests", loot = "looting", interact = "enabled" }
-- types qui demandent d'avoir appris le métier
local NEEDS_SKILL = { herb = true, ore = true, skin = true }
local ORDER = { "bobber", "herb", "ore", "skin" }

-- lines : textes de la bulle d'aide (ligne 1 = nom de l'objet)
function Context.Classify(lines)
    if not lines then return nil end
    local L = HH.L
    for _, kind in ipairs(ORDER) do
        local kw = L["kw_" .. kind]
        for _, s in ipairs(lines) do
            if s and string.find(s, kw, 1, true) then return kind end
        end
    end
    return nil
end

-- numéro d'objet dans un GUID "GameObject-0-serveur-instance-zone-ID-spawn"
function Context.ObjectID(guid)
    if not guid then return nil end
    local id = guid:match("^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)")
    return id and tonumber(id)
end

-- objet visé : appris, liste des nœuds, puis mot repère du nom (filons)
function Context.ClassifyObject(id, name, learned)
    if learned and learned[id] then return learned[id] end
    if HH.Nodes.herb[id] then return "herb" end
    if HH.Nodes.ore[id] then return "ore" end
    if name then
        -- sans casse : « Grand coffre endommagé », « Petit filon de thorium »
        local low = name:lower()
        for _, w in ipairs(HH.L.ore_words) do
            if string.find(low, w:lower(), 1, true) then return "ore" end
        end
        for _, w in ipairs(HH.L.chest_words) do
            if string.find(low, w:lower(), 1, true) then return "chest" end
        end
    end
    return nil
end

-- type de butin : artisanat (classe 7), herbe (9) ou métal et pierre (7)
local LOOT = { [9] = "herb", [7] = "ore" }
function Context.LootKind(itemIDs)
    local info = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    if not info then return nil end
    for _, id in ipairs(itemIDs) do
        local _, _, _, _, _, class, sub = info(id)
        if class == 7 and LOOT[sub] then return LOOT[sub] end
    end
    return nil
end

-- s = { kind = <Classify>, fishingKnown = bool, known = <KnownProfessions> ou nil }
function Context.Resolve(s)
    local cfg = HH.Config
    if not cfg:Get("enabled") then return nil end
    local learned = not NEEDS_SKILL[s.kind] or not s.known or s.known[s.kind]
    if s.kind and learned and cfg:Get(PROFESSION[s.kind]) then return s.kind end
    -- Forever exige une canne : sans elle, F garde sa fonction normale
    if cfg:Get("fishing") and s.fishingKnown and s.pole ~= false then return "cast" end
    return nil
end

-- métiers de récolte appris, par ligne de compétence (IDs Retail, à vérifier
-- sur Forever) ; nil si l'API manque : on ne filtre alors rien
local SKILL_LINE = { [182] = "herb", [186] = "ore", [393] = "skin" }
function Context.KnownProfessions()
    if not (GetProfessions and GetProfessionInfo) then return nil end
    local known = {}
    for _, index in pairs({ GetProfessions() }) do
        local kind = SKILL_LINE[select(7, GetProfessionInfo(index))]
        if kind then known[kind] = true end
    end
    return known
end

-- canne à pêche en main droite (emplacement 16) : arme (classe 2),
-- sous-classe 20 ; sans API d'objet, on ne filtre pas
function Context.PoleEquipped()
    local info = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    if not info then return true end
    local id = GetInventoryItemID("player", 16)
    if not id then return false end
    local _, _, _, _, _, class, sub = info(id)
    return class == 2 and sub == 20
end

-- "native" si la CVar d'interaction douce existe, sinon "mouse"
function Context.DetectMode()
    local mode = HH.Config:Get("mode")
    if mode == "native" or mode == "mouse" then return mode end
    return (C_CVar and C_CVar.GetCVar("SoftTargetInteract") ~= nil) and "native" or "mouse"
end

-- nom du sort Pêche s'il est connu (résolu par nom, jamais d'ID en dur)
function Context.FishingSpell()
    local name, id = HH.L.spell_fishing, nil
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(name)
        id = info and info.spellID
    elseif GetSpellInfo then
        id = select(7, GetSpellInfo(name))
    end
    if not id then return nil end
    local known = (IsPlayerSpell and IsPlayerSpell(id)) or (IsSpellKnown and IsSpellKnown(id))
    return known and name or nil
end
