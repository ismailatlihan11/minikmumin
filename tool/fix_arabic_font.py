"""Noto Naskh Arabic'te şedde + esre birleşik glifini kaldırır.

Font, şedde ile esre/esre-tenvinini tek glife (uni06510650) çevirip esreyi
harfin üstüne, şeddenin altına çiziyor. Diyanet elifbâsı ve Türkçe öğretim
geleneği esreyi harfin altında gösterdiği için bu ligatürleri siliyoruz;
kaldırıldığında esre normal mark-to-base kuralıyla harfin altına iniyor.

Betik idempotenttir: `python3 tool/fix_arabic_font.py`
"""

import sys

from fontTools.ttLib import TTFont

FONT = "assets/fonts/NotoNaskhArabic-Regular.ttf"
# Şedde ile birleşince yukarı taşınan alt işaretler: esre ve esre tenvini.
BELOW_MARKS = {0x0650, 0x064D}


def subtables(lookup):
    for table in lookup.SubTable:
        yield getattr(table, "ExtSubTable", table)


def main():
    font = TTFont(FONT)
    cmap = font.getBestCmap()
    shadda = cmap[0x0651]
    targets = {cmap[code] for code in BELOW_MARKS}

    removed = []
    for lookup in font["GSUB"].table.LookupList.Lookup:
        for table in subtables(lookup):
            if getattr(table, "LookupType", lookup.LookupType) != 4:
                continue
            if not hasattr(table, "ligatures"):
                continue
            for first, ligatures in list(table.ligatures.items()):
                kept = []
                for ligature in ligatures:
                    parts = {first, *ligature.Component}
                    if shadda in parts and parts & targets:
                        removed.append(ligature.LigGlyph)
                    else:
                        kept.append(ligature)
                if kept:
                    table.ligatures[first] = kept
                else:
                    del table.ligatures[first]

    if not removed:
        print("zaten temiz: şedde + esre ligatürü yok")
        return 0

    font.save(FONT)
    print(f"kaldırılan ligatür: {', '.join(sorted(set(removed)))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
