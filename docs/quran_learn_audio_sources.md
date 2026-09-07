# Kur'an Öğren educational audio sources

These files were generated using Google Cloud Text-to-Speech. The audio files are synthetic outputs generated from the supplied text. Review Google Cloud's current terms and pricing before commercial redistribution.

This audio is **educational pronunciation**, not Quran recitation, adhan, or qari imitation. Short surahs here use the same cartoon-boy TTS. Fâtiha pacing follows Alafasy murattal as a reference, but the clip is child TTS. Kur'an-ı Kerim tilavet stays on Husary (`assets/audio/quran/`).

- Voice: `ar-XA-Chirp3-HD-Fenrir`
- Language: `ar-XA`
- Speaking rate: `0.9` (isolated letters `0.86`)
- Pitch: `8.0` (Neural2/Wavenet only; Chirp omits API pitch)
- Cartoon pitch shift: `5.0` semitones after TTS (cartoon-boy timbre)
- Voice style: cartoon-boy educational speaker, not a deep adult qari.
- Isolated letter cards speak Diyanet-style short names (با، تا، ثا), generated with our own Fenrir TTS. Diyanet audio files are not copied.
- Haraka chips (üstün/esre/ötre) still use sounded syllables (e.g. طَ).
- API: Google Cloud Text-to-Speech (`google-cloud-texttospeech`)
- Auth: Application Default Credentials (no keys in the Flutter app)
- Generated date: 2026-09-01
- Generated: 162
- Skipped: 437
- Failed: 0

Documentation:
- https://cloud.google.com/text-to-speech/docs
- https://cloud.google.com/terms

License is **not** marked royalty-free or public domain.

Letter `ه` is stored as `alphabet/hah.mp3` because `ha.mp3` is used for `ح`.
