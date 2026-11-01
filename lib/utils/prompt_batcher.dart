import 'dart:math';

import '../models/prompt.dart';

/// Deals a list of prompts out in fixed-size batches, one batch on screen at
/// a time, without ever repeating a prompt during a browsing session.
///
/// It only reorders its own copy of the list, so it never touches saved
/// prompts, journal entries or the repository (Surprise Me keeps picking from
/// the full dataset).
class PromptBatcher {
  PromptBatcher(
    Iterable<WhatIfPrompt> source, {
    this.batchSize = 10,
    this.shuffle = false,
    Random? random,
  })  : assert(batchSize > 0),
        _random = random ?? Random(),
        _order = List<WhatIfPrompt>.of(source) {
    if (shuffle) _order.shuffle(_random);
  }

  final int batchSize;

  /// Whether a new session (first one included) uses a random order.
  final bool shuffle;

  final Random _random;
  final List<WhatIfPrompt> _order;
  int _start = 0;

  int get total => _order.length;

  /// The batch currently on screen (at most [batchSize] prompts).
  List<WhatIfPrompt> get current =>
      _order.sublist(min(_start, total), min(_start + batchSize, total));

  /// 1-based position of the first prompt on screen (0 when empty).
  int get rangeStart => total == 0 ? 0 : _start + 1;

  /// 1-based position of the last prompt on screen.
  int get rangeEnd => min(_start + batchSize, total);

  /// Prompts not shown yet in this session.
  int get remaining => total - rangeEnd;

  bool get hasMore => remaining > 0;

  /// Size of the next batch; smaller than [batchSize] for the last one.
  int get nextBatchSize => min(batchSize, remaining);

  /// True when the whole list spans more than one batch and the last one is
  /// on screen, so the session can be restarted.
  bool get isFinished => total > batchSize && !hasMore;

  /// Moves to the next unseen batch. Does nothing when none is left.
  void next() {
    if (hasMore) _start += batchSize;
  }

  /// Starts a new session from the first batch, reshuffled if [shuffle].
  void restart() {
    _start = 0;
    if (shuffle) _order.shuffle(_random);
  }
}
