import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:what_if/models/prompt.dart';
import 'package:what_if/utils/prompt_batcher.dart';

List<WhatIfPrompt> _prompts(int n) => [
      for (var i = 0; i < n; i++)
        WhatIfPrompt(
          id: 'P$i',
          categoryId: 'storytelling',
          text: 'What if $i?',
        ),
    ];

void main() {
  group('PromptBatcher', () {
    test('shows only the first 10 prompts initially', () {
      final b = PromptBatcher(_prompts(200));
      expect(b.current.length, 10);
      expect(b.rangeStart, 1);
      expect(b.rangeEnd, 10);
      expect(b.hasMore, isTrue);
    });

    test('never repeats a prompt and never shows the whole list at once', () {
      final b = PromptBatcher(_prompts(95), shuffle: true, random: Random(7));
      final seen = <String>{};
      var batches = 0;
      while (true) {
        final ids = b.current.map((p) => p.id).toList();
        expect(ids.length, lessThanOrEqualTo(10));
        for (final id in ids) {
          expect(seen.add(id), isTrue, reason: '$id repeated');
        }
        batches++;
        if (!b.hasMore) break;
        b.next();
      }
      expect(batches, 10);
      expect(seen.length, 95);
    });

    test('last batch holds only the remaining prompts', () {
      final b = PromptBatcher(_prompts(23));
      b.next();
      expect(b.nextBatchSize, 3);
      b.next();
      expect(b.current.length, 3);
      expect(b.hasMore, isFalse);
      expect(b.isFinished, isTrue);
      b.next(); // no-op
      expect(b.current.length, 3);
    });

    test('restart begins a new session from the first batch', () {
      final b = PromptBatcher(_prompts(30), shuffle: true, random: Random(1));
      while (b.hasMore) {
        b.next();
      }
      expect(b.isFinished, isTrue);
      b.restart();
      expect(b.rangeStart, 1);
      expect(b.current.length, 10);
      expect(b.isFinished, isFalse);
    });

    test('short lists need no pagination controls', () {
      final b = PromptBatcher(_prompts(7));
      expect(b.current.length, 7);
      expect(b.hasMore, isFalse);
      expect(b.isFinished, isFalse);
      expect(PromptBatcher(const <WhatIfPrompt>[]).current, isEmpty);
    });

    test('does not modify the list it was given', () {
      final source = _prompts(40);
      final ids = source.map((p) => p.id).toList();
      PromptBatcher(source, shuffle: true, random: Random(3));
      expect(source.map((p) => p.id).toList(), ids);
    });
  });
}
