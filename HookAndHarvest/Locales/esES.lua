-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Locales/esES.lua
--  Textos en español (esES et esMX). À relire par un hispanophone.
-- ============================================================

if HH.LANG ~= "es" then return end
local L = HH.L

L.loaded      = "cargado. Escribe |cffffff00/hh|r para las opciones."
L.prompt_cast = "Lanzar el sedal"
L.prompt_reel = "¡Recoger!"
L.prompt_herb = "Recolectar"
L.prompt_ore  = "Minar"
L.prompt_skin = "Desollar"
L.prompt_chest = "Abrir"
L.prompt_loot  = "Saquear"
L.prompt_interact = "Interactuar"

L.sec_general     = "General"
L.opt_enabled     = "Activar Hook & Harvest"
L.opt_key         = "Tecla (Intro para aplicar)"
L.opt_fishing     = "Pesca"
L.opt_herbalism   = "Herboristería"
L.opt_mining      = "Minería"
L.opt_skinning    = "Desuello"
L.opt_chests      = "Cofres en el suelo"
L.opt_looting     = "Saquear cadáveres"
L.opt_mode        = "Detección"
L.mode_auto       = "auto"
L.mode_native     = "nativo"
L.mode_mouse      = "ratón"
L.mode_line       = "Modo de detección: %s"
L.mode_reload     = "Detección cambiada: escribe |cffffff00/reload|r para aplicarla."
L.sec_rp          = "Rol"
L.opt_rpSay       = "Frases de pescador en /decir al lanzar"
L.opt_rpChance    = "Probabilidad por lance"
L.opt_rpEmote     = "/emote al pescar algo"
L.opt_rpSilent    = "Silencio en bandas y mazmorras"
L.sec_prompt      = "Aviso en pantalla"
L.opt_prompt      = "Mostrar el aviso"
L.opt_scale       = "Tamaño"
L.btn_unlock      = "Desbloquear (arrastrar)"
L.opt_posX       = "Posición horizontal"
L.opt_posY       = "Posición vertical"
L.btn_resetPos   = "Posición por defecto"
L.btn_lock        = "Bloquear"
L.sec_sound       = "Sonido"
L.opt_soundBoost  = "Efectos más fuertes al pescar"
L.opt_soundVolume = "Volumen de efectos"
L.opt_soundMute   = "Silenciar música y ambiente al pescar"
L.sec_history     = "Registro de capturas"
L.opt_history     = "Guardar el historial de capturas recientes"
L.opt_historySize = "Tamaño del historial"
L.btn_stats       = "Ver estadísticas"
L.btn_reset       = "Reiniciar estadísticas"
L.stats_header    = "%d capturas, %d lances."
L.stats_none      = "Aún no hay capturas."
L.reset_confirm   = "¿Reiniciar todas las estadísticas de Hook & Harvest de este personaje?"
L.help            = "|cffffff00/hh|r opciones · |cffffff00/hh stats|r · |cffffff00/hh reset|r · |cffffff00/hh mode|r"

L.kw_bobber     = "Corcho de pesca"
L.kw_herb       = "Herboristería"
L.kw_ore        = "Minería"
L.kw_skin       = "Desollable"
L.spell_fishing = "Pesca"
L.ore_words     = { "Filón", "Depósito", "Veta" }
L.chest_words   = { "Cofre", "Baúl" }

-- à relire par un hispanophone
L.rp_say = {
    "Vamos, pequeño... el cebo está fresco, lo juro.",
    "Mi abuelo pescó un múrloc así una vez. Nunca más, decía.",
    "La paciencia es el único cebo que nunca se acaba.",
    "El agua está tranquila. Demasiado tranquila. Ahí abajo hay algo grande.",
    "Una vez saqué una bota de este lago. Una bota muy buena, además.",
    "A los peces no les importan los reyes ni las guerras. Por eso me gustan.",
    "Si el corcho no se mueve pronto, me echo una siesta.",
    "Dicen que los viejos canales de Ventormenta esconden un pez tan largo como un muelle.",
    "Un lance para la cena, otro para el camino.",
    "Despacio... el truco es pensar como un pez.",
    "Nunca te fíes de un enano que dice que nunca se le escapó un pez.",
    "El mejor sitio para pescar siempre es el que ya ocupa otro.",
    "He pescado más peces que mentiras he contado. Casi.",
    "Un buen sedal, una orilla tranquila y nadie pidiéndome ayuda. Perfecto.",
    "La última vez aquí, un crocolisco se llevó la captura y la caña.",
    "Por ahí nada el que se me escapó. Te encontraré.",
    "La luna está bien, el viento también. Esta noche van a picar.",
    "Mi viejo maestro decía: habla bajo, los peces te oyen. Nunca le creí.",
    "Ojalá sea un pez y no otro medallón oxidado.",
    "La suerte del pescador es como la marea. Vuelve si esperas.",
    "Este cebo me costó tres monedas de cobre y un mal olor. Que valga la pena.",
    "Dicen que los goblins pescan con explosivos. Bárbaros.",
    "Algunos van a la guerra por la gloria. Yo solo quiero una buena trucha.",
    "Corcho al agua. Ahora a esperar y a fingir que no me aburro.",
    "Los elfos de la noche dicen que los peces de aquí son más viejos que los árboles. Lo dudo.",
    "¿El secreto? Un golpe de muñeca y mucha terquedad.",
    "Le puse nombre al último que pesqué. Luego lo cociné.",
    "Si ves una onda en el agua, no te muevas. Ni un poco.",
    "En este estanque hay un pez con mi nombre.",
    "Pescar es el único momento en que nadie me pide que pelee contra algo.",
    "El agua está fría, el café también, pero el pez lo valdrá.",
    "Mi primo jura que pescó un pez que hablaba. Le debía dinero.",
    "Un lance más. Solo uno. Eso dije hace una hora.",
    "Más vale pez en el morral que dos en el lago.",
    "El viejo Bernabé decía que el secreto es la canción. Yo no canto. Así que, cebo.",
    "Los múrlocs nos están mirando. Lo sé.",
    "Cada lance es una pequeña plegaria a las Mareas.",
    "Dejé mis preocupaciones en la orilla. Que se las queden los peces.",
    "Este sedal ha visto tormentas, tiburones y un pelícano muy enfadado.",
    "Pica, pececito. Tengo un campamento hambriento esperando.",
}

L.rp_catch = {
    "saca %s y contempla su captura con orgullo.",
    "saca %s del agua con una sonrisa satisfecha.",
    "levanta %s para que todos la vean.",
    "consigue %s tras una lucha corta y feroz.",
    "desengancha %s y silba con admiración.",
    "sopesa %s con una mano, visiblemente contento.",
    "arranca %s del agua y casi se cae dentro.",
    "alza %s triunfalmente hacia el cielo.",
    "guarda %s en el morral con un gesto experto.",
    "mira %s y murmura que el anterior era más grande.",
    "saca %s y se sacude el agua de las mangas.",
    "sonríe a %s como a un viejo amigo.",
    "atrapa %s y hace un pequeño baile de victoria.",
    "arrastra %s a la orilla y examina su captura por todos lados.",
    "consigue %s y cuenta la historia a quien quiera oírla.",
}
