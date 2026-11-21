-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Locales/frFR.lua
--  Textes en français.
-- ============================================================

if HH.LANG ~= "fr" then return end
local L = HH.L

L.loaded      = "chargé. Tapez |cffffff00/hh|r pour les options."
L.prompt_cast = "Lancer la ligne"
L.prompt_reel = "Ferrer !"
L.prompt_herb = "Cueillir"
L.prompt_ore  = "Miner"
L.prompt_skin = "Dépecer"
L.prompt_chest = "Ouvrir"
L.prompt_loot  = "Fouiller"
L.prompt_interact = "Interagir"

L.sec_general     = "Général"
L.opt_enabled     = "Activer Hook & Harvest"
L.opt_key         = "Touche (Entrée pour valider)"
L.opt_fishing     = "Pêche"
L.opt_herbalism   = "Herboristerie"
L.opt_mining      = "Minage"
L.opt_skinning    = "Dépeçage"
L.opt_chests      = "Coffres au sol"
L.opt_looting     = "Fouiller les corps"
L.opt_mode        = "Détection"
L.mode_auto       = "auto"
L.mode_native     = "natif"
L.mode_mouse      = "souris"
L.mode_line       = "Mode de détection : %s"
L.mode_reload     = "Détection changée : tapez |cffffff00/reload|r pour l'appliquer."
L.sec_rp          = "Roleplay"
L.opt_rpSay       = "Phrases de pêcheur en /dire au lancer"
L.opt_rpChance    = "Chance par lancer"
L.opt_rpEmote     = "/emote quand vous attrapez quelque chose"
L.opt_rpSilent    = "Silence en raid et en donjon"
L.sec_prompt      = "Invite à l'écran"
L.opt_prompt      = "Afficher l'invite"
L.opt_scale       = "Taille"
L.btn_unlock      = "Déverrouiller (glisser)"
L.opt_posX       = "Position horizontale"
L.opt_posY       = "Position verticale"
L.btn_resetPos   = "Position par défaut"
L.btn_lock        = "Verrouiller"
L.sec_sound       = "Son"
L.opt_soundBoost  = "Effets plus forts pendant la pêche"
L.opt_soundVolume = "Volume des effets"
L.opt_soundMute   = "Couper musique et ambiance pendant la pêche"
L.sec_history     = "Carnet de prises"
L.opt_history     = "Garder l'historique des dernières prises"
L.opt_historySize = "Taille de l'historique"
L.btn_stats       = "Voir les stats"
L.btn_reset       = "Remettre à zéro"
L.stats_header    = "%d prises, %d lancers."
L.stats_none      = "Aucune prise pour l'instant."
L.reset_confirm   = "Remettre à zéro toutes les stats Hook & Harvest de ce personnage ?"
L.help            = "|cffffff00/hh|r options · |cffffff00/hh stats|r · |cffffff00/hh reset|r · |cffffff00/hh mode|r"

L.kw_bobber     = "Flotteur"
L.kw_herb       = "Herboristerie"
L.kw_ore        = "Minage"
L.kw_skin       = "Dépeçable"
L.spell_fishing = "Pêche"
L.ore_words     = { "Filon", "Gisement" }
L.chest_words   = { "Coffre", "Cantine" }

L.rp_say = {
    "Allez, petit... l'appât est frais, promis.",
    "Mon grand-père a pêché un murloc comme ça, une fois. Plus jamais, qu'il disait.",
    "La patience, c'est le seul appât qui ne s'épuise jamais.",
    "L'eau est calme. Trop calme. Y a du gros là-dessous.",
    "Un jour, j'ai sorti une botte de ce lac. Une belle botte, en plus.",
    "Les poissons se fichent des rois et des guerres. C'est pour ça que je les aime.",
    "Si le flotteur ne bouge pas bientôt, je fais une sieste.",
    "On dit que les vieux canaux de Hurlevent cachent un poisson long comme un ponton.",
    "Un lancer pour le souper, un pour la route.",
    "Doucement... le truc, c'est de penser comme un poisson.",
    "Ne fais jamais confiance à un nain qui dit n'avoir jamais raté un poisson.",
    "Le meilleur coin de pêche, c'est toujours celui où quelqu'un d'autre est déjà installé.",
    "J'ai attrapé plus de poissons que j'ai raconté de mensonges. Presque.",
    "Une bonne ligne, une rive tranquille, et personne pour me demander de l'aide. Parfait.",
    "La dernière fois ici, un crocilisque m'a pris la prise et la canne.",
    "Quelque part là-dedans nage celui qui m'a échappé. Je te retrouverai.",
    "La lune est bonne, le vent aussi. Ce soir, ça va mordre.",
    "Mon vieux maître disait : parle doucement, les poissons t'entendent. Je l'ai jamais cru.",
    "Pourvu que ce soit un poisson et pas encore un médaillon rouillé.",
    "La chance du pêcheur, c'est comme la marée. Elle revient si on attend.",
    "Cet appât m'a coûté trois pièces de cuivre et une sale odeur. Rentabilise-le.",
    "Il paraît que les gobelins pêchent à l'explosif. Des barbares.",
    "Certains partent en guerre pour la gloire. Moi, je veux juste une belle truite.",
    "Flotteur à l'eau. Maintenant on attend, et on fait semblant de pas s'ennuyer.",
    "Les elfes de la nuit disent que les poissons d'ici sont plus vieux que les arbres. J'en doute.",
    "Le secret ? Un coup de poignet et beaucoup d'entêtement.",
    "J'avais donné un nom au dernier que j'ai pris. Puis je l'ai cuisiné.",
    "Si tu vois une ride sur l'eau, bouge pas. Même pas un peu.",
    "Il y a un poisson dans cette mare qui porte mon nom.",
    "La pêche, c'est le seul moment où personne ne me demande de taper sur quelque chose.",
    "L'eau est froide, le café aussi, mais le poisson en vaudra la peine.",
    "Mon cousin jure avoir pêché un poisson qui parlait. Il lui devait de l'argent.",
    "Encore un lancer. Juste un. C'est ce que j'ai dit il y a une heure.",
    "Un poisson dans la besace vaut mieux que deux dans le lac.",
    "Le vieux Barnabé disait que le secret, c'est la chanson. Je chante pas. Donc, appât.",
    "Les murlocs nous observent. Je le sais.",
    "Chaque lancer, c'est une petite prière aux Marées.",
    "J'ai laissé mes soucis sur la rive. Les poissons peuvent les garder.",
    "Cette ligne a connu des tempêtes, des requins et un pélican très en colère.",
    "Mords, petit poisson. J'ai un camp affamé qui m'attend.",
}

L.rp_catch = {
    "remonte %s et contemple fièrement sa prise.",
    "sort %s de l'eau avec un sourire satisfait.",
    "brandit %s pour que tout le monde la voie.",
    "ramène %s après une lutte courte et acharnée.",
    "décroche %s et sifflote, admiratif.",
    "soupèse %s d'une main, visiblement content.",
    "arrache %s à l'eau et manque de tomber dedans.",
    "lève %s triomphalement vers le ciel.",
    "glisse %s dans sa besace d'un geste habitué.",
    "regarde %s et marmonne que le précédent était plus gros.",
    "remonte %s et secoue l'eau de ses manches.",
    "sourit à %s comme à une vieille connaissance.",
    "attrape %s et esquisse une petite danse de victoire.",
    "hisse %s sur la rive et l'examine sous tous les angles.",
    "ramène %s et raconte aussitôt l'histoire à qui veut l'entendre.",
}
