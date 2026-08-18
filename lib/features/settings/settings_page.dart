import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/storage/local_progress_store.dart';
import '../../features/quran_learn/quran_learn_progress.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _controller = TextEditingController();
  bool _loaded = false;
  bool _unlockQuranLearn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loaded) return;
    final store = context.read<LocalProgressStore>();
    final name = await store.getNickname();
    final unlock = await store.getFlag(quranLearnUnlockFlag);
    if (!mounted) return;
    _controller.text = name ?? '';
    setState(() {
      _unlockQuranLearn = unlock;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _load();
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const PageHeader(
            title: 'Ayarlar',
            subtitle: 'Adın uygulama açılınca “Hoş geldin” yazısında görünür.',
            image: 'assets/images/home/settings.png',
          ),
          MinikCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adın'),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Adını yaz, ana sayfada seni karşılayalım',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Kaydet',
                  onPressed: () async {
                    await context.read<LocalProgressStore>().setNickname(
                          _controller.text.trim(),
                        );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kaydedildi.')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MinikCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Kur\'an Öğren kilitlerini aç'),
              subtitle: const Text(
                'Ebeveyn ayarı: sonraki seviyeler kilitsiz açılsın.',
              ),
              value: _unlockQuranLearn,
              activeThumbColor: MinikColors.green,
              onChanged: (value) async {
                await context.read<LocalProgressStore>().setFlag(
                      quranLearnUnlockFlag,
                      value,
                    );
                setState(() => _unlockQuranLearn = value);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MinikCard(
            color: MinikColors.mint,
            child: Text(
              '${AppConstants.defaultAppName} tamamen bu cihazda çalışır. Kur’an ve hadis metinleri değiştirilmez.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
