"""Kur'an Öğren / Elifbâ seslerini beklenen metne göre denetler.

Her kayıt için:
  * Whisper ile ne duyulduğu çıkarılır, ünsüz iskeleti metinle karşılaştırılır.
  * Türkçe hece kayıtlarında harf adının okunup okunmadığına bakılır.
  * Harekeden ve tecvid kurallarından (med tabiî/muttasıl/munfasıl/lâzım/ârız,
    şedde, gunne, vakf) beklenen mora sayısı hesaplanır; ölçülen konuşma süresi
    aynı türdeki kayıtların ortalamasıyla kıyaslanır.
  * Kısa/uzun çiftleri (بَ / بَا, hece / tenvin) arasındaki süre farkına bakılır.
  * Sessiz, aşırı boşluklu veya patlayan kayıtlar işaretlenir.

Otomatik kontrol kulakla dinlemenin yerini tutmaz; amaç dinlenecek listeyi
kısaltmaktır.

    dart run tool/audit_elifba_audio.dart --all > /tmp/all_audio.json
    /tmp/asrenv/bin/python scripts/check_quran_learn_audio.py /tmp/all_audio.json

`--reuse` önceki rapordaki tanıma sonuçlarını kullanır; yalnız yeni/değişen
kayıtlar yeniden dinlenir.
"""

from __future__ import annotations

import difflib
import json
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent
QURAN_PACK = ROOT / "assets/data/kur_an_ogrenme_veri_paketi.json"
REPORT_DIR = ROOT / "build/audio_check"

FATHA, KASRA, DAMMA = "\u064e", "\u0650", "\u064f"
FATHATAN, DAMMATAN, KASRATAN = "\u064b", "\u064c", "\u064d"
SUKUN, SHADDA, DAGGER_ALIF = "\u0652", "\u0651", "\u0670"
MARKS = set("\u064b\u064c\u064d\u064e\u064f\u0650\u0651\u0652\u0670\u0653\u0654\u0655\u06e1")
HAMZAS = set("ءأإؤئآ")
# Tertil hızında bir hareke (mora) en az ~0,12 sn sürer.
MIN_SEC_PER_MORA = 0.12
MIN_INTERCEPT = 0.15
# Tahkik (en yavaş öğretim okuyuşu) bile mora başına ~0,55 sn'yi pek aşmaz.
MAX_SEC_PER_MORA = 0.55
MAX_INTERCEPT = 0.6
TURKISH_LETTER_NAMES = {
    "elif", "cim", "dal", "zel", "sin", "şın", "sad", "dad", "ayn", "gayn",
    "gayın", "kaf", "kef", "lam", "mim", "nun", "vav", "hı",
}


@dataclass
class Item:
    path: str
    text: str
    say: str
    kind: str
    voice: str
    heard: str = ""
    duration: float = 0.0
    speech: float = 0.0
    lead: float = 0.0
    tail: float = 0.0
    peak_db: float = -99.0
    morae: tuple[float, float] = (0.0, 0.0)
    issues: list[tuple[str, str]] = field(default_factory=list)

    @property
    def spoken(self) -> str:
        """Hareke adı kartlarında ekranda işaret, kayıtta adı (فَتْحَة) vardır."""
        return self.say if self.kind == "hareke adı" else self.text

    @property
    def group(self) -> str:
        if self.voice == "tr":
            return "tr-hece"
        if "/elifba/" in self.path:
            return "ar-tts"
        return "ar-kayit"


# ---------------------------------------------------------------- toplama

def collect(all_audio: Path) -> list[Item]:
    items: dict[str, Item] = {}

    def add(path: str, text: str, kind: str, voice: str = "ar", say: str = "") -> None:
        if not path or not text or path in items:
            return
        if not (ROOT / path).exists():
            return
        items[path] = Item(path, text, say or text, kind, voice)

    for row in json.loads(all_audio.read_text(encoding="utf-8")):
        if row["kind"] == "harf adı":
            continue
        add(row["path"], row["text"], row["kind"], row["voice"], row["say"])

    pack = json.loads(QURAN_PACK.read_text(encoding="utf-8"))
    for item in pack["quran_harakat"]["items"]:
        for ex in item.get("examples", []):
            add(ex.get("audio", ""), ex.get("arabic", ""), "hareke örneği")
    for lesson in pack["quran_combinations"]["lessons"]:
        for ex in lesson.get("examples", []):
            add(ex.get("audio", ""), ex.get("combined", ""), "birleşim")
    for word in pack["quran_words"]["words"]:
        add(word.get("audio", ""), word.get("arabic", ""), "kelime (seri)")
    for lesson in pack["quran_tajweed"]["lessons"]:
        for index, ex in enumerate(lesson.get("examples", [])):
            unique = f"assets/audio/quran_learn/tajweed/{lesson['id']}_{index + 1}.mp3"
            path = unique if (ROOT / unique).exists() else ex.get("audio", "")
            add(path, ex.get("arabic", ""), f"tecvid: {lesson.get('title', lesson['id'])}")
    return list(items.values())


