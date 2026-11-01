import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/prompt.dart';

/// Loads and queries the bundled prompt dataset.
class PromptRepository {
  static const String assetPath = 'assets/data/what_if_prompts.json';

  List<PromptCategory> categories = const [];
  List<WhatIfPrompt> prompts = const [];

  final Map<String, WhatIfPrompt> _byId = {};
  final Map<String, List<WhatIfPrompt>> _byCategory = {};
  final Random _rng = Random();

  Future<void> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final data = jsonDecode(raw);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Prompt file must contain a JSON object.');
    }

    final rawCategories = data['categories'];
    final rawPrompts = data['prompts'];
    if (rawCategories is! List || rawPrompts is! List) {
      throw const FormatException(
          'Prompt file must contain "categories" and "prompts" lists.');
    }

    categories = rawCategories
        .map((e) => PromptCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    prompts = rawPrompts
        .map((e) => WhatIfPrompt.fromJson(e as Map<String, dynamic>))
        .toList();

    if (prompts.isEmpty) {
      throw const FormatException('The prompt file contains no prompts.');
    }

    _byId
      ..clear()
      ..addEntries(prompts.map((p) => MapEntry(p.id, p)));
    _byCategory.clear();
    for (final p in prompts) {
      _byCategory.putIfAbsent(p.categoryId, () => <WhatIfPrompt>[]).add(p);
    }
  }

  PromptCategory? categoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  WhatIfPrompt? promptById(String id) => _byId[id];

  List<WhatIfPrompt> byCategory(String categoryId) {
    return _byCategory[categoryId] ?? const <WhatIfPrompt>[];
  }

  int countFor(String categoryId) => byCategory(categoryId).length;

  /// The same prompt for everyone on the same calendar day.
  WhatIfPrompt dailyFor(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return prompts[Random(seed).nextInt(prompts.length)];
  }

  WhatIfPrompt? randomPrompt({String? categoryId, String? excludeId}) {
    final pool = categoryId == null ? prompts : byCategory(categoryId);
    if (pool.isEmpty) return null;
    if (pool.length == 1) return pool.first;
    WhatIfPrompt pick;
    do {
      pick = pool[_rng.nextInt(pool.length)];
    } while (pick.id == excludeId);
    return pick;
  }

  List<WhatIfPrompt> search(String query, {int limit = 60}) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];
    final results = <WhatIfPrompt>[];
    for (final p in prompts) {
      final text = p.text.toLowerCase();
      if (words.every((w) => text.contains(w))) {
        results.add(p);
        if (results.length >= limit) break;
      }
    }
    return results;
  }
}
