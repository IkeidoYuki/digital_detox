import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game/game_state.dart';
import 'ui/cat_garden.dart';
import 'ui/panels/feed_panel.dart';
import 'ui/panels/playground_shop_panel.dart';

void main() {
  runApp(const DetoxGardenApp());
}

class DetoxGardenApp extends StatelessWidget {
  const DetoxGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameState>(
      create: (_) {
        final game = GameState();
        game.registerLifecycleObserver();
        return game;
      },
      dispose: (_, game) => game.unregisterLifecycleObserver(),
      child: MaterialApp(
        title: 'ねこデジタルデトックス',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
          useMaterial3: true,
        ),
        home: const _HomeShell(),
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  bool _simulatedSleep = false;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('猫のお庭でデジタルデトックス'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'お庭'),
              Tab(text: 'ご飯'),
              Tab(text: '遊び場'),
            ],
          ),
        ),
        body: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'スリープでポイントを貯めよう',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'アプリを閉じたりスリープ状態にすると、最大8時間までポイントが貯まります。',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _simulatedSleep,
                      onChanged: (value) {
                        setState(() => _simulatedSleep = value);
                        context.read<GameState>().manualSleepToggle(value);
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(_simulatedSleep ? '睡眠中' : '起きている'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: const [
                  CatGarden(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: FeedPanel(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: PlaygroundShopPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.read<GameState>().grantDebugPoints(60),
          icon: const Icon(Icons.bolt),
          label: const Text('お試し +60pt'),
        ),
      ),
    );
  }
}