# ---------------------------------------------------------------- metin

def units(word: str) -> list[tuple[str, str]]:
    out: list[tuple[str, str]] = []
    for ch in word:
        if ch in MARKS:
            if out:
                out[-1] = (out[-1][0], out[-1][1] + ch)
        elif ch == "\u0640":
            continue
        else:
            out.append((ch, ""))
    return out


def has_vowel(marks: str) -> bool:
    return any(m in marks for m in (FATHA, KASRA, DAMMA, FATHATAN, DAMMATAN, KASRATAN))


def is_madd_letter(seq: list[tuple[str, str]], i: int) -> bool:
    if i == 0 or i >= len(seq):
        return False
    base, marks = seq[i]
    prev_marks = seq[i - 1][1]
    if has_vowel(marks) or SHADDA in marks:
        return False
    if base in "اى" and FATHA in prev_marks:
        return True
    if base == "ي" and KASRA in prev_marks:
        return True
    if base == "و" and DAMMA in prev_marks:
        return True
    return False


def expected_morae(text: str) -> tuple[float, float]:
    """Beklenen süre (mora) aralığı. Son harf vakfla okunur."""
    words = [w for w in re.split(r"[\s،,\-–]+", text.strip()) if w]
    lo = hi = 0.0
    for wi, word in enumerate(words):
        seq = units(word)
        last_word = wi == len(words) - 1
        i = 0
        while i < len(seq):
            base, marks = seq[i]
            if base in "ٱا" and not marks and i + 2 < len(seq) and seq[i + 1][0] == "ل":
                i += 1  # lâm-ı tarif elifi okunmaz
                continue
            if is_madd_letter(seq, i):
                i += 1
                continue
            if base == "ل" and not marks and i + 1 < len(seq) and SHADDA in seq[i + 1][1]:
                i += 1  # şemsî lâm okunmaz
                continue
            # Tek harflik hece alıştırmalarında hareke vakıfla düşmez.
            final = last_word and i == len(seq) - 1 and len(seq) > 1
            near_final = last_word and i >= len(seq) - 2
            if SHADDA in marks:
                lo += 1
                hi += 1
                if base in "نم":
                    lo += 1
                    hi += 1
            if not has_vowel(marks):
                lo += 0.5
                hi += 0.5
                i += 1
                continue
            if final:
                bonus = 2 if FATHATAN in marks else 0.5
                lo += bonus
                hi += bonus
                i += 1
                continue
            madd = DAGGER_ALIF in marks or is_madd_letter(seq, i + 1)
            if not madd:
                extra = 0.5 if any(t in marks for t in (FATHATAN, DAMMATAN, KASRATAN)) else 0
                lo += 1 + extra
                hi += 1 + extra
                i += 1
                continue
            j = i + 1 if DAGGER_ALIF in marks else i + 2
            nxt = seq[j] if j < len(seq) else None
            if nxt and nxt[0] in HAMZAS:
                lo, hi = lo + 4, hi + 5  # muttasıl
            elif nxt and (SHADDA in nxt[1] or SUKUN in nxt[1]) and not (last_word and j == len(seq) - 1):
                lo, hi = lo + 6, hi + 6  # lâzım
            elif nxt is None and wi + 1 < len(words) and words[wi + 1][0] in HAMZAS:
                lo, hi = lo + 4, hi + 5  # munfasıl
            elif nxt is not None and (near_final or (last_word and j == len(seq) - 1)):
                lo, hi = lo + 2, hi + 6  # ârız (vakf)
            else:
                lo, hi = lo + 2, hi + 2  # tabiî
            i = j
    return lo, hi


def skeleton(text: str) -> str:
    text = re.sub(r"[\u064b-\u0655\u0670\u06e1\u0640]", "", text)
    text = text.replace("اللاه", "الله").replace("ٱ", "ا")
    for src, dst in (("أ", "ا"), ("إ", "ا"), ("آ", "ا"), ("ى", "ي"), ("ة", "ه"), ("ؤ", "و"), ("ئ", "ي")):
        text = text.replace(src, dst)
    return re.sub(r"[^\u0621-\u064a]", "", text).replace("ء", "")


def consonants(text: str) -> str:
    return skeleton(text).replace("ا", "")


def similarity(a: str, b: str) -> float:
    if not a and not b:
        return 1.0
    return difflib.SequenceMatcher(None, a, b).ratio()


def letter_count(text: str) -> int:
    return len([ch for ch in text if ch not in MARKS and not ch.isspace() and ch not in "-،,"])


