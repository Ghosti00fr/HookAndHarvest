-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Prompt.lua
--  Invite « F » à l'écran (style A) : touche bois sombre, liseré
--  doré, halo coloré selon le métier, illustration autour du F.
--  Visible seulement quand F a quelque chose à faire.
-- ============================================================

HH.Prompt = {}
local Prompt = HH.Prompt

local function rgb(h)
    return tonumber(h:sub(2, 3), 16) / 255, tonumber(h:sub(4, 5), 16) / 255, tonumber(h:sub(6, 7), 16) / 255
end

-- contexte -> illustration, couleur du halo, clé du libellé
Prompt.STYLE = {
    cast   = { art = "fish",   color = "#3d9be9", label = "prompt_cast" },
    bobber = { art = "fish",   color = "#7fd3ff", label = "prompt_reel" },
    herb   = { art = "flower", color = "#5fbf4a", label = "prompt_herb" },
    ore    = { art = "ore",    color = "#c98a4b", label = "prompt_ore" },
    skin   = { art = "pelt",   color = "#b0452f", label = "prompt_skin" },
    chest  = { art = "chest",  color = "#e8b33a", label = "prompt_chest" },
    loot   = { art = "bag",    color = "#e6e2d0", label = "prompt_loot" },
    interact = { art = "bag",  color = "#e6e2d0", label = "prompt_interact" },   -- cible cachée par le jeu
}

function Prompt:Create()
    local cfg = HH.Config
    local f = CreateFrame("Frame", "HookAndHarvestPrompt", UIParent)
    f:SetSize(110, 110)
    self.frame = f
    self:ApplyPosition()
    f:SetFrameStrata("MEDIUM")
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(s) s:StartMoving() end)
    -- GetCenter est dans l'échelle de l'invite, celui d'UIParent non :
    -- on ramène tout à l'échelle de l'invite, sinon décalage au rechargement
    f:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        local x, y = s:GetCenter()
        local ux, uy = UIParent:GetCenter()
        local k = s:GetScale()
        if x and ux then cfg:Set("x", math.floor(x - ux / k + .5)); cfg:Set("y", math.floor(y - uy / k + .5)) end
        Prompt:ApplyPosition()
    end)
    f:EnableMouse(false)   -- les clics traversent l'invite tant qu'elle est verrouillée
    f:Hide()

    local art = f:CreateTexture(nil, "BACKGROUND")
    art:SetSize(110, 110); art:SetPoint("CENTER")
    local halo = f:CreateTexture(nil, "BORDER")
    halo:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    halo:SetBlendMode("ADD")
    halo:SetSize(84, 84); halo:SetPoint("CENTER")
    local key = f:CreateTexture(nil, "ARTWORK")
    key:SetTexture(HH.TEX_PATH .. "key")
    key:SetSize(50, 50); key:SetPoint("CENTER")
    local keyText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    keyText:SetPoint("CENTER", 0, 1)
    keyText:SetTextColor(0.96, 0.89, 0.69)
    local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOP", f, "BOTTOM", 0, 2)

    -- balancement de la fleur : 8°, 4 s, aller-retour (géré par le moteur)
    local sway = art:CreateAnimationGroup()
    sway:SetLooping("BOUNCE")
    local rot = sway:CreateAnimation("Rotation")
    rot:SetDegrees(8); rot:SetDuration(4); rot:SetOrigin("CENTER", 0, 0)

    self.frame, self.art, self.halo, self.key, self.keyText, self.label, self.sway = f, art, halo, key, keyText, label, sway
end

function Prompt:ApplyPosition()
    local cfg, f = HH.Config, self.frame
    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "CENTER", cfg:Get("x"), cfg:Get("y"))
    f:SetScale(cfg:Get("promptScale"))
end

-- aperçu : l'invite reste visible pendant que les options sont ouvertes
function Prompt:SetPreview(v)
    self.preview = v
    HH:Update()
end

function Prompt:SetUnlocked(v)
    self.unlocked = v
    if self.frame then self.frame:EnableMouse(v) end
end

function Prompt:Show(ctx)
    if not self.frame then return end
    ctx = ctx or (self.preview and "cast")
    local style = ctx and (HH.Config:Get("prompt") or self.preview) and self.STYLE[ctx]
    if not style then
        self.sway:Stop(); self.frame:Hide(); self.ctx = nil
        return
    end
    self.keyText:SetText(GetBindingText(HH.Config:Get("key")))
    if ctx ~= self.ctx then
        self.art:SetTexture(HH.TEX_PATH .. style.art)
        self.halo:SetVertexColor(rgb(style.color))
        self.label:SetText(HH.L[style.label])
        if ctx == "herb" then self.sway:Play() else self.sway:Stop() end
        self.ctx = ctx
    end
    self.frame:Show()
end
