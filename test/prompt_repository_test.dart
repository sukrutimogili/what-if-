import 'package:flutter_test/flutter_test.dart';
import 'package:what_if/services/prompt_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PromptRepository with the real what_if_prompts.json', () {
    late PromptRepository repo;

    setUpAll(() async {
      repo = PromptRepository();
      await repo.load();
    });

    test('loads 1000 prompts in 5 categories', () {
      expect(repo.prompts.length, 1000);
      expect(repo.categories.length, 5);
    });

    test('every prompt belongs to a known category', () {
      for (final p in repo.prompts) {
        expect(repo.categoryById(p.categoryId), isNotNull, reason: p.id);
      }
    });

    test('each category has 200 prompts', () {
      for (final c in repo.categories) {
        expect(repo.countFor(c.id), 200, reason: c.id);
      }
    });

    test('daily prompt is stable for the same date', () {
      final day = DateTime(2026, 11, 1);
      expect(repo.dailyFor(day).id, repo.dailyFor(day).id);
    });

    test('random prompt respects category and exclusion', () {
      final first = repo.randomPrompt(categoryId: 'storytelling')!;
      expect(first.categoryId, 'storytelling');
      final second = repo.randomPrompt(
        categoryId: 'storytelling',
        excludeId: first.id,
      )!;
      expect(second.id, isNot(first.id));
    });

    test('search finds matches and handles no results', () {
      expect(repo.search('dragon'), isNotEmpty);
      expect(repo.search('zzzzqqqq'), isEmpty);
    });
  });
}
