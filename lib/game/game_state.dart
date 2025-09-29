import 'dart:math';

import 'package:flutter/material.dart';

import '../models/cat.dart';
import '../models/playground_item.dart';

class GameState extends ChangeNotifier with WidgetsBindingObserver {
  GameState() {
    _initializeGarden();
  }

  static const int pointsPerMinute = 12;
  static const Duration maxSleepDuration = Duration(hours: 8);
  static const int foodCost = 40;

  int _points = 0;
  int _totalFoodGiven = 0;
  DateTime? _sleepStartedAt;
  double _sleepCarrySeconds = 0;
  final Map<String, CatInstance> _cats = {};
  final Set<String> _placedPlaygrounds = <String>{};

  int get points => _points;
  int get totalFoodGiven => _totalFoodGiven;
  List<CatInstance> get cats => _cats.values.toList()
    ..sort((a, b) => a.definition.requiredFood.compareTo(b.definition.requiredFood));
  Set<String> get placedPlaygrounds => _placedPlaygrounds;
  DateTime? get sleepStartedAt => _sleepStartedAt;

  bool get canFeedCats => _points >= foodCost;

  List<CatDefinition> get _catCatalog => const [
        CatDefinition(
          id: 'mikan',
          name: 'みかん',
          sheet: CatSheet.sheet1,
          column: 0,
          row: 0,
          personality: 'のんびり屋さん。陽だまりが大好き。',
          requiredFood: 0,
        ),
        CatDefinition(
          id: 'kuro',
          name: 'くろ',
          sheet: CatSheet.sheet1,
          column: 2,
          row: 1,
          personality: '夜の見回りが得意な頼れる猫。',
          requiredFood: 3,
        ),
        CatDefinition(
          id: 'shiro',
          name: 'しろ',
          sheet: CatSheet.sheet1,
          column: 3,
          row: 3,
          personality: 'すこし恥ずかしがりやだけど、おもちゃには目がない。',
          requiredFood: 5,
        ),
        CatDefinition(
          id: 'torami',
          name: 'とらみ',
          sheet: CatSheet.sheet2,
          column: 0,
          row: 0,
          personality: 'おやつを見つける名人。',
          requiredFood: 8,
        ),
        CatDefinition(
          id: 'saba',
          name: 'さば',
          sheet: CatSheet.sheet2,
          column: 3,
          row: 3,
          personality: '木登りが得意で高いところがお気に入り。',
          requiredFood: 12,
        ),
        CatDefinition(
          id: 'kinako',
          name: 'きなこ',
          sheet: CatSheet.sheet2,
          column: 1,
          row: 2,
          personality: '誰とでも仲良し。おしゃれが好き。',
          requiredFood: 15,
        ),
      ];

  Map<String, List<CatOutfit>> get _outfitCatalog => <String, List<CatOutfit>>{
        'mikan': const [
          CatOutfit(
            id: 'sunhat',
            name: 'ひまわりハット',
            unlockedAtFood: 4,
            description: '麦わら帽子で日向ぼっこ。',
            accentColor: Color(0xFFFFC857),
          ),
        ],
        'kuro': const [
          CatOutfit(
            id: 'night_cape',
            name: 'ナイトケープ',
            unlockedAtFood: 7,
            description: '夜の見回り用のマント。',
            accentColor: Color(0xFF353535),
          ),
        ],
        'shiro': const [
          CatOutfit(
            id: 'lace',
            name: 'レースカラー',
            unlockedAtFood: 9,
            description: '真っ白な毛並みにぴったり。',
            accentColor: Color(0xFFECECEC),
          ),
        ],
        'torami': const [
          CatOutfit(
            id: 'explorer',
            name: '冒険コート',
            unlockedAtFood: 13,
            description: 'おやつ探検の必需品。',
            accentColor: Color(0xFFA97142),
          ),
        ],
        'saba': const [
          CatOutfit(
            id: 'sky_band',
            name: 'そらいろスカーフ',
            unlockedAtFood: 16,
            description: '高い場所でも風を切って。',
            accentColor: Color(0xFF8BC5E5),
          ),
        ],
        'kinako': const [
          CatOutfit(
            id: 'ribbon',
            name: 'カラフルリボン',
            unlockedAtFood: 18,
            description: 'おしゃれ番長の必須アイテム。',
            accentColor: Color(0xFFF48FB1),
          ),
        ],
      };

