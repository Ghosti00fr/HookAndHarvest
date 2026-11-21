-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Binding.lua
--  Liaison prioritaire de la touche (F) selon le contexte, bouton
--  sécurisé qui lance Pêche, et libération de F en combat par un
--  pilote d'état sécurisé.
-- ============================================================

HH.Binding = {}
local Binding = HH.Binding

local INTERACT = { native = "INTERACTTARGET", mouse = "INTERACTMOUSEOVER" }

function Binding:Create()
    -- propriétaire des liaisons : en combat, le code restreint efface F
    local owner = CreateFrame("Frame", "HookAndHarvestOwner", UIParent, "SecureHandlerStateTemplate")
    owner:SetAttribute("_onstate-combat", "if newstate == 1 then self:ClearBindings() end")
    RegisterStateDriver(owner, "combat", "[combat] 1; 0")
    self.owner = owner

    local b = CreateFrame("Button", "HookAndHarvestCastButton", UIParent, "SecureActionButtonTemplate")
    b:SetAttribute("type", "spell")
    b:SetAttribute("spell", HH.Context.FishingSpell())
    b:RegisterForClicks("AnyDown", "AnyUp")
    -- PreClick tourne pendant l'appui réel : /dire autorisé ici.
    -- Le bouton reçoit l'appui ET le relâchement : on n'agit qu'une fois,
    -- sur le même front que le sort (réglage ActionButtonUseKeyDown).
    -- Son et compteur attendent le vrai début de la pêche (Core.lua) :
    -- un lancer raté ne doit ni compter ni laisser le son renforcé.
    b:SetScript("PreClick", function(_, _, down)
        local useDown = C_CVar.GetCVar("ActionButtonUseKeyDown") ~= "0"
        if (down and true or false) ~= useDown then return end
        if HH.RP then HH.RP:OnCast() end
    end)
    self.button = b
end

-- ne refait rien si le contexte, le mode et la touche n'ont pas changé
function Binding:Apply(ctx, mode)
    if InCombatLockdown() then return end
    local key = HH.Config:Get("key")
    if self.applied and ctx == self.ctx and mode == self.mode and key == self.key then return end
    ClearOverrideBindings(self.owner)
    if ctx == "cast" then
        SetOverrideBindingClick(self.owner, true, key, "HookAndHarvestCastButton")
    elseif ctx then
        SetOverrideBinding(self.owner, true, key, INTERACT[mode])
    end
    self.applied, self.ctx, self.mode, self.key = true, ctx, mode, key
end

-- sortie de combat, changement de touche : on repose la liaison
function Binding:Refresh()
    if InCombatLockdown() then return end
    local ctx, mode = self.ctx, self.mode
    self.applied = false
    self:Apply(ctx, mode)
end

-- SPELLS_CHANGED : Pêche apprise ou oubliée
function Binding:UpdateSpell()
    if InCombatLockdown() or not self.button then return end
    self.button:SetAttribute("spell", HH.Context.FishingSpell())
end
