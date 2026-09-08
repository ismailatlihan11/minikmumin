"""Harekeli harf seslerinin gerçekten a/i/u okunup okunmadığını ölçer.

Ünlüler formantlarıyla ayrılır: /a/ yüksek F1, /i/ düşük F1 + yüksek F2,
/u/ düşük F1 + düşük F2. Kayıtta ölçülen formantlar beklenen ünlüye
uymuyorsa dosya yanlış sesi taşıyor demektir.

Kullanım: python3 scripts/check_vowel_sounds.py [harf_id ...]
"""

import subprocess
import sys
import tempfile
import wave
from pathlib import Path

import numpy as np
from scipy.signal import lfilter

EXERCISES = Path("assets/audio/quran_learn/exercises")
HARAKAT = {"fatha": "a", "kasra": "i", "damma": "u"}
# Kadın/erkek fark etmeksizin ayırt etmeye yeten kaba aralıklar (Hz).
RANGES = {
    "a": {"f1": (550, 1100), "f2": (1000, 1700)},
    "i": {"f1": (200, 450), "f2": (1800, 2900)},
    "u": {"f1": (200, 500), "f2": (600, 1300)},
}


def read_mp3(path: Path) -> tuple[np.ndarray, int]:
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
        wav_path = Path(tmp.name)
    subprocess.run(
        ["afconvert", "-f", "WAVE", "-d", "LEI16@16000", "-c", "1",
         str(path), str(wav_path)],
        check=True, capture_output=True,
    )
    with wave.open(str(wav_path), "rb") as wav:
        frames = wav.readframes(wav.getnframes())
        rate = wav.getframerate()
    wav_path.unlink(missing_ok=True)
    return np.frombuffer(frames, dtype=np.int16).astype(float) / 32768.0, rate


def formants(signal: np.ndarray, rate: int) -> tuple[float, float]:
    """En yüksek enerjili ünlü bölgesinden ilk iki formantı kestirir."""
    frame = int(0.025 * rate)
    hop = frame // 2
    energies = [
        (np.sum(signal[i:i + frame] ** 2), i)
        for i in range(0, max(1, len(signal) - frame), hop)
    ]
    if not energies:
        return 0.0, 0.0
    energies.sort(reverse=True)
    # En güçlü çerçevelerin ortasını al: patlamalı başlangıç yerine ünlü çekirdeği.
    start = sorted(i for _, i in energies[: max(3, len(energies) // 6)])
    core = start[len(start) // 2]
    window = signal[core:core + frame] * np.hamming(frame)
    pre = lfilter([1.0, -0.97], 1.0, window)
    order = 2 + rate // 1000
    autoc = np.correlate(pre, pre, mode="full")[len(pre) - 1:]
    if autoc[0] == 0:
        return 0.0, 0.0
    coeffs = _levinson(autoc[: order + 1], order)
    roots = [r for r in np.roots(coeffs) if np.imag(r) > 0.01]
    freqs = sorted(np.arctan2(np.imag(r), np.real(r)) * rate / (2 * np.pi)
                   for r in roots)
    freqs = [f for f in freqs if 150 < f < 4000]
    if len(freqs) < 2:
        return 0.0, 0.0
    return freqs[0], freqs[1]


def _levinson(r: np.ndarray, order: int) -> np.ndarray:
    a = np.zeros(order + 1)
    a[0] = 1.0
    err = r[0]
    for i in range(1, order + 1):
        acc = r[i] + sum(a[j] * r[i - j] for j in range(1, i))
        k = -acc / err if err else 0.0
        a_prev = a.copy()
        for j in range(1, i):
            a[j] = a_prev[j] + k * a_prev[i - j]
        a[i] = k
        err *= 1 - k * k
        if err <= 0:
            break
    return a


def main(argv: list[str]) -> int:
    wanted = argv or sorted({p.stem.rsplit("_", 1)[0]
                             for p in EXERCISES.glob("*.mp3")})
    problems = 0
    for letter_id in wanted:
        row = []
        for haraka, vowel in HARAKAT.items():
            path = EXERCISES / f"{letter_id}_{haraka}.mp3"
            if not path.exists():
                continue
            signal, rate = read_mp3(path)
            f1, f2 = formants(signal, rate)
            limits = RANGES[vowel]
            ok = (limits["f1"][0] <= f1 <= limits["f1"][1]
                  and limits["f2"][0] <= f2 <= limits["f2"][1])
            if not ok:
                problems += 1
            row.append(f"{haraka}={vowel} F1={f1:4.0f} F2={f2:5.0f} "
                       f"{'ok' if ok else 'UYMUYOR'}")
        if row:
            print(f"{letter_id:10s} " + " | ".join(row))
    print(f"\nuymayan kayıt: {problems}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