  List<PlaygroundItem> get playgroundCatalog => const [
        PlaygroundItem(
          id: 'sunny_mat',
          name: 'ひなたマット',
          description: 'ぽかぽかの日差しが集まるマット。',
          cost: 60,
        ),
        PlaygroundItem(
          id: 'cat_walk',
          name: 'キャットウォーク',
          description: '高いところから庭を見渡せる！',
          cost: 110,
        ),
        PlaygroundItem(
          id: 'slide',
          name: 'すべり台',
          description: 'みんなで順番待ちができる人気スポット。',
          cost: 150,
        ),
      ];

  void _initializeGarden() {
    final starterCat = _catCatalog.first;
    _cats[starterCat.id] = CatInstance(definition: starterCat);
  }

  void registerLifecycleObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  void unregisterLifecycleObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final now = DateTime.now();
    if (state == AppLifecycleState.paused) {
      _sleepStartedAt = now;
    } else if (state == AppLifecycleState.resumed) {
      _settleSleepPoints(now);
    }
    super.didChangeAppLifecycleState(state);
  }

  void manualSleepToggle(bool sleeping) {
    final now = DateTime.now();
    if (sleeping) {
      _sleepStartedAt = now;
    } else {
      _settleSleepPoints(now);
    }
  }

  void _settleSleepPoints(DateTime resumedAt) {
    if (_sleepStartedAt == null) {
      return;
    }
    final elapsed = resumedAt.difference(_sleepStartedAt!);
    _sleepStartedAt = null;
    if (elapsed.isNegative) {
      return;
    }
    final cappedSeconds = min(elapsed.inSeconds.toDouble(), maxSleepDuration.inSeconds.toDouble());
    final totalSeconds = cappedSeconds + _sleepCarrySeconds;
    final earnedMinutes = totalSeconds ~/ 60;
    _sleepCarrySeconds = totalSeconds - earnedMinutes * 60;
    final earnedPoints = earnedMinutes * pointsPerMinute;
    if (earnedPoints > 0) {
      _points += earnedPoints;
      notifyListeners();
    }
  }

  bool feedCats() {
    if (!canFeedCats) {
      return false;
    }
    _points -= foodCost;
    _totalFoodGiven += 1;
    _unlockNewCats();
    notifyListeners();
    return true;
  }

  void _unlockNewCats() {
    for (final cat in _catCatalog) {
      if (_totalFoodGiven >= cat.requiredFood && !_cats.containsKey(cat.id)) {
        _cats[cat.id] = CatInstance(definition: cat);
      }
    }
  }

  List<CatOutfit> outfitsForCat(String catId) {
    final options = _outfitCatalog[catId];
    if (options == null) {
      return const [];
    }
    return options
        .where((outfit) => _totalFoodGiven >= outfit.unlockedAtFood)
        .toList()
      ..sort((a, b) => a.unlockedAtFood.compareTo(b.unlockedAtFood));
  }

  void equipOutfit(String catId, CatOutfit? outfit) {
    final instance = _cats[catId];
    if (instance == null) {
      return;
    }
    instance.activeOutfit = outfit;
    notifyListeners();
  }

  bool purchasePlayground(String itemId) {
    final catalogItem = playgroundCatalog.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw ArgumentError('Unknown playground: $itemId'),
    );
    if (_placedPlaygrounds.contains(itemId)) {
      return false;
    }
    if (_points < catalogItem.cost) {
      return false;
    }
    _points -= catalogItem.cost;
    _placedPlaygrounds.add(itemId);
    notifyListeners();
    return true;
  }

  void grantDebugPoints(int amount) {
    _points += amount;
    notifyListeners();
  }
}
