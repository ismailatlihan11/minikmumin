import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Ebeveyn ayarlarına girmeden önce sorulan çarpma sorusu.
///
/// Doğru cevapta `true`, vazgeçilince `false` döner.
Future<bool> confirmParent(BuildContext context, {Random? random}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ParentalGateDialog(random: random),
  );
  return result ?? false;
}

class ParentalGateDialog extends StatefulWidget {
  const ParentalGateDialog({super.key, this.random});

  final Random? random;

  @override
  State<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<ParentalGateDialog> {
  late final Random _random = widget.random ?? Random();
  late int _a;
  late int _b;
  String _input = '';
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    _a = 6 + _random.nextInt(4);
    _b = 6 + _random.nextInt(4);
    _input = '';
  }

  void _press(String digit) {
    if (_input.length >= 3) return;
    setState(() {
      _wrong = false;
      _input += digit;
    });
    if (_input.length == '${_a * _b}'.length) _check();
  }

  void _erase() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _check() {
    if (int.tryParse(_input) == _a * _b) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _wrong = true;
      _newQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ebeveyn kontrolü'),
      scrollable: true,
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Devam etmek için soruyu bir büyüğün cevaplasın.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 14,
                color: MinikColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            Semantics(
              label: '$_a çarpı $_b kaç eder',
              child: Text(
                '$_a × $_b = ${_input.isEmpty ? '?' : _input}',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: MinikColors.darkGreen,
                ),
              ),
            ),
            SizedBox(
              height: 22,
              child: _wrong
                  ? const Text(
                      'Yanlış cevap, yeni soru geldi.',
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC0473A),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            for (final row in const [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
              ['', '0', '<'],
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    for (var i = 0; i < row.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: row[i].isEmpty
                              ? null
                              : _GateKey(
                                  label: row[i],
                                  onTap: row[i] == '<'
                                      ? _erase
                                      : () => _press(row[i]),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Vazgeç'),
        ),
      ],
    );
  }
}

class _GateKey extends StatelessWidget {
  const _GateKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final erase = label == '<';
    return Material(
      color: MinikColors.mint,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: erase
              ? Icon(
                  Icons.backspace_outlined,
                  color: MinikColors.darkGreen,
                  semanticLabel: 'Sil',
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: MinikColors.darkGreen,
                  ),
                ),
        ),
      ),
    );
  }
}
