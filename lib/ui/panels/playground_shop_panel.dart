import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_state.dart';
import '../../models/playground_item.dart';

class PlaygroundShopPanel extends StatelessWidget {
  const PlaygroundShopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final catalog = game.playgroundCatalog;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '遊び場をつくる',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          '遊び場を増やすと、新しい猫が遊びにきたり、ポイントがもっと貯まりやすくなります。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: catalog.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = catalog[index];
              final owned = game.placedPlaygrounds.contains(item.id);
              return _PlaygroundTile(item: item, owned: owned);
            },
          ),
        ),
      ],
    );
  }
}

class _PlaygroundTile extends StatelessWidget {
  const _PlaygroundTile({required this.item, required this.owned});

  final PlaygroundItem item;
  final bool owned;

  @override
  Widget build(BuildContext context) {
    final canAfford = context.select<GameState, bool>((game) => game.points >= item.cost);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  owned ? Icons.check_circle : Icons.yard,
                  color: owned ? Colors.green : Theme.of(context).colorScheme.primary,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('コスト: ${item.cost} pt'),
                ElevatedButton(
                  onPressed: owned || !canAfford
                      ? null
                      : () {
                          final success = context.read<GameState>().purchasePlayground(item.id);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ポイントが足りないか、すでに設置済みです。')),
                            );
                          }
                        },
                  child: Text(owned ? '設置済み' : canAfford ? '設置する' : 'ポイント不足'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
