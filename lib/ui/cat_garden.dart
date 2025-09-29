import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_state.dart';
import '../models/playground_item.dart';
import 'widgets/cat_sprite.dart';

class CatGarden extends StatelessWidget {
  const CatGarden({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final cats = game.cats;
    final playgrounds = game.playgroundCatalog
        .where((item) => game.placedPlaygrounds.contains(item.id))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
                      Theme.of(context).colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GridView.count(
                          crossAxisCount: isCompact ? 2 : 4,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.8,
                          children: [
                            for (final cat in cats)
                              Card(
                                elevation: 0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant
                                    .withOpacity(0.7),
                                child: Center(child: CatSprite(cat: cat)),
                              ),
                            if (cats.isEmpty)
                              Center(
                                child: Text(
                                  'まだ猫が少ないみたい…',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _PlaygroundRow(playgrounds: playgrounds),
                    ),
                  ],
                ),
              ),
            ),
            _GardenFooter(game: game),
          ],
        );
      },
    );
  }
}

class _PlaygroundRow extends StatelessWidget {
  const _PlaygroundRow({
    required this.playgrounds,
  });

  final List<PlaygroundItem> playgrounds;

  @override
  Widget build(BuildContext context) {
    if (playgrounds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'ポイントで遊び場をつくると、猫たちがもっと遊びにきます。',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return Container(
      height: 96,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final item = playgrounds[index];
          return _PlaygroundCard(item: item);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: playgrounds.length,
      ),
    );
  }
}

class _PlaygroundCard extends StatelessWidget {
  const _PlaygroundCard({required this.item});

  final PlaygroundItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _GardenFooter extends StatelessWidget {
  const _GardenFooter({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ねこポイント',
                    style: theme.textTheme.labelLarge,
                  ),
                  Text(
                    game.points.toString(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ご飯をあげた回数',
                  style: theme.textTheme.labelLarge,
                ),
                Text(
                  '${game.totalFoodGiven}回',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
