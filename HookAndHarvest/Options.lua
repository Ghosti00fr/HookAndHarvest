-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Options.lua
--  Fenêtre d'options (/hh), aussi listée dans Options > AddOns.
--  Même construction que Forever Cast Bars.
-- ============================================================

HH.Options = {}
local O = HH.Options
local MODES = { auto = "native", native = "mouse", mouse = "auto" }

-- ---- Réglages qui demandent une action immédiate -------------
function O:SetKey(k)
    k = (k or ""):upper():gsub("%s", "")
    if k == "" then return end
    HH.Config:Set("key", k)
    HH.Binding:Refresh()
    HH:Update()
end

function O:SetHistorySize(n)
    HH.Config:Set("historySize", n)
    HH.Stats:Trim()
end

-- position de l'invite, bornée pour rester à l'écran
function O:SetPos(x, y)
    local cfg = HH.Config
    if x then cfg:Set("x", math.max(-800, math.min(800, x))) end
    if y then cfg:Set("y", math.max(-600, math.min(600, y))) end
    HH.Prompt:ApplyPosition()
end

function O:ResetPos()
    local d = HH.Config.defaults
    self:SetPos(d.x, d.y)
end

function O:CycleMode()
    HH.Config:Set("mode", MODES[HH.Config:Get("mode")] or "auto")
    HH.Commands.say(HH.L.mode_reload)
end

local function Apply(key)
    if key == "promptScale" and HH.Prompt.frame then HH.Prompt.frame:SetScale(HH.Config:Get(key)) end
    if key == "historySize" then HH.Stats:Trim() end
    HH:Update()
end

-- ---- Contrôles ------------------------------------------------
local function Header(parent, text, x, y)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fs:SetPoint("TOPLEFT", x, y); fs:SetText(text); return fs
end

