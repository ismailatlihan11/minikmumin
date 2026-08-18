# Kur'an Öğren educational audio sources

These files were generated using Google Cloud Text-to-Speech. The audio files are synthetic outputs generated from the supplied text. Review Google Cloud's current terms and pricing before commercial redistribution.

This audio is **educational pronunciation**, not Quran recitation, adhan, or qari imitation. Short-surah tilawat stays on real recitation assets.

The Flutter app stays **offline**. TTS runs only on a developer machine; MP3s are copied into `assets/audio/quran_learn/` and shipped in the APK. Do not call Google from Dart.

Status (2026-08-18): **ADC missing** — `gcloud` / `application_default_credentials.json` not found. `--test` / `--all` were not run. JSON paths in `kur_an_ogrenme_veri_paketi.json` are already bound.

- Voice: pending ADC / generation
- Language: `ar-XA`
- Speaking rate: `0.85`
- API: Google Cloud Text-to-Speech (`google-cloud-texttospeech`)
- Auth: Application Default Credentials (no keys in the Flutter app)

Documentation:
- https://cloud.google.com/text-to-speech/docs
- https://cloud.google.com/terms

License is **not** marked royalty-free or public domain.

Letter `ه` is stored as `alphabet/hah.mp3` because `ha.mp3` is used for `ح`.

To generate:

```bash
python3 scripts/setup_quran_learn_audio.py
python3 scripts/generate_quran_learn_audio.py --test
python3 scripts/generate_quran_learn_audio.py --all
```
