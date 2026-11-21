-- Tâche 5 : son renforcé pendant la pêche
local M = dofile("test/mock.lua")
M.locale = "frFR"; M.reset()
dofile("HookAndHarvest/Locales/enUS.lua"); dofile("HookAndHarvest/Core.lua"); dofile("HookAndHarvest/Sound.lua")
HH.Config:Init()
local Snd = HH.Sound

M.cvars = { Sound_SFXVolume = "0.4", Sound_EnableMusic = "1", Sound_EnableAmbience = "1" }
Snd:Boost(); ok(M.cvars.Sound_SFXVolume == "1" and M.cvars.Sound_EnableMusic == "0" and M.cvars.Sound_EnableAmbience == "0", "son renforcé, musique et ambiance coupées")
Snd:Boost(); ok(HookAndHarvestDB.soundSaved.Sound_SFXVolume == "0.4", "second Boost n'écrase pas l'original")
Snd:Restore(); ok(M.cvars.Sound_SFXVolume == "0.4" and M.cvars.Sound_EnableMusic == "1" and HookAndHarvestDB.soundSaved == nil, "valeurs remises")
Snd:Restore(); ok(M.cvars.Sound_SFXVolume == "0.4", "Restore sans Boost : rien")
Snd:Boost() -- plantage simulé : rechargement sans Restore
M.cvars.Sound_SFXVolume = "1"; Snd:Restore()   -- appelé par PLAYER_LOGIN
ok(M.cvars.Sound_SFXVolume == "0.4", "rechargement -> réglages d'origine")
HH.Config:Set("soundMuteMusic", false); Snd:Boost()
ok(M.cvars.Sound_SFXVolume == "1" and M.cvars.Sound_EnableMusic == "1", "musique gardée si option coupée")
Snd:Restore()
HH.Config:Set("soundVolume", 0.8); Snd:Boost(); ok(M.cvars.Sound_SFXVolume == "0.8", "volume réglable")
Snd:Restore()
HH.Config:Set("soundBoost", false); Snd:Boost(); ok(M.cvars.Sound_SFXVolume == "0.4", "option coupée -> aucun changement")
