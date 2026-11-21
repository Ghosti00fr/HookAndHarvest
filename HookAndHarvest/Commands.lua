-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Commands.lua  (/hh)
-- ============================================================

HH.Commands = {}
local Cmd = HH.Commands

local function say(t) print("|cff3d9be9[HH]|r " .. t) end
Cmd.say = say

function Cmd:Register()
    SLASH_HOOKANDHARVEST1 = "/hh"
    SLASH_HOOKANDHARVEST2 = "/hookandharvest"
    SlashCmdList["HOOKANDHARVEST"] = function(msg) Cmd:Handle(msg or "") end
    StaticPopupDialogs["HOOKANDHARVEST_RESET"] = {
        text = HH.L.reset_confirm, button1 = YES, button2 = NO,
        OnAccept = function() HH.Stats:Reset() end,
        timeout = 0, whileDead = true, hideOnEscape = true,
    }
end

local function ItemLink(id)
    local info = (C_Item and C_Item.GetItemInfo) or GetItemInfo
    local link = info and select(2, info(id))
    return link or ("item:" .. id)   -- objet pas encore en cache
end

function Cmd:Stats()
    local c = HH.Config:Char()
    say(string.format(HH.L.stats_header, c.count, c.casts))
    local top = HH.Stats:Top(10)
    if #top == 0 then return say(HH.L.stats_none) end
    for _, e in ipairs(top) do say(ItemLink(e.id) .. " x" .. e.n) end
end

-- infos de détection (cible douce, bulle d'aide, sort, métiers) :
-- remplace /dump, qui oblige à autoriser les scripts personnalisés
function Cmd:Diag()
    local C = HH.Context
    local function s(v) if issecretvalue and issecretvalue(v) then return "<secret>" end; return tostring(v) end
    say("diag — " .. string.format(HH.L.mode_line, HH.L["mode_" .. (HH.mode or "auto")])
        .. " | SoftTargetInteract = " .. s(C_CVar.GetCVar("SoftTargetInteract")))
    say("softinteract : exists=" .. s(UnitExists and UnitExists("softinteract"))
        .. " name=" .. s(UnitName("softinteract")) .. " guid=" .. s(UnitGUID and UnitGUID("softinteract")))
    if not (C_TooltipInfo and C_TooltipInfo.GetUnit) then
        say("C_TooltipInfo.GetUnit : absent")
    else
        local data = C_TooltipInfo.GetUnit("softinteract")
        if not (data and data.lines) then
            say("C_TooltipInfo.GetUnit(softinteract) = nil")
        else
            local lines = {}
            for _, l in ipairs(data.lines) do lines[#lines + 1] = s(l.leftText) end
            say("tooltip : " .. table.concat(lines, " / ") .. " -> " .. s(C.Classify(lines)))
        end
    end
    local guid = UnitGUID and HH.Plain(UnitGUID("softinteract"))
    if guid and guid:match("^Creature") then
        say("corps : CanLootUnit=" .. (CanLootUnit and s(CanLootUnit(guid)) or "absent")
            .. " dead=" .. s(UnitIsDead and UnitIsDead("softinteract")))
    end
    local id = C.ObjectID(guid)
    if id then
        say("objet " .. id .. " -> " .. s(C.ClassifyObject(id, HH.Plain(UnitName("softinteract")), HookAndHarvestDB.learned)))
    end
    say("sort Pêche = " .. s(C.FishingSpell()) .. " | canal = " .. s(UnitChannelInfo("player")))
    if not (GetProfessions and GetProfessionInfo) then
        say("GetProfessions : absent")
    else
        local list = {}
        for _, i in pairs({ GetProfessions() }) do
            local name = GetProfessionInfo(i)
            list[#list + 1] = s(name) .. "=" .. s(select(7, GetProfessionInfo(i)))
        end
        say("métiers : " .. (#list > 0 and table.concat(list, ", ") or "aucun"))
    end
end

function Cmd:Handle(msg)
    local c = msg:match("^%s*(%S*)"):lower()
    if c == "" or c == "options" then return HH.Options:Toggle() end
    if c == "stats" then return self:Stats() end
    if c == "diag" then return self:Diag() end
    if c == "reset" then return StaticPopup_Show("HOOKANDHARVEST_RESET") end
    if c == "mode" then return say(string.format(HH.L.mode_line, HH.L["mode_" .. (HH.mode or "auto")])) end
    say(HH.L.help)
end
