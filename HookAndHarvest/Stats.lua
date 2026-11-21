-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Stats.lua
--  Compteur de prises (totaux par objet) et historique léger
--  des dernières prises, par personnage.
-- ============================================================

HH.Stats = {}
local Stats = HH.Stats

-- retire les plus anciennes prises au-delà de historySize
function Stats:Trim()
    local h, size = HH.Config:Char().history, HH.Config:Get("historySize") or 0
    while #h > size do table.remove(h, 1) end
end

function Stats:Record(itemID, qty, t, mapID)
    local c = HH.Config:Char()
    c.totals[itemID] = (c.totals[itemID] or 0) + qty
    c.count = c.count + qty
    if HH.Config:Get("history") then
        c.history[#c.history + 1] = { t = t, id = itemID, n = qty, map = mapID }
        self:Trim()
    end
end

function Stats:Cast()
    local c = HH.Config:Char()
    c.casts = c.casts + 1
end

-- liste { id, n } triée par quantité décroissante, puis id croissant
function Stats:Top(n)
    local list = {}
    for id, q in pairs(HH.Config:Char().totals) do list[#list + 1] = { id = id, n = q } end
    table.sort(list, function(a, b) if a.n ~= b.n then return a.n > b.n end; return a.id < b.id end)
    for i = #list, n + 1, -1 do list[i] = nil end
    return list
end

-- vide en place (les références à la sous-table restent valides)
function Stats:Reset()
    local c = HH.Config:Char()
    for k in pairs(c.totals) do c.totals[k] = nil end
    for i = #c.history, 1, -1 do c.history[i] = nil end
    c.count, c.casts = 0, 0
end

-- LOOT_OPENED : ne compte que le butin de pêche
function Stats:OnLootOpened()
    if not (IsFishingLoot and IsFishingLoot()) then return end
    local first
    for i = 1, GetNumLootItems() do
        local link = GetLootSlotLink(i)
        local id = link and tonumber(link:match("item:(%d+)"))
        if id then
            local qty = select(3, GetLootSlotInfo(i)) or 1
            self:Record(id, qty, time(), C_Map and C_Map.GetBestMapForUnit("player"))
            first = first or link:match("%[(.-)%]")
        end
    end
    if first and HH.RP then HH.RP:OnCatch(first) end
end
