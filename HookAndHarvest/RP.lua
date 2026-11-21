-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — RP.lua
--  Phrases de pêcheur en /dire au lancer (pendant l'appui réel,
--  seul moment où le jeu autorise /dire en extérieur), et emote
--  facultative à la prise. Anti-spam : chance, délai, silence en
--  groupe, jamais deux fois la même phrase de suite.
-- ============================================================

HH.RP = { last = {} }
local RP = HH.RP

function RP:ShouldSpeak(now, roll)
    local cfg = HH.Config
    if not cfg:Get("rpSay") then return false end
    if cfg:Get("rpSilentInGroup") then
        local _, kind = IsInInstance()
        if IsInRaid() or kind == "party" or kind == "raid" then return false end
    end
    if self.lastSay and now - self.lastSay < cfg:Get("rpCooldown") then return false end
    return roll <= cfg:Get("rpChance")
end

-- roll dans [0, 1[ ; jamais le même index que le dernier tiré pour cette liste
function RP:Pick(list, roll)
    local n = #list
    local i = math.min(n, math.floor((roll or math.random()) * n) + 1)
    if n > 1 and i == self.last[list] then i = i % n + 1 end
    self.last[list] = i
    return i
end

function RP:OnCast()
    local now = GetTime()
    if not self:ShouldSpeak(now, math.random(100)) then return end
    local list = HH.L.rp_say
    SendChatMessage(list[self:Pick(list)], "SAY")
    self.lastSay = now
end

function RP:OnCatch(itemName)
    if not HH.Config:Get("rpEmoteCatch") then return end
    local list = HH.L.rp_catch
    SendChatMessage(string.format(list[self:Pick(list)], itemName), "EMOTE")
end
