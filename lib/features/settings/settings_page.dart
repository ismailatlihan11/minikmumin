import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/theme_controller.dart';
import '../../core/share/app_share.dart';
import '../../core/storage/local_progress_store.dart';
import '../../features/elifba_adventure/elifba_progress.dart';
import '../../features/quran_learn/quran_learn_progress.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/minik_ui.dart';
import '../../shared/widgets/parental_gate.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _controller = TextEditingController();
  bool _loaded = false;
  bool _unlockLessons = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _setUnlockLessons(
    LocalProgressStore store,
    bool value,
  ) async {
    await store.setFlag(quranLearnUnlockFlag, value);
    await ElifbaProgress(store).setUnlockAll(value);
  }

  Future<void> _load() async {
    if (_loaded) return;
    final store = context.read<LocalProgressStore>();
    final name = await store.getNickname();
    final unlockQl = await store.getFlag(quranLearnUnlockFlag);
    final elifba = await ElifbaProgress(store).load();
    // Eski ayar yalnız Kur'an Öğren'i açıyordu; açıkken Elifbâ'yı da eşitle.
    var unlock = unlockQl || elifba.unlockAll;
    if (unlock && (!unlockQl || !elifba.unlockAll)) {
      await _setUnlockLessons(store, true);
    }
    if (!mounted) return;
    _controller.text = name ?? '';
    setState(() {
      _unlockLessons = unlock;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final isDark = context.watch<ThemeController>().isDark;
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const PageHeader(
            subtitle: 'Adın uygulama açılınca “Hoş geldin” yazısında görünür.',
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
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDark ? MinikColors.goldSoft : MinikColors.gold,
              ),
              title: const Text('Koyu mod'),
              subtitle: const Text(
                'Gece kullanımında gözü yormayan koyu renkler.',
              ),
              value: isDark,
              onChanged: (value) =>
                  context.read<ThemeController>().setDark(value),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MinikCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Öğrenme kilitlerini aç'),
              subtitle: const Text(
                'Ebeveyn ayarı: Kur’an Öğren ve Elifbâ + Tecvid dersleri kilitsiz açılsın.',
              ),
              value: _unlockLessons,
              onChanged: (value) async {
                if (value && !await confirmParent(context)) return;
                if (!context.mounted) return;
                await _setUnlockLessons(
                  context.read<LocalProgressStore>(),
                  value,
                );
                setState(() => _unlockLessons = value);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MinikCard(
            child: Builder(
              builder: (context) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.share_rounded, color: MinikColors.green),
                title: const Text('Uygulamayı paylaş'),
                subtitle: const Text(
                  'Minik Mümin’i aileni ve arkadaşlarınla paylaş.',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => AppShare.shareApp(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
