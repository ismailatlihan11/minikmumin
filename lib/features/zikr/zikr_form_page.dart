import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_spacing.dart';
import '../../data/models/dhikr.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import 'dhikr_store.dart';

class ZikrFormPage extends StatefulWidget {
  const ZikrFormPage({super.key, this.existing});

  final Dhikr? existing;

  @override
  State<ZikrFormPage> createState() => _ZikrFormPageState();
}

class _ZikrFormPageState extends State<ZikrFormPage> {
  final _title = TextEditingController();
  final _arabic = TextEditingController();
  final _transliteration = TextEditingController();
  final _meaning = TextEditingController();
  int _target = 33;
  int _step = 1;
  int _vibrationEvery = 1;
  int _soundEvery = 33;
  bool _customTarget = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _title.text = existing.title;
      _arabic.text = existing.arabic;
      _transliteration.text = existing.transliteration;
      _meaning.text = existing.meaning;
      _target = existing.targetCount;
      _step = existing.incrementStep;
      _vibrationEvery = existing.vibrationEvery;
      _soundEvery = existing.soundEvery;
      _customTarget = ![10, 33, 99, 100, 500, 1000].contains(_target);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _arabic.dispose();
    _transliteration.dispose();
    _meaning.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zikir adı yazmalısın.')),
      );
      return;
    }
    final store = context.read<DhikrStore>();
    final existing = widget.existing;
    if (existing == null) {
      await store.createCustom(
        title: title,
        arabic: _arabic.text,
        transliteration: _transliteration.text,
        meaning: _meaning.text,
        targetCount: _target,
        incrementStep: _step,
        vibrationEvery: _vibrationEvery,
        soundEvery: _soundEvery,
      );
    } else {
      await store.updateDhikr(
        existing.copyWith(
          title: title,
          arabic: _arabic.text.trim(),
          transliteration: _transliteration.text.trim(),
          meaning: _meaning.text.trim(),
          targetCount: _target,
          incrementStep: _step,
          vibrationEvery: _vibrationEvery,
          soundEvery: _soundEvery,
          contentEdited: true,
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Yeni zikir' : 'Zikir ayarları'),
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const PageHeader(
            title: 'Zikir kaydı',
            subtitle: 'Bu cihazda saklanır, internet gerekmez.',
          ),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Zikir adı'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _arabic,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(labelText: 'Arapça (opsiyonel)'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _transliteration,
            decoration: const InputDecoration(labelText: 'Okunuş'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _meaning,
            decoration: const InputDecoration(labelText: 'Anlam'),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Hedef'),
          Wrap(
            spacing: 8,
            children: [
              for (final value in const [10, 33, 99, 100, 500, 1000])
                ChoiceChip(
                  label: Text('$value'),
                  selected: !_customTarget && _target == value,
                  onSelected: (_) => setState(() {
                    _customTarget = false;
                    _target = value;
                  }),
                ),
              ChoiceChip(
                label: const Text('Özel'),
                selected: _customTarget,
                onSelected: (_) => setState(() => _customTarget = true),
              ),
            ],
          ),
          if (_customTarget)
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: '$_target'),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed == null) return;
                setState(() => _target = parsed.clamp(1, 100000));
              },
            ),
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Artış'),
          Wrap(
            spacing: 8,
            children: [
              for (final value in const [1, 5, 10])
                ChoiceChip(
                  label: Text('+$value'),
                  selected: _step == value,
                  onSelected: (_) => setState(() => _step = value),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Ek titreşim aralığı'),
          const Text(
            'Her çekişte zaten titreşim olur. Buradaki sayı dolunca ekstra güçlü titreşim verir (1 = her çekiş güçlü).',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final value in const [1, 10, 11, 33, 50, 99, 100])
                ChoiceChip(
                  label: Text('$value'),
                  selected: _vibrationEvery == value,
                  onSelected: (_) => setState(() => _vibrationEvery = value),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionLabel('Tesbih sesi'),
          const Text(
            'Her çekişte tıklar. Zikir ekranındaki Tesbih sesi anahtarından açıp kapatabilirsin.',
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: 'Kaydet', onPressed: _save),
        ],
      ),
    );
  }
}
