#!/usr/bin/env python3
"""Generated illustration -> 512px webp with transparent rounded corners.

Usage: python3 scripts/process_art.py SRC DEST.webp
"""

import sys

from PIL import Image, ImageDraw

SIZE = 512
RADIUS = 64
# Generated art comes with dark rounded corners; trim them before re-masking.
INSET = 0.035


def process(src: str, dest: str) -> None:
    image = Image.open(src).convert('RGB')
    w, h = image.size
    side = min(w, h)
    pad = int(side * INSET)
    left = (w - side) // 2 + pad
    top = (h - side) // 2 + pad
    image = image.crop((left, top, left + side - 2 * pad, top + side - 2 * pad))
    image = image.resize((SIZE, SIZE), Image.LANCZOS).convert('RGBA')
    mask = Image.new('L', (SIZE * 4, SIZE * 4), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, SIZE * 4 - 1, SIZE * 4 - 1), radius=RADIUS * 4, fill=255
    )
    image.putalpha(mask.resize((SIZE, SIZE), Image.LANCZOS))
    image.save(dest, 'WEBP', quality=82, method=6)


if __name__ == '__main__':
    process(sys.argv[1], sys.argv[2])
