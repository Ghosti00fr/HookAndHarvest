# Hook & Harvest © 2026 Ghosti. All Rights Reserved.
# ============================================================
#  Hook & Harvest — pipeline/draw_prompt.py
#  Dessine les textures de l'invite « F » d'après la maquette
#  validée (style A + illustration) : touche, poisson, fleur,
#  roche, peau. Sorties TGA 32 bits + planche d'aperçu PNG.
#  Lancer depuis la racine du projet : python pipeline/draw_prompt.py
# ============================================================
import math
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "HookAndHarvest", "textures")
PREVIEW = os.path.join(ROOT, "build", "preview")
DARKEN = 0.55          # leçon Forever Cast Bars : sinon surexposé
SS = 4                 # suréchantillonnage pour l'anticrénelage
ART, KEY = 128, 64     # tailles finales (puissances de 2)
U = ART * SS / 128     # unité : 1 px de la maquette SVG (110 de côté)
PAD = (128 - 110) / 2  # la maquette est centrée dans 128 ; ses débords (queue, pétales) restent dans l'image


def hexc(h, a=255):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)


def p(x, y):
    return ((x + PAD) * U, (y + PAD) * U)


def quad(p0, c, p1, n=12):
    """Points d'une courbe de Bézier quadratique (coordonnées maquette)."""
    return [p((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * c[0] + t * t * p1[0],
              (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * c[1] + t * t * p1[1])
            for t in (i / n for i in range(n + 1))]


def canvas():
    return Image.new("RGBA", (ART * SS, ART * SS), (0, 0, 0, 0))


def finish(img, size):
    img = img.resize((size, size), Image.LANCZOS)
    r, g, b, a = img.split()
    r, g, b = (ch.point(lambda v: int(v * DARKEN)) for ch in (r, g, b))
    return Image.merge("RGBA", (r, g, b, a))


# ---- poisson (derrière le F) --------------------------------
def fish():
    im = canvas(); d = ImageDraw.Draw(im)
    d.polygon([p(8, 55), p(-6, 40), p(-2, 55), p(-6, 70)], fill=hexc("#4a86a8"))
    d.ellipse([p(3, 31), p(107, 79)], fill=hexc("#5b9cc2"))
    belly = canvas(); ImageDraw.Draw(belly).ellipse([p(11, 50), p(99, 74)], fill=hexc("#9fd0e6", 153))
    im = Image.alpha_composite(im, belly); d = ImageDraw.Draw(im)
    d.polygon(quad((40, 31), (55, 18), (72, 31)), fill=hexc("#4a86a8"))
    d.ellipse([p(90, 46), p(98, 54)], fill=hexc("#ffffff"))
    d.ellipse([p(93, 48), p(97, 52)], fill=hexc("#111111"))
    return im


# ---- fleur (herboristerie) ----------------------------------
def flower():
    im = canvas(); d = ImageDraw.Draw(im)
    d.polygon(quad((18, 92), (30, 70), (40, 78)) + quad((40, 78), (30, 90), (18, 92)), fill=hexc("#3e8a2e"))
    d.polygon(quad((92, 92), (80, 70), (70, 78)) + quad((70, 78), (80, 90), (92, 92)), fill=hexc("#3e8a2e"))
    for i in range(8):  # pétale vertical dessiné puis tourné autour du centre
        pet = canvas(); pd = ImageDraw.Draw(pet)
        pd.ellipse([p(41, -6), p(69, 34)], fill=hexc("#c86fc9"), outline=hexc("#8e3f93"), width=int(1.5 * U))
        im = Image.alpha_composite(im, pet.rotate(-45 * i, center=p(55, 55), resample=Image.BICUBIC))
    d = ImageDraw.Draw(im)
    d.ellipse([p(21, 21), p(89, 89)], fill=hexc("#e8c34a"))
    return im


# ---- bloc de roche avec filon (minage) ----------------------
def ore():
    im = canvas(); d = ImageDraw.Draw(im)
    rock = [(12, 30), (40, 6), (82, 10), (104, 40), (98, 84), (66, 106), (24, 100), (4, 68)]
    d.polygon([p(*q) for q in rock], fill=hexc("#5d5650"), outline=hexc("#2e2a26"), width=int(3 * U))
    d.polygon([p(12, 30), p(40, 6), p(82, 10), p(70, 24), p(30, 22)], fill=hexc("#7a726a"))
    d.polygon([p(98, 84), p(66, 106), p(24, 100), p(40, 92), p(80, 90)], fill=hexc("#3f3a35"))
    for tri in ([(20, 40), (28, 34), (30, 46)], [(86, 30), (96, 36), (88, 42)],
                [(84, 76), (94, 72), (90, 86)], [(22, 78), (32, 82), (24, 90)]):
        d.polygon([p(*q) for q in tri], fill=hexc("#d9893f"))
    for cx, cy in ((27, 39), (90, 36), (90, 78)):
        d.ellipse([p(cx - 2, cy - 2), p(cx + 2, cy + 2)], fill=hexc("#ffd27a"))
    return im


# ---- peau tendue et cousue (dépeçage) -----------------------
def hide_outline(pts):
    out = []
    for i in range(0, len(pts) - 2, 2):
        out += quad(pts[i], pts[i + 1], pts[i + 2])
    return out


def pelt():
    im = canvas(); d = ImageDraw.Draw(im)
    outer = [(55, 2), (66, 12), (78, 6), (86, 20), (104, 22), (96, 40), (106, 55), (96, 70), (104, 88), (86, 90),
             (78, 104), (66, 98), (55, 108), (44, 98), (32, 104), (24, 90), (6, 88), (14, 70), (4, 55), (14, 40),
             (6, 22), (24, 20), (32, 6), (44, 12), (55, 2)]
    inner = [(55, 14), (64, 22), (74, 18), (80, 28), (92, 30), (86, 44), (94, 55), (86, 66), (92, 80), (80, 82),
             (74, 92), (64, 88), (55, 96), (46, 88), (36, 92), (30, 82), (18, 80), (24, 66), (16, 55), (24, 44),
             (18, 30), (30, 28), (36, 18), (46, 22), (55, 14)]
    d.polygon(hide_outline(outer), fill=hexc("#8a5a36"), outline=hexc("#4a2e1a"), width=int(2.5 * U))
    line = hide_outline(inner)
    for i in range(0, len(line) - 1, 2):  # couture en pointillés
        d.line([line[i], line[i + 1]], fill=hexc("#d8b07a"), width=int(1.5 * U))
    for cx, cy, r in ((30, 40, 4), (80, 34, 3), (76, 78, 4), (32, 74, 3)):
        d.ellipse([p(cx - r, cy - r), p(cx + r, cy + r)], fill=hexc("#6e4528", 178))
    return im


# ---- touche bois sombre, liseré doré (sans lettre) ----------
def key():
    s = KEY * SS
    im = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    grad = Image.new("RGBA", (s, s))
    top, bot = hexc("#3a2f22"), hexc("#1c1610")
    gd = ImageDraw.Draw(grad)
    for y in range(s):
        t = y / (s - 1)
        gd.line([(0, y), (s, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)) + (255,))
    mask = Image.new("L", (s, s), 0)
    m = 3 * SS
    ImageDraw.Draw(mask).rounded_rectangle([m, m, s - m, s - m], radius=10 * SS, fill=255)
    im.paste(grad, (0, 0), mask)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle([m, m, s - m, s - m], radius=10 * SS, outline=hexc("#b8954a"), width=3 * SS)
    return im


# ---- coffre au sol (ouverture, crochetage) ------------------
def chest():
    im = canvas(); d = ImageDraw.Draw(im)
    wood, dark, gold = hexc("#7a4a24"), hexc("#4a2c14"), hexc("#c9a03a")
    lid = quad((6, 42), (55, -6), (104, 42))                       # couvercle bombé
    d.polygon(lid, fill=hexc("#8a5630"), outline=dark)
    d.rectangle([p(6, 42), p(104, 102)], fill=wood, outline=dark, width=int(2 * U))
    for y in (56, 72, 88):                                         # planches
        d.line([p(8, y), p(102, y)], fill=dark, width=int(1.2 * U))
    for x0 in (16, 84):                                            # ferrures dorées
        d.rectangle([p(x0, 42), p(x0 + 10, 102)], fill=gold)
        d.polygon([p(x0, 42)] + quad((x0, 42), (x0 + 5, 14), (x0 + 10, 42))[1:], fill=gold)
    d.rectangle([p(6, 40), p(104, 47)], fill=gold)                 # bande du couvercle
    d.rounded_rectangle([p(46, 84), p(64, 104)], radius=int(3 * U), fill=gold, outline=dark, width=int(1.5 * U))
    d.ellipse([p(53, 89), p(57, 93)], fill=dark)                   # serrure
    d.rectangle([p(54, 92), p(56, 99)], fill=dark)
    for cx, cy in ((21, 52), (21, 96), (89, 52), (89, 96)):
        d.ellipse([p(cx - 2, cy - 2), p(cx + 2, cy + 2)], fill=hexc("#ffe9a0"))
    return im


# ---- sac de butin (fouiller un corps) -----------------------
def bag():
    im = canvas(); d = ImageDraw.Draw(im)
    cloth, dark, rope = hexc("#b08a55"), hexc("#5e4426"), hexc("#6b4a2a")
    d.polygon(quad((38, 6), (55, 16), (72, 6)) + [p(66, 26), p(44, 26)], fill=hexc("#c49b62"), outline=dark)  # col évasé
    d.polygon([p(44, 24), p(66, 24), p(70, 34), p(40, 34)], fill=cloth)                                      # cou
    d.ellipse([p(10, 30), p(100, 108)], fill=cloth, outline=dark, width=int(2 * U))                           # panse
    d.rectangle([p(40, 26), p(70, 33)], fill=rope)                                                            # lien
    d.line([p(68, 30), p(80, 42)], fill=rope, width=int(2.5 * U))
    d.line([p(68, 30), p(84, 36)], fill=rope, width=int(2.5 * U))
    for i in range(0, 6):                                                                                     # couture
        x = 24 + i * 12
        d.line([p(x, 98), p(x + 6, 100)], fill=dark, width=int(1.2 * U))
    for cx, cy, r in ((90, 96, 7), (100, 104, 6), (80, 104, 5)):                                              # pièces d'or
        d.ellipse([p(cx - r, cy - r), p(cx + r, cy + r)], fill=hexc("#e8c34a"), outline=hexc("#9a7a1a"), width=int(1 * U))
    return im


TEXTURES = {"fish": fish, "flower": flower, "ore": ore, "pelt": pelt, "chest": chest, "bag": bag}

# contexte -> (illustration, halo, libellé FR) : même table que Prompt.lua
STATES = [("cast", "fish", "#3d9be9", "Lancer la ligne"), ("bobber", "fish", "#7fd3ff", "Ferrer !"),
          ("herb", "flower", "#5fbf4a", "Cueillir"), ("ore", "ore", "#c98a4b", "Miner"),
          ("skin", "pelt", "#b0452f", "Dépecer"),
          ("chest", "chest", "#e8b33a", "Ouvrir"), ("loot", "bag", "#e6e2d0", "Fouiller")]


def preview(arts, keytex, states=None):
    global STATES
    full, STATES = STATES, (states or STATES)
    try:
        return _preview(arts, keytex)
    finally:
        STATES = full


def _preview(arts, keytex):
    tile = 220
    sheet = Image.new("RGBA", (tile * len(STATES), tile + 40), hexc("#0e1a14"))
    try:
        font = ImageFont.truetype("georgia.ttf", 16)
        big = ImageFont.truetype("georgiab.ttf", 34)
    except OSError:
        font = big = ImageFont.load_default()
    for i, (_, art, halo, label) in enumerate(STATES):
        cx, cy = i * tile + tile // 2, tile // 2
        a = arts[art].resize((176, 176), Image.LANCZOS)
        sheet.alpha_composite(a, (cx - 88, cy - 88))
        glow = Image.new("RGBA", sheet.size, (0, 0, 0, 0))
        ImageDraw.Draw(glow).rounded_rectangle([cx - 46, cy - 46, cx + 46, cy + 46], radius=18, fill=hexc(halo, 200))
        sheet = Image.alpha_composite(sheet, glow.filter(ImageFilter.GaussianBlur(10)))
        k = keytex.resize((80, 80), Image.LANCZOS)
        sheet.alpha_composite(k, (cx - 40, cy - 40))
        d = ImageDraw.Draw(sheet)
        d.text((cx, cy), "F", fill=hexc("#f4e3b0"), font=big, anchor="mm")
        d.text((cx, tile + 10), label, fill=hexc("#f4e3b0"), font=font, anchor="mm")
    return sheet


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)
    arts = {}
    for name, draw in TEXTURES.items():
        arts[name] = finish(draw(), ART)
        arts[name].save(os.path.join(OUT, name + ".tga"))
    keytex = finish(key(), KEY)
    keytex.save(os.path.join(OUT, "key.tga"))
    preview(arts, keytex).save(os.path.join(PREVIEW, "prompt.png"))
    preview(arts, keytex, STATES[-2:]).save(os.path.join(PREVIEW, "prompt_coffre_sac.png"))
    print("ok :", ", ".join(list(TEXTURES) + ["key"]), "->", OUT)


if __name__ == "__main__":
    main()
