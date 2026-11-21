-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Sound.lua
--  Pendant la pêche : volume des effets renforcé (et musique,
--  ambiance coupées) pour entendre le plouf du bouchon. Les
--  valeurs d'origine sont sauvées dans HookAndHarvestDB, donc
--  remises même après un plantage ou un /reload.
-- ============================================================

HH.Sound = {}
local Sound = HH.Sound

local SAVED = { "Sound_SFXVolume", "Sound_EnableMusic", "Sound_EnableAmbience" }

function Sound:Boost()
    local cfg = HH.Config
    if not cfg:Get("soundBoost") or HookAndHarvestDB.soundSaved then return end
    local saved = {}
    for _, k in ipairs(SAVED) do saved[k] = C_CVar.GetCVar(k) end
    HookAndHarvestDB.soundSaved = saved
    C_CVar.SetCVar("Sound_SFXVolume", cfg:Get("soundVolume"))
    if cfg:Get("soundMuteMusic") then
        C_CVar.SetCVar("Sound_EnableMusic", "0")
        C_CVar.SetCVar("Sound_EnableAmbience", "0")
    end
end

function Sound:Restore()
    local saved = HookAndHarvestDB and HookAndHarvestDB.soundSaved
    if not saved then return end
    for k, v in pairs(saved) do C_CVar.SetCVar(k, v) end
    HookAndHarvestDB.soundSaved = nil
end
