import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/cat.dart';

class CatSprite extends StatelessWidget {
  const CatSprite({
    super.key,
    required this.cat,
  });

  final CatInstance cat;

  static const int columns = 4;
  static const int rows = 4;

  static final Map<String, Future<bool>> _assetAvailabilityCache = {};

  Future<bool> _canLoadAsset(String assetPath) {
    return _assetAvailabilityCache.putIfAbsent(assetPath, () async {
      try {
        await rootBundle.load(assetPath);
        return true;
      } catch (_) {
        return false;
      }
    });
  }

  Alignment _alignmentFor(int column, int row) {
    final x = (column / (columns - 1)) * 2 - 1;
    final y = (row / (rows - 1)) * 2 - 1;
    return Alignment(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final outfit = cat.activeOutfit;
    final accent = outfit?.accentColor;
    final assetPath = cat.definition.assetPath;

    return FutureBuilder<bool>(
      future: _canLoadAsset(assetPath),
      builder: (context, snapshot) {
        final waiting = snapshot.connectionState == ConnectionState.waiting;
        final available = snapshot.data ?? false;
        final showPlaceholder = !waiting && !available;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: accent?.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: 72,
                height: 72,
                child: waiting
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : available
                        ? ClipRect(
                            child: Align(
                              alignment:
                                  _alignmentFor(cat.definition.column, cat.definition.row),
                              widthFactor: 1 / columns,
                              heightFactor: 1 / rows,
                              child: Image.asset(
                                assetPath,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.pets,
                              color: accent ?? Theme.of(context).colorScheme.primary,
                              size: 32,
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cat.definition.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (outfit != null)
              Text(
                outfit.name,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: accent ?? Theme.of(context).colorScheme.secondary),
              ),
            if (showPlaceholder)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '猫画像を追加すると表示されます',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Theme.of(context).colorScheme.tertiary),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }
}
