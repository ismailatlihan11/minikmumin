#!/usr/bin/env python3
"""Generate missing catalog cards in the existing Minik Mümin icon style."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FONT = ROOT / "assets" / "fonts" / "NotoSans-Bold.ttf"
SIZE = 512

GREEN = (33, 104, 78, 255)
DARK = (30, 57, 47, 255)
MINT = (229, 238, 230, 255)
WHITE = (255, 255, 255, 255)
GOLD = (194, 151, 57, 255)
TEAL = (38, 125, 124, 255)
BLUE = (70, 130, 160, 255)


def font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT), size)


def card(border=GREEN) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    im = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    pad = 18
    radius = 92
    draw.rounded_rectangle(
        [pad, pad, SIZE - pad, SIZE - pad],
        radius=radius,
        fill=WHITE,
        outline=border,
        width=10,
    )
    cx, cy, r = SIZE // 2, 210, 118
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=MINT, outline=border, width=7)
    return im, draw


def label(draw: ImageDraw.ImageDraw, text: str, fill=DARK) -> None:
    size = 42 if len(text) < 14 else 34 if len(text) < 20 else 28
    f = font(size)
    bbox = draw.textbbox((0, 0), text, font=f)
    w = bbox[2] - bbox[0]
    draw.text(((SIZE - w) / 2, 390), text, font=f, fill=fill)


def circle_xy() -> tuple[int, int, int]:
    return SIZE // 2, 210, 118


def save(im: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)


def icon_waves(draw, color=TEAL):
    cx, cy, _ = circle_xy()
    for i, y in enumerate((-18, 18)):
        draw.arc([cx - 54, cy + y - 18, cx + 54, cy + y + 18], 200, 340, fill=color, width=8)


def icon_book(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.rounded_rectangle([cx - 48, cy - 36, cx + 48, cy + 36], 10, outline=color, width=7)
    draw.line([(cx, cy - 36), (cx, cy + 36)], fill=GOLD, width=6)


def icon_star(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    pts = []
    for i in range(8):
        ang = math.radians(-90 + i * 45)
        r = 48 if i % 2 == 0 else 22
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    draw.polygon(pts, fill=color)


def icon_heart(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.ellipse([cx - 42, cy - 28, cx - 2, cy + 12], fill=color)
    draw.ellipse([cx + 2, cy - 28, cx + 42, cy + 12], fill=color)
    draw.polygon([(cx - 40, cy), (cx + 40, cy), (cx, cy + 44)], fill=color)


def icon_hands(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.arc([cx - 50, cy - 10, cx - 6, cy + 42], 200, 20, fill=color, width=9)
    draw.arc([cx + 6, cy - 10, cx + 50, cy + 42], 160, 340, fill=color, width=9)
    draw.ellipse([cx - 14, cy - 36, cx + 14, cy - 8], outline=GOLD, width=6)


def icon_crescent(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.ellipse([cx - 40, cy - 40, cx + 40, cy + 40], fill=color)
    draw.ellipse([cx - 18, cy - 44, cx + 46, cy + 28], fill=MINT)


def icon_drop(draw, color=TEAL):
    cx, cy, _ = circle_xy()
    draw.polygon([(cx, cy - 48), (cx - 32, cy + 8), (cx + 32, cy + 8)], fill=color)
    draw.ellipse([cx - 32, cy - 8, cx + 32, cy + 40], fill=color)


def icon_mosque(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.rectangle([cx - 40, cy - 4, cx + 40, cy + 36], fill=color)
    draw.polygon([(cx - 48, cy - 4), (cx, cy - 48), (cx + 48, cy - 4)], fill=color)
    draw.rectangle([cx - 6, cy + 8, cx + 6, cy + 36], fill=MINT)


def icon_kaaba(draw, color=DARK):
    cx, cy, _ = circle_xy()
    draw.polygon(
        [(cx, cy - 42), (cx + 46, cy - 12), (cx + 46, cy + 36), (cx, cy + 8), (cx - 46, cy + 36), (cx - 46, cy - 12)],
        outline=color,
        width=7,
    )
    draw.line([(cx - 46, cy - 12), (cx + 46, cy - 12)], fill=GOLD, width=6)


def icon_ark(draw, color=BLUE):
    cx, cy, _ = circle_xy()
    draw.polygon([(cx - 56, cy + 8), (cx + 56, cy + 8), (cx + 40, cy + 36), (cx - 40, cy + 36)], fill=color)
    draw.rectangle([cx - 28, cy - 28, cx + 28, cy + 8], outline=color, width=7)
    icon_waves(draw, color)


def icon_mountain(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.polygon([(cx - 58, cy + 36), (cx - 18, cy - 28), (cx + 10, cy + 8), (cx + 28, cy - 16), (cx + 58, cy + 36)], fill=color)


def icon_staff(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.line([(cx, cy + 44), (cx, cy - 20)], fill=color, width=10)
    draw.arc([cx - 28, cy - 52, cx + 28, cy - 4], 200, 20, fill=color, width=10)


def icon_whale(draw, color=BLUE):
    cx, cy, _ = circle_xy()
    draw.ellipse([cx - 52, cy - 18, cx + 36, cy + 28], fill=color)
    draw.polygon([(cx + 28, cy), (cx + 58, cy - 22), (cx + 52, cy + 18)], fill=color)


def icon_tree(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.rectangle([cx - 8, cy + 8, cx + 8, cy + 44], fill=(120, 84, 48, 255))
    draw.ellipse([cx - 42, cy - 44, cx + 42, cy + 16], fill=color)


def icon_scale(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.line([(cx, cy - 36), (cx, cy + 36)], fill=color, width=8)
    draw.line([(cx - 44, cy - 8), (cx + 44, cy - 8)], fill=color, width=8)
    draw.polygon([(cx - 44, cy - 8), (cx - 28, cy + 22), (cx - 60, cy + 22)], outline=GOLD, width=6)
    draw.polygon([(cx + 44, cy - 8), (cx + 28, cy + 22), (cx + 60, cy + 22)], outline=GOLD, width=6)


def icon_lamp(draw, color=GOLD):
    cx, cy, _ = circle_xy()
    draw.polygon([(cx - 22, cy - 8), (cx + 22, cy - 8), (cx + 14, cy + 28), (cx - 14, cy + 28)], fill=color)
    draw.ellipse([cx - 10, cy - 36, cx + 10, cy - 12], fill=GREEN)


def icon_star_moon(draw):
    icon_crescent(draw, GREEN)
    cx, cy, _ = circle_xy()
    draw.regular_polygon((cx + 28, cy - 22, 12), 5, fill=GOLD)


def icon_ladder(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.line([(cx - 22, cy + 40), (cx - 8, cy - 40)], fill=color, width=8)
    draw.line([(cx + 22, cy + 40), (cx + 8, cy - 40)], fill=color, width=8)
    for y in range(-24, 36, 18):
        draw.line([(cx - 20, cy + y), (cx + 20, cy + y)], fill=GOLD, width=6)


def icon_well(draw, color=TEAL):
    cx, cy, _ = circle_xy()
    draw.ellipse([cx - 40, cy - 8, cx + 40, cy + 28], outline=color, width=8)
    draw.rectangle([cx - 40, cy + 8, cx + 40, cy + 40], outline=color, width=8)
    draw.line([(cx, cy - 40), (cx, cy - 8)], fill=GOLD, width=6)


def icon_fish(draw, color=BLUE):
    cx, cy, _ = circle_xy()
    draw.ellipse([cx - 40, cy - 22, cx + 28, cy + 22], fill=color)
    draw.polygon([(cx + 24, cy), (cx + 52, cy - 20), (cx + 52, cy + 20)], fill=color)


def icon_crown(draw, color=GOLD):
    cx, cy, _ = circle_xy()
    draw.polygon(
        [(cx - 46, cy + 16), (cx - 46, cy - 8), (cx - 24, cy + 4), (cx, cy - 28), (cx + 24, cy + 4), (cx + 46, cy - 8), (cx + 46, cy + 16)],
        fill=color,
    )


def icon_bird(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.arc([cx - 50, cy - 20, cx, cy + 28], 200, 20, fill=color, width=9)
    draw.arc([cx, cy - 20, cx + 50, cy + 28], 160, 340, fill=color, width=9)


def icon_flame(draw, color=GOLD):
    cx, cy, _ = circle_xy()
    draw.polygon([(cx, cy - 48), (cx - 28, cy + 8), (cx + 28, cy + 8)], fill=color)
    draw.ellipse([cx - 28, cy - 8, cx + 28, cy + 40], fill=color)


def icon_scroll(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.rounded_rectangle([cx - 36, cy - 40, cx + 36, cy + 40], 16, outline=color, width=7)
    draw.line([(cx - 18, cy - 12), (cx + 18, cy - 12)], fill=GOLD, width=6)
    draw.line([(cx - 18, cy + 8), (cx + 18, cy + 8)], fill=GOLD, width=6)


def icon_people(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.ellipse([cx - 38, cy - 36, cx - 14, cy - 12], fill=color)
    draw.ellipse([cx + 14, cy - 36, cx + 38, cy - 12], fill=color)
    draw.rounded_rectangle([cx - 46, cy - 8, cx - 6, cy + 36], 12, fill=color)
    draw.rounded_rectangle([cx + 6, cy - 8, cx + 46, cy + 36], 12, fill=color)


def icon_help(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.ellipse([cx - 18, cy - 40, cx + 18, cy - 4], fill=color)
    draw.polygon([(cx, cy - 8), (cx - 40, cy + 40), (cx + 40, cy + 40)], fill=GOLD)


def icon_moon_star(draw):
    icon_crescent(draw)
    cx, cy, _ = circle_xy()
    draw.regular_polygon((cx + 30, cy - 24, 14), 5, fill=GOLD)


def icon_question(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    f = font(92)
    bbox = draw.textbbox((0, 0), "?", font=f)
    w = bbox[2] - bbox[0]
    draw.text((cx - w / 2, cy - 58), "?", font=f, fill=color)


def icon_up(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.polygon([(cx, cy - 40), (cx - 36, cy + 8), (cx + 36, cy + 8)], fill=color)
    draw.rectangle([cx - 12, cy + 4, cx + 12, cy + 40], fill=color)


def icon_leaf(draw, color=GREEN):
    cx, cy, _ = circle_xy()
    draw.ellipse([cx - 20, cy - 44, cx + 36, cy + 28], fill=color)
    draw.line([(cx, cy + 36), (cx + 8, cy - 20)], fill=DARK, width=6)


def make(path: Path, text: str, painter, border=GREEN) -> None:
    im, draw = card(border=border)
    painter(draw)
    label(draw, text, fill=DARK)
    save(im, path)
    print("wrote", path.relative_to(ROOT))


def main() -> None:
    prophets = ROOT / "assets/images/prophets"
    duas = ROOT / "assets/images/duas"
    home = ROOT / "assets/images/home"
    morality = ROOT / "assets/images/morality"
    ilmihal = ROOT / "assets/images/ilmihal"

    make(prophets / "idris.png", "Hz. İdrîs", icon_star, BLUE)
    make(prophets / "hud.png", "Hz. Hûd", icon_mountain, TEAL)
    make(prophets / "salih.png", "Hz. Sâlih", icon_mountain, GREEN)
    make(prophets / "lut.png", "Hz. Lût", icon_mosque, DARK)
    make(prophets / "ismail.png", "Hz. İsmail", icon_well, TEAL)
    make(prophets / "ishak.png", "Hz. İshak", icon_leaf, GREEN)
    make(prophets / "yakup.png", "Hz. Yakup", icon_ladder, GREEN)
    make(prophets / "yusuf.png", "Hz. Yusuf", icon_moon_star, GOLD)
    make(prophets / "eyyub.png", "Hz. Eyyub", icon_tree, GREEN)
    make(prophets / "shuayb.png", "Hz. Şuayb", icon_scale, GREEN)
    make(prophets / "harun.png", "Hz. Harun", icon_staff, TEAL)
    make(prophets / "davud.png", "Hz. Davud", lambda d: icon_mountain(d, BLUE), BLUE)
    make(prophets / "suleyman.png", "Hz. Süleyman", icon_crown, GOLD)
    make(prophets / "ilyas.png", "Hz. İlyas", icon_flame, GOLD)
    make(prophets / "elyesa.png", "Hz. Elyesa", icon_waves, BLUE)
    make(prophets / "zulkifl.png", "Hz. Zülkifl", icon_tree, TEAL)
    make(prophets / "yunus.png", "Hz. Yunus", icon_whale, BLUE)
    make(prophets / "zekeriya.png", "Hz. Zekeriya", icon_lamp, GOLD)
    make(prophets / "yahya.png", "Hz. Yahya", icon_drop, TEAL)

    make(duas / "rabbena_la_tuzig.png", "Kalplerimizi Koru", icon_heart)
    make(duas / "anne_baba.png", "Anne-Baba Duası", icon_people)
    make(duas / "zidni_ilma.png", "Rabbî Zıdnî İlmâ", icon_book)
    make(duas / "rabbighfirli.png", "Rabbîğfir Lî", icon_crescent)
    make(duas / "qiyam_after_ruku.png", "Rükûdan Doğrulma", icon_up)
    make(duas / "rabbena_ghfirli.png", "Rabbenâ'ğfirlî", icon_hands)

    make(home / "gunun_ayeti.png", "Günün Ayeti", icon_book, GREEN)
    make(home / "hadis.png", "Hadisler", icon_scroll, GOLD)

    make(morality / "truthfulness.png", "Doğruluk", icon_scale)
    make(morality / "mercy.png", "Merhamet", icon_heart)
    make(morality / "parents.png", "Anne-Baba", icon_people)
    make(morality / "sharing.png", "Yardımlaşma", icon_help)

    make(ilmihal / "temizlik.png", "Temizlik", icon_drop, TEAL)
    make(ilmihal / "abdest.png", "Abdest", icon_waves, TEAL)
    make(ilmihal / "namaz.png", "Namaz", icon_mosque)
    make(ilmihal / "oruc.png", "Oruç", icon_crescent, GOLD)
    make(ilmihal / "cami_adabi.png", "Cami Adabı", icon_mosque, DARK)


if __name__ == "__main__":
    main()
