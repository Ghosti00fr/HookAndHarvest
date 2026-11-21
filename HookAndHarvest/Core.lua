-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Core.lua
--  Espace de noms, réglages enregistrés, données par personnage.
-- ============================================================

HH = HH or {}
HH.VERSION    = "1.0.7"
HH.DB_VERSION = 1
HH.PATH       = "Interface\\AddOns\\HookAndHarvest\\"
HH.TEX_PATH   = HH.PATH .. "textures\\"

-- ---- Réglages ------------------------------------------------
HH.Config = { defaults = {
    enabled = true, key = "F",
    fishing = true, herbalism = true, mining = true, skinning = true, chests = true, looting = true,
    mode = "auto",
    rpSay = true, rpChance = 20, rpCooldown = 60, rpEmoteCatch = false, rpSilentInGroup = true,
    prompt = true, promptScale = 1.0, x = 0, y = -180,
    soundBoost = true, soundVolume = 1.0, soundMuteMusic = true,
    history = true, historySize = 100,
} }
local Config = HH.Config

-- migrations futures : une étape par version, jamais de renommage brutal
function Config:Migrate(db)
    db.version = db.version or HH.DB_VERSION
end

function Config:Init()
    HookAndHarvestDB = HookAndHarvestDB or {}
    local db = HookAndHarvestDB
    for k, v in pairs(self.defaults) do
        if db[k] == nil then db[k] = v end
    end
    self:Migrate(db)
    db.chars = db.chars or {}
    db.learned = db.learned or {}   -- objets appris : [numéro] = "herb" | "ore"
    self.db = db
end
function Config:Get(k) return self.db and self.db[k] end
function Config:Set(k, v) if self.db then self.db[k] = v end end

-- ---- Contexte courant -> liaison + invite ---------------------
-- Forever (comme le Retail 12) rend certaines valeurs « secrètes » pour
-- les addons, en instance surtout : les lire lève une erreur. On les ignore.
local function Plain(v)
    if issecretvalue and issecretvalue(v) then return nil end
    return v
end
HH.Plain = Plain