# ---------------------------------------------------------------- ses

def load_pcm(path: Path) -> np.ndarray:
    raw = subprocess.run(
        ["ffmpeg", "-v", "error", "-i", str(path), "-ac", "1", "-ar", "16000", "-f", "f32le", "-"],
        capture_output=True,
        check=True,
    ).stdout
    return np.frombuffer(raw, dtype=np.float32)


def measure(item: Item, pcm: np.ndarray) -> None:
    rate = 16000
    item.duration = len(pcm) / rate
    if len(pcm) == 0:
        return
    peak = float(np.max(np.abs(pcm)))
    item.peak_db = 20 * np.log10(peak + 1e-9)
    frame = int(rate * 0.02)
    count = len(pcm) // frame
    if count == 0:
        return
    rms = np.sqrt(np.mean(pcm[: count * frame].reshape(count, frame) ** 2, axis=1))
    db = 20 * np.log10(rms + 1e-9)
    speech = db > max(db.max() - 35, -55)
    item.speech = float(speech.sum()) * 0.02
    idx = np.flatnonzero(speech)
    if len(idx):
        item.lead = idx[0] * 0.02
        item.tail = (count - 1 - idx[-1]) * 0.02


# ---------------------------------------------------------------- kurallar

def check_text(item: Item) -> None:
    if item.voice == "tr":
        heard = re.sub(r"[^a-zçğıöşü ]", " ", item.heard.lower()).split()
        target = item.say.lower().replace("â", "a").replace("î", "i").replace("û", "u")
        names = [w for w in heard if w in TURKISH_LETTER_NAMES and w != target]
        if names:
            item.issues.append(("YÜKSEK", f"harf adı gibi duyuluyor: {' '.join(names)}"))
        elif heard and not any(similarity(w, target) >= 0.5 for w in heard):
            item.issues.append(("ORTA", f"'{item.say}' yerine '{' '.join(heard)}' duyuluyor"))
        return
    want, got = consonants(item.spoken), consonants(item.heard)
    if any(t in item.text for t in (FATHATAN, DAMMATAN, KASRATAN)) and got.endswith("ن"):
        got = got[:-1]
    if not want:
        return
    if not got:
        item.issues.append(("ORTA" if letter_count(item.text) <= 2 else "YÜKSEK", "konuşma tanınamadı"))
        return
    score = similarity(want, got)
    short = letter_count(item.text) <= 2
    if score < (0.34 if short else 0.6):
        level = "ORTA" if short else "YÜKSEK"
        item.issues.append((level, f"metinden farklı duyuluyor (benzerlik {score:.0%})"))


def check_signal(item: Item) -> None:
    if item.speech < 0.15:
        item.issues.append(("YÜKSEK", "ses yok ya da çok kısa"))
    if item.lead > 1.0 or item.tail > 1.5:
        item.issues.append(("DÜŞÜK", f"uzun boşluk (baş {item.lead:.1f} sn, son {item.tail:.1f} sn)"))
    if item.peak_db > -0.05:
        item.issues.append(("DÜŞÜK", "tepe seviyesi 0 dB, patlama olabilir"))


def tempo_candidate(it: Item) -> bool:
    # Tire ile ayrılmış hece grupları bilerek boşluklu okunur.
    return it.speech > 0.15 and it.morae[0] > 0 and letter_count(it.text) >= 2 and "-" not in it.text


def check_tempo(items: list[Item]) -> None:
    # Sınırlar mutlak: kayıtların çoğu TTS ve zaten hızlı olduğundan
    # ortalamaya göre kıyas toplu kısalığı göremez, insan kaydını da yavaş sanar.
    for it in items:
        if not tempo_candidate(it):
            continue
        lo, hi = it.morae
        want_lo = MIN_INTERCEPT + MIN_SEC_PER_MORA * lo
        want_hi = MAX_INTERCEPT + MAX_SEC_PER_MORA * hi
        if lo >= 3 and it.speech < 0.75 * want_lo:
            it.issues.append(("ORTA", f"beklenenden hızlı: uzatma/gunne kısa kalmış olabilir ({it.speech:.1f} sn, beklenen ~{want_lo:.1f}+ sn)"))
        elif it.speech > want_hi:
            it.issues.append(("ORTA", f"beklenenden yavaş: gereksiz uzatma/tekrar olabilir ({it.speech:.1f} sn, beklenen ~{want_hi:.1f} sn)"))


