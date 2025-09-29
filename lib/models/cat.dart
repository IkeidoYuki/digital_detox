import 'package:flutter/material.dart';

enum CatSheet { sheet1, sheet2 }

class CatDefinition {
  const CatDefinition({
    required this.id,
    required this.name,
    required this.sheet,
    required this.column,
    required this.row,
    required this.personality,
    required this.requiredFood,
  });

  final String id;
  final String name;
  final CatSheet sheet;
  final int column;
  final int row;
  final String personality;
  final int requiredFood;

  String get assetPath => switch (sheet) {
        CatSheet.sheet1 => 'assets/images/cat_sheet_1.png',
        CatSheet.sheet2 => 'assets/images/cat_sheet_2.png',
      };
}

class CatOutfit {
  const CatOutfit({
    required this.id,
    required this.name,
    required this.unlockedAtFood,
    required this.description,
    this.accentColor,
  });

  final String id;
  final String name;
  final int unlockedAtFood;
  final String description;
  final Color? accentColor;
}

class CatInstance {
  CatInstance({
    required this.definition,
    this.activeOutfit,
  });

  final CatDefinition definition;
  CatOutfit? activeOutfit;
}