-- lignes de la bulle d'aide de la cible douce (mode natif)
local function SoftLines()
    if not (C_TooltipInfo and C_TooltipInfo.GetUnit) then return nil end
    local data = C_TooltipInfo.GetUnit("softinteract")
    if not data or not data.lines then return nil end
    local lines = {}
    for _, l in ipairs(data.lines) do lines[#lines + 1] = Plain(l.leftText) end
    return lines
end

-- lignes de GameTooltip visibles (mode souris) ; seules les bulles du monde
-- (propriétaire UIParent) comptent, pas celles des sacs ou du grimoire
local function MouseLines()
    if not GameTooltip:IsShown() or GameTooltip:GetOwner() ~= UIParent then return nil end
    local n = GameTooltip:NumLines() or 0
    if n == 0 then return nil end
    local lines = {}
    for i = 1, n do
        local fs = _G["GameTooltipTextLeft" .. i]
        lines[#lines + 1] = fs and Plain(fs:GetText())
    end
    return lines
end

-- CVar d'interaction douce : posée à "3" en mode natif, remise si l'addon est coupé
local function SetSoftInteract(on)
    local db = HookAndHarvestDB
    if on and db.softSaved == nil then
        db.softSaved = C_CVar.GetCVar("SoftTargetInteract")
        C_CVar.SetCVar("SoftTargetInteract", "3")
    elseif not on and db.softSaved ~= nil then
        C_CVar.SetCVar("SoftTargetInteract", db.softSaved)
        db.softSaved = nil
    end
end

function HH:Update()
    local cfg, C = self.Config, self.Context
    SetSoftInteract(self.mode == "native" and cfg:Get("enabled"))
    -- en combat, F a sa fonction normale : pas d'invite
    if self.inCombat or InCombatLockdown() then return self.Prompt:Show(nil) end
    local spell = C.FishingSpell()
    -- corps avec du butin : à fouiller avant de le dépecer
    local guid = self.mode == "native" and Plain(UnitGUID("softinteract"))
    local kind = guid and guid:match("^Creature") and CanLootUnit and Plain(CanLootUnit(guid)) and "loot" or nil
    kind = kind or C.Classify(self.mode == "native" and UnitExists("softinteract") and SoftLines() or
                            self.mode == "mouse" and MouseLines() or nil)
    -- herbes et filons : Forever ne donne que le nom et le GUID de l'objet
    if not kind and guid then
        local id = C.ObjectID(guid)
        if id then
            kind = C.ClassifyObject(id, Plain(UnitName("softinteract")), HookAndHarvestDB.learned)
            self.lastObject, self.lastObjectTime = id, GetTime()
        end
    end
    -- pendant la pêche, F ne doit jamais relancer (ça couperait la ligne)
    if not kind and spell and Plain(UnitChannelInfo("player")) == spell then kind = "bobber" end
    -- le jeu cache tout (en instance) mais quelque chose est visé : invite générique
    if not kind and self.mode == "native" and issecretvalue and issecretvalue(UnitGUID("softinteract")) then kind = "interact" end
    local ctx = C.Resolve({ kind = kind, fishingKnown = spell ~= nil, known = self.known, pole = C.PoleEquipped() })
    self.Binding:Apply(ctx, self.mode)
    self.Prompt:Show(ctx)
end

-- butin hors pêche juste après avoir visé un objet inconnu : on retient
-- si c'était une herbe ou un filon (fenêtre de 10 s contre les erreurs)
function HH:Learn()
    if (IsFishingLoot and IsFishingLoot()) or not self.lastObject then return end
    if GetTime() - (self.lastObjectTime or 0) > 10 then return end
    local ids = {}
    for i = 1, GetNumLootItems() do
        local link = GetLootSlotLink(i)
        local id = link and tonumber(link:match("item:(%d+)"))
        if id then ids[#ids + 1] = id end
    end
    local kind = self.Context.LootKind(ids)
    if kind and not self.Context.ClassifyObject(self.lastObject) then
        HookAndHarvestDB.learned[self.lastObject] = kind
    end
end

-- ---- Événements ----------------------------------------------
local function Update() HH:Update() end

HH.events = CreateFrame("Frame")
HH.events:RegisterEvent("PLAYER_LOGIN")
HH.events:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_LOGIN" then
        Config:Init()
        HH.mode = HH.Context.DetectMode()
        HH.known = HH.Context.KnownProfessions()
        HH.Sound:Restore()   -- réparation après un plantage pendant la pêche
        HH.Binding:Create()
        HH.Prompt:Create()
        if HH.Options then HH.Options:Create() end
        if HH.Commands then HH.Commands:Register() end
        local ev = HH.events
        for _, e in ipairs({ "PLAYER_SOFT_INTERACT_CHANGED", "SPELLS_CHANGED", "SKILL_LINES_CHANGED",
                             "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "LOOT_OPENED", "PLAYER_EQUIPMENT_CHANGED" }) do ev:RegisterEvent(e) end
        ev:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
        ev:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
        if HH.mode == "mouse" then
            ev:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
            GameTooltip:HookScript("OnShow", Update)
            GameTooltip:HookScript("OnHide", Update)
        end
        print("|cff3d9be9Hook & Harvest|r " .. HH.L.loaded)
        HH:Update()
    elseif event == "LOOT_OPENED" then
        HH:Learn()
        HH.Stats:OnLootOpened()
    elseif event == "PLAYER_REGEN_DISABLED" then
        HH.inCombat = true
        HH.Prompt:Show(nil)
    elseif event == "PLAYER_REGEN_ENABLED" then
        HH.inCombat = false
        HH.Binding:Refresh()
        HH:Update()
    elseif event == "SKILL_LINES_CHANGED" then
        HH.known = HH.Context.KnownProfessions()
        HH:Update()
    elseif event == "SPELLS_CHANGED" then
        HH.Binding:UpdateSpell()
        HH:Update()
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        if unit ~= "player" then return end
        if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
            HH.Sound:Restore()
        elseif Plain(UnitChannelInfo("player")) == HH.Context.FishingSpell() then
            -- la pêche a vraiment démarré : son renforcé et lancer compté
            HH.Sound:Boost()
            HH.Stats:Cast()
        end
        HH:Update()
    else
        HH:Update()
    end
end)

-- sous-table du personnage : "Nom-Royaume"
function Config:Char()
    local key = (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
    local c = self.db.chars[key]
    if not c then
        c = { totals = {}, history = {}, count = 0, casts = 0 }
        self.db.chars[key] = c
    end
    return c
end
