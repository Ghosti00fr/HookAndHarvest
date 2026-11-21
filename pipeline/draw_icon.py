# Hook & Harvest © 2026 Ghosti. All Rights Reserved.
# ============================================================
#  Hook & Harvest — pipeline/draw_icon.py
#  Avatar CurseForge 400×400 (PNG), dessiné par code à partir des
#  mêmes formes que l'invite F. Deux variantes à comparer.
#  Lancer depuis la racine du projet : python pipeline/draw_icon.py
# ============================================================
import math
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

import draw_prompt as dp

SIZE = 400
OUT = os.path.join(dp.ROOT, "build", "curseforge")


def background(top="#1d4a3a", bottom="#08130f"):
    """Fond dégradé radial sombre (eau la nuit) + liseré doré."""
    im = Image.new("RGBA", (SIZE, SIZE))
    c0, c1 = dp.hexc(top), dp.hexc(bottom)
    d = ImageDraw.Draw(im)
    cx, cy, rmax = SIZE / 2, SIZE * .62, SIZE * .8
    for r in range(int(rmax), 0, -2):
        t = r / rmax
        col = tuple(int(c0[i] + (c1[i] - c0[i]) * t) for i in range(3)) + (255,)
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col)
    # vaguelettes
    for k, y in enumerate((300, 326, 350)):
        d.arc([60 - k * 20, y - 14, 340 + k * 20, y + 14], 200, 340, fill=dp.hexc("#5fa8c8", 90 - k * 20), width=3)
    # carré plein (CurseForge l'affiche carré : pas de coins noirs), liseré doré arrondi
    ImageDraw.Draw(im).rounded_rectangle([8, 8, SIZE - 9, SIZE - 9], radius=40, outline=dp.hexc("#c9a03a"), width=8)
    return im


def bright(img, k=0.85):
    """Les textures de jeu sont assombries ×0,55 ; l'avatar se voit en petit, on éclaircit moins."""
    r, g, b, a = img.split()
    r, g, b = (ch.point(lambda v: min(255, int(v * k))) for ch in (r, g, b))
    return Image.merge("RGBA", (r, g, b, a))


def glow(base, box, color, blur=18):
    g = Image.new("RGBA", base.size, (0, 0, 0, 0))
    ImageDraw.Draw(g).rounded_rectangle(box, radius=40, fill=dp.hexc(color, 220))
    return Image.alpha_composite(base, g.filter(ImageFilter.GaussianBlur(blur)))


def key_with_f(base, cx, cy, size):
    k = bright(dp.key()).resize((size, size), Image.LANCZOS)
    base.alpha_composite(k, (int(cx - size / 2), int(cy - size / 2)))
    try:
        font = ImageFont.truetype("georgiab.ttf", int(size * .55))
    except OSError:
        font = ImageFont.load_default()
    d = ImageDraw.Draw(base)
    d.text((cx + 3, cy + 4), "F", fill=(0, 0, 0, 160), font=font, anchor="mm")
    d.text((cx, cy), "F", fill=dp.hexc("#f4e3b0"), font=font, anchor="mm")
    return base


# ---- A : l'invite du jeu en grand (poisson derrière le F) --------
def variant_a():
    im = background()
    fish = bright(dp.fish()).resize((380, 380), Image.LANCZOS)
    im.alpha_composite(fish, (10, 0))
    im = glow(im, [118, 98, 282, 262], "#3d9be9")
    return key_with_f(im, 200, 180, 170)


# ---- B : canne, ligne et bouchon, avec le F en médaillon --------
def variant_b():
    im = background("#24405a", "#0a1018")
    d = ImageDraw.Draw(im)
    d.line([(52, 352), (318, 62)], fill=dp.hexc("#7a4a24"), width=14)          # canne
    d.line([(52, 352), (120, 278)], fill=dp.hexc("#3a2414"), width=18)          # poignée
    d.ellipse([92, 268, 128, 304], outline=dp.hexc("#c9a03a"), width=6)         # moulinet
    pts = [(318, 62)] + [(318 + 2 * t, 62 + 220 * (t / 10) ** 1.6) for t in range(1, 11)]
    d.line(pts, fill=dp.hexc("#e6e2d0", 200), width=3)                          # ligne
    bx, by = 352, 286                                                           # bouchon
    d.ellipse([bx - 26, by - 26, bx + 2, by + 2], fill=dp.hexc("#d8d8d8"), outline=(30, 30, 30, 255), width=3)
    d.chord([bx - 26, by - 26, bx + 2, by + 2], 180, 360, fill=dp.hexc("#c0392b"))
    for r in (30, 44):
        d.arc([bx - 12 - r, by - 6, bx - 12 + r, by + 26], 0, 180, fill=dp.hexc("#7fd3ff", 140), width=3)
    im = glow(im, [128, 118, 272, 262], "#7fd3ff", 16)
    return key_with_f(im, 200, 190, 150)


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, fn in (("A", variant_a), ("B", variant_b)):
        img = fn().convert("RGB")      # PNG opaque : CurseForge n'aime pas la transparence
        img.save(os.path.join(OUT, "icon_%s.png" % name))
    # planche de comparaison, avec un aperçu en petit (taille des listes CurseForge)
    a, b = (Image.open(os.path.join(OUT, "icon_%s.png" % n)) for n in "AB")
    sheet = Image.new("RGB", (880, 520), (24, 24, 28))
    sheet.paste(a, (20, 20)); sheet.paste(b, (460, 20))
    sheet.paste(a.resize((64, 64), Image.LANCZOS), (188, 440)); sheet.paste(b.resize((64, 64), Image.LANCZOS), (628, 440))
    try:
        font = ImageFont.truetype("georgia.ttf", 22)
    except OSError:
        font = ImageFont.load_default()
    d = ImageDraw.Draw(sheet)
    d.text((20, 446), "A", fill=(240, 230, 200), font=font); d.text((460, 446), "B", fill=(240, 230, 200), font=font)
    sheet.save(os.path.join(OUT, "comparaison.png"))
    print("ok ->", OUT)


if __name__ == "__main__":
    main()
