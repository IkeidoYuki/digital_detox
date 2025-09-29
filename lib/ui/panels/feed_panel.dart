import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_state.dart';
import '../../models/cat.dart';
import '../widgets/cat_sprite.dart';

class FeedPanel extends StatelessWidget {
  const FeedPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ご飯タイム',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          '携帯をスリープして貯めたポイントでご飯をあげると、猫たちがもっと遊びにきます。',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: game.canFeedCats
              ? () {
                  final success = context.read<GameState>().feedCats();
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ポイントが足りません')),
                    );
                  }
                }
              : null,
          icon: const Icon(Icons.pets),
          label: Text('ご飯をあげる (-${GameState.foodCost}pt)'),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              for (final cat in game.cats) _CatEntry(cat: cat),
            ],
          ),
        ),
      ],
    );
  }
}

class _CatEntry extends StatelessWidget {
  const _CatEntry({required this.cat});

  final CatInstance cat;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final outfits = game.outfitsForCat(cat.definition.id);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CatSprite(cat: cat),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.definition.personality,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '累計ご飯 ${cat.definition.requiredFood} で出会いました',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (outfits.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'おしゃれアイテム',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    selected: cat.activeOutfit == null,
                    label: const Text('なし'),
                    onSelected: (_) => context.read<GameState>().equipOutfit(cat.definition.id, null),
                  ),
                  for (final outfit in outfits)
                    FilterChip(
                      label: Text(outfit.name),
                      selected: cat.activeOutfit?.id == outfit.id,
                      onSelected: (_) =>
                          context.read<GameState>().equipOutfit(cat.definition.id, outfit),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
