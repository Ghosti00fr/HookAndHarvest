-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Locales/enUS.lua
--  Langue de base (anglais) et repli pour toute clé absente.
-- ============================================================

HH = HH or {}
local loc = GetLocale and GetLocale() or "enUS"
HH.LANG = (loc == "frFR") and "fr" or ((loc == "esES" or loc == "esMX") and "es" or "en")

-- clé absente -> la clé elle-même (visible, jamais d'erreur)
HH.L = setmetatable({}, { __index = function(_, k) return k end })
local L = HH.L

L.loaded      = "loaded. Type |cffffff00/hh|r for options."
L.prompt_cast = "Cast line"
L.prompt_reel = "Reel in!"
L.prompt_herb = "Gather"
L.prompt_ore  = "Mine"
L.prompt_skin = "Skin"
L.prompt_chest = "Open"
L.prompt_loot  = "Loot"
L.prompt_interact = "Interact"

-- options et commandes
L.sec_general     = "General"
L.opt_enabled     = "Enable Hook & Harvest"
L.opt_key         = "Key (Enter to apply)"
L.opt_fishing     = "Fishing"
L.opt_herbalism   = "Herbalism"
L.opt_mining      = "Mining"
L.opt_skinning    = "Skinning"
L.opt_chests      = "Ground chests"
L.opt_looting     = "Loot corpses"
L.opt_mode        = "Detection"
L.mode_auto       = "auto"
L.mode_native     = "native"
L.mode_mouse      = "mouse"
L.mode_line       = "Detection mode: %s"
L.mode_reload     = "Detection changed: type |cffffff00/reload|r to apply."
L.sec_rp          = "Roleplay"
L.opt_rpSay       = "Fishing lines in /say when casting"
L.opt_rpChance    = "Chance per cast"
L.opt_rpEmote     = "/emote when you catch something"
L.opt_rpSilent    = "Stay quiet in raids and dungeons"
L.sec_prompt      = "On-screen prompt"
L.opt_prompt      = "Show the prompt"
L.opt_scale       = "Size"
L.btn_unlock      = "Unlock (drag)"
L.opt_posX       = "Horizontal position"
L.opt_posY       = "Vertical position"
L.btn_resetPos   = "Default position"
L.btn_lock        = "Lock"
L.sec_sound       = "Sound"
L.opt_soundBoost  = "Louder effects while fishing"
L.opt_soundVolume = "Effects volume"
L.opt_soundMute   = "Mute music and ambience while fishing"
L.sec_history     = "Catch log"
L.opt_history     = "Keep a history of recent catches"
L.opt_historySize = "History size"
L.btn_stats       = "Show stats"
L.btn_reset       = "Reset stats"
L.stats_header    = "%d catches, %d casts."
L.stats_none      = "No catches yet."
L.reset_confirm   = "Reset all Hook & Harvest stats for this character?"
L.help            = "|cffffff00/hh|r options · |cffffff00/hh stats|r · |cffffff00/hh reset|r · |cffffff00/hh mode|r"

-- mots-clés lus dans les bulles d'aide, et nom du sort (à vérifier sur Forever)
L.kw_bobber     = "Fishing Bobber"
L.kw_herb       = "Herbalism"
L.kw_ore        = "Mining"
L.kw_skin       = "Skinnable"
L.spell_fishing = "Fishing"
L.ore_words     = { "Vein", "Deposit" } -- mots repères des noms de filons
L.chest_words   = { "Chest", "Footlocker" }

-- /dire au lancer (1re personne)
L.rp_say = {
    "Come on, little one... the bait is fresh, I swear.",
    "My grandfather caught a murloc this way once. Never again, he said.",
    "Patience is the only bait that never runs out.",
    "The water's calm. Too calm. Something big is down there.",
    "I once pulled a boot out of this lake. A fine boot, too.",
    "Fish don't care about kings or wars. That's why I like them.",
    "If the line stays still much longer, I'm taking a nap.",
    "They say the old Stormwind canals hide a fish as long as a dock.",
    "One cast for supper, one for the road.",
    "Easy now... the trick is to think like a fish.",
    "Never trust a dwarf who says he's never lost a fish.",
    "The best fishing spot is always the one someone else is using.",
    "I've caught more fish than I've told lies. Almost.",
    "A good line, a quiet shore, and no one asking for help. Perfect.",
    "Last time I fished here, a crocolisk took the catch and the pole.",
    "Out there somewhere swims the fish that got away. I'll find you.",
    "The moon's right, the wind's right. Tonight they'll bite.",
    "My old master said: talk softly, the fish can hear you. I never believed him.",
    "Here's hoping for a fish and not another rusty locket.",
    "A fisher's luck is like the tide. Comes back if you wait.",
    "This bait cost me three copper and a bad smell. Make it worth it.",
    "I hear goblins fish with explosives. Barbarians.",
    "Some go to war for glory. I just want a decent trout.",
    "Bobber's out. Now we wait, and we pretend we're not bored.",
    "The night elves say the fish here are older than the trees. I doubt it.",
    "The secret? A flick of the wrist and a lot of stubbornness.",
    "I named the last one I caught. Then I cooked him.",
    "If you see a ripple, don't move. Not even a little.",
    "There's a fish in this pond with my name on it.",
    "Fishing is the only time nobody asks me to fight anything.",
    "The water's cold, the coffee's cold, but the fish will be worth it.",
    "My cousin swears he caught a fish that talked. It owed him money.",
    "One more cast. Just one more. That's what I said an hour ago.",
    "A fish in the bag is worth two in the lake.",
    "Old Barnaby said the trick is the song. I don't sing. So, bait.",
    "The murlocs are watching. I know they are.",
    "Every cast is a little prayer to the Tides.",
    "I left my worries on the shore. The fish can have them.",
    "This line has seen storms, sharks and a very angry pelican.",
    "Bite, little fish. I've got a hungry camp waiting.",
}

-- emote à la prise (3e personne, %s = nom de la prise)
L.rp_catch = {
    "reels in %s and admires it proudly.",
    "pulls %s out of the water with a satisfied grin.",
    "holds up %s for everyone to see.",
    "lands %s after a short, fierce struggle.",
    "unhooks %s and whistles appreciatively.",
    "weighs %s in one hand, clearly pleased.",
    "wrestles %s out of the water, nearly falling in.",
    "lifts %s triumphantly toward the sky.",
    "slips %s into the bag with a practiced gesture.",
    "eyes %s and mutters about how big the last one was.",
    "pulls in %s and shakes the water from their sleeves.",
    "grins at %s as if it were an old friend.",
    "catches %s and does a small victory dance.",
    "hauls %s ashore and checks it from every angle.",
    "lands %s and promptly tells the story to no one in particular.",
}
