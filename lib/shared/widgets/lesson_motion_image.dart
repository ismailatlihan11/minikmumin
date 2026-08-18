import 'package:flutter/material.dart';

import '../../core/audio/asset_catalog.dart';

/// Plays existing lesson stills as a slow crossfade, or a light idle float.
/// Missing files fall back to the static [image]; the app never crashes.
class LessonMotionImage extends StatefulWidget {
  const LessonMotionImage({
    super.key,
    required this.image,
    this.frames = const [],
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  });

  final String image;
  final List<String> frames;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  State<LessonMotionImage> createState() => _LessonMotionImageState();
}

class _LessonMotionImageState extends State<LessonMotionImage>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _hold;
  late final AnimationController _cross;
  int _from = 0;
  int _to = 0;

  List<String> get _frames {
    final listed = [
      for (final path in widget.frames)
        if (path.trim().isNotEmpty) path.trim(),
    ];
    final playable = listed.where(_usable).toList();
    if (playable.length >= 2) return playable;
    final cover = widget.image.trim();
    return cover.isEmpty ? playable : [cover];
  }

  bool _usable(String path) {
    if (path.isEmpty) return false;
    if (AssetCatalog.contains(path)) return true;
    return !_catalogReady;
  }

  bool get _catalogReady =>
      AssetCatalog.contains('assets/images/home/card_wudu.png') ||
      AssetCatalog.contains(widget.image);

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _hold = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _cross = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _hold.addStatusListener(_onHold);
    _boot();
  }

  @override
  void didUpdateWidget(covariant LessonMotionImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image || oldWidget.frames != widget.frames) {
      _from = 0;
      _to = 0;
      _boot();
    }
  }

  void _boot() {
    _idle.stop();
    _hold.stop();
    _cross.stop();
    final frames = _frames;
    if (frames.length >= 2) {
      _from = 0;
      _to = 0;
      _cross.value = 1;
      _hold.forward(from: 0);
    } else {
      _idle.repeat(reverse: true);
    }
  }

  void _onHold(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final frames = _frames;
    if (!mounted || frames.length < 2) return;
    setState(() {
      _from = _to;
      _to = (_to + 1) % frames.length;
    });
    _cross.forward(from: 0).whenComplete(() {
      if (mounted) _hold.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _hold.removeStatusListener(_onHold);
    _idle.dispose();
    _hold.dispose();
    _cross.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frames = _frames;
    if (frames.isEmpty) return const SizedBox.shrink();
    if (MediaQuery.disableAnimationsOf(context)) {
      return _Still(
        path: frames.first,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        semanticLabel: widget.semanticLabel,
      );
    }

    final bob = Tween<double>(begin: -3.5, end: 3.5).animate(
      CurvedAnimation(parent: _idle, curve: Curves.easeInOut),
    );
    final scale = Tween<double>(begin: 1, end: 1.03).animate(
      CurvedAnimation(parent: _idle, curve: Curves.easeInOut),
    );

    if (frames.length == 1) {
      return AnimatedBuilder(
        animation: _idle,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, bob.value),
          child: Transform.scale(scale: scale.value, child: child),
        ),
        child: _Still(
          path: frames.first,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          semanticLabel: widget.semanticLabel,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _cross,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_cross.value.clamp(0.0, 1.0));
        return SizedBox(
          height: widget.height,
          width: widget.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 1 - t,
                child: _Still(
                  path: frames[_from],
                  height: widget.height,
                  width: widget.width,
                  fit: widget.fit,
                ),
              ),
              Opacity(
                opacity: t,
                child: _Still(
                  path: frames[_to],
                  height: widget.height,
                  width: widget.width,
                  fit: widget.fit,
                  semanticLabel: widget.semanticLabel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Still extends StatelessWidget {
  const _Still({
    required this.path,
    required this.fit,
    this.height,
    this.width,
    this.semanticLabel,
  });

  final String path;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      height: height,
      width: width,
      fit: fit,
      semanticLabel: semanticLabel,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => SizedBox(
        height: height,
        width: width,
        child: const Icon(Icons.image_outlined),
      ),
    );
  }
}
