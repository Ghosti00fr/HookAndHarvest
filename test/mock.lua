-- Mock de l'API WoW pour les tests hors jeu de Hook & Harvest.
-- Usage : local M = dofile("test/mock.lua") ; M.locale = "frFR" ; M.reset()
local M = { locale = "frFR" }

local rawprint = print
function ok(c, m) rawprint((c and "OK  " or "FAIL") .. "  " .. m); if not c then os.exit(1) end end

-- ---- Cadres -------------------------------------------------
local function stub()
    local t = { shown = false, attrs = {}, scripts = {}, events = {}, hooks = {} }
    setmetatable(t, { __index = function() return function() end end })
    function t:Show() self.shown = true end
    function t:Hide() self.shown = false end
    function t:IsShown() return self.shown end
    function t:SetShown(v) self.shown = v and true or false end
    function t:SetAttribute(k, v) self.attrs[k] = v end
    function t:GetAttribute(k) return self.attrs[k] end
    function t:SetScript(n, fn) self.scripts[n] = fn end
    function t:GetScript(n) return self.scripts[n] end
    function t:HookScript(n, fn) self.hooks[n] = fn end
    function t:RegisterEvent(e) self.events[e] = true end
    function t:RegisterUnitEvent(e) self.events[e] = true end
    function t:UnregisterEvent(e) self.events[e] = nil end
    function t:CreateTexture() return stub() end
    function t:CreateFontString() local fs = stub(); function fs:SetText(s) self.txt = s end; function fs:GetText() return self.txt end; return fs end
    function t:SetTexture(p) self.tex = p end
    function t:SetVertexColor(r, g, b, a) self.color = { r, g, b, a } end
    function t:CreateAnimationGroup() local ag = stub(); ag.playing = false
        function ag:Play() self.playing = true end; function ag:Stop() self.playing = false end
        function ag:IsPlaying() return self.playing end; function ag:CreateAnimation() return stub() end; return ag end
    function t:GetName() return self.name end
    function t:GetPoint() return "CENTER", nil, "CENTER", self.x or 0, self.y or 0 end
    function t:SetPoint(...) self.point = { ... } end
    function t:ClearAllPoints() self.point = nil end
    function t:SetScale(v) self.scale = v end
    function t:GetScale() return self.scale or 1 end
    function t:GetCenter() return self.cx, self.cy end
    return t
end
M.stub = stub

function M.reset()
    M.now, M.combat, M.random = 0, false, nil
    M.cvars = { SoftTargetInteract = "0", Sound_SFXVolume = "1", Sound_EnableMusic = "1", Sound_EnableAmbience = "1" }
    M.bindings, M.clearCount, M.said, M.printed, M.drivers = {}, 0, {}, {}, {}
    M.known = { ["Pêche"] = 131474, ["Fishing"] = 131474, ["Pesca"] = 131474 }
    M.instance, M.raid = "none", false
    M.channel, M.soft, M.softLines, M.tipLines = nil, false, nil, nil
    M.loot = { fishing = false, items = {} }
    M.popup = nil
    M.profs = { 182, 186, 393 }   -- herbo, minage, dépeçage (lignes de compétence)
    M.tipShown, M.tipOwner = false, UIParent
    M.mainhand = { id = 6256, class = 2, sub = 20 }
    M.softName, M.softGUID = nil, nil
    M.canLoot = false
    M.items = { [765] = { 7, 9 }, [2770] = { 7, 7 }, [2589] = { 7, 5 } }   -- herbe, minerai, tissu   -- canne à pêche équipée (classe 2 arme, sous-classe 20)
    HookAndHarvestDB = nil
    HH = nil
end

-- ---- Globales -----------------------------------------------
UIParent = stub(); UIParent.cx, UIParent.cy = 960, 540
CreateFrame = function(kind, name, parent, template)
    local f = stub(); f.name, f.kind, f.template = name, kind, template
    if name then _G[name] = f end
    return f
end
GetTime = function() return M.now end
time = function() return 1000 + M.now end
GetLocale = function() return M.locale end
InCombatLockdown = function() return M.combat end
UnitName = function(u) if u == "softinteract" then return M.softName end; return "Ghosti" end
UnitGUID = function(u) if u == "softinteract" then return M.softGUID end end
-- valeur secrète (Retail 12 / Forever) : toute lecture par l'addon lève une erreur
SECRET = setmetatable({}, { __index = function() error("attempt to index a secret string value") end,
    __concat = function() error("attempt to concatenate a secret value") end,
    __tostring = function() error("attempt to convert a secret value") end })