local function CfgCheck(parent, x, y, key, label)
    local b = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    b:SetPoint("TOPLEFT", x, y); b:SetSize(24, 24)
    local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("LEFT", b, "RIGHT", 4, 0); fs:SetText(label); fs:SetJustifyH("LEFT")
    b:SetScript("OnClick", function(self) HH.Config:Set(key, self:GetChecked() and true or false); Apply(key) end)
    b.Refresh = function() b:SetChecked(HH.Config:Get(key) and true or false) end
    O.controls[#O.controls + 1] = b
    return b
end

local function Stepper(parent, x, y, key, label, step, lo, hi, fmt, set)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("TOPLEFT", x, y - 4)
    local function txt() fs:SetText(label .. " : " .. string.format(fmt, HH.Config:Get(key) or 0)) end
    local minus = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate"); minus:SetSize(26, 22); minus:SetText("-")
    local plus = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate"); plus:SetSize(26, 22); plus:SetText("+")
    minus:SetPoint("TOPLEFT", x + 250, y); plus:SetPoint("LEFT", minus, "RIGHT", 4, 0)
    local function change(d)
        local v = math.max(lo, math.min(hi, (HH.Config:Get(key) or lo) + d))
        v = math.floor(v / step + .5) * step
        if set then set(v) else HH.Config:Set(key, v); Apply(key) end
        txt()
    end
    minus:SetScript("OnClick", function() change(-step) end)
    plus:SetScript("OnClick", function() change(step) end)
    O.controls[#O.controls + 1] = { Refresh = txt }
end

local function Button(parent, x, y, w, label, fn)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetPoint("TOPLEFT", x, y); b:SetSize(w, 24); b:SetText(label); b:SetScript("OnClick", fn); return b
end

function O:Build(p)
    local L = HH.L
    self.controls = {}
    local t = p:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    t:SetPoint("TOPLEFT", 16, -14); t:SetText("|cff3d9be9Hook & Harvest|r  v" .. HH.VERSION)

    -- colonne gauche
    local x, y = 16, -50
    Header(p, L.sec_general, x, y); y = y - 28
    CfgCheck(p, x, y, "enabled", L.opt_enabled); y = y - 30
    local kl = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight"); kl:SetPoint("TOPLEFT", x, y - 4); kl:SetText(L.opt_key)
    local eb = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
    eb:SetPoint("TOPLEFT", x + 250, y); eb:SetSize(60, 22); eb:SetAutoFocus(false)
    eb:SetScript("OnEnterPressed", function(s) O:SetKey(s:GetText()); s:SetText(HH.Config:Get("key")); s:ClearFocus() end)
    eb:SetScript("OnEscapePressed", function(s) s:SetText(HH.Config:Get("key")); s:ClearFocus() end)
    self.controls[#self.controls + 1] = { Refresh = function() eb:SetText(HH.Config:Get("key")) end }
    y = y - 30
    CfgCheck(p, x, y, "fishing", L.opt_fishing); y = y - 26
    CfgCheck(p, x, y, "herbalism", L.opt_herbalism); y = y - 26
    CfgCheck(p, x, y, "mining", L.opt_mining); y = y - 26
    CfgCheck(p, x, y, "skinning", L.opt_skinning); y = y - 26
    CfgCheck(p, x, y, "chests", L.opt_chests); y = y - 26
    CfgCheck(p, x, y, "looting", L.opt_looting); y = y - 32
    local mb
    mb = Button(p, x, y, 220, "", function() O:CycleMode(); mb.Refresh() end)
    mb.Refresh = function() mb:SetText(L.opt_mode .. " : " .. L["mode_" .. HH.Config:Get("mode")]) end
    self.controls[#self.controls + 1] = mb
    y = y - 40

    Header(p, L.sec_prompt, x, y); y = y - 28
    CfgCheck(p, x, y, "prompt", L.opt_prompt); y = y - 30
    Stepper(p, x, y, "promptScale", L.opt_scale, .1, .5, 2, "%.1f"); y = y - 30
    Stepper(p, x, y, "x", L.opt_posX, 10, -800, 800, "%d", function(v) O:SetPos(v, nil) end); y = y - 30
    Stepper(p, x, y, "y", L.opt_posY, 10, -600, 600, "%d", function(v) O:SetPos(nil, v) end); y = y - 32
    Button(p, x + 226, y, 150, L.btn_resetPos, function() O:ResetPos(); O:Refresh() end)
    local ub
    ub = Button(p, x, y, 220, L.btn_unlock, function()
        HH.Prompt:SetUnlocked(not HH.Prompt.unlocked)
        ub:SetText(HH.Prompt.unlocked and L.btn_lock or L.btn_unlock)
        if HH.Prompt.unlocked then HH.Prompt:Show(HH.Prompt.ctx or "cast") else HH:Update() end
    end)

    -- colonne droite
    local tx, ty = 420, -50
    Header(p, L.sec_rp, tx, ty); ty = ty - 28
    CfgCheck(p, tx, ty, "rpSay", L.opt_rpSay); ty = ty - 30
    Stepper(p, tx, ty, "rpChance", L.opt_rpChance, 5, 0, 100, "%d%%"); ty = ty - 30
    CfgCheck(p, tx, ty, "rpEmoteCatch", L.opt_rpEmote); ty = ty - 26
    CfgCheck(p, tx, ty, "rpSilentInGroup", L.opt_rpSilent); ty = ty - 40

    Header(p, L.sec_sound, tx, ty); ty = ty - 28
    CfgCheck(p, tx, ty, "soundBoost", L.opt_soundBoost); ty = ty - 30
    Stepper(p, tx, ty, "soundVolume", L.opt_soundVolume, .1, 0, 1, "%.1f"); ty = ty - 30
    CfgCheck(p, tx, ty, "soundMuteMusic", L.opt_soundMute); ty = ty - 40

    Header(p, L.sec_history, tx, ty); ty = ty - 28
    CfgCheck(p, tx, ty, "history", L.opt_history); ty = ty - 30
    Stepper(p, tx, ty, "historySize", L.opt_historySize, 50, 0, 500, "%d", function(v) O:SetHistorySize(v) end); ty = ty - 34
    Button(p, tx, ty, 170, L.btn_stats, function() HH.Commands:Stats() end)
    Button(p, tx + 176, ty, 170, L.btn_reset, function() StaticPopup_Show("HOOKANDHARVEST_RESET") end)
end

function O:Refresh() for _, c in ipairs(self.controls or {}) do if c.Refresh then c.Refresh() end end end

function O:Create()
    local p = CreateFrame("Frame", "HookAndHarvestOptions", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    p:SetSize(800, 580); p:SetPoint("CENTER"); p:SetFrameStrata("DIALOG"); p:Hide()
    p:SetMovable(true); p:EnableMouse(true); p:RegisterForDrag("LeftButton")
    p:SetScript("OnDragStart", p.StartMoving); p:SetScript("OnDragStop", p.StopMovingOrSizing)
    if p.SetBackdrop then
        p:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                        tile = true, tileSize = 32, edgeSize = 32, insets = { left = 8, right = 8, top = 8, bottom = 8 } })
    end
    local close = CreateFrame("Button", nil, p, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", -6, -6)
    tinsert(UISpecialFrames, "HookAndHarvestOptions")
    self:Build(p)
    p:SetScript("OnShow", function() O:Refresh(); HH.Prompt:SetPreview(true) end)
    p:SetScript("OnHide", function() HH.Prompt:SetPreview(false) end)
    self.panel = p

    -- entrée dans Options > AddOns (ouvre la fenêtre)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local stub = CreateFrame("Frame")
        local b = CreateFrame("Button", nil, stub, "UIPanelButtonTemplate"); b:SetPoint("TOPLEFT", 16, -16); b:SetSize(220, 26)
        b:SetText("Hook & Harvest…"); b:SetScript("OnClick", function() O:Toggle() end)
        pcall(function()
            local cat = Settings.RegisterCanvasLayoutCategory(stub, "Hook & Harvest")
            Settings.RegisterAddOnCategory(cat)
        end)
    end
end

function O:Toggle()
    if not self.panel then return end
    if self.panel:IsShown() then self.panel:Hide() else self.panel:Show() end
end
