import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Offline reference images with an accessible, zoomable full-screen gallery.
class ExerciseImageGallery extends StatelessWidget {
  const ExerciseImageGallery({
    super.key,
    required this.exerciseName,
    required this.assets,
  });

  final String exerciseName;
  final List<String> assets;

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: l10n.exerciseGalleryOpen(exerciseName),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: const Color(0xFFF2F1EC),
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _FullScreenGallery(
                      exerciseName: exerciseName,
                      assets: assets,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: _ExercisePicture(
                        asset: assets.first,
                        preview: true,
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 10,
                      end: 10,
                      child: IgnorePointer(
                        child: Tooltip(
                          message: l10n.exerciseGalleryView,
                          child: const CircleAvatar(child: Icon(Icons.zoom_in)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.exerciseGalleryReference,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ExercisePicture extends StatelessWidget {
  const _ExercisePicture({required this.asset, this.preview = false});

  final String asset;
  final bool preview;

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    fit: BoxFit.contain,
    cacheWidth: preview ? 960 : null,
    excludeFromSemantics: true,
    errorBuilder: (context, error, stackTrace) => ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppLocalizations.of(context)!.exerciseGalleryUnavailable,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}

class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({required this.exerciseName, required this.assets});

  final String exerciseName;
  final List<String> assets;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseName)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: widget.assets.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) => Semantics(
                  image: true,
                  label: l10n.exerciseGalleryOpen(widget.exerciseName),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: _ExercisePicture(asset: widget.assets[index]),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.assets.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).previousPageTooltip,
                    onPressed: _index == 0
                        ? null
                        : () => _pages.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Flexible(
                    child: Text(
                      l10n.exerciseGalleryPosition(
                        _index + 1,
                        widget.assets.length,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).nextPageTooltip,
                    onPressed: _index == widget.assets.length - 1
                        ? null
                        : () => _pages.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${l10n.exerciseGalleryZoomHint}\n${l10n.exerciseGalleryReference}',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
