-- Hook & Harvest © 2026 Ghosti. All Rights Reserved.
-- ============================================================
--  Hook & Harvest — Nodes.lua
--  Numéros d'objets (GameObject) des herbes et filons vanilla.
--  Forever ne donne pas la bulle d'aide d'un objet visé, seulement
--  son nom et son GUID : on reconnaît le nœud par son numéro.
--  Les nœuds absents d'ici sont appris au premier butin (Core.lua).
-- ============================================================

HH.Nodes = {
    herb = {
        [1618] = true, [3724] = true,      -- Pacifique
        [1617] = true, [3725] = true,      -- Feuillargent
        [1619] = true, [3726] = true,      -- Terrestrine
        [1620] = true, [3727] = true,      -- Mage royal
        [1621] = true, [3729] = true,      -- Églantine
        [2045] = true,                     -- Algue étrangleuse
        [1622] = true, [3730] = true,      -- Doulourante
        [1623] = true,                     -- Aciérite sauvage
        [1628] = true,                     -- Tombeline
        [1624] = true,                     -- Sang-royal
        [2041] = true,                     -- Vietérule
        [2042] = true,                     -- Pâlerette
        [2046] = true,                     -- Dorépine
        [2043] = true,                     -- Moustache de Khadgar
        [2044] = true,                     -- Hivernale
        [2866] = true,                     -- Fleur de feu
        [142140] = true,                   -- Lotus pourpre
        [142141] = true, [176642] = true,  -- Larmes d'Arthas
        [142142] = true, [176636] = true,  -- Soleillette
        [142143] = true,                   -- Aveuglette
        [142144] = true,                   -- Champignon fantôme
        [142145] = true, [176637] = true,  -- Gromsang
        [176583] = true, [176638] = true,  -- Sansam doré
        [176584] = true, [176639] = true,  -- Feuillerêve
        [176586] = true, [176640] = true,  -- Sauge-argent des montagnes
        [176587] = true, [176641] = true,  -- Fleur de peste
        [176588] = true,                   -- Calot de glace
        [176589] = true,                   -- Lotus noir
    },
    ore = {
        [1731] = true, [2055] = true, [3763] = true, [103713] = true,  -- cuivre
        [1732] = true, [2054] = true, [3764] = true, [103711] = true,  -- étain
        [1733] = true, [73940] = true,                                 -- argent
        [1734] = true, [150080] = true,                                -- or
        [1735] = true,                                                 -- fer
        [2040] = true, [123310] = true,                                -- mithril
        [2047] = true, [150081] = true, [123309] = true,               -- vrai-argent
        [324] = true, [150082] = true, [176643] = true, [123848] = true, -- petit thorium
        [175404] = true, [177388] = true,                              -- riche thorium
        [165658] = true,                                               -- sombrefer
    },
}
