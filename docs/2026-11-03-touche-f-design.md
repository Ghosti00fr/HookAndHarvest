# Forever Angler — design

2026-11-03 · Addon WoW pour **WoW Forever** (base Retail modifiée, contenu vanilla, sortie US le 2026-11-04).
Commande : `/fa`. Note de suivi dans le vault : `03-Projets/Addon WoW - Touche F recolte.md`.

## 1. Intention

Ghosti veut **une seule touche (F)** pour pêcher et récolter, sans viser à la souris ni chercher le sort dans ses barres :
- pêche : un appui lance la ligne, un appui quand ça mord ferre (récupère la prise) ;
- herboristerie, minage, dépeçage : un appui récolte le nœud ou le corps devant soi.

La pêche est le cœur de l'addon, avec une couche **RP** : phrases aléatoires et anecdotes de pêcheur en /dire, compteur de prises et historique.
Addon destiné à être publié sur **CurseForge** plus tard : il doit être propre, traduit et original.

## 2. Objectifs, non-objectifs, anti-objectifs

**Objectifs (v1)**
- Touche F contextuelle : lancer la pêche, ferrer, récolter (herbo, minage, dépeçage). Chaque métier s'active séparément.
- Invite « F » à l'écran, visible seulement quand F a quelque chose à faire (visuel validé, § 5.3).
- Phrases RP aléatoires sur la pêche, fréquence limitée.
- Compteur de prises (poissons et objets) et historique léger.
- Trois langues : français, espagnol, anglais.
- Aucun lag perceptible.

