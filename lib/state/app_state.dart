import 'package:flutter/widgets.dart';

import '../models/journey_entry.dart';
import '../models/prompt.dart';
import '../services/journal_db.dart';
import '../services/prompt_repository.dart';
import '../services/saved_service.dart';

/// App-wide state: dataset, bookmarks, journal entries and the current tab.
class AppState extends ChangeNotifier {
  final PromptRepository repo = PromptRepository();
  final SavedService _savedService = SavedService();
  final JournalDb _journal = JournalDb();

  List<String> savedIds = <String>[];
  List<JourneyEntry> entries = <JourneyEntry>[];

  /// Set when the SQLite journal could not be opened. The rest of the app
  /// keeps working; only responses are unavailable.
  String? journalError;

  late WhatIfPrompt daily;
  late WhatIfPrompt featured;

  int tabIndex = 0;

  /// Throws if the prompt dataset cannot be loaded (the app shows an error
  /// screen with a retry button).
  Future<void> init() async {
    await repo.load();

    daily = repo.dailyFor(DateTime.now());
    featured = repo.randomPrompt(excludeId: daily.id) ?? daily;

    try {
      savedIds = await _savedService.load();
    } catch (_) {
      savedIds = <String>[];
    }

    try {
      await _journal.open();
      entries = await _journal.all();
      journalError = null;
    } catch (e) {
      entries = <JourneyEntry>[];
      journalError = 'Your journal could not be opened, so responses cannot '
          'be saved right now. ($e)';
    }
  }

  void goToTab(int index) {
    if (tabIndex == index) return;
    tabIndex = index;
    notifyListeners();
  }

  void refreshFeatured() {
    featured = repo.randomPrompt(excludeId: featured.id) ?? featured;
    notifyListeners();
  }

  // --- Bookmarks -----------------------------------------------------------

  bool isSaved(String promptId) => savedIds.contains(promptId);

  Future<void> toggleSaved(String promptId) async {
    if (savedIds.contains(promptId)) {
      savedIds = savedIds.where((id) => id != promptId).toList();
    } else {
      savedIds = <String>[promptId, ...savedIds];
    }
    notifyListeners();
    try {
      await _savedService.save(savedIds);
    } catch (_) {
      // The in-memory state is still correct for this session.
    }
  }

  // --- Journal -------------------------------------------------------------

  bool hasResponseFor(String promptId) {
    return entries.any((e) => e.promptId == promptId);
  }

  JourneyEntry? entryFor(String promptId) {
    for (final e in entries) {
      if (e.promptId == promptId) return e;
    }
    return null;
  }

  /// Returns null on success, or a message describing what went wrong.
  Future<String?> saveEntry({
    required WhatIfPrompt prompt,
    required String response,
    JourneyEntry? existing,
  }) async {
    if (journalError != null) return journalError;
    final now = DateTime.now();
    try {
      final entry = JourneyEntry(
        id: existing?.id,
        promptId: prompt.id,
        promptText: prompt.text,
        categoryId: prompt.categoryId,
        response: response.trim(),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
      await _journal.save(entry);
      entries = await _journal.all();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Could not save your response. ($e)';
    }
  }

  Future<String?> deleteEntry(JourneyEntry entry) async {
    final id = entry.id;
    if (id == null) return null;
    try {
      await _journal.delete(id);
      entries = await _journal.all();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Could not delete this response. ($e)';
    }
  }
}

/// Makes [AppState] available to every widget below it (including pushed
/// routes, because it is installed above the Navigator).
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}