def check_pairs(items: list[Item]) -> None:
    by_path = {it.path: it for it in items}
    pairs = []
    for it in items:
        m = re.search(r"quran_learn/madd/(\w+)_madd_(alif|ya|waw)\.mp3$", it.path)
        if m:
            short = {"alif": "fatha", "ya": "kasra", "waw": "damma"}[m.group(2)]
            pairs.append((it, f"assets/audio/quran_learn/exercises/{m.group(1)}_{short}.mp3", 1.3, "uzatma"))
        m = re.search(r"elifba/exercises/(\w+)_(fathatayn|kasratayn|dammatayn)\.mp3$", it.path)
        if m:
            short = {"fathatayn": "fatha", "kasratayn": "kasra", "dammatayn": "damma"}[m.group(2)]
            pairs.append((it, f"assets/audio/elifba/exercises/{m.group(1)}_{short}.mp3", 0.9, "tenvin"))
    for long_item, short_path, need, label in pairs:
        short_item = by_path.get(short_path)
        if short_item is None and (ROOT / short_path).exists():
            short_item = Item(short_path, "", "", "", "")
            measure(short_item, load_pcm(ROOT / short_path))
        if short_item is None or short_item.speech <= 0:
            continue
        ratio = long_item.speech / short_item.speech
        if ratio < need:
            long_item.issues.append(("ORTA", f"{label} duyulmuyor: kısa hâlinin {ratio:.2f} katı ({Path(short_path).name})"))


# ---------------------------------------------------------------- rapor

def write_report(items: list[Item]) -> Path:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    order = {"YÜKSEK": 0, "ORTA": 1, "DÜŞÜK": 2}
    flagged = sorted(
        (it for it in items if it.issues),
        key=lambda it: (min(order[l] for l, _ in it.issues), it.path),
    )
    lines = [
        "# Kur'an Öğren ses kontrolü",
        "",
        f"Taranan kayıt: {len(items)} · işaretlenen: {len(flagged)}",
        "",
        "Otomatik kontrol; kesin hüküm değildir. Önce YÜKSEK, sonra ORTA satırlarını dinleyin.",
        "",
    ]
    for level in ("YÜKSEK", "ORTA", "DÜŞÜK"):
        rows = [it for it in flagged if min(order[l] for l, _ in it.issues) == order[level]]
        if not rows:
            continue
        lines += [f"## {level} ({len(rows)})", ""]
        for it in rows:
            lo, hi = it.morae
            lines.append(f"- `{it.path}` — {it.kind}")
            lines.append(f"  - metin: {it.text}" + (f" · okunuş: {it.say}" if it.voice == "tr" else ""))
            lines.append(f"  - duyulan: {it.heard or '—'}")
            lines.append(f"  - süre: {it.speech:.2f} sn konuşma / {it.duration:.2f} sn · beklenen mora: {lo:g}–{hi:g}")
            for level_name, message in it.issues:
                lines.append(f"  - **{level_name}**: {message}")
        lines.append("")
    path = REPORT_DIR / "report.md"
    path.write_text("\n".join(lines), encoding="utf-8")
    (REPORT_DIR / "report.json").write_text(
        json.dumps(
            [
                {
                    "path": it.path, "kind": it.kind, "text": it.text, "say": it.say,
                    "heard": it.heard, "speech": round(it.speech, 2),
                    "morae": list(it.morae), "issues": it.issues,
                }
                for it in items
            ],
            ensure_ascii=False,
            indent=1,
        ),
        encoding="utf-8",
    )
    return path


def main(argv: list[str]) -> int:
    reuse = "--reuse" in argv
    argv = [a for a in argv if a != "--reuse"]
    items = collect(Path(argv[0]))
    previous: dict[str, str] = {}
    if reuse and (REPORT_DIR / "report.json").exists():
        for row in json.loads((REPORT_DIR / "report.json").read_text(encoding="utf-8")):
            previous[row["path"]] = row["heard"]
    model = None
    for index, it in enumerate(items, 1):
        pcm = load_pcm(ROOT / it.path)
        measure(it, pcm)
        it.morae = expected_morae(it.spoken) if it.voice == "ar" else (0.0, 0.0)
        if it.path in previous:
            it.heard = previous[it.path]
        else:
            if model is None:
                from faster_whisper import WhisperModel

                model = WhisperModel(argv[1] if len(argv) > 1 else "medium", device="cpu", compute_type="int8")
            segments, _ = model.transcribe(
                pcm, language="tr" if it.voice == "tr" else "ar", beam_size=5, vad_filter=False
            )
            it.heard = " ".join(s.text.strip() for s in segments)
        check_signal(it)
        check_text(it)
        if index % 25 == 0:
            print(f"{index}/{len(items)}", flush=True)
    check_tempo(items)
    check_pairs(items)
    path = write_report(items)
    counts = {lvl: sum(1 for it in items if any(l == lvl for l, _ in it.issues)) for lvl in ("YÜKSEK", "ORTA", "DÜŞÜK")}
    print(f"taranan: {len(items)} · {counts} · rapor: {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