**Non-objectifs (v1)**
- Désenchantement, mouture, prospection (éventuellement plus tard).
- RP et statistiques pour herbo, minage et dépeçage (la v1 ne fait que la touche et l'invite ; extension facile ensuite).
- Carte des récoltes, or par heure, aide à l'hôtel des ventes.
- Paquet CurseForge (fichiers `.toc` prêts, mais pas de publication en v1).

**Anti-objectifs**, à éviter même si tout « marche » :
- lag ou chute d'images (aucun `OnUpdate` permanent) ;
- spam du chat : les joueurs autour ne doivent pas subir une phrase à chaque lancer ;
- F cassée en combat (F doit retrouver sa fonction normale, par défaut « Assister ») ;
- perte des statistiques à une mise à jour (SavedVariables à migrer, jamais renommer) ;
- code ou images repris d'un autre addon (SKTools est sous licence « All Rights Reserved »).

## 3. Contraintes

- **API de Forever non vérifiée.** C'est une base Retail, mais chaque API Retail peut manquer. Le tout premier test en jeu est le **jeudi 2026-11-05**. Liste des points à vérifier au § 7.
- **Actions protégées :** lancer un sort ou interagir exige un appui réel (événement matériel) et un cadre sécurisé. Une liaison de touche ne peut pas changer en combat (`InCombatLockdown()`).
- **/dire (`SAY`) en extérieur** n'est permis que pendant un appui de touche ou un clic (règle Retail depuis 8.2.5 ; présence sur Forever à vérifier). `EMOTE` n'est pas soumis à cette règle.
- Lua 5.1 (WoW). Tests hors jeu possibles avec LuaJIT 2.1 : `C:\Users\klass\AppData\Local\Programs\LuaJIT\bin\luajit.exe` (même méthode que Forever Cast Bars : mocks dans `test/`).
- Pipeline d'images Python déjà en place dans `C:\Users\klass\Projets\ForeverCastBars\pipeline` (pillow, numpy) : on le réutilise comme modèle, sans dépendre de lui.

## 4. Approches envisagées

| # | Approche | Avantages | Inconvénients |
|---|---|---|---|
| 1 | **Interaction native seule** : CVar `SoftTargetInteract` + F lié à « Interagir avec la cible ». Le jeu choisit l'objet le plus proche. | Très léger, piloté par événements, aucune visée | Ne marche pas du tout si Forever n'a pas cette CVar |
| 2 | **Souris seule** : F lié à « Interagir avec l'objet survolé » ; l'addon lit la bulle d'aide pour savoir ce qu'il y a dessous. | Marche à coup sûr | Il faut viser à la souris, ce que Ghosti veut éviter |
| 3 | **Hybride** : 1 par défaut, bascule automatique sur 2 si la CVar n'existe pas. | Le test de jeudi marche dans tous les cas | Une trentaine de lignes de plus |

**Choix de Ghosti : 3 (hybride).** Raison : Forever n'est pas encore sorti et on ne sait pas si la CVar existe.

## 5. Ce qui est décidé

### 5.1 Touche F

- Un cadre propriétaire pose une **liaison prioritaire** (`SetOverrideBinding…`) sur la touche configurée (F par défaut), **hors combat seulement**.
- À l'entrée en combat, la liaison est effacée par un **pilote d'état sécurisé** (`SecureHandlerStateTemplate` + `RegisterStateDriver(cadre, "combat", "[combat] 1; 0")`, avec `self:ClearBindings()` dans `_onstate-combat`). Ce code tourne dans l'environnement restreint, donc il marche même en combat, contrairement à un simple gestionnaire de `PLAYER_REGEN_DISABLED`, qui peut arriver trop tard. F retrouve sa fonction normale. La liaison est reposée à la sortie de combat (`PLAYER_REGEN_ENABLED`). *(Choix de Claude, suite à la relecture.)*
- Ce que fait F selon le contexte, recalculé à chaque changement de contexte (hors combat) :

| Contexte | F fait | Invite affichée |
|---|---|---|
| Bouchon de pêche visé | Interagir (ferrer) | poisson, état « Ferrer ! » |
| Herbe visée (herbo activée) | Interagir | fleur, « Cueillir » |
| Filon visé (minage activé) | Interagir | roche, « Miner » |
| Corps dépeçable visé (dépeçage activé) | Interagir | peau, « Dépecer » |
| Rien de visé, Pêche connue, pêche activée | Clic sur un bouton sécurisé qui lance **Pêche** | poisson, « Lancer la ligne » |
| Aucun des cas | Aucune liaison (F normale) | rien |

- **Mode natif** (CVar présente) : l'addon met `SoftTargetInteract` à la valeur qui vise les objets du monde (il retient l'ancienne valeur et la remet si on désactive l'addon ou passe en mode souris). Effet de bord assumé : la CVar est globale, donc les icônes d'interaction douce apparaissent aussi sur les PNJ et objets pendant toute la session. F, lui, n'est lié à « Interagir » que pour les contextes du tableau. *(Choix de Claude.)* Contexte lu sur l'événement de changement de cible douce (`PLAYER_SOFT_INTERACT_CHANGED`) et le nom ou le type de l'objet visé.
- **Mode souris** (CVar absente) : F est lié à « Interagir avec l'objet survolé » quand la bulle d'aide montre un bouchon, une herbe, un filon ou un corps dépeçable. Contexte lu au survol (`GameTooltip`, `UPDATE_MOUSEOVER_UNIT`), sans boucle permanente.
- Le choix du mode se fait une fois, au chargement. Il est affiché dans `/fa` et peut être forcé dans les options.
- ~~Pêche lancée dès que le sort est connu, sans vérifier la canne.~~ **Modifié le 2026-11-05 (v1.0.1)** : Forever exige une canne (confirmé par Ghosti), et l'invite « Lancer la ligne » restait affichée partout. « Lancer » n'est proposé **que si une canne est équipée** (main droite, arme de sous-classe 20). Sans canne, F garde sa fonction normale ; la récolte n'est pas concernée.

### 5.2 RP

- **Au lancer** (appui sur F qui lance Pêche, donc appui réel) : `SendChatMessage(…, "SAY")` est appelé dans le `PreClick` du bouton sécurisé de pêche, qui s'exécute dans le même événement matériel que le clic. Une phrase aléatoire en /dire, tirée d'une liste par langue (anecdotes, dictons, petites histoires de pêcheur ; environ 40 phrases par langue).
- **À la prise :** une emote facultative (`/e`, pas de restriction d'appui), avec le nom de la prise, par exemple « remonte une Truite arc-en-ciel et la contemple fièrement ». Désactivée par défaut. *(Choix de Claude.)*
- Anti-spam : une chance sur 5 par lancer par défaut (réglable de « jamais » à « toujours ») et jamais deux phrases à moins de 60 s d'intervalle. Pas de phrase pendant un groupe de raid ou de donjon (option).
- Les phrases ne sont pas tirées deux fois de suite (on mémorise la dernière).

### 5.3 Invite « F » à l'écran (visuel validé)

- **Style A** : touche en bois sombre, liseré doré, halo coloré selon le métier.
- **Illustration autour du F** :
  - pêche : poisson derrière le F, **calme** (pas de frétillement : aucun signal fiable de touche, voir § 5.8) ;
  - herboristerie : fleur ;
  - minage : bloc de roche avec un filon ;
  - dépeçage : peau tendue et cousue.
- Couleurs de halo : pêche bleu `#3d9be9`, ferrer bleu clair `#7fd3ff`, herbo vert `#5fbf4a`, minage cuivre `#c98a4b`, dépeçage rouge brun `#b0452f`.
- Un libellé localisé sous la touche : « Lancer la ligne », « Ferrer ! », « Cueillir », « Miner », « Dépecer ».
- La touche affichée suit la liaison réelle (si on choisit G, l'invite affiche G).
- Animations par `AnimationGroup` (gérées par le moteur), jouées seulement quand l'invite est visible.
- Position : sous le centre de l'écran par défaut, déplaçable (glisser quand les options sont ouvertes), taille réglable.
- Images : textures `.tga` en puissance de 2, dessinées par code (Python), **assombries ×0,5 à 0,6** avant livraison (leçon de Forever Cast Bars : sinon elles sortent surexposées).

### 5.4 Compteur et historique

- Une prise est comptée quand le butin vient de la pêche (`IsFishingLoot()` à l'ouverture du butin), par identifiant d'objet et quantité.
- Données par personnage :
  - `totals[itemID] = quantité` ;
  - `history` : file circulaire des **100** dernières prises `{t, itemID, n, mapID}` ;
  - `count` (prises totales) et `casts` (lancers).
- Option : historique désactivable (seuls les totaux restent). Taille réglable de 0 à 500.
- `/fa stats` affiche dans le chat le total et le top 10 des prises ; `/fa reset` remet à zéro (avec confirmation).
- SavedVariables : `ForeverAnglerDB` (compte) avec un champ `version` pour les migrations futures, et une sous-table par personnage `"Nom-Royaume"`.

### 5.5 Langues

- `Locales/enUS.lua` (base et repli), `frFR.lua`, `esES.lua` ; `esMX` utilise `esES`.
- Tout texte visible passe par la table `L`, y compris les phrases RP.
- Les noms détectés dans les bulles d'aide (« Flotteur », « Fishing Bobber », etc.) sont dans les fichiers de langue.

### 5.6 Options (`/fa`)

- Panneau d'options dans les réglages du jeu, plus les commandes `/fa`, `/fa stats` et `/fa reset`.
- Réglages :
  - activer ou non l'addon ;
  - touche (F par défaut) ;
  - métiers : pêche, herbo, minage et dépeçage, chacun activable ;
  - mode de détection : auto, natif ou souris ;
  - RP : /dire activé et fréquence, emote à la prise, silence en groupe ;
  - invite : affichage, taille, position ;
  - historique : activé et taille.

### 5.7 Performance

- Tout est piloté par événements. Aucun `OnUpdate` permanent.
- Pas de création de tables à chaque événement fréquent. Textures créées une fois.
- Les liaisons ne sont mises à jour que si le contexte **change**.

### 5.8 Touche du poisson (choix de Ghosti : option A)

- L'addon **ne détecte pas** la touche. Ghosti guette lui-même le plouf du bouchon et appuie sur F.
- Pendant la pêche (du lancer jusqu'à la fin du canal `UNIT_SPELLCAST_CHANNEL_STOP`), l'addon **monte le volume des effets** (CVar `Sound_SFXVolume`, valeur réglable, 1,0 par défaut) et peut couper la musique et l'ambiance. Il remet les valeurs d'origine à la fin, et aussi au rechargement de l'interface si elles étaient restées modifiées (valeurs d'origine sauvegardées dans `ForeverAnglerDB`).
- L'invite affiche « Ferrer ! » pendant toute l'attente, avec un poisson calme.
- Option désactivable : « Renforcer le son pendant la pêche ».

### 5.9 Licence (demande de Ghosti)

- Licence **« All Rights Reserved »** (tous droits réservés) : copie, modification et redistribution interdites sans autorisation écrite de l'auteur.
- Fichier `LICENSE.txt` à la racine de l'addon, en anglais (langue de référence sur CurseForge) avec une traduction française en dessous.
- Ligne courte en tête de chaque fichier `.lua` et dans le `.toc` (`## X-License: All Rights Reserved`) : `-- Forever Angler © 2026 Ghosti. All Rights Reserved.`
- Sur CurseForge, choisir la licence « All Rights Reserved » au moment de la publication.
- Limite : le code Lua d'un addon reste lisible par tous, la licence ne l'empêche pas techniquement. Elle donne le droit de faire retirer une copie (signalement DMCA à CurseForge ou Wago).
- Auteur affiché : **Ghosti** (aussi dans `## Author: Ghosti` du `.toc`).

## 6. Laissé au constructeur

- Arborescence exacte des fichiers et découpage en modules.
- Comment reconnaître un bouchon, une herbe, un filon et un corps dépeçable en mode natif (type d'objet, nom, ou icône de curseur) ; en mode souris, par lignes de bulle d'aide localisées.
- Dessin final des textures (le brouillon validé donne la direction).
- Écriture des phrases RP dans les trois langues (l'espagnol sera relu par un hispanophone avant la publication).
- Mocks et tests LuaJIT : au moins la logique de contexte, l'anti-spam RP, le compteur et la file d'historique, et la migration de version.

## 7. Non vérifié sur Forever (à tester jeudi)

1. Présence de la CVar `SoftTargetInteract` et de l'événement `PLAYER_SOFT_INTERACT_CHANGED`.
2. Ciblage doux du **bouchon** (il marche sur Retail récent, inconnu sur Forever).
3. Identifiant et nom du sort Pêche (ID Retail ≠ ID Classic) : le résoudre par le grimoire plutôt qu'en dur.
4. Restriction du /dire en extérieur.
5. `IsFishingLoot()`.
6. API du panneau d'options (`Settings.RegisterCanvasLayoutCategory`).
7. Format `.tga` accepté pour les textures d'addon.
8. Les CVars de son (`Sound_SFXVolume`, `Sound_EnableMusic`, `Sound_EnableAmbience`) et l'événement `UNIT_SPELLCAST_CHANNEL_STOP` pour la pêche.
9. Sur une herbe et sur le bouchon : `/dump C_TooltipInfo.GetUnit("softinteract")` et `/dump UnitName("softinteract")`. Si le premier renvoie `nil`, la détection native des herbes et filons ne marche pas : forcer le mode souris dans `/fa`.
10. Avec un PNJ amical ciblé, appuyer sur F près d'une herbe : vérifier que F agit sur l'herbe et pas sur le PNJ.
11. `GetProfessions()` et `GetProfessionInfo()` existent, et les lignes de compétence sont bien 182 (herbo), 186 (minage), 393 (dépeçage).