issecretvalue = function(v) return v == SECRET end
CanLootUnit = function(guid) return M.canLoot, M.canLoot end
GetRealmName = function() return "Forever" end
IsInRaid = function() return M.raid end
IsInGroup = function() return M.raid end
IsInInstance = function() return M.instance ~= "none", M.instance end
GetBindingText = function(k) return k end
C_Map = { GetBestMapForUnit = function() return 12 end }
C_CVar = {
    GetCVar = function(k) return M.cvars[k] end,
    SetCVar = function(k, v) M.cvars[k] = tostring(v) end,
}
SetOverrideBinding = function(owner, prio, key, action) M.bindings[key] = action end
SetOverrideBindingClick = function(owner, prio, key, button, mouse)
    M.bindings[key] = "CLICK " .. button .. ":" .. (mouse or "LeftButton")
end
ClearOverrideBindings = function() M.bindings = {}; M.clearCount = M.clearCount + 1 end
RegisterStateDriver = function(frame, state, cond) M.drivers[frame:GetName()] = cond end
SendChatMessage = function(msg, chan) M.said[#M.said + 1] = { msg, chan } end
print = function(...)
    local t = {}; for i = 1, select("#", ...) do t[#t + 1] = tostring((select(i, ...))) end
    M.printed[#M.printed + 1] = table.concat(t, " ")
end
math.random = function(a, b) if M.random then return M.random end; return a and (b and a or 1) or 0.5 end

-- sorts
C_Spell = { GetSpellInfo = function(n)
    local id = M.known[n]; if not id then return nil end
    return { name = n, spellID = id }
end }
IsPlayerSpell = function(id) for _, v in pairs(M.known) do if v == id then return true end end; return false end

-- butin
IsFishingLoot = function() return M.loot.fishing end
GetNumLootItems = function() return #M.loot.items end
GetLootSlotLink = function(i) return M.loot.items[i].link end
GetLootSlotInfo = function(i) local it = M.loot.items[i]; return nil, it.name, it.qty end

-- cible douce, canal, bulle d'aide
UnitChannelInfo = function(u) if u == "player" then return M.channel end end
UnitExists = function(u) if u == "softinteract" then return M.soft end end
C_TooltipInfo = { GetUnit = function(u)
    if u ~= "softinteract" or not M.soft or not M.softLines then return nil end
    local lines = {}; for i, s in ipairs(M.softLines) do lines[i] = { leftText = s } end
    return { lines = lines }
end }
GameTooltip = stub()
GameTooltip.NumLines = function() return M.tipLines and #M.tipLines or 0 end
GameTooltip.IsShown = function() return M.tipShown end
GameTooltip.GetOwner = function() return M.tipOwner end
GetProfessions = function() local t = {}; for i = 1, #M.profs do t[i] = i end; return unpack(t) end
GetProfessionInfo = function(i) return "prof", nil, 1, 300, 0, 0, M.profs[i] end
for i = 1, 8 do
    local fs = stub(); fs.GetText = function() return M.tipLines and M.tipLines[i] end
    _G["GameTooltipTextLeft" .. i] = fs
end

-- commandes, fenêtres, confirmation
SlashCmdList, UISpecialFrames, StaticPopupDialogs = {}, {}, {}
tinsert = table.insert
YES, NO = "Oui", "Non"
StaticPopup_Show = function(n) M.popup = n end
function M.confirmPopup() StaticPopupDialogs[M.popup].OnAccept() end
GetItemInfo = function() return nil end
GetInventoryItemID = function(u, slot) if u == "player" and slot == 16 and M.mainhand then return M.mainhand.id end end
GetItemInfoInstant = function(id)
    if M.mainhand and id == M.mainhand.id then return id, "Arme", "Canne", "INVTYPE_2HWEAPON", 0, M.mainhand.class, M.mainhand.sub end
    local it = M.items and M.items[id]
    if it then return id, "Artisanat", "?", "", 0, it[1], it[2] end
end

return M
